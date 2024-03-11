// To parse required this.JSON data, do
//
//     final paymentMode = paymentModeFromJson(jsonString);

import 'dart:convert';

PaymentMode paymentModeFromJson(String str) => PaymentMode.fromJson(json.decode(str));

String paymentModeToJson(PaymentMode data) => json.encode(data.toJson());

class PaymentMode {
  PaymentMode({
    required this.table,
  });

  List<PaymentData> table;

  factory PaymentMode.fromJson(Map<String, dynamic> json) => PaymentMode(
    table: List<PaymentData>.from(json["Table"].map((x) => PaymentData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "Table": List<dynamic>.from(table.map((x) => x.toJson())),
  };
}

class PaymentData {
  PaymentData({
    required this.id,
    required this.userId,
    required this.customerId,
    required this.receivedAmount,
    required this.receivedDate,
    required this.paymentType,
    required this.transType,
    required this.bankName,
    required this.chequeNo,
    required this.chequeDate,
    required this.createdOn,
    required this.isEmpPost,
    required this.empPostAt,
    required this.isVoucherCreated,
    required this.voucherCreatedAt,
    required this.remarks,
    required this.customerName
  });

  int? id;
  int? userId;
  int? customerId;
  var receivedAmount;
  DateTime? receivedDate;
  String? paymentType;
  String? transType;
  String? bankName;
  String? chequeNo;
  DateTime? chequeDate;
  DateTime? createdOn;
  bool? isEmpPost;
  var empPostAt;
  bool? isVoucherCreated;
  var voucherCreatedAt;
  String? remarks;
  String? customerName;

  factory PaymentData.fromJson(Map<String, dynamic> json) => PaymentData(
    id: json["ID"]==null?null:json["ID"],
    userId: json["UserID"]==null?null: json["UserID"],
    customerId: json["CustomerID"]==null?null:json["CustomerID"],
    receivedAmount: json["ReceivedAmount"]==null?null: json["ReceivedAmount"],
    receivedDate:json["ReceivedDate"]==null?null: DateTime.parse(json["ReceivedDate"]),
    paymentType: json["PaymentType"]==null?null:json["PaymentType"],
    transType: json["TransType"]==null?null:json["TransType"],
    bankName: json["BankName"]==null?null:json["BankName"],
    chequeNo: json["ChequeNo"]==null?null: json["ChequeNo"],
    chequeDate: json["ChequeDate"]==null?null:DateTime.parse(json["ChequeDate"]),
    createdOn: json["CreatedOn"]==null?null:DateTime.parse(json["CreatedOn"]),
    isEmpPost: json["Is_Emp_Post"]==null?null:json["Is_Emp_Post"],
    empPostAt: json["Emp_Post_At"]==null?null:json["Emp_Post_At"],
    isVoucherCreated: json["Is_Voucher_Created"]==null?null:json["Is_Voucher_Created"],
    voucherCreatedAt: json["Voucher_Created_At"]==null?null:json["Voucher_Created_At"],
    remarks: json["Remarks"]==null?null:json["Remarks"],
    customerName: json["Remarks"]==null?null:json["CustomerName"],
  );

  Map<String, dynamic> toJson() => {
    "ID": id==null?null:id,
    "UserID": userId==null?null:userId,
    "CustomerID": customerId==null?null:customerId,
    "ReceivedAmount": receivedAmount==null?null:receivedAmount,
    "ReceivedDate": receivedDate==null?null:receivedDate!.toIso8601String(),
    "PaymentType": paymentType==null?null:paymentType,
    "TransType": transType==null?null:transType,
    "BankName": bankName==null?null:bankName,
    "ChequeNo": chequeNo==null?null:chequeNo,
    "ChequeDate":chequeDate ==null?null:chequeDate!.toIso8601String(),
    "CreatedOn": createdOn==null?null:createdOn!.toIso8601String(),
    "Is_Emp_Post": isEmpPost==null?null:isEmpPost,
    "Emp_Post_At": empPostAt==null?null:empPostAt,
    "Is_Voucher_Created": isVoucherCreated==null?null:isVoucherCreated,
    "Voucher_Created_At": voucherCreatedAt==null?null:voucherCreatedAt,
    "Remarks": remarks==null?null:remarks,
    "CustomerName": customerName==null?null:customerName,
  };
}
