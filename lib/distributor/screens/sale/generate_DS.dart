import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:hbe/distributor/screens/sale/daily_sales.dart';
import 'package:hbe/enums/globals.dart';
import 'package:hbe/utils/app_routes.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import '../../../models/total_products_model.dart';
import '../../../service/api_urls.dart';
import '../../../utils/color_constants.dart';
import '../../../utils/toast_utils.dart';
import '../../../widgets/custom_buttons.dart';
import '../../../widgets/loading_animation.dart';

class DistributorGenerateDS extends StatefulWidget {
  final String cID,date;
  const DistributorGenerateDS({Key? key,required this.cID,required this.date}) : super(key: key);

  @override
  State<DistributorGenerateDS> createState() => _DistributorGenerateDSState();
}

class _DistributorGenerateDSState extends State<DistributorGenerateDS> {
  List<GetTotalProducts> getProducts=[];
  List<dynamic> newProducts=[];
  bool isLoading = true;
  bool showOther = false;
  bool submitLoading = false;
  final Duration initialDelay = const Duration(milliseconds: 100);
  TextEditingController remarksController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  String originalPrice="";
  int price=0;
  StreamController _event =StreamController<int>.broadcast();
  List<int> counter =[];
  List<int> prices =[];
  int detailMethodCount = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTotalProducts();
    _event.add(0);
  }

  //GET TOTAL PRODUCTS API
  Future<void> getTotalProducts() async {

    try {
      final response = await http.get(
          Uri.parse('${ApiUrls.distributorUrl}${ApiUrls.getProductListByCustomer2}?CustomerID=${widget.cID}'),
          headers: {
            ApiUrls.key_name: ApiUrls.apikey,
          });

      List<dynamic> data = json.decode(response.body);
      if (response.statusCode == 200 && data.toString() != "[]") {
        getProducts.clear();

        for (int i = 0; i < data.length; i++) {
          getProducts.add(GetTotalProducts.fromJson(data[i]));
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
      ToastUtils.failureToast("No Internet Connection", context);
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

  var selectedIndex;
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    getProducts.clear();
  }

  var invoiceID;
  //SUBMIT MASTER SALE
  Future<void> submitMasterSale() async{
    print( jsonEncode(newProducts).toString());
    try {

      final response = await http.post(
          Uri.parse('${ApiUrls.distributorUrl}${ApiUrls.submitMstrSaleNew2}?PODate=${widget.date}&CustomerID=${widget.cID}&Remarks=${remarksController.text.toString()}&UserID=${globalData.userId}'),
          headers: {
            ApiUrls.key_name: ApiUrls.apikey,
            'Content-Type': 'application/json',
          },
      body: jsonEncode(newProducts));
      var res = json.decode(response.body);
      log("RESPONSE   "+res.toString());
      if (response.statusCode == 200) {

        if(mounted) {
          setState(() {
            invoiceID=res.toString();
          });
        }
      ToastUtils.successToast("Invoice No. "+res.toString(), context);
        Future.delayed(Duration(seconds: 1),(){
          if(mounted) {
            setState(() {
              submitLoading = false;
            });
          }
          ToastUtils.successToast("Daily sale added successfully!", context);
          AppRoutes.pushAndRemoveUntil(context, DistributorDailySales());
        });

      // Future.delayed(Duration(milliseconds: 1500),(){
      //   for (int i = 0; i < getProducts.length; i++) {
      //   detailMethodCount++;
      //
      //   submitDetailPO(getProducts[i].productId.toString(),counter[i].toString());
      //   ToastUtils.successToast("Daily sale added successfully!", context);
      // }
      // });
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

  //SUBMIT PO DETAIL API
  Future<void> submitDetailPO(String poID, String quantity) async{

    try {
      final response = await http.post(
          Uri.parse('${ApiUrls.distributorUrl}${ApiUrls.submitDetSale2}?POID=$invoiceID&ProductID=$poID&CustomerId=${widget.cID}&Quantity=$quantity'),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: greenBasic,
        title: Text("Daily Sale",style: TextStyle(fontFamily: "Poppins-Medium",fontSize: 16),),
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
                          if(counter.length < getProducts.length){
                            counter.add(0);
                            prices.add(0);
                          }
                          return DelayedDisplay(
                            delay: initialDelay,
                            child: Container(
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
                                          SizedBox(
                                              width: MediaQuery.of(context).size.width*0.55,
                                              child: Text(getProducts[index].productName.toString(),style: TextStyle(fontSize: 11,fontFamily: "Poppins-Regular",color: black),overflow: TextOverflow.ellipsis,)),
                                          SizedBox(height: 2),
                                          Text.rich(
                                            TextSpan(
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: white,
                                              ),
                                              children: [
                                                TextSpan(
                                                    text: '(Discount '
                                                    ,style: TextStyle(fontSize: 10,fontFamily: "Poppins-Regular",color: redBasic)
                                                ),
                                                TextSpan(
                                                    text: getProducts[index].discount.toString()+")",
                                                    style: TextStyle(fontSize: 10,fontFamily: "Poppins-Regular",color: redBasic)
                                                ),
                                              ],
                                            ),
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
                                                    text:"Unit Price: ",
                                                    style: TextStyle(fontSize: 10,fontFamily: "Poppins-Regular",color: black)
                                                ),
                                                TextSpan(
                                                    text: double.parse(getProducts[index].productSalaPrice.toString()).toStringAsFixed(2)
                                                    ,style: TextStyle(fontSize: 10,fontFamily: "Poppins-SemiBold",color: black)
                                                ),

                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      // selectedIndex==index?  price.toString()!="0"?Text(price.toString()+"PKR"):const SizedBox():const SizedBox()
                                      Text(prices[index].toString()!="0"?prices[index].toString()+" PKR":"0 PKR")
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      InkWell(
                                        onTap: (){
                                          _incrementCounter(index);
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
                                              FeatherIcons.plus,color: white,
                                              size: 15,
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
                                                                    counter[index]=int.parse(quantityController.text.toString());
                                                                    _event.add(counter[index]);
                                                                    selectedIndex=index;
                                                                    originalPrice = getProducts[index].productSalaPrice.toString();
                                                                    prices[index] = (double.parse(originalPrice.toString()) * double.parse(counter[index].toString())).toInt();
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
                                            child: Center(child: Text(counter[index].toString(),style: TextStyle(fontSize: 12,fontFamily: "Poppins-Medium",color: greenBasic),))
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      InkWell(
                                        onTap: (){
                                          _decrementCounter(index);
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
                                              FeatherIcons.minus,color: white,
                                              size: 15,
                                            )
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },itemCount: getProducts.length,),
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
                              border: Border.all(color: Colors.black.withOpacity(0.25), width: 1),
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
                            width: MediaQuery.of(context).size.width*0.8,
                            onTap: (){
                              if(remarksController.text.isEmpty){
                                ToastUtils.failureToast("Please add remarks", context);
                              }
                              else{
                                if(getProducts.isEmpty){
                                  ToastUtils.failureToast("No Products Found", context);
                                }
                                else{
                                  if(mounted){
                                    setState(() {
                                      submitLoading=true;
                                    });
                                  }
                                  newProducts.clear();
                                  for (int i = 0; i < getProducts.length; i++) {
                                    newProducts.add({
                                      "ProductID":int.parse(getProducts[i].productId.toString()),
                                      "Quantity":int.parse(counter[i].toString())
                                    });
                                    if(i==getProducts.length-1){
                                      print("Last");
                                     submitMasterSale();
                                    }


                                  }

                                }

                              }
                            }, color: greenBasic, text: "SUBMIT DAILY SALES")
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

  _incrementCounter(int i) {
    if(mounted){
      setState(() {
        counter[i]++;
        _event.add(counter[i]);
        selectedIndex=i;
        originalPrice = getProducts[i].productSalaPrice.toString();
        prices[i] = (double.parse(originalPrice.toString()) * double.parse(counter[i].toString())).toInt();
      });
    }
  }

  _decrementCounter(int i)  {
    if(mounted){
      setState(() {
        if (counter[i] <= 0) {
          counter[i] = 0;
          ToastUtils.infoToast("Quantity is zero", context);
        } else {
          counter[i]--;
          selectedIndex=i;
          originalPrice = getProducts[i].productSalaPrice.toString();
          prices[i] = (double.parse(prices[i].toString()) - double.parse(originalPrice.toString())).toInt();

        }
        _event.add(counter[i]);
      });
    }

  }
}
