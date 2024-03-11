// To parse required this.JSON data, do
//
//     final updateSaleDistributor = updateSaleDistributorFromJson(jsonString);

import 'dart:convert';

List<UpdateSaleDistributor> updateSaleDistributorFromJson(String str) => List<UpdateSaleDistributor>.from(json.decode(str).map((x) => UpdateSaleDistributor.fromJson(x)));

String updateSaleDistributorToJson(List<UpdateSaleDistributor> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UpdateSaleDistributor {
  UpdateSaleDistributor({
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

  int poid;
  String poNumber;
  DateTime poDate;
  String remarks;
  double subTotalAmt;
  double totalTax;
  double totalAmt;
  int cusCustomerId;
  String cusCustomerCode;
  String cusCustomerName;
  int cusCityId;
  String cusCityName;
  String cusArea;
  String cusAddress;
  String cusMobile;
  String cusMobile1;
  List<ProducDetail2> producDetails;

  factory UpdateSaleDistributor.fromJson(Map<String, dynamic> json) => UpdateSaleDistributor(
    poid: json["POID"],
    poNumber: json["PO_Number"],
    poDate: DateTime.parse(json["PODate"]),
    remarks: json["Remarks"],
    subTotalAmt: json["SubTotal_Amt"].toDouble(),
    totalTax: json["TotalTax"].toDouble(),
    totalAmt: json["TotalAmt"].toDouble(),
    cusCustomerId: json["CusCustomerID"],
    cusCustomerCode: json["CusCustomerCode"],
    cusCustomerName: json["CusCustomerName"],
    cusCityId: json["CusCityID"],
    cusCityName: json["CusCityName"],
    cusArea: json["CusArea"],
    cusAddress: json["CusAddress"],
    cusMobile: json["CusMobile"],
    cusMobile1: json["CusMobile1"],
    producDetails: List<ProducDetail2>.from(json["ProducDetails"].map((x) => ProducDetail2.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "POID": poid,
    "PO_Number": poNumber,
    "PODate": poDate.toIso8601String(),
    "Remarks": remarks,
    "SubTotal_Amt": subTotalAmt,
    "TotalTax": totalTax,
    "TotalAmt": totalAmt,
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

class ProducDetail2 {
  ProducDetail2({
    required this.id,
    required this.poid,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.salePrice,
    required this.total,
  });

  int id;
  int poid;
  int productId;
  String productName;
  double quantity;
  double salePrice;
  double total;

  factory ProducDetail2.fromJson(Map<String, dynamic> json) => ProducDetail2(
    id: json["ID"],
    poid: json["POID"],
    productId: json["ProductID"],
    productName: json["ProductName"],
    quantity: json["Quantity"],
    salePrice: json["SalePrice"].toDouble(),
    total: json["Total"].toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "ID": id,
    "POID": poid,
    "ProductID": productId,
    "ProductName": productName,
    "Quantity": quantity,
    "SalePrice": salePrice,
    "Total": total,
  };
}
