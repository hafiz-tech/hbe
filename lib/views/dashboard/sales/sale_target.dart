// ignore_for_file: must_be_immutable

import 'dart:convert';
import 'dart:io';
import 'package:hbe/enums/globals.dart';
import 'package:hbe/widgets/loading_animation.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import '../../../service/api_urls.dart';
import '../../../utils/color_constants.dart';
import '../../../utils/toast_utils.dart';
import '../../../widgets/navDrawer.dart';

class SaleTarget extends StatefulWidget {
  bool fromTab;
  SaleTarget({Key? key,required this.fromTab}) : super(key: key);

  @override
  State<SaleTarget> createState() => _SaleTargetState();
}

class _SaleTargetState extends State<SaleTarget> {
  bool isLoading = true;
  bool showOther = true;
  bool noInternet = false;
  var data;
  final Duration initialDelay = const Duration(milliseconds: 100);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
   Future.delayed(const Duration(seconds: 2),(){ getSaleTarget();});
  }

  //GET SALE TARGET DATA  API
  Future<void> getSaleTarget() async {
    try {
      final response = await http.get(
          Uri.parse('${ApiUrls.baseURL}${ApiUrls.getSaleTargetDetails}?UserID=${globalData.userId}'),
          headers: {
            ApiUrls.key_name: ApiUrls.apikey,
          });

       var res = json.decode(response.body);

      if (response.statusCode == 200 ) {
        if(mounted) {
          setState(() {
            data = res;
            isLoading = false;
            showOther = false;
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
      ToastUtils.warningToast("No Internet Connection", context);
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

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        automaticallyImplyLeading:widget.fromTab? true:false,
        backgroundColor: greenBasic,
        title: const Text("Sale Target Detail",style: TextStyle(fontFamily: "Poppins-Medium",fontSize: 16),),
        centerTitle: true,
      ),
      drawer: widget.fromTab?const DrawerWidget():null,
      body: LoadingAnimation(
        inAsyncCall: isLoading,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: showOther?Center(child: Column(
              children: [
                Lottie.asset("assets/animations/no_data.json"),
                const SizedBox(height: 10),
                const Text("No Sale Target Detail Found",style: TextStyle(fontSize: 20,fontFamily: 'Poppins-SemiBold',color: black),)
              ],
            ),):
            Column(
              children: [
                const SizedBox(height: 10),
                DelayedDisplay(
                  delay: initialDelay,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 160,
                        padding: const EdgeInsets.all(10),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                              Icon(FeatherIcons.calendar,color: greenBasic,size: 20,),
                                SizedBox(width: 10),
                              Text("Date From",style: TextStyle(fontFamily: "Poppins-SemiBold",fontSize: 12,color: greenBasic),),
                            ]),
                            const SizedBox(height: 5),
                            Text(data["DateFrom"].toString()=="null"?"N/A":data["DateFrom"].toString(),style: const TextStyle(fontFamily: "Poppins-Regular",fontSize: 14,color: black)),
                          ],
                        ),
                      ),
                      Container(
                        width: 160,
                        padding: const EdgeInsets.all(10),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                                children: [
                                  Icon(FeatherIcons.calendar,color: greenBasic,size: 20,),
                                  SizedBox(width: 10),
                                  Text("Date To",style: TextStyle(fontFamily: "Poppins-SemiBold",fontSize: 12,color: greenBasic),),
                                ]),
                            const SizedBox(height: 5),
                            Text(data["DateTo"].toString()=="null"?"N/A":data["DateTo"].toString(),style: const TextStyle(fontFamily: "Poppins-Regular",fontSize: 14,color: black)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                    width: MediaQuery.of(context).size.width*0.7,
                    child: const Divider(color: greenBasic,thickness: 1.0,)),
                const SizedBox(height: 10),
                DelayedDisplay(
                  delay: Duration(
                      milliseconds: initialDelay.inMilliseconds + 100),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: 160,
                            padding: const EdgeInsets.all(10),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                    children: [
                                      Icon(FeatherIcons.target,color: greenBasic,size: 20,),
                                      SizedBox(width: 5),
                                      Text("Sale Target",style: TextStyle(fontFamily: "Poppins-SemiBold",fontSize: 12,color: greenBasic),),
                                    ]),
                                const SizedBox(height: 5),
                                Text(data["SaleTarget"].toString()=="null"?"N/A":data["SaleTarget"].toString(),style: const TextStyle(fontFamily: "Poppins-Regular",fontSize: 14,color: black)),
                                const SizedBox(height: 5),
                                Text(data["TotalDays"].toString()=="null"?"N/A":data["TotalDays"].toString(),style: const TextStyle(fontFamily: "Poppins-Regular",fontSize: 14,color: black)),
                              ],
                            ),
                          ),
                          Container(
                            width: 160,
                            padding: const EdgeInsets.all(10),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                    children: [
                                      Icon(FeatherIcons.target,color: greenBasic,size: 20,),
                                      SizedBox(width: 5),
                                      Text("Achieved Target",style: TextStyle(fontFamily: "Poppins-SemiBold",fontSize: 12,color: greenBasic),),
                                    ]),
                                const SizedBox(height: 5),
                                Text(data["AchieveTarget"].toString()=="null"?"N/A":data["AchieveTarget"].toString(),style: const TextStyle(fontFamily: "Poppins-Regular",fontSize: 14,color: black)),
                                const SizedBox(height: 5),
                                Text(data["PassedDays"].toString()=="null"?"N/A":data["PassedDays"].toString(),style: const TextStyle(fontFamily: "Poppins-Regular",fontSize: 14,color: black)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10,),
                      Container(
                      width: MediaQuery.of(context).size.width*0.91,
                        padding: const EdgeInsets.all(10),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                                children: [
                                  Icon(FeatherIcons.dollarSign,color: greenBasic,size: 20,),
                                  SizedBox(width: 5),
                                  Text("Remaining Target",style: TextStyle(fontFamily: "Poppins-SemiBold",fontSize: 12,color: greenBasic),),
                                ]),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(data["RemainingTarget"].toString()=="null"?"N/A":data["RemainingTarget"].toString(),style: const TextStyle(fontFamily: "Poppins-Regular",fontSize: 14,color: black)),
                                Text(data["RemainingDays"].toString()=="null"?"N/A":data["RemainingDays"].toString(),style: const TextStyle(fontFamily: "Poppins-Regular",fontSize: 14,color: black)),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                    width: MediaQuery.of(context).size.width*0.7,
                    child: const Divider(color: greenBasic,thickness: 1.0,)),
                const SizedBox(height: 10),
                DelayedDisplay(
                  delay: Duration(
                      milliseconds: initialDelay.inMilliseconds + 200),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 160,
                        padding: const EdgeInsets.all(10),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                                children: [
                                  Icon(FeatherIcons.target,color: greenBasic,size: 20,),
                                  SizedBox(width: 5),
                                  Text("Current Target",style: TextStyle(fontFamily: "Poppins-SemiBold",fontSize: 12,color: greenBasic),),
                                ]),
                            const SizedBox(height: 5),
                            Text(data["CurrentTargetRatio"].toString()=="null"?"N/A":data["CurrentTargetRatio"].toString(),style: const TextStyle(fontFamily: "Poppins-Regular",fontSize: 14,color: black)),
                          ],
                        ),
                      ),
                      Container(
                        width: 160,
                        padding: const EdgeInsets.all(10),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                                children: [
                                  Icon(FeatherIcons.target,color: greenBasic,size: 20,),
                                  SizedBox(width: 5),
                                  Text("Required Target",style: TextStyle(fontFamily: "Poppins-SemiBold",fontSize: 12,color: greenBasic),),
                                ]),
                            const SizedBox(height: 5),
                            Text(data["RequiredTargetPerday"].toString()=="null"?"N/A":data["RequiredTargetPerday"].toString(),style: const TextStyle(fontFamily: "Poppins-Regular",fontSize: 14,color: black)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                DelayedDisplay(
                  delay: Duration(
                      milliseconds: initialDelay.inMilliseconds + 300),
                  child: Container(
                    width: MediaQuery.of(context).size.width*0.91,
                    padding: const EdgeInsets.all(10),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                            children: [
                              Icon(FeatherIcons.tag,color: greenBasic,size: 20,),
                              SizedBox(width: 10),
                              Text("Pending Target",style: TextStyle(fontFamily: "Poppins-SemiBold",fontSize: 12,color: greenBasic),),
                            ]),
                        const SizedBox(height: 5),
                        Text(data["PerDayTarget"].toString()=="null"?"N/A":data["PerDayTarget"].toString(),style: const TextStyle(fontFamily: "Poppins-Regular",fontSize: 14,color: black)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                    width: MediaQuery.of(context).size.width*0.7,
                    child: const Divider(color: greenBasic,thickness: 1.0,)),
                const SizedBox(height: 10),
                DelayedDisplay(
                  delay: Duration(
                      milliseconds: initialDelay.inMilliseconds + 400),
                  child: Container(
                      width: MediaQuery.of(context).size.width*0.91,
                      padding: const EdgeInsets.all(10),
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(FeatherIcons.file,color: greenBasic,size: 20,),
                              SizedBox(width: 5,),
                              Text("Remarks",style: TextStyle(fontSize: 12,fontFamily: 'Poppins-SemiBold',color: greenBasic),),
                            ],
                          ),
                          Text(data["Result"].toString()=="null"?"N/A":data["Result"].toString(),style: const TextStyle(fontSize: 12,fontFamily: 'Poppins-Medium',color: greenBasic),),
                        ],
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
