import 'package:flutter/material.dart';

class AddictionInfoBox extends StatelessWidget {
  const AddictionInfoBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue.shade400,
                size: 30,
              ),
              const SizedBox(width: 10),
              const Text(
                'Niveles de Adicción',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const SizedBox(
            height: 200, // Altura fija para el cuadro
            child: SingleChildScrollView(
              child: Text(
                '''
El nivel de adicción (0 a 7) representa la intensidad del uso de redes sociales. A mayor número, mayor compromiso o dependencia:

- Nivel 0: Sin uso o uso muy limitado de redes sociales.
- Nivel 1: Uso muy bajo o poca dependencia.
- Nivel 2: Uso moderado, pero no excesivo.
- Nivel 3: Uso habitual, parte de la rutina diaria.
- Nivel 4: Uso significativo, afectando la gestión del tiempo.
- Nivel 5: Uso alto, impactando otras áreas de la vida.
- Nivel 6: Uso muy alto, posiblemente descuidando responsabilidades.
- Nivel 7: Uso extremo, con un fuerte impacto negativo.
                ''',
                style: TextStyle(fontSize: 16,color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
