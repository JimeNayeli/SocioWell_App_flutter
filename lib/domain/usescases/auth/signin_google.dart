import 'package:dartz/dartz.dart';
import 'package:tesis_v2/core/usecase/usecase.dart';
import 'package:tesis_v2/domain/repository/auth/auth.dart';

import '../../../service_locator.dart';


class SigninGoogleCase implements UseCase<Either,dynamic> {
  @override
  Future<Either> call({params}) async {
    return await sl<AuthRepository>().signinWithGoogle();
  }

}