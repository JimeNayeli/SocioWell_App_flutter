import 'package:flutter/material.dart';

class InstructionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 330, // Ajusta el ancho deseado
        height: MediaQuery.of(context).size.height * 0.8,
        child: Card(
          elevation: 4,
          color: Colors.blue[50], // Fondo azul claro
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.blueAccent, width: 2), // Borde azul intenso
          ),
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info, color: Colors.blueAccent, size: 40),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        "Instrucciones de Uso",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 24), // Viñeta
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "La sección \"Cuestionario de uso\" es obligatoria la primera vez que utilices la aplicación. Posteriormente, puedes modificar tus respuestas o mantener las opciones seleccionadas anteriormente.",
                        
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 24), // Viñeta
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "La sección \"Información de uso\" muestra un resumen de tu actividad en redes sociales durante los últimos 7 días, incluyendo Facebook, Instagram y TikTok.",
                        
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 24), // Viñeta
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Recibirás notificaciones de alerta si superas 1, 2 o 3 horas de uso continuo. Cada alerta durará 1 minuto y se recomienda hacer una pausa de al menos 10 minutos antes de continuar usando cualquier aplicación.",
        
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
