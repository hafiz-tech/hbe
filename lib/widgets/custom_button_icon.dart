import 'package:flutter/material.dart';

import '../utils/color_constants.dart';
class CustomButtonIcon extends StatelessWidget {
  final VoidCallback onTap;
  final Color color;
  final String text;
  final IconData iconData;
  final Color textColor;
  final double? width;

  const CustomButtonIcon({Key? key,this.width,required this.textColor,required this.iconData,required this.onTap,required this.color,required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
        child: Container(
          width:width?? 150,
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: color,
              border: Border.all(color: textColor),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                    color: black.withOpacity(0.25),
                    blurRadius: 4
                )
              ]
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(iconData,color: textColor,),
              SizedBox(width: 10),
              Text(text,style: TextStyle(fontSize: 12,fontFamily: 'Poppins-Medium',color: textColor),),
            ],
          ),
        ));
  }
}
