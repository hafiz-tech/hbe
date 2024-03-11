// To parse required this.JSON data, do
//
//     final todayShopVisitModel = todayShopVisitModelFromJson(jsonString);

import 'dart:convert';

List<TodayShopVisitModel> todayShopVisitModelFromJson(String str) => List<TodayShopVisitModel>.from(json.decode(str).map((x) => TodayShopVisitModel.fromJson(x)));

String todayShopVisitModelToJson(List<TodayShopVisitModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TodayShopVisitModel {
  TodayShopVisitModel({
    required this.customerId,
    required this.customerName,
    required this.cityName,
    required this.area,
    required this.address,
    required this.mobile,
  });

  int? customerId;
  String? customerName;
  String? cityName;
  String? area;
  String? address;
  String? mobile;

  factory TodayShopVisitModel.fromJson(Map<String, dynamic> json) => TodayShopVisitModel(
    customerId: json["CustomerID"]==null?null:json["CustomerID"],
    customerName: json["CustomerName"]==null?null:json["CustomerName"],
    cityName: json["CityName"]==null?null:json["CityName"],
    area: json["Area"]==null?null:json["Area"],
    address: json["Address"]==null?null:json["Address"],
    mobile: json["Mobile"]==null?null:json["Mobile"],
  );

  Map<String, dynamic> toJson() => {
    "CustomerID": customerId==null?null:customerId,
    "CustomerName": customerName==null?null:customerName,
    "CityName": cityName==null?null:cityName,
    "Area": area==null?null:area,
    "Address": address==null?null:address,
    "Mobile": mobile==null?null:mobile,
  };
}
