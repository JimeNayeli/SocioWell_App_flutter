import 'package:cloud_firestore/cloud_firestore.dart';
class CreateAnswer {
  final int selfControl;
  final int satisfaction;
  final int productivityLoss;
  final Timestamp createDate;

  CreateAnswer({
    required this.selfControl,
    required this.satisfaction,
    required this.productivityLoss,
    required this.createDate,
  });
}