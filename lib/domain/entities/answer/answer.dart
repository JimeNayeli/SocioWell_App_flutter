import 'package:cloud_firestore/cloud_firestore.dart';
class AnswerEntity{
  int ? selfControl;
  int ? productivityLoss;
  int ? satisfaction;
  Timestamp ? createDate;


  AnswerEntity({
    required this.selfControl,
    required this.satisfaction,
    required this.productivityLoss, 
    required this.createDate
  });

}