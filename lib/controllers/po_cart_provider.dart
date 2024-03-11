import 'package:flutter/material.dart';

class POCartProvider extends ChangeNotifier {
  late BuildContext context;

  init({required BuildContext context}) {
    this.context = context;
  }
  int itemCount=0;
  String originalPrice="";
  int price=0;
  var selectedIndex;


}
