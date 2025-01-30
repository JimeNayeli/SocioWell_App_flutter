import 'package:dartz/dartz.dart';
import 'package:tesis_v2/data/models/usage/save_usage.dart';

abstract class UsageRepository{
  Future<Either> saveUsage(SaveUsage saveUsage);

}