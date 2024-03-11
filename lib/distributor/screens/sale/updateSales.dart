import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:hbe/distributor/screens/sale/daily_sales.dart';
import 'package:hbe/enums/globals.dart';
import 'package:hbe/utils/toast_utils.dart';
import 'package:hbe/widgets/loading_animation.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import '../../../models/daily_sale_model.dart';
import '../../../models/update_sale_distributor.dart';
import '../../../service/api_urls.dart';
import '../../../utils/app_routes.dart';
import '../../../utils/color_constants.dart';
import '../../../widgets/custom_buttons.dart';

class DistributorUpdateSales extends StatefulWidget {
  final DailySaleModel dailySaleModel;
  const DistributorUpdateSales({Key? key,required this.dailySaleModel}) : super(key: key);

  @override
  State<DistributorUpdateSales> createState() => _DistributorUpdateSalesState();
}

class _DistributorUpdateSalesState extends State<DistributorUpdateSales> {
  bool submitLoading = false;
  bool isLoading = true;
  bool showOther = false;
  TextEditingController remarksController = TextEditingController();

  List<ProducDetail2> getUpdateProducts=[];
  final Duration initialDelay = const Duration(milliseconds: 100);
  int detailMethodCount = 0;
  int detailMethodCount2 = 0;

  int detailMethodCount3 = 0;
  int detailMethodCount4 = 0;
  String originalPrice1="";
  var selectedIndex1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(mounted){
      setState(() {
       getProductsForUpdate();
      });
    }

  }

  //GET TOTAL PRODUCTS API
  Future<void> getProductsForUpdate() async {

    try {
      log('${ApiUrls.distributorUrl}${ApiUrls.getSaleDetails_Single}?UserID=${globalData.userId}&SaleID=${widget.dailySaleModel.poid}');

      final response = await http.get(
          Uri.parse('${ApiUrls.distributorUrl}${ApiUrls.getSaleDetails_Single}?UserID=${globalData.userId}&SaleID=${widget.dailySaleModel.poid}'),
          headers: {
            ApiUrls.key_name: ApiUrls.apikey,
          });

      List<dynamic> data = json.decode(response.body)[0]["ProducDetails"];
      if (response.statusCode == 200 && data.toString() != "[]") {
        getUpdateProducts.clear();

        for (int i = 0; i < data.length; i++) {
          getUpdateProducts.add(ProducDetail2.fromJson(data[i]));
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
          Uri.parse('${ApiUrls.distributorUrl}${ApiUrls.updateMasterSale2}?POID=${widget.dailySaleModel.poid}&PODate=${widget.dailySaleModel.poDate}&CustomerID=${widget.dailySaleModel.cusCustomerId}&Remarks=${remarksController.text.toString()}&UserID=${globalData.userId}'),
          headers: {
            ApiUrls.key_name: ApiUrls.apikey,
          });
      var res = json.decode(response.body);
      log(res.toString());
      bool secondLoop = false;

      if (response.statusCode == 200&& res.toString()=="Update" ) {
        ToastUtils.successToast("Updating Sale...", context);

        Future.delayed(Duration(milliseconds: 1500),(){
          for (int i = 0; i < getUpdateProducts.length; i++) {
            detailMethodCount++;

            if (detailMethodCount < getUpdateProducts.length) {
              deleteSale(widget.dailySaleModel.poid);
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

                submitDetailSale(getUpdateProducts[i].poid.toString(),getUpdateProducts[i].productId.toString(),double.parse(getUpdateProducts[i].quantity.toString()).toInt());
                ToastUtils.successToast("Sale detail updated successfully!", context);

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
      log('${ApiUrls.distributorUrl}${ApiUrls.deleteDetSale2}?POID=$poID');
      final response = await http.post(
          Uri.parse('${ApiUrls.distributorUrl}${ApiUrls.deleteDetSale2}?POID=$poID'),
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
  Future<void> submitDetailSale(String poID,String productID, int quantity) async{

    try {
      log('${ApiUrls.distributorUrl}${ApiUrls.submitDetSale2}?POID=${widget.dailySaleModel.poid}&ProductID=$productID&CustomerId=${widget.dailySaleModel.cusCustomerId}&Quantity=$quantity');
      final response = await http.post(
          Uri.parse('${ApiUrls.distributorUrl}${ApiUrls.submitDetSale2}?POID=${widget.dailySaleModel.poid}&ProductID=$productID&CustomerId=${widget.dailySaleModel.cusCustomerId}&Quantity=$quantity'),
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
        Future.delayed(Duration(seconds: 1),(){
          AppRoutes.pushAndRemoveUntil(context, DistributorDailySales());
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: greenBasic,
        title: Text("Update Daily Sale",style: TextStyle(fontFamily: "Poppins-Medium",fontSize: 16),),
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
                      isLoading?
                      Center(
                        child:   Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(child: Lottie.asset("assets/animations/loading.json",height: 200),),
                          ],
                        ),
                      )
                          : ListView.builder(
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
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            //Text(counter1[index]!=0?"${counter1[index].toString()} x":double.parse(getUpdateProducts[index].quantity.toString()).toStringAsFixed(0)+" x",style: TextStyle(fontSize: 11,fontFamily: "Poppins-Medium",color: black)),
                                            Text(double.parse(getUpdateProducts[index].quantity.toString()).toStringAsFixed(0)+" x",style: TextStyle(fontSize: 11,fontFamily: "Poppins-Medium",color: black)),
                                            SizedBox(width: 5),
                                            Text(getUpdateProducts[index].productName.toString(),style: TextStyle(fontSize: 11,fontFamily: "Poppins-Regular",color: black))
                                          ],
                                        ),
                                        SizedBox(height: 2),
                                        Text.rich(
                                          TextSpan(
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              color: white,
                                            ),
                                            children: [
                                              TextSpan(
                                                  text: 'Unit Price: '
                                                  ,style: TextStyle(fontSize: 10,fontFamily: "Poppins-Regular",color: black)
                                              ),
                                              TextSpan(
                                                  text: double.parse(getUpdateProducts[index].salePrice.toString()).toStringAsFixed(0)+" PKR",
                                                  style: TextStyle(fontSize: 10,fontFamily: "Poppins-Medium",color: black)
                                              ),
                                            ],
                                          ),
                                        ),

                                      ],
                                    ),
                                    Text.rich(
                                      TextSpan(
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          color: white,
                                        ),
                                        children: [
                                          TextSpan(
                                             // text: prices1[index].toString()!="0"?"${(prices1[index].toString())}":double.parse(getUpdateProducts[index].total.toString()).toStringAsFixed(0)
                                              text: double.parse(getUpdateProducts[index].total.toString()).toStringAsFixed(0)
                                              ,style: TextStyle(fontSize: 11,fontFamily: "Poppins-SemiBold",color: black)
                                          ),
                                          TextSpan(
                                              text:"/PKR",
                                              style: TextStyle(fontSize: 9,fontFamily: "Poppins-Regular",color: black)
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    InkWell(
                                      onTap: (){

                                      if(mounted){
                                        setState(() {
                                          getUpdateProducts[index].quantity++;
                                          selectedIndex1=index;
                                          originalPrice1 = double.parse(getUpdateProducts[index].salePrice.toString()).toStringAsFixed(0);
                                          getUpdateProducts[index].total = (double.parse(originalPrice1.toString()) * double.parse(getUpdateProducts[index].quantity.toString())).toDouble();
                                        });
                                      }
                                      //  _incrementCounter1(index);
                                      },
                                      child: Container(
                                          width: 40,
                                          height: 40,
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
                                            FeatherIcons.plus,color: white, size: 15,
                                          )
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    InkWell(
                                      onTap: (){
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
                                                            controller: quantityController,
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
                                                            CustomButton(onTap: (){
                                                              if(mounted){
                                                                setState(() {
                                                                  getUpdateProducts[index].quantity=double.parse(quantityController.text.toString());
                                                                  selectedIndex1=index;
                                                                  originalPrice1 = double.parse(getUpdateProducts[index].salePrice.toString()).toStringAsFixed(0);
                                                                  getUpdateProducts[index].total = (double.parse(originalPrice1.toString()) * double.parse(getUpdateProducts[index].quantity.toString())).toDouble();
                                                                });
                                                              }
                                                              quantityController.text="";
                                                              AppRoutes.pop(context);
                                                            }, color: greenBasic, text: "Add",width: 100,),
                                                          ],
                                                        ),
                                                        SizedBox(height: 10),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
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
                                          child: Center(child: Text(double.parse(getUpdateProducts[index].quantity.toString()).toInt().toString(),style: TextStyle(fontSize: 12,fontFamily: "Poppins-Medium",color: greenBasic),))
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    InkWell(
                                      onTap: (){
                                        if(mounted){
                                          setState(() {
                                            getUpdateProducts[index].quantity--;
                                            if( getUpdateProducts[index].quantity<=0){
                                              getUpdateProducts[index].quantity = 0;
                                              ToastUtils.infoToast("Quantity is zero", context);
                                            }
                                            selectedIndex1=index;
                                            originalPrice1 = double.parse(getUpdateProducts[index].salePrice.toString()).toStringAsFixed(0);
                                            getUpdateProducts[index].total = (double.parse(getUpdateProducts[index].total.toString()) - double.parse(originalPrice1.toString())).toDouble();
                                          });
                                        }

                                       // _decrementCounter1(index);
                                      },
                                      child: Container(
                                          width: 40,
                                          height: 40,
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
                                            FeatherIcons.minus,color: white, size: 15,
                                          )
                                      ),
                                    ),
                                  ],
                                )
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
                            }, color: greenBasic, text: "Update Sale")
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

}
