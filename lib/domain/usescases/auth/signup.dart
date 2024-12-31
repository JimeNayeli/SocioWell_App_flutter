import 'package:dartz/dartz.dart';
import 'package:tesis_v2/core/usecase/usecase.dart';
import 'package:tesis_v2/data/models/auth/create_user_req.dart';
import 'package:tesis_v2/domain/repository/auth/auth.dart';

import '../../../service_locator.dart';

class SignupUseCase implements UseCase<Either,CreateUserReq> {


  @override
  Future<Either> call({CreateUserReq ? params}) async {
    return sl<AuthRepository>().signup(params!);
  }

}