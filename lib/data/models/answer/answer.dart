import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tesis_v2/domain/entities/answer/answer.dart';

class AnswerModel{
  int ? selfControl;
  int ? productivityLoss;
  int ? satisfaction;
  Timestamp ? createDate;


  AnswerModel({
    required this.selfControl,
    required this.satisfaction,
    required this.productivityLoss, 
    required this.createDate
  });

    AnswerModel.fromJson(Map<String,dynamic> data) {
    selfControl = data['selfControl'];
    satisfaction = data['satisfaction'];
    productivityLoss = data['productivityLoss'];
    createDate = data['createDate'];
    }
}


extension AnswerModelX on AnswerModel {

  AnswerEntity toEntity() {
    return AnswerEntity(
      selfControl: selfControl,
      satisfaction: satisfaction,
      productivityLoss: productivityLoss,
      createDate: createDate
    );
  }
}