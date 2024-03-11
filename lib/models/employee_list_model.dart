// To parse required this.JSON data, do
//
//     final employeeListModel = employeeListModelFromJson(jsonString);

// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';

EmployeeListModel employeeListModelFromJson(String str) => EmployeeListModel.fromJson(json.decode(str));

String employeeListModelToJson(EmployeeListModel data) => json.encode(data.toJson());

class EmployeeListModel {
  EmployeeListModel({
    required this.table,
    required this.table1,
    required this.table2,
    required this.table3,
    required this.table4,
  });

  List<EMPTable> table;
  List<EMPTable> table1;
  List<EMPTable> table2;
  List<EMPTable> table3;
  List<EMPTable> table4;

  factory EmployeeListModel.fromJson(Map<String, dynamic> json) => EmployeeListModel(
    table: List<EMPTable>.from(json["Table"].map((x) => EMPTable.fromJson(x))),
    table1: List<EMPTable>.from(json["Table1"].map((x) => EMPTable.fromJson(x))),
    table2: List<EMPTable>.from(json["Table2"].map((x) => EMPTable.fromJson(x))),
    table3: List<EMPTable>.from(json["Table3"].map((x) => EMPTable.fromJson(x))),
    table4: List<EMPTable>.from(json["Table4"].map((x) => EMPTable.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "Table": List<dynamic>.from(table.map((x) => x.toJson())),
    "Table1": List<dynamic>.from(table1.map((x) => x.toJson())),
    "Table2": List<dynamic>.from(table2.map((x) => x.toJson())),
    "Table3": List<dynamic>.from(table3.map((x) => x.toJson())),
    "Table4": List<dynamic>.from(table4.map((x) => x.toJson())),
  };
}

class EMPTable {
  EMPTable({
    required this.userId,
    required this.userName,
    required this.userTypeId,
    required this.gm,
    required this.st,
    required this.dm,
    required this.sdm,
    required this.so,
    required this.gmName,
    required this.stName,
    required this.dmName,
    required this.sdmName,
  });

  int? userId;
  String? userName;
  int? userTypeId;
  int? gm;
  int? st;
  int? dm;
  int? sdm;
  int? so;
  String? gmName;
  String? stName;
  String? dmName;
  String? sdmName;

  factory EMPTable.fromJson(Map<String, dynamic> json) => EMPTable(
    userId: json["UserID"] == null ? null :json["UserID"] ,
    userName: json["UserName"] == null ? null : json["UserName"],
    userTypeId: json["UserTypeID"] == null ? null : json["UserTypeID"],
    gm: json["GM"] == null ? null : json["GM"],
    st: json["ST"] == null ? null : json["ST"],
    dm: json["DM"] == null ? null :json["DM"]  ,
    sdm: json["SDM"] == null ? null :json["SDM"]  ,
    so: json["SO"] == null ? null : json["SO"],
    gmName: json["GMName"] == null ? null : json["GMName"],
    stName: json["STName"] == null ? null : json["STName"],
    dmName: json["DMName"] == null ? null : json["DMName"],
    sdmName: json["SDMName"] == null ? null : json["SDMName"],
  );

  Map<String, dynamic> toJson() => {
    "UserID": userId == null ? null : userId,
    "UserName": userName == null ? null : userName,
    "UserTypeID": userTypeId == null ? null : userTypeId,
    "GM": gm == null ? null : gm,
    "ST": st == null ? null : st,
    "DM": dm == null ? null : dm,
    "SDM": sdm == null ? null : sdm,
    "SO": so == null ? null :so ,
    "GMName": gmName == null ? null : gmName,
    "STName": stName == null ? null : stName,
    "DMName": dmName == null ? null :dmName,
    "SDMName": sdmName == null ? null : sdmName,
  };
}


