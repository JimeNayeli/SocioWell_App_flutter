import 'package:tesis_v2/domain/entities/usage/usage.dart';

class UsageModel{
  String ? fechaRegistro;
  String ? tiempoUso;
  String ? accesos;
  String ? nivelAdiccion;
  String? appName;


  UsageModel({
    required this.fechaRegistro,
    required this.tiempoUso,
    required this.accesos, 
    required this.nivelAdiccion,
    required this.appName,
  });

    UsageModel.fromJson(Map<String,dynamic> data) {
    fechaRegistro = data['fechaRegistro'];
    tiempoUso = data['tiempoUso'];
    accesos = data['accesos'];
    nivelAdiccion = data['nivelAdiccion'];
    appName = data['appName'];
    }
}


extension AnswerModelX on UsageModel {

  UsageEntity toEntity() {
    return UsageEntity(
      fechaRegistro: fechaRegistro,
      tiempoUso: tiempoUso,
      accesos: accesos,
      nivelAdiccion: nivelAdiccion,
      appName: appName,
    );
  }
}