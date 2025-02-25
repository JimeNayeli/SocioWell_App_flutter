
import 'package:dartz/dartz.dart';
import 'package:tesis_v2/data/models/usage/save_usage.dart';
import 'package:tesis_v2/data/sources/usage/usage_firebase_service.dart';
import 'package:tesis_v2/domain/repository/usage/usage.dart';
import 'package:tesis_v2/service_locator.dart';

class UsageRepositoryImpl extends UsageRepository {


  @override
  Future<Either> saveUsage(SaveUsage createUsage, ) async {
    return await sl<UsageFirebaseService>().saveUsage(createUsage);
  }
  
  
}