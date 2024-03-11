import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:hbe/distributor/screens/return/return_sales.dart';
import 'package:hbe/enums/globals.dart';
import 'package:hbe/utils/toast_utils.dart';
import 'package:hbe/widgets/loading_animation.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import '../../../models/return_sale_model.dart';
import '../../../models/return_update_model.dart';
import '../../../service/api_urls.dart';
import '../../../utils/app_routes.dart';
import '../../../utils/color_constants.dart';
import '../../../widgets/custom_buttons.dart';


class UpdateReturn extends StatefulWidget {
  final ReturnModel returnModel;
  const UpdateReturn({Key? key,required this.returnModel}) : super(key: key);

  @override
  State<UpdateReturn> createState() => _UpdateReturnState();
}

class _UpdateReturnState extends State<UpdateReturn> {
  bool submitLoading = false;
  bool isLoading = true;
  bool showOther = false;
  TextEditingController remarksController = TextEditingController();
  final Duration initialDelay = const Duration(milliseconds: 100);
  int detailMethodCount = 0;
  int detailMethodCount2 = 0;

  int detailMethodCount3 = 0;
  int detailMethodCount4 = 0;

  String originalPrice1="";

  var selectedIndex1;

  List<UProducDetail> getUpdateProducts=[];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProductsForUpdate();
  }

  //GET TOTAL PRODUCTS API
  Future<void> getProductsForUpdate() async {

   try {
      final response = await http.get(
          Uri.parse('${ApiUrls.baseURL}${ApiUrls.getSaleDetailsSingleR}?UserID=${globalData.userId}&SaleReturnID=${widget.returnModel.saleReturnId}'),
          headers: {
            ApiUrls.key_name: ApiUrls.apikey,
          });

      List<dynamic> data = json.decode(response.body)[0]["ProducDetails"];
      if (response.statusCode == 200 && data.toString() != "[]") {
        getUpdateProducts.clear();

        for (int i = 0; i < data.length; i++) {
          getUpdateProducts.add(UProducDetail.fromJson(data[i]));
        }

        if(mounted) {
          setState(() {
            isLoading = false;
            showOther = false;
          });
        }

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

  }

  //SUBMIT MASTER SALE
  Future<void> updateMasterSale() async{
    try {
      final response = await http.post(
          Uri.parse('${ApiUrls.baseURL}${ApiUrls.updateMasterSaleR}?SaleReturnID=${widget.returnModel.saleReturnId}&PODate=${widget.returnModel.poDate}&CustomerID=${widget.returnModel.cusCustomerId}&Remarks=${remarksController.text.toString()}&UserID=${globalData.userId}'),
          headers: {
            ApiUrls.key_name: ApiUrls.apikey,
          });
      var res = json.decode(response.body);
      log(res.toString());
      bool secondLoop = false;

      if (response.statusCode == 200 && res.toString()=="Update") {
        ToastUtils.successToast("Updating Sale...", context);

        Future.delayed(Duration(milliseconds: 1500),(){
          for (int i = 0; i < getUpdateProducts.length; i++) {
            detailMethodCount++;

            if (detailMethodCount < getUpdateProducts.length) {
              deleteSale(widget.returnModel.saleReturnId);
            }
            else{
              if(mounted){
                setState(() {
                  secondLoop = true;
                });
              }
            }
          }
          if(secondLoop){
            Future.delayed(Duration(milliseconds: 1500),(){
              for (int i = 0; i < getUpdateProducts.length; i++) {
                detailMethodCount3++;

               submitDetailSale(getUpdateProducts[i].productId.toString(),getUpdateProducts[i].returnQuantity.toString(),getUpdateProducts[i].demageReplaceQuantity.toString(),getUpdateProducts[i].demageNotReplaceQuantity.toString());
              }
            });
          }


        });

      }
      else {
        if(mounted) {
          setState(() {
            submitLoading = false;
          });
        }
        ToastUtils.failureToast("Something wrong occurred", context);
        throw Exception('Unexpected error occurred!');
      }
    } on SocketException {
      if(mounted) {
        setState(() {
          submitLoading = false;
        });
      }
      ToastUtils.failureToast("No Internet Connection", context);
    } on HttpException {
      if(mounted) {
        setState(() {
          submitLoading = false;
        });
      }
      ToastUtils.warningToast("Couldn't find the data 😱", context);
    } on FormatException {
      if(mounted) {
        setState(() {
          submitLoading = false;
        });
      }
      ToastUtils.warningToast("Something went wrong ", context);
    }

  }

  //DELETE SALE
  Future<void> deleteSale(poID) async{
    try {
      final response = await http.post(
          Uri.parse('${ApiUrls.baseURL}${ApiUrls.deleteDetSaleR}?SaleReturnID=$poID'),
          headers: {
            ApiUrls.key_name: ApiUrls.apikey,
          });

      var res = json.decode(response.body);
      if (response.statusCode == 200 && res.toString()=="Deleted") {

      }

      else {

        throw Exception('Unexpected error occurred!');
      }
    } on SocketException {

    } on HttpException {

      ToastUtils.warningToast("Couldn't find the data 😱", context);
    } on FormatException {

      ToastUtils.warningToast("Something went wrong ", context);
    }
  }

  //SUBMIT DETAIL API
  Future<void> submitDetailSale(String productID,String returnQuantity, String damageReplace, String damageNotReplace) async{

    try {
      final response = await http.post(
          Uri.parse('${ApiUrls.baseURL}${ApiUrls.submitDetSaleR}?SaleReturnID=${widget.returnModel.saleReturnId}&ProductID=$productID&CustomerId=${widget.returnModel.cusCustomerId}&ReturnQuantity=${int.parse(returnQuantity)}&DemageReplace=${int.parse(damageReplace)}&DemageNotReplace=${int.parse(damageNotReplace)}'),
          headers: {
            ApiUrls.key_name: ApiUrls.apikey,
          });

      var res = json.decode(response.body);

      if (response.statusCode == 200) {
        if(mounted) {
          setState(() {
            submitLoading = false;
          });
        }

          ToastUtils.successToast("Return detail updated successfully!", context);
          Future.delayed(Duration(seconds: 1),(){
            AppRoutes.pushAndRemoveUntil(context, ReturnDetail());
          });

      }
      else {
        ToastUtils.failureToast(res.toString(), context);
        if(mounted) {
          setState(() {
            submitLoading = false;
          });
        }
        throw Exception('Unexpected error occurred!');
      }
    } on SocketException {
      if(mounted) {
        setState(() {
          submitLoading = false;
        });
      }
      ToastUtils.failureToast("No Internet Connection", context);
    } on HttpException {
      if(mounted) {
        setState(() {
          submitLoading = false;
        });
      }
      ToastUtils.warningToast("Couldn't find the data 😱", context);
    } on FormatException {
      if(mounted) {
        setState(() {
          submitLoading = false;
        });
      }
      ToastUtils.warningToast("Something went wrong ", context);
    }

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    getUpdateProducts.clear();
  }
  TextEditingController quantityController = TextEditingController();
  TextEditingController replaceController = TextEditingController();
  TextEditingController damageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: greenBasic,
        title: Text("Update Return Sale",style: TextStyle(fontFamily: "Poppins-Medium",fontSize: 16),),
        centerTitle: true,
      ),
      body: LoadingAnimation(
        inAsyncCall: submitLoading,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Invoice Added Products",style: TextStyle(fontFamily: "Poppins-SemiBold",fontSize: 14,color: greenBasic)),
                      showOther?
                      DelayedDisplay(
                        delay: initialDelay,
                        child: Center(
                          child: Column(
                            children: [
                              Lottie.asset("assets/animations/no_sale_found.json",height: 200),
                              SizedBox(height: 10),
                              Text("No Products Found",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 15,color: greenBasic),)
                            ],
                          ),
                        ),
                      )
                      :isLoading?
                      DelayedDisplay(
                        delay: initialDelay,
                        child: Center(
                          child: Lottie.asset("assets/animations/loading.json",height: 200),
                        ),
                      )
                      :ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context,index){
                          return Container(
                            margin: EdgeInsets.only(bottom: 10,left: 5,right: 5,top: 5),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: white,
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 2,
                                      color: black.withOpacity(0.25)
                                  )
                                ],
                                borderRadius: BorderRadius.circular(8)
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                    width: MediaQuery.of(context).size.width*0.7,
                                    child: Text(getUpdateProducts[index].productName.toString(),style: TextStyle(fontSize: 13,fontFamily: "Poppins-SemiBold",color: greenBasic),overflow: TextOverflow.ellipsis,)),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Return Quantity",style: TextStyle(fontSize: 11,fontFamily: "Poppins-SemiBold",color: black)),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        InkWell(
                                          onTap: (){
                                            if(mounted){
                                              setState(() {
                                                 getUpdateProducts[index].returnQuantity++;
                                                selectedIndex1=index;
                                              });
                                            }
                                          },
                                          child: Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                  color: greenBasic,
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: black.withOpacity(0.2),
                                                        blurRadius: 3
                                                    )
                                                  ],
                                                  shape: BoxShape.circle
                                              ),
                                              child: Icon(
                                                FeatherIcons.plus,color: white,
                                                size: 15,
                                              )
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        InkWell(
                                          onTap: (){
                                            quantityDialog(context, quantityController, () {
                                              if(mounted){
                                                setState(() {
                                                  getUpdateProducts[index].returnQuantity=int.parse(quantityController.text.toString());
                                                  selectedIndex1=index;
                                                });
                                              }
                                              quantityController.text="";
                                              AppRoutes.pop(context);
                                            });
                                          },
                                          child: Container(
                                              width: 60,
                                              height: 35,
                                              decoration: BoxDecoration(
                                                  color: white,
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: black.withOpacity(0.2),
                                                        blurRadius: 3
                                                    )
                                                  ],
                                                  borderRadius: BorderRadius.circular(5)
                                              ),
                                              child: Center(child: Text(double.parse(getUpdateProducts[index].returnQuantity.toString()).toInt().toString(),style: TextStyle(fontSize: 12,fontFamily: "Poppins-Medium",color: greenBasic),))
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        InkWell(
                                          onTap: (){
                                            if(mounted){
                                              setState(() {
                                                getUpdateProducts[index].returnQuantity--;
                                                if( getUpdateProducts[index].returnQuantity<=0){
                                                  getUpdateProducts[index].returnQuantity = 0;
                                                  ToastUtils.infoToast("Quantity is zero", context);
                                                }
                                                selectedIndex1=index;
                                              });
                                            }
                                          },
                                          child: Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                  color: greenBasic,
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: black.withOpacity(0.2),
                                                        blurRadius: 3
                                                    )
                                                  ],
                                                  shape: BoxShape.circle
                                              ),
                                              child: Icon(
                                                FeatherIcons.minus,color: white,
                                                size: 15,
                                              )
                                          ),
                                        ),
                                      ],
                                    ),

                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Damage Replace",style: TextStyle(fontSize: 11,fontFamily: "Poppins-SemiBold",color: black)),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        InkWell(
                                          onTap: (){
                                            if(mounted){
                                              setState(() {
                                                getUpdateProducts[index].demageReplaceQuantity++;
                                                selectedIndex1=index;
                                              });
                                            }
                                          },
                                          child: Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                  color: greenBasic,
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: black.withOpacity(0.2),
                                                        blurRadius: 3
                                                    )
                                                  ],
                                                  shape: BoxShape.circle
                                              ),
                                              child: Icon(
                                                FeatherIcons.plus,color: white,
                                                size: 15,
                                              )
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        InkWell(
                                          onTap: (){
                                            quantityDialog(context, replaceController, () {
                                              if(mounted){
                                                setState(() {
                                                  getUpdateProducts[index].demageReplaceQuantity=int.parse(replaceController.text.toString());
                                                  selectedIndex1=index;
                                                });
                                              }
                                              replaceController.text="";
                                              AppRoutes.pop(context);
                                            });
                                          },
                                          child: Container(
                                              width: 60,
                                              height: 35,
                                              decoration: BoxDecoration(
                                                  color: white,
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: black.withOpacity(0.2),
                                                        blurRadius: 3
                                                    )
                                                  ],
                                                  borderRadius: BorderRadius.circular(5)
                                              ),
                                              child: Center(child: Text(double.parse(getUpdateProducts[index].demageReplaceQuantity.toString()).toInt().toString(),style: TextStyle(fontSize: 12,fontFamily: "Poppins-Medium",color: greenBasic),))
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        InkWell(
                                          onTap: (){
                                            if(mounted){
                                              setState(() {
                                                getUpdateProducts[index].demageReplaceQuantity--;
                                                if( getUpdateProducts[index].demageReplaceQuantity<=0){
                                                  getUpdateProducts[index].demageReplaceQuantity = 0;
                                                  ToastUtils.infoToast("Quantity is zero", context);
                                                }
                                                selectedIndex1=index;
                                              });
                                            }
                                          },
                                          child: Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                  color: greenBasic,
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: black.withOpacity(0.2),
                                                        blurRadius: 3
                                                    )
                                                  ],
                                                  shape: BoxShape.circle
                                              ),
                                              child: Icon(
                                                FeatherIcons.minus,color: white,
                                                size: 15,
                                              )
                                          ),
                                        ),
                                      ],
                                    ),

                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Damage Not Replace",style: TextStyle(fontSize: 11,fontFamily: "Poppins-SemiBold",color: black)),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        InkWell(
                                          onTap: (){
                                            if(mounted){
                                              setState(() {
                                                getUpdateProducts[index].demageNotReplaceQuantity++;
                                                selectedIndex1=index;
                                              });
                                            }
                                          },
                                          child: Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                  color: greenBasic,
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: black.withOpacity(0.2),
                                                        blurRadius: 3
                                                    )
                                                  ],
                                                  shape: BoxShape.circle
                                              ),
                                              child: Icon(
                                                FeatherIcons.plus,color: white,
                                                size: 15,
                                              )
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        InkWell(
                                          onTap: (){
                                            quantityDialog(context, damageController, () {
                                              if(mounted){
                                                setState(() {
                                                  getUpdateProducts[index].demageNotReplaceQuantity=int.parse(damageController.text.toString());
                                                  selectedIndex1=index;
                                                });
                                              }
                                              damageController.text="";
                                              AppRoutes.pop(context);
                                            });
                                          },
                                          child: Container(
                                              width: 60,
                                              height: 35,
                                              decoration: BoxDecoration(
                                                  color: white,
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: black.withOpacity(0.2),
                                                        blurRadius: 3
                                                    )
                                                  ],
                                                  borderRadius: BorderRadius.circular(5)
                                              ),
                                              child: Center(child: Text(double.parse(getUpdateProducts[index].demageNotReplaceQuantity.toString()).toInt().toString(),style: TextStyle(fontSize: 12,fontFamily: "Poppins-Medium",color: greenBasic),))
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        InkWell(
                                          onTap: (){
                                            if(mounted){
                                              setState(() {
                                                getUpdateProducts[index].demageNotReplaceQuantity--;
                                                if( getUpdateProducts[index].demageNotReplaceQuantity<=0){
                                                  getUpdateProducts[index].demageNotReplaceQuantity = 0;
                                                  ToastUtils.infoToast("Quantity is zero", context);
                                                }
                                                selectedIndex1=index;
                                              });
                                            }
                                          },
                                          child: Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                  color: greenBasic,
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: black.withOpacity(0.2),
                                                        blurRadius: 3
                                                    )
                                                  ],
                                                  shape: BoxShape.circle
                                              ),
                                              child: Icon(
                                                FeatherIcons.minus,color: white,
                                                size: 15,
                                              )
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },itemCount: getUpdateProducts.length,),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                      color: white,
                      boxShadow: [
                        BoxShadow(
                            color: black.withOpacity(0.25),
                            blurRadius: 4
                        )
                      ]
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.zero,
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              border:
                              Border.all(color: Colors.black.withOpacity(0.25), width: 1),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: TextFormField(
                            controller: remarksController,
                            decoration: InputDecoration(
                              isDense: true,
                              fillColor: white,
                              filled: true,
                              labelText: 'Remarks',
                              labelStyle: TextStyle(
                                  color: greenBasic,
                                  fontFamily: "Poppins-Regular",
                                  fontSize: 14),
                              floatingLabelBehavior:
                              FloatingLabelBehavior.always,
                              hintText: "Enter your remarks",
                              hintStyle: TextStyle(
                                color: greenBasic,
                                fontFamily: "Poppins-Regular",
                                fontSize: 14,
                              ),
                              enabledBorder: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                  BorderSide(color: white, width: 1)),
                              focusedBorder: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                  BorderSide(color: white, width: 1)),
                            ),
                          ),
                        ),
                        CustomButton(
                            width: MediaQuery.of(context).size.width*0.9,
                            onTap: (){
                              if(remarksController.text.isEmpty){
                                ToastUtils.failureToast("Please add remarks", context);
                              }
                              else{
                                if(mounted){
                                  setState(() {
                                    submitLoading = true;
                                  });
                                }
                                updateMasterSale();
                              }
                            }, color: greenBasic, text: "Update Return Sale".toUpperCase())
                      ],
                    ),
                  )
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  quantityDialog(BuildContext ctx, TextEditingController controller,VoidCallback onTap){
    showDialog(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.zero,
                      decoration: BoxDecoration(
                          border:
                          Border.all(color: Colors.black.withOpacity(0.25), width: 1),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'\s')),
                        ],
                        controller: controller,
                        decoration: InputDecoration(
                          isDense: true,
                          fillColor: white,
                          filled: true,
                          labelText: 'Quantity',
                          labelStyle: TextStyle(
                              color: greenBasic,
                              fontFamily: "Poppins-Regular",
                              fontSize: 14),
                          floatingLabelBehavior:
                          FloatingLabelBehavior.always,
                          hintText: "Enter your quantity",
                          hintStyle: TextStyle(
                            color: greenBasic,
                            fontFamily: "Poppins-Regular",
                            fontSize: 14,
                          ),
                          enabledBorder: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                              BorderSide(color: white, width: 1)),
                          focusedBorder: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                              BorderSide(color: white, width: 1)),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomButton(onTap: (){
                          AppRoutes.pop(context);
                        }, color: Colors.grey.withOpacity(0.25), text: "Cancel",colorText: white,width: 100,),
                        SizedBox(width: 10),
                        CustomButton(onTap: onTap, color: greenBasic, text: "Add",width: 100,),
                      ],
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          );
        });
  }

}
