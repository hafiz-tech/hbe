import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:hbe/distributor/screens/payment/add_payment_screen.dart';
import 'package:hbe/distributor/screens/payment/update_payment_screen.dart';
import 'package:hbe/enums/globals.dart';
import 'package:hbe/models/payment_model.dart';
import 'package:hbe/utils/color_constants.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import '../../../service/api_urls.dart';
import '../../../utils/toast_utils.dart';
import '../../../widgets/loading_animation.dart';
import '../../widgets/distributorDrawer.dart';
import 'package:http/http.dart' as http;

class DistributorPaymentScreen extends StatefulWidget {
  const DistributorPaymentScreen({Key? key}) : super(key: key);

  @override
  State<DistributorPaymentScreen> createState() => _DistributorPaymentScreenState();
}

class _DistributorPaymentScreenState extends State<DistributorPaymentScreen> {

  bool isLoading = true;
  bool showOther = false;
  Future<List<PaymentData>>? paymentData;
  final Duration initialDelay = const Duration(milliseconds: 100);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(mounted){
      setState(() {
        paymentData = getPaymentData();
      });
    }
  }
  //GET PAYMENT DATA BY USER_ID API
  Future<List<PaymentData>> getPaymentData() async {

    try {
      log('${ApiUrls.distributorUrl}${ApiUrls.getPaymentReceived}?UserID=${globalData.userId}');
      final response = await http.get(
          Uri.parse('${ApiUrls.distributorUrl}${ApiUrls.getPaymentReceived}?UserID=${globalData.userId}'),
          headers: {
            ApiUrls.key_name: ApiUrls.apikey,
          });
      Map<String, dynamic> jsonResponse = Map<String, dynamic>.from(json.decode(response.body));
      List<dynamic> data = jsonResponse["Table"];
      if (response.statusCode == 200 && data.toString() != "[]") {

        if(mounted) {
          setState(() {
            isLoading = false;
            showOther = false;
          });
        }
        return data.map((data) => PaymentData.fromJson(data)).toList();
      }
         else if (response.statusCode == 200  && data.toString() == "[]") {
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

  //DELETE SPECIFIC PAYMENT FROM LIST API
  Future<void> deletePayment(selectedID) async{
    try {
      final response = await http.post(
          Uri.parse('${ApiUrls.distributorUrl}${ApiUrls.deletePaymentReceived}?ID=$selectedID'),
          headers: {
            ApiUrls.key_name: ApiUrls.apikey,
          });

      var res = json.decode(response.body);
      log(res.toString());

      if (response.statusCode == 200 ) {
        ToastUtils.successToast("Removed Successfully", context);
        if(mounted) {
          setState(() {
            paymentData = getPaymentData();
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

  //POST SPECIFIC PAYMENT FROM LIST API
  Future<void> postPayment(selectedID) async{
    try {
      final response = await http.post(
          Uri.parse('${ApiUrls.distributorUrl}${ApiUrls.postPaymentReceived}?ID=$selectedID'),
          headers: {
            ApiUrls.key_name: ApiUrls.apikey,
          });

      var res = json.decode(response.body);
      log(res.toString());

      if (response.statusCode == 200 ) {
        ToastUtils.successToast("Posted Successfully", context);
        if(mounted) {
          setState(() {
            paymentData = getPaymentData();
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
        title: Text("Received Payment",style: TextStyle(fontFamily: "Poppins-Medium",fontSize: 16),),
        centerTitle: true,
      ),
      drawer: DistributorDrawer(),
      body: LoadingAnimation(
        inAsyncCall: isLoading,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child:showOther?
          Center(
            child: Column(
              children: [
                Lottie.asset("assets/animations/nothingFound.json",height: 300),
                Text("No Payment Data Found",style: TextStyle(fontFamily:'Poppins-SemiBold',fontSize: 20),)
              ],
            ),
          ): FutureBuilder<List<PaymentData>>(
            future: paymentData,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<PaymentData>? data = snapshot.data;
                return DelayedDisplay(
                  delay: Duration(
                      milliseconds: initialDelay.inMilliseconds + 100),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context,index){
                      return  buildListCard(context,data![index],() async{
                        await Navigator.push(
                          context,
                          PageTransition(type: PageTransitionType.fade, child: UpdatePaymentScreen(paymentData:data[index],)),
                        ).then((value) {
                          if(mounted){
                            setState(() {
                              isLoading = true;
                              paymentData = getPaymentData();
                            });
                          }
                        });
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
        onPressed: ()async{
          await Navigator.push(
            context,
            PageTransition(type: PageTransitionType.fade, child: AddPaymentScreen()),
          ).then((value) {
            if(mounted){
              setState(() {
                isLoading = true;
                paymentData = getPaymentData();
              });
            }
          });

        },
        child: Icon(FeatherIcons.plus,color: white,),
      ),
    );
  }

  Widget buildListCard(BuildContext context, PaymentData paymentData,onTap) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width*0.6,
                    child: Text(paymentData.customerName.toString(),style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 16,color: greenBasic),),
                  ),
                  Text("(${paymentData.paymentType.toString()})",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 14,color: greenBasic),),

                ]),
                Text("${paymentData.receivedAmount.toStringAsFixed(0)} PKR",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 16,color: black))
              ],
            ),
            paymentData.paymentType.toString()=="Bank"?
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(FeatherIcons.home,color: greenBasic,size: 20,),
                        SizedBox(width: 10,),
                        Text("Bank Name: ",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 14,color: greenBasic)),
                      ],
                    ),
                    Text(paymentData.bankName.toString()==""?"N/A":paymentData.bankName.toString(),style: TextStyle(fontFamily: 'Poppins-Regular',fontSize: 14,color: black)),
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(FeatherIcons.dollarSign,color: greenBasic,size: 20,),
                        SizedBox(width: 10,),
                        Text("TransType: ",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 14,color: greenBasic)),
                      ],
                    ),
                    Text(paymentData.transType.toString()==""?"N/A":paymentData.transType.toString(),style: TextStyle(fontFamily: 'Poppins-Regular',fontSize: 14,color: black)),
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(FeatherIcons.creditCard,color: greenBasic,size: 20,),
                        SizedBox(width: 10,),
                        Text("Cheque Number: ",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 14,color: greenBasic)),
                      ],
                    ),
                    Text(paymentData.chequeNo.toString()==""?"N/A":paymentData.chequeNo.toString(),style: TextStyle(fontFamily: 'Poppins-Regular',fontSize: 14,color: black)),
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(FeatherIcons.calendar,color: greenBasic,size: 20,),
                        SizedBox(width: 10,),
                        Text("Cheque Date: ",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 14,color: greenBasic)),
                      ],
                    ),
                    Text(paymentData.chequeDate.toString()==""?"N/A":DateFormat("yyyy-MM-dd").format(DateTime.parse(paymentData.chequeDate.toString())),style: TextStyle(fontFamily: 'Poppins-Regular',fontSize: 14,color: black)),
                  ],
                ),
              ],
            ):const SizedBox(),

            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_month,color: greenBasic,size: 20,),
                    SizedBox(width: 10),
                    Text("Received Date:",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 14,color: greenBasic)),

                  ],
                ),
                Text(DateFormat("yyyy-MM-dd").format(DateTime.parse(paymentData.receivedDate.toString())),style: TextStyle(fontFamily: 'Poppins-Medium',fontSize: 14,color: Colors.black)),
              ],
            ),
            SizedBox(height: 20,),
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
                    deletePayment(paymentData.id.toString());

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
                  onTap: onTap,
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
                    postPayment(paymentData.id.toString());

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
