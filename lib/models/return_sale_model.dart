// To parse this JSON data, do
//
//     final returnModel = returnModelFromJson(jsonString);

import 'dart:convert';

List<ReturnModel> returnModelFromJson(String str) => List<ReturnModel>.from(json.decode(str).map((x) => ReturnModel.fromJson(x)));

String returnModelToJson(List<ReturnModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ReturnModel {
  ReturnModel({
    required this.saleReturnId,
    required this.poNumber,
    required this.poDate,
    required this.remarks,
    required this.totalAmount,
    required this.cusCustomerId,
    required this.cusCustomerCode,
    required this.cusCustomerName,
    required this.cusCityId,
    required this.cusCityName,
    required this.cusArea,
    required this.cusAddress,
    required this.cusMobile,
    required this.cusMobile1,
    required this.producDetails,
  });

  int saleReturnId;
  String poNumber;
  DateTime poDate;
  String remarks;
  double totalAmount;
  int cusCustomerId;
  String cusCustomerCode;
  String cusCustomerName;
  int cusCityId;
  String cusCityName;
  String cusArea;
  String cusAddress;
  String cusMobile;
  String cusMobile1;
  List<dynamic> producDetails;

  factory ReturnModel.fromJson(Map<String, dynamic> json) => ReturnModel(
    saleReturnId: json["SaleReturnID"],
    poNumber: json["PO_Number"],
    poDate: DateTime.parse(json["PODate"]),
    remarks: json["Remarks"],
    totalAmount: json["TotalAmount"],
    cusCustomerId: json["CusCustomerID"],
    cusCustomerCode: json["CusCustomerCode"],
    cusCustomerName: json["CusCustomerName"],
    cusCityId: json["CusCityID"],
    cusCityName: json["CusCityName"],
    cusArea: json["CusArea"],
    cusAddress: json["CusAddress"],
    cusMobile: json["CusMobile"],
    cusMobile1: json["CusMobile1"],
    producDetails: List<dynamic>.from(json["ProducDetails"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "SaleReturnID": saleReturnId,
    "PO_Number": poNumber,
    "PODate": poDate.toIso8601String(),
    "Remarks": remarks,
    "TotalAmount": totalAmount,
    "CusCustomerID": cusCustomerId,
    "CusCustomerCode": cusCustomerCode,
    "CusCustomerName": cusCustomerName,
    "CusCityID": cusCityId,
    "CusCityName": cusCityName,
    "CusArea": cusArea,
    "CusAddress": cusAddress,
    "CusMobile": cusMobile,
    "CusMobile1": cusMobile1,
    "ProducDetails": List<dynamic>.from(producDetails.map((x) => x)),
  };
}
