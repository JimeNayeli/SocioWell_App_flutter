import 'package:flutter/material.dart';
import 'package:tesis_v2/common/widgets/appbar/app_bar.dart';
import 'package:tesis_v2/core/configs/assets/app_model.dart';
import 'package:tesis_v2/core/configs/theme/app_colors.dart';
import 'package:tesis_v2/data/models/usage/save_usage.dart';
import 'package:tesis_v2/domain/usescases/answer/get_answer.dart';
import 'package:tesis_v2/domain/usescases/usage/save_usage.dart';
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
      await savePredictedData(
      fechaRegistro: DateTime.now().toIso8601String(), // Fecha actual
      tiempoUso: widget.averageDailyUsage,
      accesos: widget.averageDailyAccesses,
      nivelAdiccion: predictedLevel.toString(),
    );
      return [predictedLevel, probabilities];
    } catch (e) {
      //print('Error al cargar el modelo: $e');
      return [-1, []];
    }
  }
Future<void> savePredictedData({
  required String fechaRegistro,
  required String tiempoUso,
  required String accesos,
  required String nivelAdiccion,
}) async {
  try {
    final usageModel = SaveUsage(
      fechaRegistro: fechaRegistro,
      tiempoUso: widget.averageDailyUsage,
      accesos: widget.averageDailyAccesses,
      nivelAdiccion: nivelAdiccion,
      appName: widget.appName, // Nombre de la aplicación
      momentoDia: widget.averageDailyFrecuency,
    );

    final result = await sl<CreateUsageUseCase>().call(params: usageModel);

    result.fold(
      (failure) {
        var snackbar = SnackBar(
          content: Text('Error al guardar los datos: $failure'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      },
      (success) {
        var snackbar = SnackBar(
          content: Text('Datos guardados exitosamente: $success'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      },
    );
  } catch (e) {
    var snackbar = SnackBar(
      content: Text('Error al guardar los datos: ${e.toString()}'),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }
}



  Color getColorForLevel(int level) {
    if (level <= 2) {
      return Colors.green;
    } else if (level <= 5) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BasicAppbar(
        backgroundColor: Color(0xFF046051),
        title: Text('Diagnóstico de Adicción',style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),),
      ),
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
                  Icon(Icons.error, color: Colors.red, size: 50),
                  SizedBox(height: 16),
                  Text(
                    'Error al predecir el nivel de adicción.\nPor favor, verifica tus respuestas\n en el cuestionario de uso.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            );
          }

          int predictedLevel = snapshot.data![0];
          Color levelColor = getColorForLevel(predictedLevel);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Círculo superior pequeño con color principal
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.backCard,
                    ),
                    child: const Icon(
                      Icons.phone_android,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Nombre de la red social
                  Text(
                    widget.appName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Nivel de adicción
                  Text(
                    'Nivel de adicción:',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Círculo grande con el color según el nivel
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: levelColor,
                    ),
                    child: Center(
                      child: Text(
                        predictedLevel.toString(),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AdviceCard(level: predictedLevel),
                  const SizedBox(height: 14),
                  const AddictionInfoBox(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
