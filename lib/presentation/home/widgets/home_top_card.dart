import 'package:tesis_v2/domain/usescases/answer/get_answer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tesis_v2/common/helpers/is_dark_mode.dart';
import 'package:tesis_v2/common/widgets/button/button_app_small.dart';
import 'package:tesis_v2/core/configs/theme/app_colors.dart';
import 'package:tesis_v2/data/models/answer/create_answer.dart';
import 'package:tesis_v2/domain/usescases/answer/create_answer.dart';
import 'package:tesis_v2/service_locator.dart';


class HomeTopCard extends StatefulWidget {
  @override
  _HomeTopCardState createState() => _HomeTopCardState();
}

class _HomeTopCardState extends State<HomeTopCard> {
  double question1Value = 5;
  double question2Value = 5;
  double question3Value = 5;
  bool isLoading = true;
  @override
void initState() {
  super.initState();
  _loadSliderValues();
}

Future<void> _loadSliderValues() async {
  final answers = await fetchAnswer();
  if(mounted){
    setState(() {
    question1Value = answers['satisfaction']!;
    question2Value = answers['productivityLost']!;
    question3Value = answers['selfControl']!;
    isLoading = false; // Datos cargados, ocultar indicador
  });
  }
  
}

  final PageController _pageController = PageController();

  // Índice actual para el indicador
  int _currentIndex = 0;

  Future<Map<String, double>> fetchAnswer() async {
  try {
    final getAnswerUseCase = sl<GetAnswerUseCase>();
    final result = await getAnswerUseCase();

    return result.fold(
      (error) {
        // Si ocurre un error, retorna valores predeterminados
        return {
          'selfControl': 5.0,
          'productivityLost': 5.0,
          'satisfaction': 5.0,
        };
      },
      (data) {
        return {
          'selfControl': (data['selfControl'] ?? 5).toDouble(),
          'productivityLost': (data['productivityLost'] ?? 5).toDouble(),
          'satisfaction': (data['satisfaction'] ?? 5).toDouble(),
        };
      },
    );
  } catch (e) {
    // Si ocurre una excepción, también retorna valores predeterminados
    return {
      'selfControl': 5.0,
      'productivityLost': 5.0,
      'satisfaction': 5.0,
    };
  }
}

@override
Widget build(BuildContext context) {
  return isLoading
      ? const Center(
          child: CircularProgressIndicator(),
        )
      : Center(
          child: Container(
            width: 330,
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              color: context.isDarkMode ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary,
                width: 2.0,
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          "Preguntas necesarias!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: context.isDarkMode ? Colors.white : Colors.black,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "Responde las 3 preguntas para ver tu resultado. Califica cada afirmación del 1 al 10, donde 1 significa que no estás de acuerdo en absoluto y 10 significa que estás completamente de acuerdo.",
                        style: TextStyle(
                          color: context.isDarkMode ? Colors.white : Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    children: [
                      _buildQuestionSlide(
                        "Regularmente me siento insatisfecho/a porque quiero pasar más tiempo en las redes sociales",
                        question1Value,
                        (value) => setState(() => question1Value = value),
                      ),
                      _buildQuestionSlide(
                        "Descuido otras actividades (por ejemplo, pasatiempos, deportes) por utilizar las redes sociales",
                        question2Value,
                        (value) => setState(() => question2Value = value),
                      ),
                      _buildQuestionSlide(
                        "He intentado pasar menos tiempo en redes sociales sin haberlo conseguido",
                        question3Value,
                        (value) => setState(() => question3Value = value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                _buildIndicator(),
                const SizedBox(height: 30),
                AppButtonSmall(
                  onPressed: () async {
                    int satisfaction = question1Value.round();
                    int productivityLoss = question2Value.round();
                    int selfControl = question3Value.round();

                    // Guardar respuestas en Firestore
                    final result = await sl<CreateAnswerUseCase>().call(
                      params: CreateAnswer(
                        satisfaction: satisfaction,
                        productivityLoss: productivityLoss,
                        selfControl: selfControl,
                        createDate: Timestamp.now(),
                      ),
                    );

                    result.fold(
                      (failure) {
                        // Mostrar SnackBar en caso de error
                        var snackbar = SnackBar(
                          content: Text(failure),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.red,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackbar);
                      },
                      (success) {
                        // Mostrar SnackBar en caso de éxito
                        var snackbar = SnackBar(
                          content: Text(success),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.green,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackbar);
                      },
                    );
                  },
                  title: 'Guardar respuestas',
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
        );
}

Widget _buildQuestionSlide(
  String question,
  double currentValue,
  ValueChanged<double> onChanged,
) {
  return Padding(
    padding: const EdgeInsets.all(14),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          question,
          style: TextStyle(
            color: context.isDarkMode ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 15),
        Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    10,
                    (index) => Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: context.isDarkMode ? Colors.white : Colors.black,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Caritas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFace(
                  icon: FontAwesomeIcons.sadTear,
                  color: Colors.red,
                  label: 'Desacuerdo',
                ),
                const Spacer(),
                _buildFace(
                  icon: FontAwesomeIcons.meh,
                  color: Colors.amber,
                  label: 'Neutral',
                ),
                const Spacer(),
                _buildFace(
                  icon: FontAwesomeIcons.smileBeam,
                  color: Colors.green,
                  label: 'De acuerdo',
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Slider
            Slider(
              value: currentValue,
              min: 1,
              max: 10,
              divisions: 9,
              label: currentValue.round().toString(),
              activeColor: context.isDarkMode ? Colors.white : Colors.black,
              inactiveColor: Colors.grey.shade300,
              onChanged: onChanged,
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildFace({required IconData icon, required Color color, required String label}) {
  return Column(
    children: [
      FaIcon(
        icon,
        color: color,
        size: 30,
      ),
      const SizedBox(height: 5),
      Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: color),
      ),
    ],
  );
}


  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentIndex == index ? 12 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentIndex == index
                ? (context.isDarkMode ? Colors.white : Colors.black)
                : Colors.grey,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
