// To parse required this.JSON data, do
//
//     final weeklyDataModel = weeklyDataModelFromJson(jsonString);

import 'dart:convert';

List<WeeklyDataModel> weeklyDataModelFromJson(String str) => List<WeeklyDataModel>.from(json.decode(str).map((x) => WeeklyDataModel.fromJson(x)));

String weeklyDataModelToJson(List<WeeklyDataModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class WeeklyDataModel {
  WeeklyDataModel({
    required this.dayName,
    required this.saleAmount,
  });

  String? dayName;
  double? saleAmount;

  factory WeeklyDataModel.fromJson(Map<String, dynamic> json) => WeeklyDataModel(
    dayName: json["DayName"]==null?null:json["DayName"],
    saleAmount: json["SaleAmount"]==null?null:json["SaleAmount"],
  );

  Map<String, dynamic> toJson() => {
    "DayName": dayName==null?null:dayName,
    "SaleAmount": saleAmount==null?null:saleAmount,
  };
}
