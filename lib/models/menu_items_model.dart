// To parse required this.JSON data, do
//
//     final menuItemsModel = menuItemsModelFromJson(jsonString);

import 'dart:convert';

List<MenuItemsModel> menuItemsModelFromJson(String str) => List<MenuItemsModel>.from(json.decode(str).map((x) => MenuItemsModel.fromJson(x)));

String menuItemsModelToJson(List<MenuItemsModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MenuItemsModel {
  MenuItemsModel({
    required this.sortNo,
    required this.groupName,
    required this.menuName,
  });

  int sortNo;
  String groupName;
  String menuName;

  factory MenuItemsModel.fromJson(Map<String, dynamic> json) => MenuItemsModel(
    sortNo: json["SortNo"],
    groupName: json["GroupName"],
    menuName: json["MenuName"],
  );

  Map<String, dynamic> toJson() => {
    "SortNo": sortNo,
    "GroupName": groupName,
    "MenuName": menuName,
  };
}
