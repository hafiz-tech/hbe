// To parse this JSON data, do
//
//     final returnUpdateModel = returnUpdateModelFromJson(jsonString);

import 'dart:convert';

List<ReturnUpdateModel> returnUpdateModelFromJson(String str) => List<ReturnUpdateModel>.from(json.decode(str).map((x) => ReturnUpdateModel.fromJson(x)));

String returnUpdateModelToJson(List<ReturnUpdateModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ReturnUpdateModel {
  ReturnUpdateModel({
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
  List<UProducDetail> producDetails;

  factory ReturnUpdateModel.fromJson(Map<String, dynamic> json) => ReturnUpdateModel(
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
    producDetails: List<UProducDetail>.from(json["ProducDetails"].map((x) => UProducDetail.fromJson(x))),
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
    "ProducDetails": List<dynamic>.from(producDetails.map((x) => x.toJson())),
  };
}

class UProducDetail {
  UProducDetail({
    required this.id,
    required this.saleReturnId,
    required this.productId,
    required this.productName,
    required this.returnQuantity,
    required this.demageReplaceQuantity,
    required this.demageNotReplaceQuantity,
  });

  int id;
  int saleReturnId;
  int productId;
  String productName;
  int returnQuantity;
  int demageReplaceQuantity;
  int demageNotReplaceQuantity;

  factory UProducDetail.fromJson(Map<String, dynamic> json) => UProducDetail(
    id: json["ID"],
    saleReturnId: json["SaleReturnID"],
    productId: json["ProductID"],
    productName: json["ProductName"],
    returnQuantity: json["Return_Quantity"],
    demageReplaceQuantity: json["DemageReplace_Quantity"],
    demageNotReplaceQuantity: json["DemageNotReplace_Quantity"],
  );

  Map<String, dynamic> toJson() => {
    "ID": id,
    "SaleReturnID": saleReturnId,
    "ProductID": productId,
    "ProductName": productName,
    "Return_Quantity": returnQuantity,
    "DemageReplace_Quantity": demageReplaceQuantity,
    "DemageNotReplace_Quantity": demageNotReplaceQuantity,
  };
}
