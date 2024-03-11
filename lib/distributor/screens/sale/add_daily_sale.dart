// ignore_for_file: must_be_immutable

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:hbe/distributor/screens/sale/generate_DS.dart';
import 'package:hbe/enums/globals.dart';
import 'package:hbe/widgets/custom_buttons.dart';
import 'package:hbe/widgets/loading_animation.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

import '../../../service/api_urls.dart';
import '../../../utils/app_routes.dart';
import '../../../utils/color_constants.dart';
import '../../../utils/toast_utils.dart';
import '../../../widgets/custom_drop_down.dart';

class DistributorAddDailySale extends StatefulWidget {
  bool isFromStock;
   DistributorAddDailySale({Key? key,required this.isFromStock}) : super(key: key);

  @override
  State<DistributorAddDailySale> createState() => _DistributorAddDailySaleState();
}

class _DistributorAddDailySaleState extends State<DistributorAddDailySale> {
  bool isLoading = true;
  var _selectedCustomer;
  List mappedCustomers = [];
  final Duration initialDelay = const Duration(milliseconds: 100);
  TextEditingController dateController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMappedCustomers();
    dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
  }

  var result12, result22;
  //GET MAPPED CUSTOMERS API
  void getMappedCustomers() async{

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
            _selectedCustomer = mappedCustomers[0]["CustomerID"].toString() + "-" + mappedCustomers[0]["CustomerName"].toString();
            result12 = _selectedCustomer.substring(0, _selectedCustomer.indexOf('-'));
            result22 = _selectedCustomer.substring(_selectedCustomer.indexOf("-") + 1).trim();
            isLoading = false;
          });
        }
      }
      else {
        if(mounted) {
          setState(() {
            mappedCustomers =[];
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
        title: Text("Add Daily Sale",style: TextStyle(fontFamily: "Poppins-Medium",fontSize: 16),),
        centerTitle: true,
      ),
      body: LoadingAnimation(
        inAsyncCall: isLoading,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                        log(_selectedCustomer.toString());
                        log(result12.toString());
                        log(result22.toString());
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
                DelayedDisplay(
                    delay: Duration(
                        milliseconds: initialDelay.inMilliseconds + 200),
                    child: Text("Select Date:",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 14,color: greenBasic))),
                SizedBox(height: 10),
                DelayedDisplay(
                  delay: Duration(
                      milliseconds: initialDelay.inMilliseconds + 200),
                  child: Container(
                    padding: EdgeInsets.zero,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color:  white,
                        boxShadow: [
                          BoxShadow(
                              color: greenBasic.withOpacity(0.25),
                              blurRadius: 2
                          )
                        ]),
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
                DelayedDisplay(
                    delay: Duration(
                        milliseconds: initialDelay.inMilliseconds + 300),
                    child: Align(
                        alignment: Alignment.center,
                        child: CustomButton(onTap: (){
                          if(_selectedCustomer==null){
                            ToastUtils.failureToast("Select Customer", context);
                          }
                          else if(dateController.text.isEmpty){
                            ToastUtils.failureToast("Select Date", context);
                          }
                          else{
                            AppRoutes.push(context, PageTransitionType.fade, DistributorGenerateDS(cID: result12.toString(),date: dateController.text.toString(),));

                          }
                        }, color: greenBasic, text:widget.isFromStock?"GENERATE STOCK DETAIL": "GENERATE DAILY SALE",width: MediaQuery.of(context).size.width,)))
              ],
            ),
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

}
