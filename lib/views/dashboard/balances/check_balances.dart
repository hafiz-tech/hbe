import 'dart:convert';
import 'dart:io';

import 'package:hbe/enums/globals.dart';
import 'package:hbe/utils/app_routes.dart';
import 'package:hbe/views/reports/report_pdf_viewer.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import '../../../service/api_urls.dart';
import '../../../utils/color_constants.dart';
import '../../../utils/toast_utils.dart';
import '../../../widgets/custom_button_icon.dart';
import '../../../widgets/custom_buttons.dart';

class Balances extends StatefulWidget {
  const Balances({Key? key}) : super(key: key);

  @override
  State<Balances> createState() => _BalancesState();
}

class _BalancesState extends State<Balances> {
  bool isLoading = true;
  bool saleReport= false;
  bool attendanceReport=false;
  final Duration initialDelay = const Duration(milliseconds: 100);
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();

  List reportDropDown = [];
  List saleReportDropDown = [];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAttendanceReportName();
    getSaleAndTargetReportName();
    if(mounted){
      setState(() {
        startDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
        endDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
      });
    }
  }

  var _selectedReport;
  // GET ATTENDANCE REPORT LIST API
  Future<void> getAttendanceReportName() async{
    try {
      final response = await http.get(
          Uri.parse('${ApiUrls.baseURL}${ApiUrls.getAttendanceReportName}'),
          headers: {
            ApiUrls.key_name: ApiUrls.apikey,
          });

      var res = json.decode(response.body);

      if (response.statusCode == 200 ) {
        reportDropDown.clear();

        if(mounted) {
          setState(() {
            reportDropDown= res as List;
            _selectedReport=reportDropDown[0].toString();
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

  var _selectedSaleReport;
  // GET SALE REPORT LIST API
  Future<void> getSaleAndTargetReportName() async{
    try {
      final response = await http.get(
          Uri.parse('${ApiUrls.baseURL}${ApiUrls.getSaleAndTargetReportName}'),
          headers: {
            ApiUrls.key_name: ApiUrls.apikey,
          });

      var res = json.decode(response.body);

      if (response.statusCode == 200 ) {
        saleReportDropDown.clear();

        if(mounted) {
          setState(() {
            saleReportDropDown= res as List;
            _selectedSaleReport=saleReportDropDown[0].toString();
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: greenBasic,
        title: Text("Reports",style: TextStyle(fontFamily: "Poppins-Medium",fontSize: 16),),
        centerTitle: true,
      ),
      body:SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10,),
              DelayedDisplay(
                  delay: initialDelay,
                  child: Text("Select From & To Date:",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 14,color: greenBasic))),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DelayedDisplay(
                    delay: Duration(
                        milliseconds: initialDelay.inMilliseconds + 100),
                    child: Container(
                      width: MediaQuery.of(context).size.width*0.45,
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
                          selectDateFrom(context);
                        },
                        child: AbsorbPointer(
                          child: TextFormField(
                            readOnly: true,
                            textAlignVertical: TextAlignVertical.center,
                            controller: startDateController,
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
                              hintText: "Start Date",
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
                  DelayedDisplay(
                    delay: Duration(
                        milliseconds: initialDelay.inMilliseconds + 100),
                    child: Container(
                      width: MediaQuery.of(context).size.width*0.45,
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
                            controller: endDateController,
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
                              hintText: "End Date",
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
                  )
                ],
              ),
              SizedBox(height: 10),
              DelayedDisplay(
                  delay: Duration(
                      milliseconds: initialDelay.inMilliseconds + 150),
                  child: Text("Select Report:",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 14,color: greenBasic))),
              SizedBox(height: 10),
              DelayedDisplay(
                delay: Duration(
                    milliseconds: initialDelay.inMilliseconds + 200),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomButtonIcon(textColor:attendanceReport? white:greenBasic, iconData: FeatherIcons.checkCircle, onTap: (){
                      if(mounted){
                        setState(() {
                          attendanceReport=true;
                          saleReport=false;
                        });
                      }

                    }, color:attendanceReport? greenBasic: white, text: "Attendance"),
                    CustomButtonIcon(textColor:saleReport? white: greenBasic, iconData: FeatherIcons.file, onTap: (){
                      if(mounted){
                        setState(() {
                          attendanceReport=false;
                          saleReport=true;
                        });
                      }

                    }, color:saleReport? greenBasic: white, text: "Sale")
                  ],
                ),
              ),
              SizedBox(height: 20),
              attendanceReport? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DelayedDisplay(
                      delay: Duration(
                          milliseconds: initialDelay.inMilliseconds + 100),
                      child: Text("Select Report Name:",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 14,color: greenBasic))),
                  SizedBox(height: 10),
                  DelayedDisplay(
                    delay: Duration(
                        milliseconds: initialDelay.inMilliseconds + 150),
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: const Color(0xFFA8A8A8)),
                          borderRadius: BorderRadius.circular(10),
                        ),
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
                                  color: greenBasic,
                                ),
                                isExpanded: false,
                                style: TextStyle(
                                    color: black,
                                    fontSize: 15,
                                    fontFamily: 'Poppins-Regular'),
                                onChanged: (String? changedValue) {
                                  if(mounted) {
                                    setState(() {
                                      _selectedReport = changedValue!;
                                    });
                                  }
                                },
                                value: _selectedReport,
                                items: reportDropDown.map((item) {
                                  return DropdownMenuItem(
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width*0.7,
                                      child: Text(
                                        item.toString(),style: TextStyle(
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
                ],
              )
              :const SizedBox(),
              saleReport?Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DelayedDisplay(
                      delay: Duration(
                          milliseconds: initialDelay.inMilliseconds + 100),
                      child: Text("Select Report Name:",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 14,color: greenBasic))),
                  SizedBox(height: 10),
                  DelayedDisplay(
                    delay: Duration(
                        milliseconds: initialDelay.inMilliseconds + 150),
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: const Color(0xFFA8A8A8)),
                          borderRadius: BorderRadius.circular(10),
                        ),
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
                                  color: greenBasic,
                                ),
                                isExpanded: false,
                                style: TextStyle(
                                    color: black,
                                    fontSize: 15,
                                    fontFamily: 'Poppins-Regular'),
                                onChanged: (String? changedValue) {
                                  if(mounted) {
                                    setState(() {
                                      _selectedSaleReport = changedValue!;
                                    });
                                  }
                                },
                                value: _selectedSaleReport,
                                items: saleReportDropDown.map((item) {
                                  return DropdownMenuItem(
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width*0.7,
                                      child: Text(
                                        item.toString(),style: TextStyle(
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
                ],
              )
              :const SizedBox(),
              SizedBox(height: 20),
              DelayedDisplay(
                  delay: Duration(
                      milliseconds: initialDelay.inMilliseconds + 250),
                  child: Align(
                      alignment: Alignment.center,
                      child: CustomButton(onTap: (){
                     if(startDateController.text.isEmpty){
                          ToastUtils.failureToast("Please select start date", context);
                        }
                        else if(endDateController.text.isEmpty){
                          ToastUtils.failureToast("Please select end date", context);
                        }
                        else{
                          AppRoutes.push(context, PageTransitionType.fade, ReportPDFViewer(isSale:attendanceReport? false:true, DM:"0", GM:"0", SDM: "0", SO:globalData.userId.toString(), ST: "0", reportName:attendanceReport? _selectedReport.toString():_selectedSaleReport.toString(), fromDate: startDateController.text.toString(), toDate: endDateController.text.toString()));
                        }

                      }, color: greenBasic, text: "SUBMIT",width: MediaQuery.of(context).size.width*0.85,))),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  DateTime selectedDate = DateTime.now();

  selectDateFrom(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1947),
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
        startDateController.text =
            DateFormat('yyyy-MM-dd').format(selectedDate).toString();
      });
    } else if (selected != null && selected == selectedDate) {
      setState(() {
        selectedDate = selected;
        startDateController.text =
            DateFormat('yyyy-MM-dd').format(selectedDate).toString();
      });
    }
  }

  DateTime selectedDate2 = DateTime.now();

  selectDateTo(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: selectedDate2,
      firstDate: DateTime(1947),
      lastDate: DateTime.now(),
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
        endDateController.text =
            DateFormat('yyyy-MM-dd').format(selectedDate2).toString();
      });
    } else if (selected != null && selected == selectedDate2) {
      setState(() {
        selectedDate2 = selected;
        endDateController.text = DateFormat('yyyy-MM-dd').format(selectedDate2).toString();
      });
    }
  }
}
