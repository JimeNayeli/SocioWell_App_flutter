import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tesis_v2/core/configs/constants/app_urls.dart';
import 'package:tesis_v2/data/models/auth/create_user_req.dart';
import 'package:tesis_v2/data/models/auth/signin_user_req.dart';
import 'package:tesis_v2/data/models/auth/user.dart';
import 'package:tesis_v2/domain/entities/auth/user.dart';
import 'package:google_sign_in/google_sign_in.dart';
abstract class AuthFirebaseService {

  Future<Either> signup(CreateUserReq createUserReq);

  Future<Either> signin(SigninUserReq signinUserReq);

  Future<Either> getUser();

  Future<Either> signinWithGoogle();

  Future<Either> logout(); 
}

class AuthFirebaseServiceImpl extends AuthFirebaseService {


@override
Future<Either> signin(SigninUserReq signinUserReq) async {
  try {
    // Autenticación con FirebaseAuth
    var credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: signinUserReq.email,
      password: signinUserReq.password,
    );
    // Validar si el correo está verificado
    if (!credential.user!.emailVerified) {
      return const Left('Correo no verificado. Verifica tu bandeja de entrada y haz clic en el enlace de verificación que te hemos enviado. Si no lo encuentras, verifica también la carpeta de spam.');
    }
    // Obtener UID del usuario autenticado
    String? uid = credential.user?.uid;
    if (uid == null) {
      return const Left('No se pudo obtener el ID del usuario.');
    }

    // Consultar Firestore para obtener los datos del usuario
    var userDoc = await FirebaseFirestore.instance.collection('Users').doc(uid).get();

    if (userDoc.exists && userDoc.data() != null) {
      // Mapear los datos a UserModel
      UserModel userModel = UserModel.fromJson(userDoc.data()!);
      userModel.imageURL = credential.user?.photoURL ?? AppURLs.defaultImage;

      return Right(userModel);
    } else {
      return const Left('No se encontraron datos del usuario.');
    }
  } on FirebaseAuthException catch (e) {
    String message = '';

    if (e.code == 'invalid-email') {
      message = 'No se encontró usuario para ese correo electrónico.';
    } else if (e.code == 'invalid-credential') {
      message = 'Correo o Contraseña incorrecta.';
    } else {
      message = 'Error de autenticación: ${e.message}';
    }

    return Left(message);
  } catch (e) {
    return Left('Ocurrió un error: ${e.toString()}');
  }
}


  @override
  Future<Either> signup(CreateUserReq createUserReq) async {
    try {

     var data =  await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: createUserReq.email,
        password:createUserReq.password
      );
      await data.user?.sendEmailVerification();
      FirebaseFirestore.instance.collection('Users').doc(data.user?.uid)
      .set(
        {
          'name' : createUserReq.fullName,
          'email' : data.user?.email,
        }
      );

      return const Right('Registro exitoso!!. Por favor, verifica tu correo.');

    } on FirebaseAuthException catch(e) {
      String message = '';
      
      if(e.code == 'weak-password') {
        message = 'La contraseña es muy corta';
      } else if (e.code == 'email-already-in-use') {
        message = 'El correo electrónico ya esta registrado con una cuenta.';
      }


      return Left(message);
    }
  }
  
  @override
  Future < Either > getUser() async {
    try {
      FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

      var user = await firebaseFirestore.collection('Users').doc(
        firebaseAuth.currentUser?.uid
      ).get();

      UserModel userModel = UserModel.fromJson(user.data() !);
      userModel.imageURL = firebaseAuth.currentUser?.photoURL ?? AppURLs.defaultImage;
      UserEntity userEntity = userModel.toEntity();
      return Right(userEntity);
    } catch (e) {
      return const Left('Se produjo un error');
    }
  }
  @override
  Future<Either> signinWithGoogle() async {
    try {
      // Inicia el proceso de Google Sign-In
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        return const Left('El inicio de sesión con Google fue cancelado.');
      }

      // Obtén la autenticación de Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Credenciales para Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Autenticar con Firebase
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      // Verificar si el usuario existe en Firestore
      final uid = userCredential.user?.uid;
      if (uid == null) {
        return const Left('No se pudo obtener el UID del usuario.');
      }

      final userDoc = await FirebaseFirestore.instance.collection('Users').doc(uid).get();

      if (!userDoc.exists) {
        // Crear usuario en Firestore si no existe
        await FirebaseFirestore.instance.collection('Users').doc(uid).set({
          'name': userCredential.user?.displayName,
          'email': userCredential.user?.email,
          'photoURL': userCredential.user?.photoURL ?? AppURLs.defaultImage,
        });
      }

      // Mapear los datos del usuario
      UserModel userModel = UserModel(
        fullName: userCredential.user?.displayName ?? 'Usuario',
        email: userCredential.user?.email ?? '',
        imageURL: userCredential.user?.photoURL ?? AppURLs.defaultImage,
      );

      return Right(userModel);
    } catch (e) {
      return Left('Error en Google Sign-In: ${e.toString()}');
    }
  }

  @override
  Future<Either> logout() async {
    try {
      // Cerrar sesión de Firebase Authentication
      await FirebaseAuth.instance.signOut();

      // Si estás usando GoogleSignIn, también cierra sesión de Google
      final GoogleSignIn googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }

      return const Right('Sesión cerrada exitosamente.');
    } catch (e) {
      return Left('Error al cerrar sesión: ${e.toString()}');
    }
  }
  
}