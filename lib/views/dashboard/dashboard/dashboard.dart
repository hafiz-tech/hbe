// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:hbe/enums/globals.dart';
import 'package:hbe/models/monthly_model.dart';
import 'package:hbe/models/weekly_model.dart';
import 'package:hbe/service/api_urls.dart';
import 'package:hbe/utils/app_routes.dart';
import 'package:hbe/utils/color_constants.dart';
import 'package:hbe/views/dashboard/mapViewer/emp_mapView.dart';
import 'package:hbe/views/dashboard/pdfViewer/emp_pdfView.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../models/emp_attendance_model.dart';
import '../../../models/menu_items_model.dart';
import '../../../models/store_attendance_model.dart';
import '../../../utils/toast_utils.dart';
import '../../../widgets/navDrawer.dart';
class Dashboard extends StatefulWidget {
  bool hit;
  Dashboard({Key? key,required this.hit}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  final Duration initialDelay = const Duration(milliseconds: 100);

  String totalEmployee = "0";
  String presentEmployee = "0";
  String absentEmployee = "0";
  String leavesEmployee = "0";

  TooltipBehavior? tooltipBehavior1;
  TooltipBehavior? tooltipBehavior2;
  bool isLoading = true;
  bool showOther = false;
  Future<List<EmpAttendance>>? empAtt;
  List<StoreAttendance> empStoreData=[];
  List<WeeklyDataModel> weeklyData=[];
  List<MonthlyDataModel> monthlyData=[];
  bool isStoreLoading = false;
  bool isStoreShowOther = false;
  bool noInternet = false;
  int selectedIndex = 0;

  @override
  void initState(){
    super.initState();
    tooltipBehavior1 = TooltipBehavior(enable: true);
    tooltipBehavior2 = TooltipBehavior(enable: true);
    WidgetsBinding.instance.addPostFrameCallback((_){
      getUser();
    });
  }

  var userID;
  //GET USER FROM SHARED PREFERENCES
  getUser() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(mounted){
      setState(() {
        userID = prefs.getInt("userID");
        globalData.designationName = prefs.getString("designationName");
        globalData.userName = prefs.getString("userName");
        globalData.userId = prefs.getInt("userID");
        globalData.userTypeID= prefs.getInt("userTypeID");
      });
    }

    if( globalData.userTypeID.toString()=="8"){
      if(mounted){
        setState(() {
          empAtt = getDashboardAttendance();

        });
      }
    }
    else{
      getDashboardAttendanceCount();

    }
    if(widget.hit){
      getMenuItems();
      getUserLoc(userID.toString());
    }


  }

  Future<void> apiData(userID) async{

    final response = await http.post(
        Uri.parse('${ApiUrls.baseURL}${ApiUrls.updateUserLocation}?UserID=$userID&Lat=$lat&Long=$lng&Location=$address'),
      headers: {
        ApiUrls.key_name: ApiUrls.apikey,
        "Content-Type": "application/json; charset=utf-8"
      },);

    var data = json.decode(response.body);
    log(data.toString());
    if (response.statusCode == 200 && data["RetMsg"].toString()=="0001") {
      log(data["RetMsg"]);

    }
    else {
      log(data["RetMsg"]);
    }

  }

 //GET USER LOCATION
  getUserLoc(String customerId) async{
    await geo.Geolocator.getCurrentPosition(desiredAccuracy: geo.LocationAccuracy.high)
        .then((geo.Position position) async {

      await _getAddress(position.latitude,position.longitude,customerId);
    }).catchError((e) {

    });

  }

  var address="", lat=0.0, lng=0.0;
  _getAddress(var ulat,var ulng,String customerId) async {
    try {

      List<Placemark> placemarks = await placemarkFromCoordinates(ulat, ulng);
      Placemark place = placemarks[0];
      if(mounted){
        setState(() {
          address = '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
          lat = ulat;
          lng = ulng;
        });
      }
      apiData(customerId);

    } catch (e) {
      //print(e);
    }
  }

  //GET MENU ITEMS API
  Future<void> getMenuItems() async{
    try {

      var response = await http.get(
        Uri.parse('${ApiUrls.baseURL}${ApiUrls.getMenuList}?UserID=$userID'),
        headers: {
          ApiUrls.key_name: ApiUrls.apikey,
          "Content-Type": "application/json; charset=utf-8"
        },
      );

      var res = jsonDecode(response.body);


      List<dynamic> data = json.decode(response.body);
      if (response.statusCode == 200 && data.toString() != "[]") {
        globalData.menuItems.clear();

        for (int i = 0; i < data.length; i++) {
          globalData.menuItems.add(MenuItemsModel.fromJson(data[i]));
        }


      } else {

        throw Exception('Failed to load data');
      }
    } on SocketException {

      ToastUtils.failureToast("No Internet Connection", context);
    } on HttpException {

      ToastUtils.failureToast("Couldn't find the data 😱", context);

    } on FormatException {

      ToastUtils.failureToast("Internal Server Error ", context);
    }
  }

  //GET DASHBOARD ATTENDANCE COUNT API
  Future<void> getDashboardAttendanceCount() async {
    try {

      var response = await http.get(
        Uri.parse('${ApiUrls.baseURL}${ApiUrls.getDashBoardAttendanceCount}?LoginUserID=$userID'),
        headers: {
          ApiUrls.key_name: ApiUrls.apikey,
          "Content-Type": "application/json; charset=utf-8"
        },
      );

      var res = jsonDecode(response.body);


      if (response.statusCode == 200) {

        if (mounted) {
          setState(() {
            empAtt = getDashboardAttendance();
            getWeeklyData();
            isLoading = false;
            totalEmployee = res["TotalEmployee"].toString();
            presentEmployee = res["PresentEmployee"].toString();
            absentEmployee = res["AbsentEmployee"].toString();
            leavesEmployee = "0";
          });
        }
      }  else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }

        ToastUtils.failureToast("Something went wrong", context);
        throw Exception('Failed to load data');
      }
    } on SocketException {
      if (mounted) {
        setState(() {
          isLoading = false;
          noInternet = true;
        });
      }
      ToastUtils.failureToast("No Internet Connection", context);
    } on HttpException {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }

      ToastUtils.failureToast("Couldn't find the data 😱", context);

    } on FormatException {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      ToastUtils.failureToast("Internal Server Error ", context);
    }

  }

  //GET WEEKLY DATA  API
  Future<void> getWeeklyData() async {

    try {
      final response = await http.get(
          Uri.parse('${ApiUrls.baseURL}${ApiUrls.getWeeklyGraph}?LoginUserID=$userID'),
          headers: {
            ApiUrls.key_name: ApiUrls.apikey,
          });

      List<dynamic> data = json.decode(response.body);
      if (response.statusCode == 200 && data.toString() != "[]") {
        getMonthlyData();
        weeklyData.clear();

        for (int i = 0; i < data.length; i++) {
          weeklyData.add(WeeklyDataModel.fromJson(data[i]));
        }

        if(mounted) {
          setState(() {
            isLoading = false;
          });
        }

      }
      else if (response.statusCode == 200 && data.toString() == "[]") {
        if(mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
      else {
        if(mounted) {
          setState(() {
            isLoading = false;
          });
        }
        throw Exception('Unexpected error occurred!');
      }
    } on SocketException {
      if(mounted) {
        setState(() {
          noInternet = true;
          isLoading = false;
        });
      }
    } on HttpException {
      if(mounted) {
        setState(() {
          isLoading = false;
        });
      }
      ToastUtils.warningToast("Couldn't find the data 😱", context);
    } on FormatException {
      if(mounted) {
        setState(() {
          isLoading = false;
        });
      }
      ToastUtils.warningToast("Something went wrong ", context);
    }

  }

  //GET DASHBOARD ATTENDANCE  API
  Future<List<EmpAttendance>> getDashboardAttendance() async {

    try {
      final response = await http.get(
          Uri.parse('${ApiUrls.baseURL}${ApiUrls.getDashBoardAttendance}?LoginUserID=$userID'),
          headers: {
            ApiUrls.key_name: ApiUrls.apikey,
          });

      List<dynamic> data = json.decode(response.body);
      if (response.statusCode == 200 && data.toString() != "[]") {
        if(mounted) {
          setState(() {
            isLoading = false;
            showOther = false;
            getWeeklyData();
          });
        }
        return data.map((data) => EmpAttendance.fromJson(data)).toList();
      }
      else if (response.statusCode == 200 && data.toString() == "[]") {
        if(mounted) {
          setState(() {
            isLoading = false;
            showOther = true;
          });
        }
      }
      else {
        if(mounted) {
          setState(() {
            isLoading = false;
            showOther = true;
          });
        }
        throw Exception('Unexpected error occurred!');
      }
    } on SocketException {
      if(mounted) {
        setState(() {
          showOther = true;
          noInternet = true;
          isLoading = false;
        });
      }
    } on HttpException {
      if(mounted) {
        setState(() {
          showOther = true;
          isLoading = false;
        });
      }
      ToastUtils.warningToast("Couldn't find the data 😱", context);
    } on FormatException {
      if(mounted) {
        setState(() {
          showOther = true;
          isLoading = false;
        });
      }
      ToastUtils.warningToast("Something went wrong ", context);
    }
    return throw Exception("Something went wrong");


  }

  //GET DASHBOARD STORE ATTENDANCE API
  Future<void> getDashboardStoreAttendance(empID) async {

    try {
      final response = await http.get(
          Uri.parse('${ApiUrls.baseURL}${ApiUrls.getStoreDashBoardAttendance}?EmpID=$empID'),
          headers: {
            ApiUrls.key_name: ApiUrls.apikey,
          });

      List<dynamic> data = json.decode(response.body);
      if (response.statusCode == 200 && data.toString() != "[]") {
        empStoreData.clear();

        for (int i = 0; i < data.length; i++) {
          empStoreData.add(StoreAttendance.fromJson(data[i]));
        }
        showStoreDialog(context,empStoreData[0]);
        if(mounted) {
          setState(() {
            isStoreLoading = false;
            isStoreShowOther = false;
          });
        }
      }
      else if (response.statusCode == 200 && data.toString() == "[]") {
        if(mounted) {
          setState(() {
            isStoreLoading = false;
            isStoreShowOther = true;
          });
        }
        showEmptyDialog(context);
      }
      else {
        if(mounted) {
          setState(() {
            isStoreLoading = false;
            isStoreShowOther = true;
          });
        }
        ToastUtils.failureToast("Something went wrong", context);
        throw Exception('Unexpected error occurred!');
      }
    } on SocketException {
      if(mounted) {
        setState(() {
          noInternet = true;
          isStoreShowOther = true;
          isStoreLoading = false;
        });
      }
      ToastUtils.failureToast("No Internet Connection", context);
    } on HttpException {
      if(mounted) {
        setState(() {
          isStoreShowOther = true;
          isStoreLoading = false;
        });
      }
      ToastUtils.warningToast("Couldn't find the data 😱", context);
    } on FormatException {
      if(mounted) {
        setState(() {
          isStoreShowOther = true;
          isStoreLoading = false;
        });
      }
      ToastUtils.warningToast("Something went wrong ", context);
    }
  }

  //GET MONTHLY DATA  API
  Future<void> getMonthlyData() async {

    try {
      final response = await http.get(
          Uri.parse('${ApiUrls.baseURL}${ApiUrls.getMonthlyGraph}?LoginUserID=$userID'),
          headers: {
            ApiUrls.key_name: ApiUrls.apikey,
          });

      List<dynamic> data = json.decode(response.body);
      if (response.statusCode == 200 && data.toString() != "[]") {
        monthlyData.clear();

        for (int i = 0; i < data.length; i++) {
          monthlyData.add(MonthlyDataModel.fromJson(data[i]));
        }

        if(mounted) {
          setState(() {
            isLoading = false;
          });
        }

      }
      else if (response.statusCode == 200 && data.toString() == "[]") {
        if(mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
      else {
        if(mounted) {
          setState(() {
            isLoading = false;
          });
        }
        throw Exception('Unexpected error occurred!');
      }
    } on SocketException {
      if(mounted) {
        setState(() {

          noInternet = true;
          isLoading = false;
        });
      }
    } on HttpException {
      if(mounted) {
        setState(() {
          isLoading = false;
        });
      }
      ToastUtils.warningToast("Couldn't find the data 😱", context);
    } on FormatException {
      if(mounted) {
        setState(() {
          isLoading = false;
        });
      }
      ToastUtils.warningToast("Something went wrong ", context);
    }

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    empStoreData.clear();
    weeklyData.clear();
    monthlyData.clear();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      drawer: DrawerWidget(),
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(20),
            bottomLeft:  Radius.circular(20),
          )
        ),
        backgroundColor: greenBasic,
        title: Text("Dashboard",style: TextStyle(fontFamily: "Poppins-Medium",fontSize: 16),),
        centerTitle: true,
        actions: [
          // InkWell(
          //     onTap: () async{
          //       AppRoutes.push(context, PageTransitionType.fade, Notifications());
          //     },
          //     child: Icon(Icons.notifications_active,color: white,)),
          // SizedBox(width: 10,)
        ],
      ),
      resizeToAvoidBottomInset: false,
      body:isLoading?
       Center(
         child:   Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Center(child: Lottie.asset("assets/animations/loading.json",height: 200),),
           ],
         ),
       )
       :SingleChildScrollView(
        child:Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              globalData.userTypeID.toString()=="8"? const SizedBox():DelayedDisplay(
                delay: initialDelay,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width*0.4,
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                                color: black.withOpacity(0.25),
                                blurRadius: 4
                            )
                          ]
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Total Employee",style: TextStyle(fontSize: 12,fontFamily: 'Poppins-Regular'),),
                              Icon(FeatherIcons.users,color: greenBasic,)
                            ],
                          ),
                          Text(totalEmployee.toString(),style: TextStyle(fontSize: 25,fontFamily: 'Poppins-Bold'))
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width*0.4,
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                                color: black.withOpacity(0.25),
                                blurRadius: 4
                            )
                          ]
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Total Present",style: TextStyle(fontSize: 12,fontFamily: 'Poppins-Regular'),),
                              Icon(FeatherIcons.userCheck,color: greenBasic,)
                            ],
                          ),
                          Text(presentEmployee.toString(),style: TextStyle(fontSize: 25,fontFamily: 'Poppins-Bold'))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              globalData.userTypeID.toString()=="8"? const SizedBox(): DelayedDisplay(
                delay: Duration(
                    milliseconds: initialDelay.inMilliseconds + 100),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width*0.4,
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                                color: black.withOpacity(0.25),
                                blurRadius: 4
                            )
                          ]
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Total Absent",style: TextStyle(fontSize: 12,fontFamily: 'Poppins-Regular'),),
                              Icon(FeatherIcons.userX,color:redBasic,)
                            ],
                          ),
                          Text(absentEmployee.toString(),style: TextStyle(fontSize: 25,fontFamily: 'Poppins-Bold'))
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width*0.4,
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                                color: black.withOpacity(0.25),
                                blurRadius: 4
                            )
                          ]
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Total Leaves",style: TextStyle(fontSize: 12,fontFamily: 'Poppins-Regular'),),
                              Icon(FeatherIcons.clipboard,color: greenBasic,)
                            ],
                          ),
                          Text(leavesEmployee.toString(),style: TextStyle(fontSize: 25,fontFamily: 'Poppins-Bold'))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20,),
              DelayedDisplay(
                delay: Duration(
                    milliseconds: initialDelay.inMilliseconds + 200),
                child: Container(
                  decoration: BoxDecoration(
                      color: white,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                            color: black.withOpacity(0.25),
                            blurRadius: 4
                        )
                      ]
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DelayedDisplay(
                          delay: Duration(
                              milliseconds: initialDelay.inMilliseconds + 300),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Weekly Sales",style: TextStyle(fontSize: 18,fontFamily: 'Poppins-SemiBold',color: greenBasic),),
                              Image.asset("assets/images/weeklySales.png",width: 40,height: 40,color: greenBasic,)
                            ],
                          ),
                        ),
                        SizedBox(height: 10,),
                        DelayedDisplay(
                          delay: Duration(
                              milliseconds: initialDelay.inMilliseconds + 400),
                          child: weeklyData.isNotEmpty?
                          SfCartesianChart(

                              tooltipBehavior: tooltipBehavior1,
                              primaryXAxis: CategoryAxis(),
                              series: <ChartSeries>[
                                ColumnSeries<WeeklyDataModel, String>(
                                    dataSource: weeklyData,
                                    xValueMapper: (WeeklyDataModel data, _) => data.dayName,
                                    yValueMapper: (WeeklyDataModel data, _) => data.saleAmount,
                                    color: greenBasic
                                ),

                              ]
                          ):
                          Column(
                            children: [
                              Lottie.asset("assets/animations/no_graph.json",height:200),
                              Text("We are unable to make a graph as there is no data available",style:TextStyle(fontFamily: 'Poppins-Regular',fontSize:16,color:greenBasic),textAlign:TextAlign.center)
                            ],),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20,),
              DelayedDisplay(
                delay: Duration(
                    milliseconds: initialDelay.inMilliseconds + 500),
                child: Container(
                  decoration: BoxDecoration(
                      color: white,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                            color: black.withOpacity(0.25),
                            blurRadius: 4
                        )
                      ]
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DelayedDisplay(
                          delay: Duration(
                              milliseconds: initialDelay.inMilliseconds + 600),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Daily Attendance",style: TextStyle(fontSize: 18,fontFamily: 'Poppins-SemiBold',color: greenBasic),),
                              Image.asset("assets/images/attendance.png",width: 40,height: 40,color: greenBasic,)
                            ],
                          ),
                        ),
                        SizedBox(height: 10,),
                        DelayedDisplay(
                          delay: Duration(
                              milliseconds: initialDelay.inMilliseconds + 700),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height*0.5,
                            child:noInternet?Center(
                              child: Column(
                                children: [
                                  Lottie.asset("assets/animations/nothingFound.json",height: 300),
                                  Text("No Internet Connection",style: TextStyle(fontFamily:'Poppins-SemiBold',fontSize: 20),)
                                ],
                              ),
                            ):showOther?
                            Center(
                              child: Column(
                                children: [
                                  Lottie.asset("assets/animations/nothingFound.json",height: 300),
                                  Text("No Attendance Found",style: TextStyle(fontFamily:'Poppins-SemiBold',fontSize: 20),)
                                ],
                              ),
                            )
                            :FutureBuilder<List<EmpAttendance>>(
                              future: empAtt,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  List<EmpAttendance>? data = snapshot.data;
                                  return DelayedDisplay(
                                    delay: Duration(
                                        milliseconds: initialDelay.inMilliseconds + 800),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: const BouncingScrollPhysics(),
                                      itemBuilder: (context,index){
                                        return buildAttendanceCard(items: data![index], index: index + 1);
                                      },itemCount: data!.length,),
                                  );
                                }
                                else if (snapshot.hasError) {
                                  return Center(
                                    child: Column(
                                      children: [
                                        Lottie.asset("assets/animations/nothingFound.json",height: 300),
                                        Text(snapshot.error .toString(),style: TextStyle(fontFamily:'Poppins-SemiBold',fontSize: 20),)
                                      ],
                                    ),
                                  );
                                }
                                return Center(child: Lottie.asset("assets/animations/14127-connecting.json",height: 250),);
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20,),
              DelayedDisplay(
                delay: Duration(
                    milliseconds: initialDelay.inMilliseconds + 800),
                child: Container(
                  decoration: BoxDecoration(
                      color: white,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                            color: black.withOpacity(0.25),
                            blurRadius: 4
                        )
                      ]
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DelayedDisplay(
                          delay: Duration(
                              milliseconds: initialDelay.inMilliseconds + 900),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Daily Sales",style: TextStyle(fontSize: 18,fontFamily: 'Poppins-SemiBold',color: greenBasic),),
                              Image.asset("assets/images/dailySale.png",width: 40,height: 40,color: greenBasic,)
                            ],
                          ),
                        ),
                        SizedBox(height: 10,),
                        DelayedDisplay(
                          delay: Duration(
                              milliseconds: initialDelay.inMilliseconds + 1000),
                          child:monthlyData.isNotEmpty?
                          SfCircularChart(

                              tooltipBehavior: tooltipBehavior2,
                              legend: Legend(isVisible: true,
                                  toggleSeriesVisibility: true,
                                  position: LegendPosition.bottom
                              ),

                              series: <CircularSeries>[
                                // Render pie chart
                                DoughnutSeries<MonthlyDataModel, String>(
                                    dataSource: monthlyData,
                                    //pointColorMapper:(MonthlyDataModel data,  _) => data.color,
                                    xValueMapper: (MonthlyDataModel data, _) => data.monthName,
                                    yValueMapper: (MonthlyDataModel data, _) => data.saleAmount,

                                    // Segments will explode on tap
                                    explode: true,
                                    // First segment will be exploded on initial rendering
                                    explodeIndex: 1,
                                    dataLabelSettings: DataLabelSettings(
                                        textStyle: TextStyle(fontFamily: "Poppins-Regular",fontSize: 12,),
                                        // Renders the data label
                                        isVisible: true,
                                        labelPosition: ChartDataLabelPosition.outside,
                                        labelIntersectAction: LabelIntersectAction.shift,
                                        connectorLineSettings: ConnectorLineSettings(
                                            type: ConnectorType.curve, length: '1%'),
                                        useSeriesColor: true

                                    )
                                )
                              ]
                          ):
                          Column(
                            children: [
                              Lottie.asset("assets/animations/no_graph.json",height:200),
                              Text("We are unable to make a graph as there is no data available",style:TextStyle(fontFamily: 'Poppins-Regular',fontSize:16,color:greenBasic),textAlign:TextAlign.center)
                            ],),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20,),
            ],
          ),
        ),
      ),
    );
  }
 /*Container(
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
                color: black.withOpacity(0.25),
                blurRadius: 4
            )
          ]
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(FeatherIcons.user,color: greenBasic,),
                    SizedBox(width: 10,),
                    Text("Employee Name:",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 12,color: greenBasic,))
                  ],
                ),
                Text(data![index].empName.toString(),style: TextStyle(fontFamily: 'Poppins-Medium',fontSize: 12))
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(FeatherIcons.phone,color: greenBasic,),
                    SizedBox(width: 10,),
                    Text("Contact:",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 12,color: greenBasic,))
                  ],
                ),
                Text(data[index].contactNo.toString(),style: TextStyle(fontFamily: 'Poppins-Medium',fontSize: 12))
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(FeatherIcons.clipboard,color: greenBasic,),
                    SizedBox(width: 10,),
                    Text("Attendance Type:",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 12,color: greenBasic,))
                  ],
                ),
                Text(data[index].type.toString(),style: TextStyle(fontFamily: 'Poppins-Medium',fontSize: 12))
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(FeatherIcons.clock,color: greenBasic,),
                    SizedBox(width: 10,),
                    Text("Check In Date/Time:",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 12,color: greenBasic,))
                  ],
                ),
                Text(data[index].checkInDateTime.toString(),style: TextStyle(fontFamily: 'Poppins-Medium',fontSize: 12))
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: (){
                    AppRoutes.push(context, PageTransitionType.fade, MapViewer(lat:data[index].lat.toString() ,lng:data[index].long.toString() ,location: data[index].location.toString(),empContact: data[index].contactNo.toString(),empName:data[index].empName.toString() ,checkTime: data[index].checkInDateTime.toString(),));
                  },
                  child: Container(
                    width: 130,
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                              color: black.withOpacity(0.25),
                              blurRadius: 4
                          )
                        ]
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(FeatherIcons.mapPin,color: greenBasic,),
                        SizedBox(height: 5),
                        Text("Map Location",style: TextStyle(fontSize: 12,fontFamily: 'Poppins-Regular'),),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap:isStoreLoading? (){}:(){
                    if(mounted){
                      setState(() {
                        selectedIndex =index;
                        isStoreLoading = true;
                      });
                    }
                    getDashboardStoreAttendance(data[index].empId);
                  },
                  child: Container(
                    width: 130,
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                              color: black.withOpacity(0.25),
                              blurRadius: 4
                          )
                        ]
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        selectedIndex==index?isStoreLoading?
                        Center(child: SizedBox(
                            width: 20,height: 20,
                            child: CircularProgressIndicator(color: greenBasic)))
                            :Icon(
                          FeatherIcons.info,color: greenBasic,
                        ):Icon(FeatherIcons.info,color: greenBasic,),
                        SizedBox(height: 5),
                        Text("Store Information",style: TextStyle(fontSize: 12,fontFamily: 'Poppins-Regular'),),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: (){
                    AppRoutes.push(context, PageTransitionType.fade, PdfViewer(empID: data[index].empId.toString(),isStore: false,));
                  },
                  child: Container(
                    width: 130,
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                              color: black.withOpacity(0.25),
                              blurRadius: 4
                          )
                        ]
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset("assets/icons/pdf.png",width: 25,height: 25,color: greenBasic,),
                        SizedBox(height: 5),
                        Text("Attendance",style: TextStyle(fontSize: 12,fontFamily: 'Poppins-Regular'),),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: (){
                    AppRoutes.push(context, PageTransitionType.fade, PdfViewer(empID: data[index].empId.toString(),isStore: true,));
                  },
                  child: Container(
                    width: 130,
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                              color: black.withOpacity(0.25),
                              blurRadius: 4
                          )
                        ]
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset("assets/icons/pdf.png",width: 25,height: 25,color: greenBasic,),
                        SizedBox(height: 5),
                        Text("Store Attendance",style: TextStyle(fontSize: 12,fontFamily: 'Poppins-Regular'),),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )*/

  Widget buildAttendanceCard({
    required EmpAttendance items,
    required int index,
  }) {
    return Container(
      margin: EdgeInsets.only(left: 5,top: 10,bottom: 10),
      decoration: BoxDecoration(
          color: white,
          border: Border.all(color: items.type.toString()=="Absent"? absentColor:items.type.toString()=="Present"? presentColor:weeklyColor),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: black.withOpacity(0.25),
                blurRadius: 4
            )
          ]
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Column(

          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(

                    children: [
                      Icon(FeatherIcons.user,color: greenBasic,),
                      SizedBox(width: 10,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Name:",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 12,color: greenBasic,)),
                          SizedBox(
                              width: MediaQuery.of(context).size.width*0.4,
                              child: Text(items.empName.toString(),style: TextStyle(fontFamily: 'Poppins-Medium',fontSize: 12)))

                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  width: 110,
                  height: 30,
                  decoration: BoxDecoration(
                      color:items.type.toString()=="Absent"? absentColor:items.type.toString()=="Present"? presentColor:weeklyColor,
                    boxShadow: [
                      BoxShadow(
                        color: black.withOpacity(0.25),
                        blurRadius: 4
                      )
                    ],
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(10),bottomLeft: Radius.circular(10))
                  ),
                  child: Center(child: Text(items.type.toString().trim(),style: TextStyle(fontFamily: 'Poppins-Regular',color: white,fontSize: 12))),
                )
               ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    children: [
                      Icon(FeatherIcons.phone,color: greenBasic,),
                      SizedBox(width: 10,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Contact:",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 12,color: greenBasic)),
                          Text(items.contactNo.toString(),style: TextStyle(fontFamily: 'Poppins-Medium',fontSize: 12))
                        ],
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Row(
                    children: [
                      Icon(FeatherIcons.clock,color: greenBasic,),
                      SizedBox(width: 10,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Check In Date/Time:",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 12,color: greenBasic,)),
                          Text(items.checkInDateTime.toString(),style: TextStyle(fontFamily: 'Poppins-Medium',fontSize: 12))

                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              width: MediaQuery.of(context).size.width,

              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(10),bottomLeft: Radius.circular(10))
              ),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(FeatherIcons.info,color: greenBasic,size: 20,),
                      SizedBox(width: 10),
                      Text("More Information",style: TextStyle(fontFamily: 'Poppins-SemiBold',color: greenBasic,fontSize: 14)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: (){
                          AppRoutes.push(context, PageTransitionType.fade, MapViewer(lat:items.lat.toString() ,lng:items.long.toString() ,location: items.location.toString(),empContact: items.contactNo.toString(),empName:items.empName.toString() ,checkTime: items.checkInDateTime.toString(),));
                        },
                        child: Container(
                          width: 130,
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: white,
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                    color: black.withOpacity(0.25),
                                    blurRadius: 4
                                )
                              ]
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(FeatherIcons.mapPin,color: greenBasic,),
                              SizedBox(height: 5),
                              Text("Map Location",style: TextStyle(fontSize: 12,fontFamily: 'Poppins-Medium'),),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap:isStoreLoading? (){}:(){
                          if(mounted){
                            setState(() {
                              selectedIndex =index;
                              isStoreLoading = true;
                            });
                          }
                          getDashboardStoreAttendance(items.empId);
                        },
                        child: Container(
                          width: 130,
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: white,
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                    color: black.withOpacity(0.25),
                                    blurRadius: 4
                                )
                              ]
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              selectedIndex==index?isStoreLoading?
                              Center(child: SizedBox(
                                  width: 20,height: 20,
                                  child: CircularProgressIndicator(color: greenBasic)))
                                  :Icon(
                                FeatherIcons.info,color: greenBasic,
                              ):Icon(FeatherIcons.info,color: greenBasic,),
                              SizedBox(height: 5),
                              Text("Store Information",style: TextStyle(fontSize: 12,fontFamily: 'Poppins-Medium'),),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: (){
                          AppRoutes.push(context, PageTransitionType.fade, PdfViewer(empID: items.empId.toString(),isStore: false,));
                        },
                        child: Container(
                          width: 130,
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: white,
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                    color: black.withOpacity(0.25),
                                    blurRadius: 4
                                )
                              ]
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image.asset("assets/icons/pdf.png",width: 25,height: 25,color: greenBasic,),
                              SizedBox(height: 5),
                              Text("Attendance",style: TextStyle(fontSize: 12,fontFamily: 'Poppins-Medium'),),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          AppRoutes.push(context, PageTransitionType.fade, PdfViewer(empID: items.empId.toString(),isStore: true,));
                        },
                        child: Container(
                          width: 130,
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: white,
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                    color: black.withOpacity(0.25),
                                    blurRadius: 4
                                )
                              ]
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image.asset("assets/icons/pdf.png",width: 25,height: 25,color: greenBasic,),
                              SizedBox(height: 5),
                              Text("Store Attendance",style: TextStyle(fontSize: 12,fontFamily: 'Poppins-Medium'),),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  //SHOW STORE INFO DIALOG
  showStoreDialog(BuildContext context,StoreAttendance storeAttendance){
    return showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            elevation: 10,
            insetPadding: const EdgeInsets.all(20),
            backgroundColor: white,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DelayedDisplay(
                      delay: initialDelay,
                      child: Align(
                        alignment: Alignment.center,
                        child: Text("Store Attendance",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 18,color: greenBasic)),
                      ),
                    ),
                    SizedBox(height: 10),
                    DelayedDisplay(
                      delay: Duration(
                          milliseconds: initialDelay.inMilliseconds + 100),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(FeatherIcons.home),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text("Store Name: ",style: TextStyle(fontSize: 12,fontFamily: 'Poppins-Medium',color: black)),
                              SizedBox(height: 2),
                              SizedBox(
                                  width: MediaQuery.of(context).size.width*0.6,
                                  child: Text(storeAttendance.storeName.toString(),style: TextStyle(fontSize: 12,fontFamily: 'Poppins-Regular',color: black)))
                            ],
                          ),

                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    DelayedDisplay(
                      delay: Duration(
                          milliseconds: initialDelay.inMilliseconds + 100),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(FeatherIcons.calendar),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text("StoreInDate: ",style: TextStyle(fontSize: 12,fontFamily: 'Poppins-Medium',color: black)),
                              SizedBox(height: 2),
                              Text(storeAttendance.storeInDate.toString()=="null"?"N/A":DateFormat("yyyy-MM-dd kk:mm:ss").format(storeAttendance.storeInDate!).toString(),style: TextStyle(fontSize: 12,fontFamily: 'Poppins-Regular',color: black))
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    DelayedDisplay(
                      delay: Duration(
                          milliseconds: initialDelay.inMilliseconds + 200),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(FeatherIcons.calendar),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text("StoreOutDate: ",style: TextStyle(fontSize: 12,fontFamily: 'Poppins-Medium',color: black)),
                              SizedBox(height: 2),
                              Text(storeAttendance.storeOutDate.toString()=="null"?"N/A":DateFormat("yyyy-MM-dd kk:mm:ss").format(DateTime.parse(storeAttendance.storeOutDate!)).toString(),style: TextStyle(fontSize: 12,fontFamily: 'Poppins-Regular',color: black))
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    DelayedDisplay(
                      delay: Duration(
                          milliseconds: initialDelay.inMilliseconds + 200),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(FeatherIcons.clock),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text("WorkingMin: ",style: TextStyle(fontSize: 12,fontFamily: 'Poppins-Medium',color: black)),
                              SizedBox(height: 2),
                              Text(storeAttendance.workingMin.toString()=="null"?"N/A":storeAttendance.workingMin.toString(),style: TextStyle(fontSize: 12,fontFamily: 'Poppins-Regular',color: black))
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    DelayedDisplay(
                      delay: Duration(
                          milliseconds: initialDelay.inMilliseconds + 300),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(FeatherIcons.map),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text("Location: ",style: TextStyle(fontSize: 12,fontFamily: 'Poppins-Medium',color: black)),
                              SizedBox(height: 2),
                              SizedBox(
                                  width: MediaQuery.of(context).size.width*0.6,
                                  child: Text(storeAttendance.location.toString(),style: TextStyle(fontSize: 12,fontFamily: 'Poppins-Regular',color: black)))
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          );
        });
  }

  //SHOW EMPTY DIALOG
  showEmptyDialog(BuildContext context){
    return showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            elevation: 10,
            insetPadding: const EdgeInsets.all(20),
            backgroundColor: white,
            child: Container(
              height: 300,
              child: DelayedDisplay(
                delay: initialDelay,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Lottie.asset("assets/animations/no_store_info.json",height: 200),
                      SizedBox(height: 10),
                      Text("No Store Attendance Found",style: TextStyle(fontFamily:'Poppins-Medium',fontSize: 18),)
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  //SHOW BUTTONS DIALOG
  showButtonsDialog(BuildContext context,EmpAttendance items,int index){
    return showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            elevation: 10,
            insetPadding: const EdgeInsets.all(20),
            backgroundColor: white,
            child: Container(
              height: 280,
              child: DelayedDisplay(
                delay: initialDelay,
                child: SingleChildScrollView(
                  child: StatefulBuilder(
                    builder: (context,setter){
                      return Column(
                        children: [
                          SizedBox(height: 30),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Row(

                                  children: [
                                    Icon(FeatherIcons.user,color: greenBasic,),
                                    SizedBox(width: 10,),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Name:",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 12,color: greenBasic,)),
                                        SizedBox(
                                            width: MediaQuery.of(context).size.width*0.5,
                                            child: Text(items.empName.toString(),style: TextStyle(fontFamily: 'Poppins-Medium',fontSize: 12)))

                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                width: 110,
                                height: 30,
                                decoration: BoxDecoration(
                                    color:items.type.toString()=="Absent"? absentColor:items.type.toString()=="Present"? presentColor:weeklyColor,
                                    boxShadow: [
                                      BoxShadow(
                                          color: black.withOpacity(0.25),
                                          blurRadius: 4
                                      )
                                    ],
                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(10),bottomLeft: Radius.circular(10))
                                ),
                                child: Center(child: Text(items.type.toString(),style: TextStyle(fontFamily: 'Poppins-Regular',color: white,fontSize: 12))),
                              )
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              InkWell(
                                onTap: (){
                                  AppRoutes.pop(context);
                                  AppRoutes.push(context, PageTransitionType.fade, MapViewer(lat:items.lat.toString() ,lng:items.long.toString() ,location: items.location.toString(),empContact: items.contactNo.toString(),empName:items.empName.toString() ,checkTime: items.checkInDateTime.toString(),));
                                },
                                child: Container(
                                  width: 130,
                                  margin: EdgeInsets.all(10),
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: white,
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: [
                                        BoxShadow(
                                            color: black.withOpacity(0.25),
                                            blurRadius: 4
                                        )
                                      ]
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(FeatherIcons.mapPin,color: greenBasic,),
                                      SizedBox(height: 5),
                                      Text("Map Location",style: TextStyle(fontSize: 12,fontFamily: 'Poppins-Medium'),),
                                    ],
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap:isStoreLoading? (){}:(){
                                  if(mounted){
                                    setter(() {
                                      selectedIndex =index;
                                      isStoreLoading = true;
                                    });
                                  }
                                  getDashboardStoreAttendance(items.empId);
                                },
                                child: Container(
                                  width: 130,
                                  margin: EdgeInsets.all(10),
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: white,
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: [
                                        BoxShadow(
                                            color: black.withOpacity(0.25),
                                            blurRadius: 4
                                        )
                                      ]
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      selectedIndex==index?isStoreLoading?
                                      Center(child: SizedBox(
                                          width: 20,height: 20,
                                          child: CircularProgressIndicator(color: greenBasic)))
                                          :Icon(
                                        FeatherIcons.info,color: greenBasic,
                                      ):Icon(FeatherIcons.info,color: greenBasic,),
                                      SizedBox(height: 5),
                                      Text("Store Information",style: TextStyle(fontSize: 12,fontFamily: 'Poppins-Medium'),),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              InkWell(
                                onTap: (){
                                  AppRoutes.pop(context);
                                  AppRoutes.push(context, PageTransitionType.fade, PdfViewer(empID: items.empId.toString(),isStore: false,));
                                },
                                child: Container(
                                  width: 130,
                                  margin: EdgeInsets.all(10),
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: white,
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: [
                                        BoxShadow(
                                            color: black.withOpacity(0.25),
                                            blurRadius: 4
                                        )
                                      ]
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Image.asset("assets/icons/pdf.png",width: 25,height: 25,color: greenBasic,),
                                      SizedBox(height: 5),
                                      Text("Attendance",style: TextStyle(fontSize: 12,fontFamily: 'Poppins-Medium'),),
                                    ],
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: (){
                                  AppRoutes.pop(context);
                                  AppRoutes.push(context, PageTransitionType.fade, PdfViewer(empID: items.empId.toString(),isStore: true,));
                                },
                                child: Container(
                                  width: 130,
                                  margin: EdgeInsets.all(10),
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: white,
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: [
                                        BoxShadow(
                                            color: black.withOpacity(0.25),
                                            blurRadius: 4
                                        )
                                      ]
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Image.asset("assets/icons/pdf.png",width: 25,height: 25,color: greenBasic,),
                                      SizedBox(height: 5),
                                      Text("Store Attendance",style: TextStyle(fontSize: 12,fontFamily: 'Poppins-Medium'),),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        });
  }

}

