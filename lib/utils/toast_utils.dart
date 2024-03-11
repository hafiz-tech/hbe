import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

import 'color_constants.dart';

class ToastUtils{
  static successToast(String msg, BuildContext context){
    return showToast(msg,
      context: context,
      textStyle: TextStyle(fontSize: 12,fontFamily: 'Poppins-Regular',color: white),
      backgroundColor: Colors.green,
      animation: StyledToastAnimation.scale,
      reverseAnimation: StyledToastAnimation.fade,
      position: StyledToastPosition.top,
      animDuration:const Duration(seconds: 1),
      duration:const Duration(seconds: 3),
      curve: Curves.elasticOut,
      reverseCurve: Curves.linear,
    );
  }

  static failureToast(String msg,BuildContext context){
    return showToast(msg,
      context: context,
      textStyle: TextStyle(fontSize: 12,fontFamily: 'Poppins-Regular',color: white),
      backgroundColor: Colors.red,
      animation: StyledToastAnimation.scale,
      reverseAnimation: StyledToastAnimation.fade,
      position: StyledToastPosition.top,
      animDuration:const Duration(seconds: 1),
      duration:const Duration(seconds: 3),
      curve: Curves.elasticOut,
      reverseCurve: Curves.linear,
    );
  }

  static warningToast(String msg,BuildContext context){
    return showToast(msg,
      context: context,
      textStyle: TextStyle(fontSize: 12,fontFamily: 'Poppins-Regular',color:black),
      backgroundColor: Colors.yellowAccent,
      animation: StyledToastAnimation.scale,
      reverseAnimation: StyledToastAnimation.fade,
      position: StyledToastPosition.top,
      animDuration:const Duration(seconds: 1),
      duration:const Duration(seconds: 3),
      curve: Curves.elasticOut,
      reverseCurve: Curves.linear,
    );
  }
  static infoToast(String msg,BuildContext context){
    return showToast(msg,
      context: context,
      textStyle: TextStyle(fontSize: 12,fontFamily: 'Poppins-Regular',color: white),
      backgroundColor:Colors.lightBlueAccent,
      animation: StyledToastAnimation.scale,
      reverseAnimation: StyledToastAnimation.fade,
      position: StyledToastPosition.top,
      animDuration:const Duration(seconds: 1),
      duration:const Duration(seconds: 3),
      curve: Curves.elasticOut,
      reverseCurve: Curves.linear,
    );
  }
}

