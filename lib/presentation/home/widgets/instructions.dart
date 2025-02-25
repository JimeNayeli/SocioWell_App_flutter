import 'package:flutter/material.dart';
import 'package:tesis_v2/core/configs/theme/app_colors.dart';


class InstructionCard extends StatefulWidget {
  @override
  _InstructionScrollCardsState createState() => _InstructionScrollCardsState();
}

class _InstructionScrollCardsState extends State<InstructionCard> {
  final List<Map<String, String>> instructions = [
    {
      "title": "Acerca del cuestionario",
      "content": "La sección 'Cuestionario de uso' es obligatoria la primera vez que utilices la aplicación. Posteriormente, puedes modificar tus respuestas o mantener las opciones seleccionadas anteriormente. No olvides colocar 'Guardar Respuestas'"
    },
    {
      "title": "Resumen de Actividad",
      "content": "La sección 'Información de uso' muestra un resumen de tu actividad en redes sociales durante los últimos 4 días de Facebook, Instagram y TikTok."
    },
    {
      "title": "Alertas de Uso",
      "content": "Recibirás notificaciones de alerta si superas 1, 2 o 3 horas de uso continuo. Cada alerta durará 1 minuto y se recomienda hacer una pausa de al menos 10 minutos antes de continuar usando cualquier aplicación."
    },
  ];

  final List<IconData> icons = [
    Icons.info,
    Icons.description,
    Icons.access_time,
  ];

  int currentPage = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
    _pageController.addListener(() {
      setState(() {
        currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 40),
          SizedBox(
            height: 350,
            child: PageView.builder(
              controller: _pageController,
              itemCount: instructions.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Card(
                    elevation: 4,
                    color: AppColors.backCard,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            icons[index],
                            color: Colors.white,
                            size: 60,
                          ),
                          SizedBox(height: 16),
                          Text(
                            instructions[index]["title"]!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 16),
                          Expanded(
                            child: Text(
                              instructions[index]["content"]!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              instructions.length,
              (index) => Container(
                margin: EdgeInsets.symmetric(horizontal: 4),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: currentPage == index ? AppColors.backCard : Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
