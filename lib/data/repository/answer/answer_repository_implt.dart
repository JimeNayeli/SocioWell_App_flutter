import 'package:dartz/dartz.dart';
import 'package:tesis_v2/data/models/answer/create_answer.dart';
import 'package:tesis_v2/data/sources/answer/answer_firebase_service.dart';
import 'package:tesis_v2/domain/repository/answer/answer.dart';

import '../../../../service_locator.dart';

class AnswerRepositoryImpl extends AnswerRepository {


  @override
  Future<Either> saveAnswers(CreateAnswer createAnswer) async {
    return await sl<AnswerFirebaseService>().saveAnswers(createAnswer);
  }
  
   @override
  Future<Either> getAnswer() async {
    return await sl<AnswerFirebaseService>().getAnswer();
  }
  
}