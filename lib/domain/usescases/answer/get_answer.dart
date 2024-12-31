import 'package:dartz/dartz.dart';
import 'package:tesis_v2/core/usecase/usecase.dart';
import 'package:tesis_v2/domain/repository/answer/answer.dart';
import '../../../service_locator.dart';

class GetAnswerUseCase implements UseCase<Either,dynamic> {
  @override
  Future<Either> call({params}) async {
    return await sl<AnswerRepository>().getAnswer();
  }

}