import 'package:get_it/get_it.dart';
import 'package:tesis_v2/data/repository/answer/answer_repository_implt.dart';
import 'package:tesis_v2/data/repository/auth/auth_repository_implt.dart';
import 'package:tesis_v2/data/sources/answer/answer_firebase_service.dart';
import 'package:tesis_v2/domain/repository/answer/answer.dart';
import 'package:tesis_v2/domain/usescases/answer/create_answer.dart';
import 'package:tesis_v2/domain/usescases/auth/signin_google.dart';
import 'data/sources/auth/auth_firebase_service.dart';
import 'domain/repository/auth/auth.dart';
import 'package:tesis_v2/domain/usescases/auth/get_user.dart';
import 'package:tesis_v2/domain/usescases/answer/get_answer.dart';
import 'package:tesis_v2/domain/usescases/auth/signin.dart';
import 'package:tesis_v2/domain/usescases/auth/signup.dart'; 
final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  sl.registerSingleton<AuthFirebaseService>(
  AuthFirebaseServiceImpl()
 );

 sl.registerSingleton<AuthRepository>(
  AuthRepositoryImpl()
 );

   sl.registerSingleton<AnswerFirebaseService>(
  AnswerFirebaseServiceImpl()
 );

 sl.registerSingleton<AnswerRepository>(
  AnswerRepositoryImpl()
 );


 sl.registerSingleton<SignupUseCase>(
  SignupUseCase()
 );

 sl.registerSingleton<SigninUseCase>(
  SigninUseCase()
 );

 sl.registerSingleton<GetUserUseCase>(
  GetUserUseCase()
 );

  sl.registerSingleton<GetAnswerUseCase>(
  GetAnswerUseCase()
 );

 sl.registerSingleton<CreateAnswerUseCase>(
  CreateAnswerUseCase()
 );
  sl.registerSingleton<SigninGoogleCase>(
    SigninGoogleCase()
  );
 
}