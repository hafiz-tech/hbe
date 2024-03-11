import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:hbe/enums/globals.dart';
import 'package:hbe/views/sales/manage_po.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import '../../../models/total_products_model.dart';
import '../../../service/api_urls.dart';
import '../../../utils/app_routes.dart';
import '../../../utils/color_constants.dart';
import '../../../utils/toast_utils.dart';
import '../../../widgets/custom_buttons.dart';
import '../../../widgets/loading_animation.dart';

class GeneratePO extends StatefulWidget {
  final String cID;
  final String date;
  const GeneratePO({Key? key,required this.cID,required this.date}) : super(key: key);

  @override
  State<GeneratePO> createState() => _GeneratePOState();
}

class _GeneratePOState extends State<GeneratePO> {
  var selectedIndex;
  List<GetTotalProducts> getProducts=[];
  bool isLoading = true;
  bool showOther = false;
  bool submitLoading = false;
  final Duration initialDelay = const Duration(milliseconds: 100);
  TextEditingController remarksController = TextEditingController();
  TextEditingController quantityController= TextEditingController();
  int detailMethodCount = 0;
  String originalPrice="";
  int price=0;

  StreamController _event =StreamController<int>.broadcast();
  List<int> counter =[];
  List<int> prices =[];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTotalProducts();
    _event.add(0);
   // poCartProvider = Provider.of<POCartProvider>(context, listen: false);
  }

  //GET TOTAL PRODUCTS API
  Future<void> getTotalProducts() async {

    try {
      final response = await http.get(
          Uri.parse('${ApiUrls.baseURL}${ApiUrls.getProductListByCustomer}?CustomerID=${widget.cID}'),
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

  var invoiceID;
  //SUBMIT MASTER SALE
  Future<void> submitMasterSale() async{

    try {
      final response = await http.post(
          Uri.parse('${ApiUrls.baseURL}${ApiUrls.submitMasterPO}?PODate=${widget.date}&CustomerID=${widget.cID}&Remarks=${remarksController.text.toString()}&UserID=${globalData.userId}'),
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
            if (detailMethodCount < getProducts.length) {

              submitDetailPO(getProducts[i].productId.toString(),counter[i].toString(),false);
            }
            else{
              submitDetailPO(getProducts[i].productId.toString(),counter[i].toString(),true);

            }
          }});
      }
      else {
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

  //SUBMIT PO DETAIL API
  Future<void> submitDetailPO(String poID, String quantity, bool isLast) async{

    try {
      final response = await http.post(
          Uri.parse('${ApiUrls.baseURL}${ApiUrls.submitDetPO}?POID=$invoiceID&ProductID=$poID&CustomerId=${widget.cID}&Quantity=$quantity&IslastEntry=$isLast'),
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
       if(isLast){
         ToastUtils.successToast("Purchase Order added successfully!", context);

         Future.delayed(Duration(seconds: 1),(){
           AppRoutes.pushAndRemoveUntil(context, ManagePO());
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
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    getProducts.clear();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: greenBasic,
        title: Text("Purchase Order",style: TextStyle(fontFamily: "Poppins-Medium",fontSize: 16),),
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
                      child:Column(
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
                              }, color: greenBasic, text: "SUBMIT PURCHASE ORDER")
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
       originalPrice = double.parse(getProducts[i].productSalaPrice.toString()).toStringAsFixed(0);
       prices[i] = (double.parse(originalPrice.toString()) * double.parse(counter[i].toString())).toInt();
     });
   }
  }


  _decrementCounter(int i) {
    if(mounted){
      setState(() {
        if (counter[i] <= 0) {
          counter[i] = 0;
          ToastUtils.infoToast("Quantity is zero", context);
        } else {
          counter[i]--;
          selectedIndex=i;
          originalPrice = double.parse(getProducts[i].productSalaPrice.toString()).toStringAsFixed(0);
          prices[i] = (double.parse(prices[i].toString()) - double.parse(originalPrice.toString())).toInt();

        }
        _event.add(counter[i]);
      });
    }

  }
}
