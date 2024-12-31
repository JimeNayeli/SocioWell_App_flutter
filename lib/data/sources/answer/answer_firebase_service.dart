import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tesis_v2/data/models/answer/answer.dart';
import 'package:tesis_v2/data/models/answer/create_answer.dart'; 
abstract class AnswerFirebaseService{
  Future<Either> saveAnswers(CreateAnswer createAnswer);
  Future<Either> getAnswer();
}

class AnswerFirebaseServiceImpl extends AnswerFirebaseService{

@override
  Future<Either> saveAnswers(CreateAnswer createAnswer) async {
    try {
      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

      var user = firebaseAuth.currentUser;

      if (user == null) {
        return const Left('No hay un usuario autenticado.');
      }

      String uId = user.uid;

      // Crear un objeto de respuesta
      AnswerModel answer = AnswerModel(
        selfControl: createAnswer.selfControl,
        satisfaction: createAnswer.satisfaction,
        productivityLoss: createAnswer.productivityLoss,
        createDate: Timestamp.now(),
      );

      // Guardar en Firestore
      await firebaseFirestore
          .collection('Users')
          .doc(uId)
          .collection('Answers')
          .doc('uniqueDocumentId') // ID único fijo para sobrescribir
          .set({
        'selfControl': answer.selfControl,
        'satisfaction': answer.satisfaction,
        'productivityLoss': answer.productivityLoss,
        'createDate': Timestamp.now(),
      }, SetOptions(merge: true)); // Sobrescribe sin borrar otros campos
      return const Right('Respuestas guardadas exitosamente!!');
    } catch (e) {
      print("Error guardando respuestas: $e");
      return const Left('Ha ocurrido un error al guardar las respuestas.');
    }
  }

  @override
@override
Future<Either<String, Map<String, dynamic>>> getAnswer() async {
  try {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    // Actualizar la ruta para que coincida con donde guardas los datos
    var answerDoc = await firebaseFirestore
        .collection('Users')
        .doc(firebaseAuth.currentUser?.uid)
        .collection('Answers')
        .doc('uniqueDocumentId')  // El mismo ID fijo que usas al guardar
        .get();

    // Verificar si el documento existe
    if (!answerDoc.exists) {
      return const Left('No hay respuestas guardadas');
    }

    // Obtener los datos relevantes
    var data = answerDoc.data();
    if (data == null) {
      return const Left('No se encontraron datos');
    }

    // Extraer valores específicos
    final selfControl = data['selfControl'] ?? 0;
    final productivityLost = data['productivityLoss'] ?? 0;
    final satisfaction = data['satisfaction'] ?? 0;

    // Devolver los valores en un mapa
    return Right({
      'selfControl': selfControl,
      'productivityLost': productivityLost,
      'satisfaction': satisfaction,
    });
  } catch (e) {
    return const Left('Se produjo un error al obtener los datos');
  }
}

}