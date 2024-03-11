// To parse required this.JSON data, do
//
//     final mapCustomerModel = mapCustomerModelFromJson(jsonString);

import 'dart:convert';

List<MapCustomerModel> mapCustomerModelFromJson(String str) => List<MapCustomerModel>.from(json.decode(str).map((x) => MapCustomerModel.fromJson(x)));

String mapCustomerModelToJson(List<MapCustomerModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MapCustomerModel {
  MapCustomerModel({
    required this.customerId,
    required this.customerCode,
    required this.customerName,
    required this.cityId,
    required this.cityName,
    required this.area,
    required this.address,
    required this.mobile,
    required this.mobile1,
    required this.registrationDate,
    required this.isActive,
    required this.gm,
    required this.gmName,
    required this.st,
    required this.stName,
    required this.dm,
    required this.dmName,
    required this.sdm,
    required this.sdmName,
    required this.soId,
    required this.soName,
    required this.visitDay,
    required this.creditLimit,
    required this.paymentTypeId,
    required this.paymentTypeName,
    required this.isApproved,
    required this.approvedBy,
    required this.approvedOn,
    required this.mapLocation,
    required this.lat,
    required this.long,
    required this.isTaxRegister,
    required this.ntnNo,
    required this.stnNo,
  });

  int? customerId;
  String? customerCode;
  String? customerName;
  int? cityId;
  String? cityName;
  String? area;
  String? address;
  String? mobile;
  String? mobile1;
  DateTime? registrationDate;
  bool? isActive;
  dynamic gm;
  dynamic gmName;
  dynamic st;
  dynamic stName;
  dynamic dm;
  dynamic dmName;
  dynamic sdm;
  dynamic sdmName;
  dynamic soId;
  dynamic soName;
  dynamic visitDay;
  dynamic creditLimit;
  dynamic paymentTypeId;
  dynamic paymentTypeName;
  dynamic isApproved;
  dynamic approvedBy;
  dynamic approvedOn;
  dynamic mapLocation;
  dynamic lat;
  dynamic long;
  bool? isTaxRegister;
  dynamic ntnNo;
  dynamic stnNo;

  factory MapCustomerModel.fromJson(Map<String, dynamic> json) => MapCustomerModel(
    customerId: json["CustomerID"],
    customerCode: json["CustomerCode"],
    customerName: json["CustomerName"],
    cityId: json["CityID"],
    cityName: json["CityName"],
    area: json["Area"],
    address: json["Address"],
    mobile: json["Mobile"],
    mobile1: json["Mobile1"],
    registrationDate: DateTime.parse(json["RegistrationDate"]),
    isActive: json["IsActive"],
    gm: json["GM"],
    gmName: json["GMName"],
    st: json["ST"],
    stName: json["STName"],
    dm: json["DM"],
    dmName: json["DMName"],
    sdm: json["SDM"],
    sdmName: json["SDMName"],
    soId: json["SO_ID"],
    soName: json["SO_Name"],
    visitDay: json["Visit_Day"],
    creditLimit: json["CreditLimit"],
    paymentTypeId: json["PaymentTypeID"],
    paymentTypeName: json["PaymentTypeName"],
    isApproved: json["IsApproved"],
    approvedBy: json["ApprovedBy"],
    approvedOn: json["ApprovedOn"],
    mapLocation: json["MapLocation"],
    lat: json["Lat"],
    long: json["Long"],
    isTaxRegister: json["Is_Tax_Register"],
    ntnNo: json["NTNNo"],
    stnNo: json["STNNo"],
  );

  Map<String, dynamic> toJson() => {
    "CustomerID": customerId==null?null:customerId,
    "CustomerCode": customerCode==null?null:customerCode,
    "CustomerName": customerName==null?null:customerName,
    "CityID": cityId==null?null:cityId,
    "CityName": cityName==null?null:cityName,
    "Area": area==null?null:area,
    "Address": address==null?null:address,
    "Mobile": mobile==null?null:mobile,
    "Mobile1": mobile1==null?null:mobile1,
    "RegistrationDate": registrationDate==null?null:registrationDate!.toIso8601String(),
    "IsActive": isActive==null?null:isActive,
    "GM": gm==null?null:gm,
    "GMName": gmName==null?null:gmName,
    "ST": st==null?null:st,
    "STName": stName==null?null:stName,
    "DM": dm==null?null:dm,
    "DMName": dmName==null?null:dmName,
    "SDM": sdm==null?null:sdm,
    "SDMName": sdmName==null?null:sdmName,
    "SO_ID": soId==null?null:soId,
    "SO_Name": soName==null?null:soName,
    "Visit_Day": visitDay==null?null:visitDay,
    "CreditLimit": creditLimit==null?null:creditLimit,
    "PaymentTypeID": paymentTypeId==null?null:paymentTypeId,
    "PaymentTypeName": paymentTypeName==null?null:paymentTypeName,
    "IsApproved": isApproved==null?null:isApproved,
    "ApprovedBy": approvedBy==null?null:approvedBy,
    "ApprovedOn": approvedOn==null?null:approvedOn,
    "MapLocation": mapLocation==null?null:mapLocation,
    "Lat": lat==null?null:lat,
    "Long": long==null?null:long,
    "Is_Tax_Register": isTaxRegister==null?null:isTaxRegister,
    "NTNNo": ntnNo==null?null:ntnNo,
    "STNNo": stnNo==null?null:stnNo,
  };
}
