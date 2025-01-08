import 'package:flutter/material.dart';
import 'package:tesis_v2/core/configs/assets/app_model.dart';
import 'package:tesis_v2/domain/usescases/answer/get_answer.dart';
import 'package:tesis_v2/presentation/home/widgets/addiction_info.dart';
import 'package:tesis_v2/presentation/home/widgets/advise_info.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../../../service_locator.dart';

class AddictionPage extends StatefulWidget {
  final String appName;
  final String averageDailyUsage;
  final String averageDailyAccesses;
  final String averageDailyFrecuency;

  const AddictionPage({
    Key? key,
    required this.appName,
    required this.averageDailyUsage,
    required this.averageDailyAccesses,
    required this.averageDailyFrecuency,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AddictionPageState createState() => _AddictionPageState();
}

class _AddictionPageState extends State<AddictionPage> {
  late Future<List<dynamic>> _predictionFuture;

  @override
  void initState() {
    super.initState();
    _predictionFuture = predictAddictionLevel();
  }

  // Parámetros del StandardScaler desde Python
  final List<double> scalerMean = [151.555   ,  10.0175  ,  64.059625,   2.60925 ,  39.479475]; 
  final List<double> scalerScale = [83.6647296, 5.35230733, 33.5332278, 0.0465235156, 20.1202847];  

  // Escalado estándar
  double standardScale(double value, double mean, double scale) {
    return (value - mean) / scale;
  }

  // Escalado personalizado
  double customScale(double value, double minVal, double maxVal) {
    return (value - minVal) / (maxVal - minVal);
  }
  double calculateObjectiveComponent(double totalTimeSpent, double numberSessions, double frequency) {
  return totalTimeSpent * 0.4 +
      numberSessions * 0.3 +
      frequency * 0.3;
}

double calculateSubjectiveComponent(double productivityLoss, double satisfaction, double selfControl) {
  return productivityLoss * 0.5 +
      satisfaction * 0.3 -
      selfControl * 0.2;
}

double calculateAddictionScore(double objectiveComponent, double subjectiveComponent) {
  return objectiveComponent * 0.6 +
      subjectiveComponent * 0.4;
}

  // Generar input para el modelo
Future<List<double>> generateInput() async {
  // Obtener datos dinámicos
  final answerData = await fetchAnswer();

  // Valores originales (sin escalar)
  double totalTimeSpent = double.parse(widget.averageDailyUsage);
  double numberSessions = double.parse(widget.averageDailyAccesses);

  final frequencyMapping = {
    'Mañana': 0.5, // Morning
    'Tarde': 1.0,  // Afternoon
    'Noche': 1.5,  // Evening
    'Madrugada': 2.0, // Night
  };
  double frequencyValue = frequencyMapping[widget.averageDailyFrecuency] ?? 1.0;

  double productivityLoss = customScale(answerData['productivityLost'].toDouble(), 1.0, 10.0);
  double satisfaction = customScale(answerData['satisfaction'].toDouble(), 1.0, 10.0);
  double selfControl = customScale(answerData['selfControl'].toDouble(), 1.0, 10.0);

  // Cálculos (sin escalar)
  double objectiveComponent = calculateObjectiveComponent(totalTimeSpent, numberSessions, frequencyValue);
  double subjectiveComponent = calculateSubjectiveComponent(productivityLoss, satisfaction, selfControl);
  double addictionScore = calculateAddictionScore(objectiveComponent, subjectiveComponent);

  // Escalar valores
  double scaledTotalTime = standardScale(totalTimeSpent, scalerMean[0], scalerScale[0]);
  double scaledNumberSessions = standardScale(numberSessions, scalerMean[1], scalerScale[1]);
  double scaledObjectiveComponent = standardScale(objectiveComponent, scalerMean[2], scalerScale[2]);
  double scaledSubjectiveComponent = standardScale(subjectiveComponent, scalerMean[3], scalerScale[3]);
  double scaledAddictionScore = standardScale(addictionScore, scalerMean[4], scalerScale[4]);

  // Retornar valores escalados
  return [
    scaledTotalTime,
    scaledNumberSessions,
    frequencyValue, // Si ya está normalizado, no necesita más escalado
    productivityLoss, // Ya está escalado entre 0 y 1
    satisfaction,     // Ya está escalado entre 0 y 1
    selfControl,      // Ya está escalado entre 0 y 1
    scaledObjectiveComponent,
    scaledSubjectiveComponent,
    scaledAddictionScore,
  ];
}

  // Método para obtener datos dinámicos desde Firestore
  Future<Map<String, dynamic>> fetchAnswer() async {
    try {
      final getAnswerUseCase = sl<GetAnswerUseCase>();
      final result = await getAnswerUseCase();

      return result.fold(
        (error) {
          throw Exception('Error al obtener los datos: $error');
        },
        (data) {
          return {
            'selfControl': data['selfControl'] ?? 7,
            'productivityLost': data['productivityLost'] ?? 3,
            'satisfaction': data['satisfaction'] ?? 5,
          };
        },
      );
    } catch (e) {
      throw Exception('Error al obtener los datos: $e');
    }
  }

  // Predecir nivel de adicción
  Future<List<dynamic>> predictAddictionLevel() async {
    try {
      final interpreter = await Interpreter.fromAsset(AppModel.modelAddiction);

      // Generar entrada
      final input = [await generateInput()];
      //print("Input Data: $input");

      // Crear tensor de salida
      var outputShape = [1, 8];
      var output = List.filled(1 * 8, 0.0).reshape(outputShape);

      // Ejecutar la inferencia
      interpreter.run(input, output);

      // Interpretar salida
      var probabilities = output[0] as List<double>;
      int predictedLevel = probabilities.indexOf(probabilities.reduce((a, b) => a > b ? a : b));

      interpreter.close();
      return [predictedLevel, probabilities];
    } catch (e) {
      //print('Error al cargar el modelo: $e');
      return [-1, []];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diagnóstico de Adicción')),
      body: FutureBuilder<List<dynamic>>(
        future: _predictionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data![0] == -1) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error, // Ícono de error
                  color: Colors.red, // Cambia el color según tus preferencias
                  size: 50, // Tamaño del ícono
                ),
                SizedBox(height: 16), // Espacio entre el ícono y el texto
                Text(
                  'Error al predecir el nivel de adicción.\nPor favor, verifica tus respuestas\n en el cuestionario de uso.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18), // Opcional: ajustar el tamaño de fuente
                ),
              ],
            ),
          );
        }


          int predictedLevel = snapshot.data![0];

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.appName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Nivel de adicción predicho: $predictedLevel',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                AdviceCard(level: predictedLevel),
                const SizedBox(height: 16),
                const AddictionInfoBox(),
              ],
            ),
          );
        },
      ),
    );
  }
}
