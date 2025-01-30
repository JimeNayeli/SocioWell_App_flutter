import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tesis_v2/data/models/usage/save_usage.dart';

abstract class UsageFirebaseService{
  Future<Either<String, String>> saveUsage(SaveUsage createUsage);
}

class UsageFirebaseServiceImpl extends UsageFirebaseService{
@override
Future<Either<String, String>> saveUsage(SaveUsage saveUsage) async {
  try {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    var user = firebaseAuth.currentUser;

    if (user == null) {
      return const Left('No hay un usuario autenticado.');
    }

    String uId = user.uid;

    // Formatear la fecha para que sea solo "yyyy-MM-dd"
    String formattedDate = saveUsage.fechaRegistro.split('T')[0];

    // Referencia al documento de la aplicación
    var appDocRef = firebaseFirestore
        .collection('Users')
        .doc(uId)
        .collection('Usage')
        .doc(saveUsage.appName);

    // **Guardar los datos sobrescribiéndolos sin acumular**
    await appDocRef.set({
      formattedDate: {
        'tiempoUso': saveUsage.tiempoUso, // Reemplaza con el nuevo valor
        'accesos': saveUsage.accesos, // Reemplaza con el nuevo valor
        'nivelAdiccion': saveUsage.nivelAdiccion,
        'momentoDia': saveUsage.momentoDia,
      }
    }, SetOptions(merge: true)); // Mantiene otros datos pero reemplaza los del día

    return const Right('Datos actualizados!');
  } catch (e) {
    return Left('Ha ocurrido un error al guardar el uso: ${e.toString()}');
  }
}

}