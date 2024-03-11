import 'package:hbe/utils/color_constants.dart';
import 'package:flutter/material.dart';
class CustomButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color color;
  final String text;
  final double? width;
  final Color? colorText;
  const CustomButton({Key? key,this.colorText,required this.onTap,required this.color,required this.text, this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
        child: Container(
          width:width??150,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: black.withOpacity(0.25),
                blurRadius: 4
              )
            ]
          ),
          child: Center(
            child: Text(text,style: TextStyle(fontSize: 12,fontFamily: 'Poppins-Medium',color:colorText?? white),),
          ),
        ));
  }
}
