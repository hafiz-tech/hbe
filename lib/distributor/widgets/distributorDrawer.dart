import 'package:hbe/distributor/screens/attendance/mark_attendance/mark_attendance.dart';
import 'package:hbe/distributor/screens/dashboard/distributorDash.dart';
import 'package:hbe/distributor/screens/payment/payment_screen.dart';
import 'package:hbe/distributor/screens/sale/daily_sales.dart';
import 'package:hbe/enums/globals.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_routes.dart';
import '../../utils/color_constants.dart';
import '../../utils/toast_utils.dart';
import '../../views/login/login.dart';
import '../screens/distributor_sale_target.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/return/return_sales.dart';


class DistributorDrawer extends StatefulWidget {
  const DistributorDrawer({Key? key}) : super(key: key);

  @override
  State<DistributorDrawer> createState() => _DistributorDrawerState();
}

class _DistributorDrawerState extends State<DistributorDrawer> {
  @override
  Widget build(BuildContext context) {

    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 170,
            padding: const EdgeInsets.only(top: 40,left: 20),
            decoration: BoxDecoration(
                color: greenBasic,
                boxShadow: [
                  BoxShadow(
                      color: black.withOpacity(0.25),
                      blurRadius: 3
                  )
                ]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    const CircleAvatar(
                      foregroundImage: AssetImage("assets/images/user.png"),
                      radius: 30,
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(globalData.userName,style: const TextStyle(fontSize: 16,fontFamily: 'Poppins-Medium',color: white),),
                        Text(globalData.userTypeName,style: const TextStyle(fontSize: 16,fontFamily: 'Poppins-Medium',color: white),)
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
          ListView.builder(
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              itemCount: globalData.menuItems.length,
              itemBuilder: (context, index){
                return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  onTap: (){
                    if(globalData.menuItems[index].menuName=="Dashboard"){
                      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=> DistributorDashboard(hit: false,)),
                              (Route<dynamic> route) => false);
                    }
                    else if(globalData.menuItems[index].menuName=="Sale Target"){
                      AppRoutes.pop(context);
                      AppRoutes.push(context, PageTransitionType.fade, DistributorSaleTarget(fromTab:true));
                    }
                    else if(globalData.menuItems[index].menuName=="Profile"){
                      AppRoutes.pop(context);
                      AppRoutes.push(context, PageTransitionType.fade, DistributorProfileScreen(fromTab: true,));
                    }
                    else if(globalData.menuItems[index].menuName=="Daily Shop Visit"){
                      AppRoutes.pop(context);
                      AppRoutes.push(context, PageTransitionType.fade, const DistributorMarkAttendance(from: false,));
                    }
                    else if(globalData.menuItems[index].menuName=="Sale Return"){
                      AppRoutes.pop(context);
                      AppRoutes.push(context, PageTransitionType.fade, const ReturnDetail());
                    }
                    else if(globalData.menuItems[index].menuName=="Daily Sale"){
                      AppRoutes.pop(context);
                    AppRoutes.push(context, PageTransitionType.fade, const DistributorDailySales());
                    }
                    else if(globalData.menuItems[index].menuName=="Payment Received"){
                      AppRoutes.pop(context);
                      AppRoutes.push(context, PageTransitionType.fade, const DistributorPaymentScreen());
                    }
                    else if(globalData.menuItems[index].menuName=="Reports"){
                      AppRoutes.pop(context);
                      AppRoutes.push(context, PageTransitionType.fade, const DistributorReports());
                    }
                    else{
                      AppRoutes.pop(context);
                    }
                  },
                  leading:Image.asset(globalData.menuItems[index].menuName=="Sale Target"?"assets/icons/target.png":
                  globalData.menuItems[index].menuName=="Dashboard"?"assets/icons/home.png":
                  globalData.menuItems[index].menuName=="Payment Received"?"assets/images/weeklySales.png":
                  globalData.menuItems[index].menuName=="Daily Shop Visit"?"assets/icons/mark_attendance.png":
                  globalData.menuItems[index].menuName=="Profile"?"assets/icons/profile.png":
                  globalData.menuItems[index].menuName=="Sale Return"?"assets/icons/return.png":
                  globalData.menuItems[index].menuName=="Daily Sale"?"assets/icons/sale.png":
                  globalData.menuItems[index].menuName=="Reports"?"assets/icons/report.png":
                  "assets/icons/home.png",
                  height: 25,),
                  title: Text(globalData.menuItems[index].menuName.toString(),style: const TextStyle(fontSize: 14,fontFamily: 'Poppins-Medium',color: black),
                  ),
                ),

              ],
            );
          }),
          const Spacer(),
          const Divider(),
          ListTile(
            onTap: () async{
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.clear();
              if(mounted){
                setState(() {
                  globalData.userName ="";
                  globalData.designationName ="";
                  globalData.menuItems.clear();
                });
              }
              ToastUtils.successToast("Logout Successfully", context);
              Future.delayed(const Duration(seconds: 1),
                      () => AppRoutes.pushAndRemoveUntil(context, const Login()));
            },
            leading: const Icon( FeatherIcons.logOut),
            title:  const Text("Logout",
              style: TextStyle(fontSize: 14,fontFamily: 'Poppins-Medium'),
            ) ,
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
