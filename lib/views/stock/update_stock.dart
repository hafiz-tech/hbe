import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:hbe/enums/globals.dart';
import 'package:hbe/models/stock_detail_model.dart';
import 'package:hbe/utils/toast_utils.dart';
import 'package:hbe/views/stock/stock_details.dart';
import 'package:hbe/widgets/loading_animation.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import '../../../service/api_urls.dart';
import '../../../utils/color_constants.dart';
import '../../../widgets/custom_buttons.dart';
import '../../models/update_sale_distributor.dart';
import '../../utils/app_routes.dart';


class UpdateStock extends StatefulWidget {
  final StockDetailsModel stockDetailsModel;
  final int index;
  const UpdateStock({Key? key,required this.stockDetailsModel,required this.index}) : super(key: key);

  @override
  State<UpdateStock> createState() => _UpdateStockState();
}

class _UpdateStockState extends State<UpdateStock> {

  bool submitLoading = false;
  bool isLoading = true;
  bool showOther = false;
  TextEditingController remarksController = TextEditingController();
  final Duration initialDelay = const Duration(milliseconds: 100);
  int detailMethodCount = 0;
  int detailMethodCount2 = 0;

  int detailMethodCount3 = 0;
  int detailMethodCount4 = 0;
  TextEditingController quantityController = TextEditingController();
  String originalPrice1="";

  var selectedIndex1;

  List<ProducDetail2> getUpdateProducts=[];
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
          Uri.parse('${ApiUrls.baseURL}${ApiUrls.getStockDetails_Single}?UserID=${globalData.userId}&StockID=${widget.stockDetailsModel.stockId}'),
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

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    getUpdateProducts.clear();
  }

  //UPDATE STOCK
  Future<void> updateStock(stockID,stockDate,customerID) async{
    try {
      log('${ApiUrls.baseURL}${ApiUrls.updateMstrStock}?StockID=$stockID&StockDate=${Uri.encodeComponent(stockDate.toString())}&CustomerID=$customerID&Remarks=${remarksController.text.toString()}');
      final response = await http.post(
          Uri.parse('${ApiUrls.baseURL}${ApiUrls.updateMstrStock}?StockID=$stockID&StockDate=${Uri.encodeComponent(stockDate.toString())}&CustomerID=$customerID&Remarks=${remarksController.text.toString()}'),
          headers: {
            ApiUrls.key_name: ApiUrls.apikey,
          });

      var res = json.decode(response.body);
      bool secondLoop = false;
      if (response.statusCode == 200 && res.toString()=="Update") {
        ToastUtils.successToast("Updating Stock...", context);
        Future.delayed(Duration(milliseconds: 1500),(){
          for (int i = 0; i < getUpdateProducts.length; i++) {
            detailMethodCount++;

            if (detailMethodCount < getUpdateProducts.length) {
              deleteStock(stockID);
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

                if (detailMethodCount3 < getUpdateProducts.length) {
                  submitDetailStock(getUpdateProducts[i].poid.toString(),double.parse(getUpdateProducts[i].quantity.toString()).toInt(),false,customerID.toString());
                }
                else{
                  submitDetailStock(getUpdateProducts[i].poid.toString(),double.parse(getUpdateProducts[i].quantity.toString()).toInt(),true,customerID.toString());

                }
              }

            });
          }


        });
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

  //DELETE STOCK
  Future<void> deleteStock(stockID) async{
    try {
      log('${ApiUrls.baseURL}${ApiUrls.deleteDetStock}?StockID=$stockID');
      final response = await http.post(
          Uri.parse('${ApiUrls.baseURL}${ApiUrls.deleteDetStock}?StockID=$stockID'),
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

  //SUBMIT Stock DETAIL API
  Future<void> submitDetailStock(String poID, int quantity, bool isLast,String customerID) async{

    try {
      log('${ApiUrls.baseURL}${ApiUrls.submitDetStock}?StockID=${widget.stockDetailsModel.stockId}&ProductID=$poID&CustomerId=$customerID&Quantity=$quantity&IslastEntry=$isLast');
      final response = await http.post(
          Uri.parse('${ApiUrls.baseURL}${ApiUrls.submitDetStock}?StockID=${widget.stockDetailsModel.stockId}&ProductID=$poID&CustomerId=$customerID&Quantity=$quantity&IslastEntry=$isLast'),
          headers: {
            ApiUrls.key_name: ApiUrls.apikey,
          });

      var res = json.decode(response.body);

      if (response.statusCode == 200) {
      log("HEE");
      if(isLast){
        ToastUtils.successToast("Stock detail updated successfully!", context);
        Future.delayed(Duration(seconds: 1),(){
          AppRoutes.pushAndRemoveUntil(context, StockDetails());
        });
      }
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
  Widget build(BuildContext context) {


    return Scaffold(

      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: greenBasic,
        title: Text("Update Stock",style: TextStyle(fontFamily: "Poppins-Medium",fontSize: 16),),
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
                          Text("Stock Added Products",style: TextStyle(fontFamily: "Poppins-SemiBold",fontSize: 14,color: greenBasic)),
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
                                updateStock(widget.stockDetailsModel.stockId, widget.stockDetailsModel.stockDate, widget.stockDetailsModel.cusCustomerId.toString());
                              }
                            }, color: greenBasic, text: "Update Stock Detail")
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
