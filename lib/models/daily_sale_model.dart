// To parse required this.JSON data, do
//
//     final dailySaleModel = dailySaleModelFromJson(jsonString);

// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';

List<DailySaleModel> dailySaleModelFromJson(String str) => List<DailySaleModel>.from(json.decode(str).map((x) => DailySaleModel.fromJson(x)));

String dailySaleModelToJson(List<DailySaleModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DailySaleModel {
  DailySaleModel({
    required this.poid,
    required this.poNumber,
    required this.poDate,
    required this.remarks,
    required this.subTotalAmt,
    required this.totalTax,
    required this.totalAmt,
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

  int? poid;
  String? poNumber;
  DateTime? poDate;
  String? remarks;
  double? subTotalAmt;
  double? totalTax;
  double? totalAmt;
  int? cusCustomerId;
  String? cusCustomerCode;
  String? cusCustomerName;
  int? cusCityId;
  String? cusCityName;
  String? cusArea;
  String? cusAddress;
  String? cusMobile;
  String? cusMobile1;
  List<ProducDetail>? producDetails;

  factory DailySaleModel.fromJson(Map<String, dynamic> json) => DailySaleModel(
    poid: json["POID"]==null?null:json["POID"],
    poNumber: json["PO_Number"]==null?null:json["PO_Number"],
    poDate: json["PODate"]==null?null:DateTime.parse(json["PODate"]),
    remarks: json["Remarks"]==null?null: json["Remarks"],
    subTotalAmt:json["SubTotal_Amt"]==null?null: json["SubTotal_Amt"].toDouble(),
    totalTax:json["TotalTax"] ==null?null:json["TotalTax"].toDouble(),
    totalAmt:json["TotalAmt"] ==null?null:json["TotalAmt"].toDouble(),
    cusCustomerId: json["CusCustomerID"]==null?null:json["CusCustomerID"],
    cusCustomerCode: json["CusCustomerCode"]==null?null: json["CusCustomerCode"],
    cusCustomerName: json["CusCustomerName"]==null?null:json["CusCustomerName"],
    cusCityId: json["CusCityID"]==null?null:json["CusCityID"],
    cusCityName: json["CusCityName"]==null?null:json["CusCityName"],
    cusArea: json["CusArea"]==null?null:json["CusArea"],
    cusAddress: json["CusAddress"]==null?null:json["CusAddress"],
    cusMobile: json["CusMobile"]==null?null:json["CusMobile"],
    cusMobile1: json["CusMobile1"]==null?null:json["CusMobile1"],
    producDetails:json["ProducDetails"]==null?null: List<ProducDetail>.from(json["ProducDetails"].map((x) => ProducDetail.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "POID": poid==null?null:poid,
    "PO_Number": poNumber==null?null:poNumber,
    "PODate": poDate==null?null:poDate!.toIso8601String(),
    "Remarks": remarks==null?null:remarks,
    "SubTotal_Amt": subTotalAmt==null?null:subTotalAmt,
    "TotalTax": totalTax==null?null:totalTax,
    "TotalAmt": totalAmt==null?null:totalAmt,
    "CusCustomerID": cusCustomerId==null?null:cusCustomerId,
    "CusCustomerCode": cusCustomerCode==null?null:cusCustomerCode,
    "CusCustomerName": cusCustomerName==null?null:cusCustomerName,
    "CusCityID": cusCityId==null?null:cusCityId,
    "CusCityName": cusCityName==null?null:cusCityName,
    "CusArea": cusArea==null?null:cusArea,
    "CusAddress": cusAddress==null?null:cusAddress,
    "CusMobile": cusMobile==null?null:cusMobile,
    "CusMobile1": cusMobile1==null?null:cusMobile1,
    "ProducDetails":producDetails==null?null:List<dynamic>.from(producDetails!.map((x) => x.toJson())),
  };
}

class ProducDetail {
  ProducDetail({
    required this.id,
    required this.poid,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.salePrice,
    required this.total,
  });

  int? id;
  int? poid;
  int? productId;
  String? productName;
  double? quantity;
  double? salePrice;
  double? total;

  factory ProducDetail.fromJson(Map<String, dynamic> json) => ProducDetail(
    id: json["ID"]==null?null: json["ID"],
    poid: json["POID"]==null?null:json["POID"],
    productId: json["ProductID"]==null?null: json["ProductID"],
    productName: json["ProductName"]==null?null:json["ProductName"],
    quantity: json["Quantity"]==null?null:json["Quantity"],
    salePrice: json["SalePrice"]==null?null: json["SalePrice"].toDouble(),
    total: json["Total"]==null?null:json["Total"].toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "ID": id==null?null:id,
    "POID": poid==null?null:poid,
    "ProductID": productId==null?null:productId,
    "ProductName": productName==null?null:productName,
    "Quantity": quantity==null?null:quantity,
    "SalePrice": salePrice==null?null:salePrice,
    "Total": total==null?null:total,
  };
}
