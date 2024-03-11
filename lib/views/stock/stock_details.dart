import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:hbe/enums/globals.dart';
import 'package:hbe/views/stock/update_stock.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import '../../models/stock_detail_model.dart';
import '../../service/api_urls.dart';
import '../../utils/app_routes.dart';
import '../../utils/color_constants.dart';
import '../../utils/toast_utils.dart';
import '../../widgets/loading_animation.dart';
import '../../widgets/navDrawer.dart';
import '../sales/add_daily_sale.dart';

class StockDetails extends StatefulWidget {
  const StockDetails({Key? key}) : super(key: key);

  @override
  State<StockDetails> createState() => _StockDetailsState();
}

class _StockDetailsState extends State<StockDetails> {

  bool isLoading = true;
  bool showOther = false;
  Future<List<StockDetailsModel>>? stockDetail;
  final Duration initialDelay = const Duration(milliseconds: 100);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(mounted){
      setState(() {
        stockDetail = getStockDetails();
      });
    }
  }

  //GET DAILY SALE BY USER_ID API
  Future<List<StockDetailsModel>> getStockDetails() async {

    try {
      final response = await http.get(
          Uri.parse('${ApiUrls.baseURL}${ApiUrls.getStockDetails}?UserID=${globalData.userId}'),
          headers: {
            ApiUrls.key_name: ApiUrls.apikey,
          });

      List<dynamic> data = json.decode(response.body);
      if (response.statusCode == 200&& data[0]["StockNumber"].toString() != "null") {

        if(mounted) {
          setState(() {
            isLoading = false;
            showOther = false;
          });
        }
        return data.map((data) => StockDetailsModel.fromJson(data)).toList();
      }
      else if (response.statusCode == 200 && data[0]["StockNumber"].toString() == "null") {
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

  //DELETE SPECIFIC SALE FROM LIST API
  Future<void> deleteSale(selectedID) async{
    try {
      final response = await http.post(
          Uri.parse('${ApiUrls.baseURL}${ApiUrls.deleteStock}?StockID=$selectedID&UserID=${globalData.userId}'),
          headers: {
            ApiUrls.key_name: ApiUrls.apikey,
          });

      var res = json.decode(response.body);
      log(res.toString());

      if (response.statusCode == 200) {
        ToastUtils.successToast("Removed Successfully", context);
        if(mounted) {
          setState(() {
            stockDetail = getStockDetails();
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
          isLoading = false;
        });
      }
      ToastUtils.warningToast("No Internet Connection", context);
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

  //POST SPECIFIC SALE FROM LIST API
  Future<void> postSale(selectedID) async{
    try {
      final response = await http.post(
          Uri.parse('${ApiUrls.baseURL}${ApiUrls.postStock}?StockID=$selectedID&UserID=${globalData.userId}'),
          headers: {
            ApiUrls.key_name: ApiUrls.apikey,
          });

      var res = json.decode(response.body);
      log(res.toString());

      if (response.statusCode == 200 ) {
        ToastUtils.successToast("Posted Successfully", context);
        if(mounted) {
          setState(() {
            stockDetail = getStockDetails();
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
          isLoading = false;
        });
      }
      ToastUtils.warningToast("No Internet Connection", context);
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: greenBasic,
        title: Text("Manage Stock",style: TextStyle(fontFamily: "Poppins-Medium",fontSize: 16),),
        centerTitle: true,
      ),
      drawer: DrawerWidget(),
      body: LoadingAnimation(
        inAsyncCall: isLoading,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child:showOther?
          Center(
            child: Column(
              children: [
                Lottie.asset("assets/animations/nothingFound.json",height: 300),
                Text("No Stock Detail Found",style: TextStyle(fontFamily:'Poppins-SemiBold',fontSize: 20),)
              ],
            ),
          ): FutureBuilder<List<StockDetailsModel>>(
            future: stockDetail,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<StockDetailsModel>? data = snapshot.data;
                return DelayedDisplay(
                  delay: Duration(
                      milliseconds: initialDelay.inMilliseconds + 100),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context,index){
                      return  buildListCard(context,data![index],(){
                        AppRoutes.push(context, PageTransitionType.fade, UpdateStock(stockDetailsModel: data![index],index :data[index].producDetails.length));
                      });
                    },itemCount: data!.length,),
                );
              }
              else if (snapshot.hasError) {
                return Center(
                  child: Column(
                    children: [
                      Lottie.asset("assets/animations/nothingFound.json",height: 300),
                      Text("Something Went Wrong",style: TextStyle(fontFamily:'Poppins-SemiBold',fontSize: 20),)
                    ],
                  ),
                );
              }
              return Center();
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: greenBasic,
        onPressed: (){
          AppRoutes.push(context, PageTransitionType.fade, AddDailySale(isFromStock: true,));
        },
        child: Icon(FeatherIcons.plus,color: white,),
      ),
    );
  }

  Widget buildListCard(BuildContext context, StockDetailsModel stockDetailsModel,onTap) {
    return Container(
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
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: MediaQuery.of(context).size.width*0.8,
                child: Text(stockDetailsModel.cusCustomerName.toString(),style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 16,color: greenBasic),)),
            SizedBox(height: 10,),
            Row(
              children: [
                Icon(FeatherIcons.map,color: greenBasic,size: 20,),
                SizedBox(width: 10,),
                Text("Location:",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 14,color: greenBasic)),
              ],
            ),
            SizedBox(height: 5),
            Text(stockDetailsModel.cusAddress.toString(),style: TextStyle(fontFamily: 'Poppins-Regular',fontSize: 14,color: black)),
            SizedBox(height: 10,),
            Row(
              children: [
                Icon(Icons.calendar_month,color: greenBasic,size: 20,),
                SizedBox(width: 5),
                Text("Date:",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 14,color: greenBasic)),
                SizedBox(width: 10),
                Text(DateFormat("yyyy-MM-dd").format(DateTime.parse(stockDetailsModel.stockDate.toString())),style: TextStyle(fontFamily: 'Poppins-Medium',fontSize: 14,color: Colors.black)),
              ],
            ),
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: (){
                    if(mounted){
                      setState(() {
                        isLoading = true;
                      });
                    }
                    deleteSale(stockDetailsModel.stockId.toString());

                  },
                  child: Container(

                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          border: Border.all(color: greenBasic),
                          color: white,
                          boxShadow: [
                            BoxShadow(
                                color: black.withOpacity(0.2),
                                blurRadius: 3
                            )
                          ],
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.delete,color: greenBasic,
                            size: 18,
                          ),
                          SizedBox(width: 10,),
                          Text("Delete",style: TextStyle(
                              fontSize: 12,fontFamily: "Poppins-Medium",color: greenBasic
                          ),)

                        ],
                      )
                  ),
                ),
                InkWell(
                  onTap:onTap,
                  child: Container(

                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: greenBasic,
                          boxShadow: [
                            BoxShadow(
                                color: black.withOpacity(0.2),
                                blurRadius: 3
                            )
                          ],
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FeatherIcons.edit,color: white,
                            size: 18,
                          ),
                          SizedBox(width: 10,),
                          Text("Update",style: TextStyle(
                              fontSize: 12,fontFamily: "Poppins-Medium",color: white
                          ),)

                        ],
                      )
                  ),
                ),
                InkWell(
                  onTap: (){
                    if(mounted){
                      setState(() {
                        isLoading = true;
                      });
                    }
                    postSale(stockDetailsModel.stockId.toString());

                  },
                  child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: greenBasic,
                          boxShadow: [
                            BoxShadow(
                                color: black.withOpacity(0.2),
                                blurRadius: 3
                            )
                          ],
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FeatherIcons.checkCircle,color: white,
                            size: 18,
                          ),
                          SizedBox(width: 10,),
                          Text("Post",style: TextStyle(
                              fontSize: 12,fontFamily: "Poppins-Medium",color: white
                          ),)

                        ],
                      )
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
