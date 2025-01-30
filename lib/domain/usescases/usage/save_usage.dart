import 'package:dartz/dartz.dart';
import 'package:tesis_v2/core/usecase/usecase.dart';
import 'package:tesis_v2/data/models/usage/save_usage.dart';
import 'package:tesis_v2/domain/repository/usage/usage.dart';
import '../../../service_locator.dart';

class CreateUsageUseCase implements UseCase<Either,SaveUsage> {


  @override
  Future<Either> call({SaveUsage ? params}) async {
    return sl<UsageRepository>().saveUsage(params!);
  }

}