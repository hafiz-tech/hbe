// To parse required this.JSON data, do
//
//     final empAttendance = empAttendanceFromJson(jsonString);

// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';

List<EmpAttendance> empAttendanceFromJson(String str) => List<EmpAttendance>.from(json.decode(str).map((x) => EmpAttendance.fromJson(x)));

String empAttendanceToJson(List<EmpAttendance> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class EmpAttendance {
  EmpAttendance({
    required this.dutyTime,
    required this.checkInDateTime,
    required this.lateMin,
    required this.empName,
    required this.contactNo,
    required this.type,
    required this.empId,
    required this.location,
    required this.lat,
    required this.long,
  });

  String? dutyTime;
  String? checkInDateTime;
  int? lateMin;
  String? empName;
  String? contactNo;
  String? type;
  int? empId;
  String? location;
  String? lat;
  String? long;

  factory EmpAttendance.fromJson(Map<String, dynamic> json) => EmpAttendance(
    dutyTime: json["DutyTime"] == null ? null :json["DutyTime"] ,
    checkInDateTime: json["CheckInDateTime"] == null ? null :json["CheckInDateTime"] ,
    lateMin: json["LateMin"] == null ? null :json["LateMin"] ,
    empName: json["EmpName"] == null ? null : json["EmpName"],
    contactNo: json["ContactNo"] == null ? null : json["ContactNo"],
    type: json["Type"] == null ? null :json["Type"] ,
    empId: json["EmpID"] == null ? null : json["EmpID"],
    location: json["Location"] == null ? null : json["Location"],
    lat: json["Lat"] == null ? null : json["Lat"],
    long: json["Long"] == null ? null : json["Long"],
  );

  Map<String, dynamic> toJson() => {
    "DutyTime": dutyTime == null ? null : dutyTime,
    "CheckInDateTime": checkInDateTime == null ? null : checkInDateTime,
    "LateMin": lateMin == null ? null : lateMin,
    "EmpName": empName == null ? null : empName,
    "ContactNo": contactNo == null ? null : contactNo,
    "Type": type == null ? null :type,
    "EmpID": empId == null ? null : empId,
    "Location": location == null ? null : location,
    "Lat": lat == null ? null : lat,
    "Long": long == null ? null : long,
  };
}


