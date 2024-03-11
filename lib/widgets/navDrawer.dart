import 'package:hbe/enums/globals.dart';
import 'package:hbe/views/attendance/upload_images/uploadImages.dart';
import 'package:hbe/views/profile/profile_screen.dart';
import 'package:hbe/views/reports/sales_report.dart';
import 'package:hbe/views/sales/daily_sales.dart';
import 'package:hbe/views/sales/manage_po.dart';
import 'package:hbe/views/stock/stock_details.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import '../utils/app_routes.dart';
import '../utils/color_constants.dart';
import '../views/attendance/mark_attendance/mark_attendance.dart';
import '../views/dashboard/dash_screen.dart';
import '../views/dashboard/sales/sale_target.dart';
import '../views/reports/attendance_reports.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 170,
              padding: EdgeInsets.only(top: 40,left: 20),
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
                  Align(
                      alignment: Alignment.center,
                      child: Image.asset("assets/images/deens_logo.png",color: white,height: 30,)),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      CircleAvatar(
                        foregroundImage: AssetImage("assets/images/user.png"),
                        radius: 30,
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(globalData.userName,style: TextStyle(fontSize: 16,fontFamily: 'Poppins-Medium',color: white),),
                          Text(globalData.designationName,style: TextStyle(fontSize: 14,fontFamily: 'Poppins-Regular',color: white),)
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
            ListView.builder(
                padding: EdgeInsets.zero,
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: globalData.menuItems.length,
                itemBuilder: (context, index){
                  return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    onTap: (){
                      if(globalData.menuItems[index].menuName=="Dashboard"){
                        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=> DashScreen(hit: false,)),
                                (Route<dynamic> route) => false);
                      }
                      else if(globalData.menuItems[index].menuName=="View Sale Target"){
                        AppRoutes.pop(context);
                        AppRoutes.push(context, PageTransitionType.fade, SaleTarget(fromTab:true));
                      }
                      else if(globalData.menuItems[index].menuName=="Profile"){
                        AppRoutes.pop(context);
                        AppRoutes.push(context, PageTransitionType.fade, ProfileScreen(fromTab: true,));
                      }
                      else if(globalData.menuItems[index].menuName=="Mark Attendance"){
                        AppRoutes.pop(context);
                        AppRoutes.push(context, PageTransitionType.fade, MarkAttendance());
                      }
                      else if(globalData.menuItems[index].menuName=="Upload Images"){
                        AppRoutes.pop(context);
                        AppRoutes.push(context, PageTransitionType.fade, UploadImages());
                      }
                      else if(globalData.menuItems[index].menuName=="Daily Sale"){
                        AppRoutes.pop(context);
                        AppRoutes.push(context, PageTransitionType.fade, DailySales());
                      }

                      else if(globalData.menuItems[index].menuName=="Manage PO"){
                        AppRoutes.pop(context);
                        AppRoutes.push(context, PageTransitionType.fade, ManagePO());
                      }
                      else if(globalData.menuItems[index].menuName=="Attendance Report"){
                        AppRoutes.pop(context);
                        AppRoutes.push(context, PageTransitionType.fade, AttendanceReports());
                      }
                      else if(globalData.menuItems[index].menuName=="Sale Report"){
                        AppRoutes.pop(context);
                        AppRoutes.push(context, PageTransitionType.fade, SalesReports());
                      }
                      else if(globalData.menuItems[index].menuName=="Manage Stock"){
                        AppRoutes.pop(context);
                        AppRoutes.push(context, PageTransitionType.fade, StockDetails());
                      }

                      else{
                        AppRoutes.pop(context);
                      }

                    },
                    leading: Image.asset(globalData.menuItems[index].menuName=="View Sale Target"?"assets/icons/target.png":
                    globalData.menuItems[index].menuName=="Dashboard"?"assets/icons/home.png":
                    globalData.menuItems[index].menuName=="Profile"?"assets/icons/profile.png":
                    globalData.menuItems[index].menuName=="Mark Attendance"?"assets/icons/mark_attendance.png":
                    globalData.menuItems[index].menuName=="Attendance Report"?"assets/icons/report.png":
                    globalData.menuItems[index].menuName=="Sale Report"?"assets/images/weeklySales.png":
                    globalData.menuItems[index].menuName=="Upload Images"?"assets/icons/image.png":
                    globalData.menuItems[index].menuName=="Daily Sale"?"assets/icons/sale.png":
                    globalData.menuItems[index].menuName=="Manage PO"?"assets/icons/po.png":
                    globalData.menuItems[index].menuName=="Manage Stock"?"assets/icons/po.png":
                    globalData.menuItems[index].menuName=="Key Account Ledger"?"assets/icons/ledget.png":globalData.menuItems[index].menuName=="Distributer Ledger"?"assets/icons/distributor.png":"",
                    height: 25,),
                    title: Text(globalData.menuItems[index].menuName.toString(),style: TextStyle(fontSize: 14,fontFamily: 'Poppins-Medium',color: black),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
