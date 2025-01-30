import 'package:flutter/material.dart';
import 'package:tesis_v2/core/configs/theme/app_colors.dart';

class AddictionInfoBox extends StatelessWidget {
  const AddictionInfoBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Niveles de Adicción',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.backCard,
            ),
          ),
          const SizedBox(height: 8),
          Divider(color: Colors.grey.shade300),
          const SizedBox(height: 8),
          const Text(
            'El nivel de adicción (0 a 7) representa la intensidad del uso de redes sociales. A mayor número, mayor compromiso o dependencia:',
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          const Text(
            '''
- Nivel 0: Sin uso o uso muy limitado de redes sociales.
- Nivel 1: Uso muy bajo o poca dependencia.
- Nivel 2: Uso moderado, pero no excesivo.
- Nivel 3: Uso habitual, parte de la rutina diaria.
- Nivel 4: Uso significativo, afectando la gestión del tiempo.
- Nivel 5: Uso alto, impactando otras áreas de la vida.
- Nivel 6: Uso muy alto, posiblemente descuidando responsabilidades.
- Nivel 7: Uso extremo, con un fuerte impacto negativo.
                ''',
            style: TextStyle(fontSize: 15, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}