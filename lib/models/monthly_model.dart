// To parse this JSON data, do
//
//     final weeklyDataModel = weeklyDataModelFromJson(jsonString);

import 'dart:convert';

List<MonthlyDataModel> monthlyDataModelFromJson(String str) => List<MonthlyDataModel>.from(json.decode(str).map((x) => MonthlyDataModel.fromJson(x)));

String MonthlyDataModelToJson(List<MonthlyDataModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MonthlyDataModel {
  MonthlyDataModel({
    required this.monthName,
    required this.saleAmount,
  });

  String? monthName;
  double? saleAmount;

  factory MonthlyDataModel.fromJson(Map<String, dynamic> json) => MonthlyDataModel(
    monthName: json["MonthName"]==null?null:json["MonthName"],
    saleAmount: json["SaleAmount"]==null?null:json["SaleAmount"],
  );

  Map<String, dynamic> toJson() => {
    "MonthName": monthName,
    "SaleAmount": saleAmount,
  };
}
