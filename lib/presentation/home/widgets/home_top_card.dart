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


// ignore: use_key_in_widget_constructors
class HomeTopCard extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _HomeTopCardState createState() => _HomeTopCardState();
}

class _HomeTopCardState extends State<HomeTopCard> {
  double question1Value = 5;
  double question2Value = 5;
  double question3Value = 5;
  bool isLoading = true;
  final PageController _pageController = PageController();
  int _currentIndex = 0;

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
        isLoading = false;
      });
    }
  }

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
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "Preguntas necesarias!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.isDarkMode ? Colors.white : AppColors.backCard,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
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
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  
                  // Card con las preguntas
                  Container(
                    height: MediaQuery.of(context).size.height * 0.4, // Altura ajustable
                    width: 330,
                    decoration: BoxDecoration(
                      color: AppColors.backCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.backCard,
                        width: 2.0,
                      ),
                    ),
                    child: Column(
                      children: [
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
                        _buildIndicator(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Botón fuera del card
                  AppButtonSmall(
                    onPressed: () async {
                      int satisfaction = question1Value.round();
                      int productivityLoss = question2Value.round();
                      int selfControl = question3Value.round();

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
                          var snackbar = SnackBar(
                            content: Text(failure),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.red,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackbar);
                        },
                        (success) {
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
                  const SizedBox(height: 20),
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              question,
              style: TextStyle(
                color:  Colors.white,
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
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
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