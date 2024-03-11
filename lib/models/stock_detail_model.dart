// To parse required this.JSON data, do
//
//     final stockDetailsModel = stockDetailsModelFromJson(jsonString);

import 'dart:convert';

List<StockDetailsModel> stockDetailsModelFromJson(String str) => List<StockDetailsModel>.from(json.decode(str).map((x) => StockDetailsModel.fromJson(x)));

String stockDetailsModelToJson(List<StockDetailsModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class StockDetailsModel {
  StockDetailsModel({
    required this.stockId,
    required this.stockNumber,
    required this.stockDate,
    required this.remarks,
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

  int stockId;
  String stockNumber;
  DateTime stockDate;
  String remarks;
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
  List<ProducDetail> producDetails;

  factory StockDetailsModel.fromJson(Map<String, dynamic> json) => StockDetailsModel(
    stockId: json["StockID"],
    stockNumber: json["StockNumber"],
    stockDate: DateTime.parse(json["StockDate"]),
    remarks: json["Remarks"],
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
    producDetails: List<ProducDetail>.from(json["ProducDetails"].map((x) => ProducDetail.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "StockID": stockId,
    "StockNumber": stockNumber,
    "StockDate": stockDate.toIso8601String(),
    "Remarks": remarks,
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

  int id;
  int poid;
  int productId;
  String productName;
  double quantity;
  double salePrice;
  double total;

  factory ProducDetail.fromJson(Map<String, dynamic> json) => ProducDetail(
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
