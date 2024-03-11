import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';

import '../utils/color_constants.dart';

class ProfileListItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool hasNavigation;
  final String textValue;

  const ProfileListItem({
    Key? key,
    required this.icon,
    required this.text,
    required this.hasNavigation,
    required this.textValue
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: EdgeInsets.all(5),
      padding:EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: white,
        boxShadow: [
          BoxShadow(
            color: black.withOpacity(0.25),
            blurRadius: 2
          )
        ]
      ),
      child: Row(
       crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(
            this.icon,
          ),
          SizedBox(width: 10),
          textValue.toString()==""?  Text(this.text,
            style: TextStyle(fontSize: 14,fontFamily: 'Poppins-Medium'),
          )
              :Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(this.text,
                style: TextStyle(fontSize: 12,fontFamily: 'Poppins-Medium'),
              ),
              Text(this.textValue,
                style: TextStyle(fontSize: 14,fontFamily: 'Poppins-Medium'),
              ),
            ],
          ),
          Spacer(),
          if (this.hasNavigation)
            Icon(
              FeatherIcons.chevronRight,
            ),
        ],
      ),
    );
  }
}