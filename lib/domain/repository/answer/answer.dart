import 'package:dartz/dartz.dart';
import 'package:tesis_v2/data/models/answer/create_answer.dart';
abstract class AnswerRepository{
  Future<Either> saveAnswers(CreateAnswer createAnswer);
  Future<Either> getAnswer();

}