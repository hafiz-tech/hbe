// To parse required this.JSON data, do
//
//     final getTotalProducts = getTotalProductsFromJson(jsonString);

import 'dart:convert';

List<GetTotalProducts> getTotalProductsFromJson(String str) => List<GetTotalProducts>.from(json.decode(str).map((x) => GetTotalProducts.fromJson(x)));

String getTotalProductsToJson(List<GetTotalProducts> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetTotalProducts {
  GetTotalProducts({
    required this.productId,
    required this.companyName,
    required this.productCode,
    required this.productName,
    required this.productSalaPrice,
    required this.productType,
    required this.productUnit,
    required this.tradeOffer,
    required this.discount,
  });

  int? productId;
  String? companyName;
  String? productCode;
  String? productName;
  double? productSalaPrice;
  String? productType;
  String? productUnit;
  double? tradeOffer;
  double? discount;

  factory GetTotalProducts.fromJson(Map<String, dynamic> json) => GetTotalProducts(
    productId: json["ProductID"]==null?null:json["ProductID"],
    companyName: json["CompanyName"]==null?null:json["CompanyName"],
    productCode: json["ProductCode"]==null?null:json["ProductCode"],
    productName: json["ProductName"]==null?null:json["ProductName"],
    productSalaPrice: json["ProductSalaPrice"]==null?null: json["ProductSalaPrice"].toDouble(),
    productType: json["ProductType"]==null?null:json["ProductType"],
    productUnit: json["ProductUnit"]==null?null:json["ProductUnit"],
    tradeOffer: json["TradeOffer"]==null?null:json["TradeOffer"],
    discount: json["Discount"]==null?null:json["Discount"],
  );

  Map<String, dynamic> toJson() => {
    "ProductID": productId==null?null:productId,
    "CompanyName": companyName==null?null:companyName,
    "ProductCode": productCode==null?null:productCode,
    "ProductName": productName==null?null:productName,
    "ProductSalaPrice": productSalaPrice==null?null:productSalaPrice,
    "ProductType": productType==null?null:productType,
    "ProductUnit":productUnit==null?null:productUnit,
    "TradeOffer": tradeOffer==null?null:tradeOffer,
    "Discount": discount==null?null:discount,
  };
}

