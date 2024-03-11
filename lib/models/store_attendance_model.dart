// To parse this JSON data, do
//
//     final storeAttendance = storeAttendanceFromJson(jsonString);

import 'dart:convert';

List<StoreAttendance> storeAttendanceFromJson(String str) => List<StoreAttendance>.from(json.decode(str).map((x) => StoreAttendance.fromJson(x)));

String storeAttendanceToJson(List<StoreAttendance> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class StoreAttendance {
  StoreAttendance({
    required this.storeName,
    required this.storeInDate,
    required this.storeOutDate,
    required this.workingMin,
    required this.location,
    required this.lat,
    required this.long,
  });

  String? storeName;
  DateTime? storeInDate;
  dynamic storeOutDate;
  dynamic workingMin;
  String? location;
  String? lat;
  String? long;

  factory StoreAttendance.fromJson(Map<String, dynamic> json) => StoreAttendance(
    storeName: json["StoreName"]==null?null:json["StoreName"],
    storeInDate:json["StoreInDate"]==null?null: DateTime.parse(json["StoreInDate"]),
    storeOutDate: json["StoreOutDate"]==null?null:json["StoreOutDate"],
    workingMin: json["WorkingMin"]==null?null:json["WorkingMin"],
    location: json["Location"]==null?null:json["Location"],
    lat: json["Lat"]==null?null:json["Lat"],
    long: json["Long"]==null?null:json["Long"],
  );

  Map<String, dynamic> toJson() => {
    "StoreName": storeName==null?null:storeName,
    "StoreInDate": storeInDate==null?null:storeInDate!.toIso8601String(),
    "StoreOutDate": storeOutDate==null?null:storeOutDate,
    "WorkingMin": workingMin==null?null:workingMin,
    "Location": location==null?null:location,
    "Lat": lat==null?null:lat,
    "Long": long==null?null:long,
  };
}
