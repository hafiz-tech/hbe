import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../utils/color_constants.dart';
class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: greenBasic,
        title: Text("Notifications",style: TextStyle(fontFamily: "Poppins-Medium",fontSize: 16,color: white)),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset("assets/animations/no_alerts.json",height: 200),
            SizedBox(height: 20,),
            Text("No Notifications Found",style: TextStyle(fontFamily: 'Poppins-Medium',fontSize: 20,color: black),)
          ],
        ),
      ),
    );
  }
}
