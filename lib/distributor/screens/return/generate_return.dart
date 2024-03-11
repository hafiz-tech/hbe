import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:hbe/distributor/screens/return/return_sales.dart';
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

class GenerateReturn extends StatefulWidget {
  final String cID,date;
  const GenerateReturn({Key? key,required this.cID,required this.date}) : super(key: key);

  @override
  State<GenerateReturn> createState() => _GenerateReturnState();
}

class _GenerateReturnState extends State<GenerateReturn> {
  List<GetTotalProducts> getProducts=[];
  bool isLoading = true;
  bool showOther = false;
  bool submitLoading = false;
  final Duration initialDelay = const Duration(milliseconds: 100);
  TextEditingController remarksController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController replaceController = TextEditingController();
  TextEditingController damageController = TextEditingController();
  String originalPrice="";
  int price=0;
  StreamController _event =StreamController<int>.broadcast();
  List<int> counter =[];
  List<int> counter2 =[];
  List<int> counter3 =[];
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
          Uri.parse('${ApiUrls.baseURL}${ApiUrls.getRListCustomer}?CustomerID=${widget.cID}'),
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
    try {
      final response = await http.post(
          Uri.parse('${ApiUrls.baseURL}${ApiUrls.submitMasterSaleR}?InvDate=${widget.date}&CustomerID=${widget.cID}&Remarks=${remarksController.text.toString()}&UserID=${globalData.userId}'),
          headers: {
            ApiUrls.key_name: ApiUrls.apikey,
          });
      var res = json.decode(response.body);
      if (response.statusCode == 200) {

        if(mounted) {
          setState(() {
            invoiceID=res.toString();
          });
        }
        ToastUtils.successToast("Invoice No. "+res.toString(), context);
        Future.delayed(Duration(milliseconds: 1500),(){
          for (int i = 0; i < getProducts.length; i++) {
            detailMethodCount++;
            submitDetailPO(getProducts[i].productId.toString(),counter[i].toString(),counter2[i].toString(),counter3[i].toString());
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

  //SUBMIT PO DETAIL API
  Future<void> submitDetailPO(String poID, String returnQuantity, String damageReplace, String damageNotReplace) async{

    try {
      final response = await http.post(
          Uri.parse('${ApiUrls.baseURL}${ApiUrls.submitDetSaleR}?SaleReturnID=$invoiceID&ProductID=$poID&CustomerID=${widget.cID}&ReturnQuantity=${int.parse(returnQuantity)}&DemageReplace=${int.parse(damageReplace)}&DemageNotReplace=${int.parse(damageNotReplace)}'),
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
          ToastUtils.successToast("Return sale added successfully!", context);
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: greenBasic,
        title: Text("Return Sale",style: TextStyle(fontFamily: "Poppins-Medium",fontSize: 16),),
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
                            counter2.add(0);
                            counter3.add(0);
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width*0.7,
                                      child: Text(getProducts[index].productName.toString(),style: TextStyle(fontSize: 13,fontFamily: "Poppins-SemiBold",color: greenBasic),overflow: TextOverflow.ellipsis,)),
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
                                              _incrementCounter(index);
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
                                                                        _event.add(counter2[index]);
                                                                        _event.add(counter3[index]);
                                                                        selectedIndex=index;
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
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Damage Replace",style: TextStyle(fontSize: 12,fontFamily: "Poppins-Medium",color: black)),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          InkWell(
                                            onTap: (){
                                              _incrementCounter2(index);
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
                                              quantityDialog(context, replaceController, (){
                                                if(mounted){
                                                  setState(() {
                                                    counter2[index]=int.parse(replaceController.text.toString());
                                                    _event.add(counter2[index]);
                                                    selectedIndex=index;
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
                                                child: Center(child: Text(counter2[index].toString(),style: TextStyle(fontSize: 12,fontFamily: "Poppins-Medium",color: greenBasic),))
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          InkWell(
                                            onTap: (){
                                              _decrementCounter2(index);
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
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Damage Not Replace",style: TextStyle(fontSize: 12,fontFamily: "Poppins-Medium",color: black)),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          InkWell(
                                            onTap: (){
                                              _incrementCounter3(index);
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
                                              quantityDialog(context, damageController, (){
                                                if(mounted){
                                                  setState(() {
                                                    counter3[index]=int.parse(damageController.text.toString());
                                                    _event.add(counter3[index]);
                                                    selectedIndex=index;
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
                                                child: Center(child: Text(counter3[index].toString(),style: TextStyle(fontSize: 12,fontFamily: "Poppins-Medium",color: greenBasic),))
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          InkWell(
                                            onTap: (){
                                              _decrementCounter3(index);
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
                                      )
                                    ],
                                  ),
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
                                    submitLoading=true;
                                  });
                                }
                                submitMasterSale();

                              }
                            }, color: greenBasic, text: "SUBMIT RETURN SALES")
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

  _incrementCounter(int i) {
    if(mounted){
      setState(() {
        counter[i]++;
        _event.add(counter[i]);
        selectedIndex=i;
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
        }
        _event.add(counter[i]);
      });
    }

  }

  _incrementCounter2(int i) {
    if(mounted){
      setState(() {
        counter2[i]++;
        _event.add(counter2[i]);
        selectedIndex=i;
      });
    }
  }

  _decrementCounter2(int i)  {
    if(mounted){
      setState(() {
        if (counter2[i] <= 0) {
          counter2[i] = 0;
          ToastUtils.infoToast("Quantity is zero", context);
        } else {
          counter2[i]--;
          selectedIndex=i;
        }
        _event.add(counter2[i]);
      });
    }

  }

  _incrementCounter3(int i) {
    if(mounted){
      setState(() {
        counter3[i]++;
        _event.add(counter3[i]);
        selectedIndex=i;
      });
    }
  }

  _decrementCounter3(int i)  {
    if(mounted){
      setState(() {
        if (counter3[i] <= 0) {
          counter3[i] = 0;
          ToastUtils.infoToast("Quantity is zero", context);
        } else {
          counter3[i]--;
          selectedIndex=i;
        }
        _event.add(counter3[i]);
      });
    }

  }
}
