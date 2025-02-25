import 'package:flutter/material.dart';
import 'package:tesis_v2/core/configs/theme/app_colors.dart';

class AdviceCard extends StatelessWidget {
  final int level;

  const AdviceCard({Key? key, required this.level}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String advice = AddictionAdvice.getAdvice(level);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.amber.shade100,
            child: const Icon(
              Icons.lightbulb,
              color: Colors.amber,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Consejo para Nivel $level',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.backCard,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  advice,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AddictionAdvice {
  static String getAdvice(int level) {
    switch (level) {
      case 0:
        return "Continúa priorizando actividades offline que fomenten tu bienestar y relaciones interpersonales.";
      case 1:
        return "Posees buenos hábitos digitales actuales, un leve aumento puede volverse rutina, afectando gradualmente tu tiempo y prioridades.";
      case 2:
        return "Mantener el control actual.  Si aumentas el tiempo de uso, podrías comenzar a descuidar pequeñas responsabilidades o experimentar distracciones frecuentes.";
      case 3:
        return "Introduce pausas digitales en tu rutina. Limita las notificaciones para reducir interrupciones.";
      case 4:
        return "Define límites estrictos de desconexión cada día, especialmente antes de dormir, para mejorar tu descanso. La luz azul de las pantallas puede interferir con la producción de melatonina, afectando tu descanso.";
      case 5:
        return "Establece un límite diario de uso. Reconoce situaciones que te llevan a usar las redes en exceso y encuentra actividades alternativas.";
      case 6:
        return "Define tiempos máximos de uso diario, usar más de 3 horas diarias en redes aumentan el riesgo de ansiedad y aumentar el estrés.";
      case 7:
        return "Consulta con un profesional para abordar patrones de comportamiento y mejorar tu calidad de vida. La adicción a redes puede generar aislamiento social y afectar relaciones personales y laborales.";
      default:
        return "Nivel no reconocido. Por favor, selecciona un nivel entre 0 y 7.";
    }
  }
}
