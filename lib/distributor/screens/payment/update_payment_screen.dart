// ignore_for_file: must_be_immutable

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:hbe/enums/globals.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../models/payment_model.dart';
import '../../../service/api_urls.dart';
import '../../../utils/app_routes.dart';
import '../../../utils/color_constants.dart';
import '../../../utils/toast_utils.dart';
import '../../../widgets/custom_buttons.dart';
import '../../../widgets/custom_drop_down.dart';
import '../../../widgets/loading_animation.dart';

class UpdatePaymentScreen extends StatefulWidget {
  PaymentData paymentData;
  UpdatePaymentScreen({Key? key,required this.paymentData}) : super(key: key);

  @override
  State<UpdatePaymentScreen> createState() => _UpdatePaymentScreenState();
}

class _UpdatePaymentScreenState extends State<UpdatePaymentScreen> {
  TextEditingController dateController = TextEditingController();
  TextEditingController chequeDateController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController remarksController = TextEditingController();
  TextEditingController chequeController = TextEditingController();
  TextEditingController bankController= TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final Duration initialDelay = const Duration(milliseconds: 100);
  var _selectedCustomer;
  bool showOther = false;
  bool isLoading = false;
  List mappedCustomers = [];

  String selectedType="Cash";
  List items=["Cash","Bank"];

  String selectedTrans="Cheque";
  List items2=["Cheque","Online"];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMappedCustomers();
  }

  void setValues() {
    if(mounted){
      setState(() {
       _selectedCustomer =  widget.paymentData.customerId.toString() + "-" +  widget.paymentData.customerName.toString();
       log(_selectedCustomer.toString());
       result12 = _selectedCustomer.substring(0, _selectedCustomer.indexOf('-'));
       result22 = _selectedCustomer.substring(_selectedCustomer.indexOf("-") + 1).trim();
       log(result12.toString());
       log(result22.toString());
        dateController.text = DateFormat('yyyy-MM-dd').format(widget.paymentData.receivedDate!).toString();
        amountController.text =widget.paymentData.receivedAmount.toString();
        remarksController.text =widget.paymentData.remarks.toString();
        if(widget.paymentData.paymentType.toString()=="Bank"){
          selectedType=widget.paymentData.paymentType.toString();
          bankController.text =widget.paymentData.bankName.toString();
          selectedTrans=widget.paymentData.transType.toString();
          if(widget.paymentData.transType=="Cheque"){
            chequeController.text =widget.paymentData.chequeNo.toString();
            chequeDateController.text = DateFormat('yyyy-MM-dd').format(widget.paymentData.chequeDate!).toString();
          }
        }

      });
    }

  }

  var result12, result22;
  //GET MAPPED CUSTOMERS API
  void getMappedCustomers() async{
    mappedCustomers.clear();
    try {
      final response = await http.get(
          Uri.parse('${ApiUrls.distributorUrl}${ApiUrls.getMappedCustomer2}?UserID=${globalData.userId}'),
          headers: {
            ApiUrls.key_name: ApiUrls.apikey,
          });

      var res = json.decode(response.body);


      if (response.statusCode == 200 ) {

        if(mounted) {
          setState(() {
            mappedCustomers= res as List;
           // _selectedCustomer = mappedCustomers[0]["CustomerName"].toString() + "-" + mappedCustomers[0]["CustomerID"].toString();
           //  result12 = _selectedCustomer.substring(0, _selectedCustomer.indexOf('-'));
           //  result22 = _selectedCustomer.substring(_selectedCustomer.indexOf("-") + 1).trim();
            isLoading = false;
            showOther = false;
          });
        }
        setValues();
      }
      else {
        if(mounted) {
          setState(() {
            mappedCustomers =[];
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

  //UPDATE PAYMENT
  Future<void> updatePayment() async{
    try {
      final response = await http.post(
          Uri.parse('${ApiUrls.distributorUrl}${ApiUrls.updatePaymentReceived}?ID=${widget.paymentData.id}&UserID=${globalData.userId.toString()}&CustomerID=$result12&ReceivedAmount=${amountController.text.toString()}&ReceivedDate=${dateController.text.toString()}&PaymentType=$selectedType&TransType=${selectedType=="Cash"?"":selectedTrans}&BankName=${bankController.text.toString()}&ChequeNo=${selectedTrans=="Cheque"?chequeController.text:""}&ChequeDate=${selectedType=="Cash"?"":selectedTrans=="Cheque"?chequeDateController.text.toString():""}&Remarks=${remarksController.text.toString()}'),
          headers: {
            ApiUrls.key_name: ApiUrls.apikey,
          });

      var res = json.decode(response.body);
      log(res.toString());

      if (response.statusCode == 200 && res["RetCode"]=="0001") {
        ToastUtils.successToast(res["RetMsg"].toString(), context);
        if(mounted) {
          setState(() {
            isLoading = false;
          });
        }
        AppRoutes.pop(context);
      }
      else {
        ToastUtils.failureToast(res["RetMsg"].toString(), context);
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
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    mappedCustomers.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: greenBasic,
        title: Text("Update Payment",style: TextStyle(fontFamily: "Poppins-Medium",fontSize: 16),),
        centerTitle: true,
      ),
      body: LoadingAnimation(
        inAsyncCall: isLoading,
        child: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.all(15.0),
              child:Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //SELECT CUSTOMER
                  DelayedDisplay(
                      delay: initialDelay,
                      child: Text("Select Customer:",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 14,color: greenBasic))),
                  SizedBox(height: 10),
                  DelayedDisplay(
                    delay: Duration(
                        milliseconds: initialDelay.inMilliseconds + 100),
                    child: Align(
                      alignment: Alignment.center,
                      child: CustomDropDown(
                        hint: "Search customer..",
                        searchFieldController: searchController,
                        initialValue: _selectedCustomer.toString(),
                        items: mappedCustomers.map((item) {
                          return DropdownMenuItem(
                            child: SizedBox(
                              width:
                              MediaQuery.of(context).size.width *
                                  0.7,
                              child: Text(
                                item["CustomerName"].toString(),
                                style: TextStyle(
                                    color: black,
                                    fontSize:14,
                                    fontFamily: 'Poppins-Regular'),
                              ),
                            ),
                            value:item["CustomerID"].toString() + "-" + item["CustomerName"].toString(),
                          );
                        }).toList(),
                        onChanged: (changedValue) {
                          if (mounted) {
                            setState(() {
                              _selectedCustomer = changedValue!;
                              result12 = _selectedCustomer
                                  .substring(
                                  0,
                                  _selectedCustomer
                                      .indexOf('-'));
                              result22 = _selectedCustomer
                                  .substring(_selectedCustomer
                                  .indexOf("-") +
                                  1)
                                  .trim();
                            });
                          }
                        },
                        searchMatchFn: (item, searchValue) {
                          return (item.value
                              .toString()
                              .toLowerCase()
                              .contains(searchValue.toLowerCase()));
                        },
                        onMenuStateChange: (isOpen) {
                          if (!isOpen) {
                            searchController.clear();
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  //RECEIVED DATE
                  DelayedDisplay(
                      delay: Duration(
                          milliseconds: initialDelay.inMilliseconds + 200),
                      child: Text("Received Date:",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 14,color: greenBasic))),
                  SizedBox(height: 10),
                  DelayedDisplay(
                    delay: Duration(
                        milliseconds: initialDelay.inMilliseconds + 200),
                    child: Container(
                      padding: EdgeInsets.zero,
                      decoration: BoxDecoration(
                          border:
                          Border.all(color: Colors.black.withOpacity(0.25), width: 1),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: GestureDetector(
                        onTap: () {
                          selectDateTo(context);
                        },
                        child: AbsorbPointer(
                          child: TextFormField(
                            readOnly: true,
                            textAlignVertical: TextAlignVertical.center,
                            controller: dateController,
                            style: TextStyle(
                                fontFamily: 'Poppins-Regular',
                                fontSize: 14,
                                color: greenBasic
                            ),
                            decoration: InputDecoration(
                              suffixIcon: Container(
                                  height: 20,
                                  width: 20,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10),
                                  child: Icon(FeatherIcons.calendar,color: greenBasic,)),
                              isDense: true,
                              fillColor: white,
                              filled: true,
                              hintText: "Leave Date",
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
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  //RECEIVED AMOUNT
                  DelayedDisplay(
                      delay: Duration(
                          milliseconds: initialDelay.inMilliseconds + 250),
                      child: Text("Received Amount:",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 14,color: greenBasic))),
                  SizedBox(height: 10),
                  DelayedDisplay(
                    delay: Duration(
                        milliseconds: initialDelay.inMilliseconds + 250),
                    child: Container(
                      padding: EdgeInsets.zero,

                      decoration: BoxDecoration(
                          border:
                          Border.all(color: Colors.black.withOpacity(0.25), width: 1),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: TextFormField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          isDense: true,
                          fillColor: white,
                          filled: true,
                          floatingLabelBehavior:
                          FloatingLabelBehavior.never,
                          hintText: "Enter your amount",
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
                  ),
                  SizedBox(height: 20),
                  //PAYMENT TYPE
                  DelayedDisplay(
                      delay: Duration(
                          milliseconds: initialDelay.inMilliseconds + 300),
                      child: Text("Payment Type:",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 14,color: greenBasic))),
                  SizedBox(height: 10),
                  DelayedDisplay(
                    delay: Duration(
                        milliseconds: initialDelay.inMilliseconds + 300),
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 40,
                        decoration: BoxDecoration(
                            border:
                            Border.all(color: Colors.black.withOpacity(0.25), width: 1),
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding:
                          const EdgeInsets.only(left: 10.0, right: 10.0),
                          child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                menuMaxHeight: 350,
                                borderRadius: BorderRadius.circular(10),
                                icon: Icon(
                                  FeatherIcons.chevronDown,
                                  size: 20,
                                ),
                                isExpanded: false,
                                style: TextStyle(
                                    color: black,
                                    fontSize: 15,
                                    fontFamily: 'Poppins-Regular'),
                                onChanged: (String? changedValue) {
                                  if(mounted) {
                                    setState(() {
                                      selectedType = changedValue!;
                                    });
                                  }
                                },
                                value: selectedType,
                                items: items.map((item) {
                                  return DropdownMenuItem(
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width*0.7,
                                      child: Text(item,style: TextStyle(
                                          color: black,
                                          fontSize: 12,
                                          fontFamily: 'Poppins-Medium'),
                                      ),
                                    ),
                                    value: item.toString(),
                                  );
                                }).toList(),
                              )),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  selectedType=="Bank"? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DelayedDisplay(
                          delay: Duration(
                              milliseconds: initialDelay.inMilliseconds + 300),
                          child: Text("Trans Type:",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 14,color: greenBasic))),
                      SizedBox(height: 10),
                      DelayedDisplay(
                        delay: Duration(
                            milliseconds: initialDelay.inMilliseconds + 300),
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 40,
                            decoration: BoxDecoration(
                                border:
                                Border.all(color: Colors.black.withOpacity(0.25), width: 1),
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding:
                              const EdgeInsets.only(left: 10.0, right: 10.0),
                              child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    menuMaxHeight: 350,
                                    borderRadius: BorderRadius.circular(10),
                                    icon: Icon(
                                      FeatherIcons.chevronDown,
                                      size: 20,
                                    ),
                                    isExpanded: false,
                                    style: TextStyle(
                                        color: black,
                                        fontSize: 15,
                                        fontFamily: 'Poppins-Regular'),
                                    onChanged: (String? changedValue) {
                                      if(mounted) {
                                        setState(() {
                                          selectedTrans = changedValue!;
                                        });
                                      }
                                    },
                                    value: selectedTrans,
                                    items: items2.map((item) {
                                      return DropdownMenuItem(
                                        child: SizedBox(
                                          width: MediaQuery.of(context).size.width*0.7,
                                          child: Text(item,style: TextStyle(
                                              color: black,
                                              fontSize: 12,
                                              fontFamily: 'Poppins-Medium'),
                                          ),
                                        ),
                                        value: item.toString(),
                                      );
                                    }).toList(),
                                  )),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      //BANK NAME
                      DelayedDisplay(
                          delay: Duration(
                              milliseconds: initialDelay.inMilliseconds + 100),
                          child: Text("Bank Name:",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 14,color: greenBasic))),
                      SizedBox(height: 10),
                      DelayedDisplay(
                        delay: Duration(
                            milliseconds: initialDelay.inMilliseconds + 100),
                        child: Container(
                          padding: EdgeInsets.zero,

                          decoration: BoxDecoration(
                              border:
                              Border.all(color: Colors.black.withOpacity(0.25), width: 1),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: TextFormField(
                            controller: bankController,
                            decoration: InputDecoration(
                              isDense: true,
                              fillColor: white,
                              filled: true,
                              floatingLabelBehavior:
                              FloatingLabelBehavior.never,
                              hintText: "Enter bank number",
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
                      ),
                      SizedBox(height: 20),
                      selectedTrans.toString()=="Cheque"? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          //CHEQUE NO
                          DelayedDisplay(
                              delay: Duration(
                                  milliseconds: initialDelay.inMilliseconds + 120),
                              child: Text("Cheque Number:",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 14,color: greenBasic))),
                          SizedBox(height: 10),
                          DelayedDisplay(
                            delay: Duration(
                                milliseconds: initialDelay.inMilliseconds + 120),
                            child: Container(
                              padding: EdgeInsets.zero,

                              decoration: BoxDecoration(
                                  border:
                                  Border.all(color: Colors.black.withOpacity(0.25), width: 1),
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)),
                              child: TextFormField(
                                controller: chequeController,
                                decoration: InputDecoration(
                                  isDense: true,
                                  fillColor: white,
                                  filled: true,
                                  floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
                                  hintText: "Enter your cheque number",
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
                          ),
                          SizedBox(height: 20),
                          //CHEQUE DATE
                          DelayedDisplay(
                              delay: Duration(
                                  milliseconds: initialDelay.inMilliseconds + 150),
                              child: Text("Cheque Date:",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 14,color: greenBasic))),
                          SizedBox(height: 10),
                          DelayedDisplay(
                            delay: Duration(
                                milliseconds: initialDelay.inMilliseconds + 200),
                            child: Container(
                              padding: EdgeInsets.zero,
                              decoration: BoxDecoration(
                                  border:
                                  Border.all(color: Colors.black.withOpacity(0.25), width: 1),
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)),
                              child: GestureDetector(
                                onTap: () {
                                  selectDateTo2(context);
                                },
                                child: AbsorbPointer(
                                  child: TextFormField(
                                    readOnly: true,
                                    textAlignVertical: TextAlignVertical.center,
                                    controller: chequeDateController,
                                    style: TextStyle(
                                        fontFamily: 'Poppins-Regular',
                                        fontSize: 14,
                                        color: greenBasic
                                    ),
                                    decoration: InputDecoration(
                                      suffixIcon: Container(
                                          height: 20,
                                          width: 20,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: Icon(FeatherIcons.calendar,color: greenBasic,)),
                                      isDense: true,
                                      fillColor: white,
                                      filled: true,
                                      hintText: "Cheque Date",
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
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      )
                      :const SizedBox(),
                    ],
                  )
                      :const SizedBox(),
                  //REMARKS
                  DelayedDisplay(
                      delay: Duration(
                          milliseconds: initialDelay.inMilliseconds + 400),
                      child: Text("Remarks:",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 14,color: greenBasic))),
                  SizedBox(height: 10),
                  DelayedDisplay(
                    delay: Duration(
                        milliseconds: initialDelay.inMilliseconds + 400),
                    child: Container(
                      padding: EdgeInsets.zero,

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
                          floatingLabelBehavior:
                          FloatingLabelBehavior.never,
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
                  ),
                  SizedBox(height: 20),
                  DelayedDisplay(
                      delay: Duration(
                          milliseconds: initialDelay.inMilliseconds + 300),
                      child: Align(
                          alignment: Alignment.center,
                          child: CustomButton(
                            onTap: (){
                              if(_selectedCustomer==null){
                                ToastUtils.failureToast("Select Customer", context);
                              }
                              else if(dateController.text.isEmpty){
                                ToastUtils.failureToast("Select Date", context);
                              }
                              else if(amountController.text.isEmpty){
                                ToastUtils.failureToast("Enter Amount", context);
                              }
                              else if(selectedType=="Bank"){
                                if(selectedTrans=="Cheque"){
                                  if(bankController.text.isEmpty){
                                    ToastUtils.failureToast("Enter bank name", context);
                                  }
                                  else  if(chequeController.text.isEmpty){
                                    ToastUtils.failureToast("Enter cheque number", context);
                                  }
                                  else{
                                    if(remarksController.text.isEmpty){
                                      ToastUtils.failureToast("Enter remarks", context);
                                    }
                                    else{
                                      if(mounted){
                                        setState(() {
                                          isLoading = true;
                                        });
                                      }
                                      updatePayment();
                                    }
                                  }
                                }
                                else{
                                  if(bankController.text.isEmpty){
                                    ToastUtils.failureToast("Enter bank name", context);
                                  }
                                  else if(remarksController.text.isEmpty){
                                    ToastUtils.failureToast("Enter remarks", context);
                                  }
                                  else{
                                    if(mounted){
                                      setState(() {
                                        isLoading = true;
                                      });
                                    }
                                    updatePayment();
                                  }
                                }
                              }
                              else if(remarksController.text.isEmpty){
                                ToastUtils.failureToast("Enter remarks", context);
                              }
                              else{
                                if(mounted){
                                  setState(() {
                                    isLoading = true;
                                  });
                                }
                                updatePayment();
                              }
                            }, color: greenBasic, text:"SUBMIT",width: MediaQuery.of(context).size.width,)))
                ],
              )
          ),
        ),
      ),
    );
  }

  DateTime selectedDate = DateTime.now();

  selectDateTo(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(Duration(days: 1)),
      lastDate: DateTime(2200),
      helpText: "SELECT TO DATE",
      fieldHintText: "YEAR/MONTH/DATE",
      fieldLabelText: "TO DATE",
      errorFormatText: "Enter a Valid Date",
      errorInvalidText: "Date Out of Range",
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: greenBasic, // header background color
              onPrimary: white, // header text color
              onSurface: greenBasic, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                primary: greenBasic, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (selected != null && selected != selectedDate) {
      setState(() {
        selectedDate = selected;
        dateController.text =
            DateFormat('yyyy-MM-dd').format(selectedDate).toString();
      });
    } else if (selected != null && selected == selectedDate) {
      setState(() {
        selectedDate = selected;
        dateController.text =
            DateFormat('yyyy-MM-dd').format(selectedDate).toString();
      });
    }
  }

  DateTime selectedDate2 = DateTime.now();

  selectDateTo2(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: selectedDate2,
      firstDate: DateTime(1920),
      lastDate: DateTime(2050),
      helpText: "SELECT TO DATE",
      fieldHintText: "YEAR/MONTH/DATE",
      fieldLabelText: "TO DATE",
      errorFormatText: "Enter a Valid Date",
      errorInvalidText: "Date Out of Range",
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: greenBasic, // header background color
              onPrimary: white, // header text color
              onSurface: greenBasic, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                primary: greenBasic, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (selected != null && selected != selectedDate2) {
      setState(() {
        selectedDate2 = selected;
        chequeDateController.text =
            DateFormat('yyyy-MM-dd').format(selectedDate2).toString();
      });
    } else if (selected != null && selected == selectedDate2) {
      setState(() {
        selectedDate2 = selected;
        chequeDateController.text =
            DateFormat('yyyy-MM-dd').format(selectedDate2).toString();
      });
    }
  }


}
