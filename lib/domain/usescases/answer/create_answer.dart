import 'package:dartz/dartz.dart';
import 'package:tesis_v2/core/usecase/usecase.dart';
import 'package:tesis_v2/data/models/answer/create_answer.dart';
import 'package:tesis_v2/domain/repository/answer/answer.dart';
import '../../../service_locator.dart';

class CreateAnswerUseCase implements UseCase<Either,CreateAnswer> {


  @override
  Future<Either> call({CreateAnswer ? params}) async {
    return sl<AnswerRepository>().saveAnswers(params!);
  }

}