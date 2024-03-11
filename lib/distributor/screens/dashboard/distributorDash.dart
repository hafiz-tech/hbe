// ignore_for_file: must_be_immutable
import 'dart:convert';

import 'dart:developer';
import 'dart:io';
import 'package:hbe/distributor/screens/attendance/mark_attendance/mark_attendance.dart';
import 'package:hbe/enums/globals.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:http/http.dart' as http;
import 'package:hbe/utils/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../models/menu_items_model.dart';
import '../../../models/monthly_model.dart';
import '../../../models/today_shop_visit_model.dart';
import '../../../models/weekly_model.dart';
import '../../../service/api_urls.dart';
import '../../../utils/toast_utils.dart';
import '../../widgets/distributorDrawer.dart';

class DistributorDashboard extends StatefulWidget {
  bool hit;
  DistributorDashboard({Key? key,required this.hit}) : super(key: key);

  @override
  State<DistributorDashboard> createState() => _DistributorDashboardState();
}

class _DistributorDashboardState extends State<DistributorDashboard> {
  bool isLoading = true;
  bool showOther = false;
  bool  noInternet = false;

  final Duration initialDelay = const Duration(milliseconds: 100);

  String totalShops = "0";
  String todayShop = "0";
  String todayVisit = "0";
  String remaining = "0";

  TooltipBehavior? tooltipBehavior1;
  TooltipBehavior? tooltipBehavior2;
  Future<List<TodayShopVisitModel>>? shopVisits;
  List<WeeklyDataModel> weeklyData=[];
  List<MonthlyDataModel> monthlyData=[];

  @override
  void initState(){
    super.initState();
    tooltipBehavior1 = TooltipBehavior(enable: true);
    tooltipBehavior2 = TooltipBehavior(enable: true);
    getAllData();
  }

  getAllData() async{
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
        globalData.userTypeName = prefs.getString("userTypeName");
      });
    }
    getDashboardCount();
    if(widget.hit){
      getMenuItems();
      getUserLoc(userID.toString(),"update",setState);
    }

  }

  Future<void> apiData(userID) async{

    final response = await http.post(
      Uri.parse('${ApiUrls.distributorUrl}${ApiUrls.updateUserLocation2}?UserID=$userID&Lat=$lat&Long=$lng&Location=$address'),
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

  //GET MENU ITEMS API
  Future<void> getMenuItems() async{
    try {

      var response = await http.get(
        Uri.parse('${ApiUrls.distributorUrl}${ApiUrls.getMenuList2}?UserID=$userID'),
        headers: {
          ApiUrls.key_name: ApiUrls.apikey,
          "Content-Type": "application/json; charset=utf-8"
        },
      );



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

  //GET DASHBOARD SHOP COUNT API
  Future<void> getDashboardCount() async {
    try {

      var response = await http.get(
        Uri.parse('${ApiUrls.distributorUrl}${ApiUrls.getDashBoardShopCount}?LoginUserID=$userID'),
        headers: {
          ApiUrls.key_name: ApiUrls.apikey,
          "Content-Type": "application/json; charset=utf-8"
        },
      );

      var res = jsonDecode(response.body);


      if (response.statusCode == 200) {

        if (mounted) {
          setState(() {
            shopVisits = getShopVisits();
            getWeeklyData();
            totalShops = res["TotalShop"].toString();
            todayShop = res["TodayShop"].toString();
            todayVisit = res["TodayVisit"].toString();
            remaining = res["Remaining"].toString();
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

  //GET DASHBOARD SHOP VISIT API
  Future<List<TodayShopVisitModel>> getShopVisits() async {

    try {
      final response = await http.get(
          Uri.parse('${ApiUrls.distributorUrl}${ApiUrls.getTodayShopVisit}?LoginUserID=$userID'),
          headers: {
            ApiUrls.key_name: ApiUrls.apikey,
          });

      List<dynamic> data = json.decode(response.body);
      if (response.statusCode == 200 && data.toString() != "[]") {

        return data.map((data) => TodayShopVisitModel.fromJson(data)).toList();
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

  //GET WEEKLY DATA  API
  Future<void> getWeeklyData() async {

    try {
      final response = await http.get(
          Uri.parse('${ApiUrls.distributorUrl}${ApiUrls.getWeeklyGraph2}?LoginUserID=$userID'),
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

        // if(mounted) {
        //   setState(() {
        //     isLoading = false;
        //   });
        // }

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

  //GET MONTHLY DATA  API
  Future<void> getMonthlyData() async {

    try {
      final response = await http.get(
          Uri.parse('${ApiUrls.distributorUrl}${ApiUrls.getMonthlyGraph2}?LoginUserID=$userID'),
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

  //GET USER LOCATION
  getUserLoc(String customerId, String from,StateSetter setter) async{
    await geo.Geolocator.getCurrentPosition(desiredAccuracy: geo.LocationAccuracy.high)
        .then((geo.Position position) async {

      await _getAddress(position.latitude,position.longitude,customerId,from,setter);
    }).catchError((e) {

    });

  }

  var address="", lat=0.0, lng=0.0;
  _getAddress(var ulat,var ulng,String customerId,String from,StateSetter setter) async {
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

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    weeklyData.clear();
    monthlyData.clear();
    data2.clear();
  }

  TextEditingController searchController = TextEditingController();

  List<TodayShopVisitModel> data2=[];

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  Future<void> _refresh() {
    if(mounted){
      setState(() {
        isLoading=true;
      });
    }
    return getAllData().then((user) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      drawer: const DistributorDrawer(),
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(20),
              bottomLeft:  Radius.circular(20),
            )
        ),
        backgroundColor: greenBasic,
        title: const Text("Distributor Dashboard",style: TextStyle(fontFamily: "Poppins-Medium",fontSize: 16),),
        centerTitle: true,
       
      ),
      resizeToAvoidBottomInset: false,
      body: isLoading?
      Center(
        child:   Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: Lottie.asset("assets/animations/loading.json",height: 200),),
          ],
        ),
      )
      :RefreshIndicator( onRefresh: _refresh,
      key: _refreshIndicatorKey,
      color: greenBasic,
      child: SingleChildScrollView(
        child:Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              DelayedDisplay(
                delay: initialDelay,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width*0.4,
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(10),
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
                              const Text("Total Shops",style: TextStyle(fontSize: 12,fontFamily: 'Poppins-Regular'),),
                              SvgPicture.asset("assets/icons/totalShops.svg",height: 30,),
                            ],
                          ),
                          Text(totalShops.toString(),style: const TextStyle(fontSize: 25,fontFamily: 'Poppins-Bold'))
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width*0.4,
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(10),
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
                              const Text("Today Shops",style: TextStyle(fontSize: 12,fontFamily: 'Poppins-Regular'),),
                              SvgPicture.asset("assets/icons/todayVisit.svg",height: 30,),
                            ],
                          ),
                          Text(todayShop.toString(),style: const TextStyle(fontSize: 25,fontFamily: 'Poppins-Bold'))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              DelayedDisplay(
                delay: Duration(
                    milliseconds: initialDelay.inMilliseconds + 100),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width*0.4,
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(10),
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
                              const Text("Today Visits",style: TextStyle(fontSize: 12,fontFamily: 'Poppins-Regular'),),
                              SvgPicture.asset("assets/icons/visits.svg",height: 30,),
                            ],
                          ),
                          Text(todayVisit.toString(),style: const TextStyle(fontSize: 25,fontFamily: 'Poppins-Bold'))
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width*0.4,
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(10),
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
                              const Text("Remaining",style: TextStyle(fontSize: 12,fontFamily: 'Poppins-Regular'),),
                              SvgPicture.asset("assets/icons/remain.svg",height: 30,),
                            ],
                          ),
                          Text(remaining.toString(),style: const TextStyle(fontSize: 25,fontFamily: 'Poppins-Bold'))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20,),
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
                              const Text("Weekly Sales",style: TextStyle(fontSize: 18,fontFamily: 'Poppins-SemiBold',color: greenBasic),),
                              Image.asset("assets/images/weeklySales.png",width: 40,height: 40,color: greenBasic,)
                            ],
                          ),
                        ),
                        const SizedBox(height: 10,),
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
                              const Text("We are unable to make a graph as there is no data available",style:TextStyle(fontFamily: 'Poppins-Regular',fontSize:16,color:greenBasic),textAlign:TextAlign.center)
                            ],),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20,),
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
                              const Text("Shop Visits",style: TextStyle(fontSize: 18,fontFamily: 'Poppins-SemiBold',color: greenBasic),),
                              SvgPicture.asset("assets/icons/visits.svg",width: 40,height: 40,color: greenBasic,)
                            ],
                          ),
                        ),
                        const SizedBox(height: 10,),
                        DelayedDisplay(
                          delay: Duration(
                              milliseconds: initialDelay.inMilliseconds + 700),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height*0.5,
                            child:noInternet?Center(
                              child: Column(
                                children: [
                                  Lottie.asset("assets/animations/nothingFound.json",height: 300),
                                  const Text("No Internet Connection",style: TextStyle(fontFamily:'Poppins-SemiBold',fontSize: 20),)
                                ],
                              ),
                            ):showOther?
                            Center(
                              child: Column(
                                children: [
                                  Lottie.asset("assets/animations/nothingFound.json",height: 300),
                                  const Text("No Attendance Found",style: TextStyle(fontFamily:'Poppins-SemiBold',fontSize: 20),)
                                ],
                              ),
                            )
                                : FutureBuilder<List<TodayShopVisitModel>>(
                              future: shopVisits,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  List<TodayShopVisitModel>? data = snapshot.data;
                                  return DelayedDisplay(
                                    delay: Duration(
                                        milliseconds: initialDelay.inMilliseconds + 800),
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 40,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10.0),
                                            color:  greenBasic.withOpacity(0.2),
                                          ),
                                          child: TextField(
                                            onChanged: (value){
                                              if(mounted){
                                                setState(() {
                                                  data2 = data!.where((data) => data.customerName.toString().toLowerCase().contains(searchController.text.toString().toLowerCase())).toList();
                                                });
                                              }

                                            },
                                            controller: searchController,

                                            cursorColor: Colors.white70,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: greenBasic,
                                              fontFamily: 'Poppins-Regular',
                                            ),
                                            decoration: InputDecoration(
                                                suffixIcon: searchController.text.isEmpty
                                                    ? const Icon(
                                                  FeatherIcons.search,
                                                  color: greenBasic,
                                                  size: 20,
                                                )
                                                    : GestureDetector(
                                                  onTap: () {
                                                    if(mounted)
                                                      setState(() {
                                                        searchController.text = "";
                                                      });
                                                  },
                                                  child: const Icon(
                                                    FeatherIcons.trash,
                                                    size: 20,
                                                    color: greenBasic,
                                                  ),
                                                ),
                                                contentPadding: const EdgeInsets.only(left: 10,top: 8,bottom: 0),
                                                hintText: 'Search Visit',
                                                hintStyle: const TextStyle(
                                                  fontFamily: 'Poppins-Regular',
                                                  fontSize: 12,
                                                  color: greenBasic,
                                                ),
                                                border: InputBorder.none),
                                          ),
                                        ),
                                        Expanded(
                                          child:searchController.text.isEmpty? ListView.builder(
                                            shrinkWrap: true,
                                            physics: const BouncingScrollPhysics(),
                                            itemBuilder: (context,index){
                                              return buildShopCard(items: data![index], index: index + 1);
                                            },itemCount: data!.length,):
                                          data2.isEmpty? Center(
                                            child: Column(
                                              children: [
                                                Lottie.asset("assets/animations/no_store_info.json",height: 250),
                                                const Text("No Search Results Found",style: TextStyle(fontFamily:'Poppins-SemiBold',fontSize: 18),)
                                              ],
                                            ),
                                          ): ListView.builder(
                                            shrinkWrap: true,
                                            physics: const BouncingScrollPhysics(),
                                            itemBuilder: (context,index){

                                              return buildShopCard(items: data2[index], index: index + 1);
                                            },itemCount: data2.length,),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                else if (snapshot.hasError) {
                                  return Center(
                                    child: Column(
                                      children: [
                                        Lottie.asset("assets/animations/no_store_info.json",height: 300),
                                        Text(snapshot.error .toString(),style: const TextStyle(fontFamily:'Poppins-SemiBold',fontSize: 20),)
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
              const SizedBox(height: 20,),
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
                              const Text("Monthly Sales",style: TextStyle(fontSize: 18,fontFamily: 'Poppins-SemiBold',color: greenBasic),),
                              Image.asset("assets/images/dailySale.png",width: 40,height: 40,color: greenBasic,)
                            ],
                          ),
                        ),
                        const SizedBox(height: 10,),
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
                                    dataLabelSettings: const DataLabelSettings(
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
                              const Text("We are unable to make a graph as there is no data available",style:TextStyle(fontFamily: 'Poppins-Regular',fontSize:16,color:greenBasic),textAlign:TextAlign.center)
                            ],),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20,),
            ],
          ),
        ),
      ))
    );
  }

  var selectedIndex;
  Widget buildShopCard({
    required TodayShopVisitModel items,
    required int index,
  }) {
    return items.customerId.toString()=="0"?
    Center(
      child: Column(
        children: [
          Lottie.asset("assets/animations/no_store_info.json",height: 250),
          const Text("No Shop Visits Found",style: TextStyle(fontFamily:'Poppins-SemiBold',fontSize: 18),)
        ],
      ),
    )
        :Container(
      margin: const EdgeInsets.only(left: 5,top: 10,bottom: 10),
      decoration: BoxDecoration(
          color: white,
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
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(

                    children: [
                      const Icon(FeatherIcons.user,color: greenBasic,),
                      const SizedBox(width: 10,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Name:",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 12,color: greenBasic,)),
                          SizedBox(
                              width: MediaQuery.of(context).size.width*0.4,
                              child: Text(items.customerName.toString(),style: const TextStyle(fontFamily: 'Poppins-Medium',fontSize: 12)))

                        ],
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    children: [
                      const Icon(FeatherIcons.phone,color: greenBasic,),
                      const SizedBox(width: 10,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Contact:",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 12,color: greenBasic)),
                          Text(items.mobile.toString(),style: const TextStyle(fontFamily: 'Poppins-Medium',fontSize: 12))
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(

                    children: [
                      const Icon(FeatherIcons.home,color: greenBasic,),
                      const SizedBox(width: 10,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("City:",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 12,color: greenBasic,)),
                          SizedBox(
                              width: MediaQuery.of(context).size.width*0.4,
                              child: Text(items.cityName.toString(),style: const TextStyle(fontFamily: 'Poppins-Medium',fontSize: 12)))

                        ],
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    children: [
                      const Icon(FeatherIcons.mapPin,color: greenBasic,),
                      const SizedBox(width: 10,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Area:",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 12,color: greenBasic)),
                          SizedBox(
                              width: MediaQuery.of(context).size.width*0.2,
                              child: Text(items.area.toString(),style: const TextStyle(fontFamily: 'Poppins-Medium',fontSize: 12),overflow: TextOverflow.ellipsis,))
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(

                children: [
                  const Icon(FeatherIcons.map,color: greenBasic,),
                  const SizedBox(width: 10,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Address:",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 12,color: greenBasic,)),
                      SizedBox(
                          width: MediaQuery.of(context).size.width*0.7,
                          child: Text(items.address.toString(),style: const TextStyle(fontFamily: 'Poppins-Medium',fontSize: 12)))

                    ],
                  )
                ],
              ),
            ),
            InkWell(onTap:() async{
              await Navigator.push(
                context,
                PageTransition(
                    type: PageTransitionType.fade,
                    child: DistributorMarkAttendance(from: true,customerId: items.customerId.toString())),
              ).then((value) {
                if(mounted) {
                  setState(() {
                    data2.clear();
                    searchController.text="";
                    getDashboardCount();
                    shopVisits = getShopVisits();
                  });
                }
              });

            },
            child: Container(
              width: 120,
              height: 40,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: greenBasic,
                borderRadius: BorderRadius.circular(10)
              ),
              child: const Center(
                child:Text("Update Visit",style: TextStyle(fontFamily: "Poppins-Medium",fontSize: 14,color: white)),
              ),
            ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
