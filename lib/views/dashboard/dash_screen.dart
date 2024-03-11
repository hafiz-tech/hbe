// ignore_for_file: must_be_immutable

import 'package:bottom_bar/bottom_bar.dart';
import 'package:hbe/views/dashboard/dashboard/dashboard.dart';
import 'package:hbe/views/dashboard/sales/sale_target.dart';
import 'package:hbe/views/profile/profile_screen.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import '../../utils/color_constants.dart';
import 'balances/check_balances.dart';

class DashScreen extends StatefulWidget {
  bool hit;
   DashScreen({Key? key,required this.hit}) : super(key: key);

  @override
  State<DashScreen> createState() => _DashScreenState();
}

class _DashScreenState extends State<DashScreen> {

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      backgroundColor: Colors.white,
      body: Center(
        child: IndexedStack(
            index: _selectedIndex,
            children: [
              Dashboard(hit: widget.hit,),
              Balances(),
              SaleTarget(fromTab: false,),
              ProfileScreen(fromTab: false,),
            ]
        ),
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: white,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: black.withOpacity(0.25),
              blurRadius: 4,
            ),
          ],
        ),
        child: BottomBar(
          textStyle: TextStyle(fontFamily: 'Poppins-Regular',fontSize: 16,color: greenBasic),
          selectedIndex: _selectedIndex,
          onTap: (int index) {
            setState(() => _selectedIndex = index);
          },
          items: <BottomBarItem>[
            BottomBarItem(
              icon: Icon(FeatherIcons.home),
              title: Text('Home'),
              activeColor: greenBasic,

            ),
            BottomBarItem(
              icon: Icon(FeatherIcons.briefcase),
              title: Text('Reports'),
              activeColor: greenBasic,
            ),
            BottomBarItem(
              icon: Icon(FeatherIcons.barChart),
              title: Text('Sales'),
              activeColor: greenBasic,
            ),
            BottomBarItem(
              icon: Icon(FeatherIcons.user),
              title: Text('Profile'),
              activeColor: greenBasic,
            ),
          ],
        ),
      ),
    );
  }
}
