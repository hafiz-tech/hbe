import 'dart:convert';
import 'dart:io';
import 'package:hbe/enums/globals.dart';
import 'package:hbe/utils/app_routes.dart';
import 'package:hbe/views/reports/report_pdf_viewer.dart';
import 'package:hbe/widgets/loading_animation.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import '../../models/employee_list_model.dart';
import '../../service/api_urls.dart';
import '../../utils/color_constants.dart';
import '../../utils/toast_utils.dart';
import '../../widgets/custom_buttons.dart';
import '../../widgets/navDrawer.dart';

class AttendanceReports extends StatefulWidget {
  const AttendanceReports({Key? key}) : super(key: key);

  @override
  State<AttendanceReports> createState() => _AttendanceReportsState();
}

class _AttendanceReportsState extends State<AttendanceReports> {
  bool isLoading = true;
  final Duration initialDelay = const Duration(milliseconds: 100);
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();

  var _selectedGM;
  var _selectedST;
  var _selectedRegion;
  var _selectedCity;
  var _selectedSO;
  var _selectedReport;

  List<EMPTable> gmDropDown=[];
  List<EMPTable> allGmDropDown=[];

  List<EMPTable> stDropDown=[];
  List<EMPTable> allStDropDown=[];

  List<EMPTable> regionDropDown=[];
  List<EMPTable> allRegionDropDown=[];

  List<EMPTable> cityDropDown=[];
  List<EMPTable> allCityDropDown=[];

  List<EMPTable> soDropDown=[];
  List<EMPTable> allSoDropDown=[];

  bool regionAll= false;
  bool cityAll= false;
  bool soAll= false;


  List reportDropDown = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getEmpList();
    getAttendanceReportName();
    if(mounted){
      setState(() {
        startDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
        endDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
        regionAll= true;
        cityAll= true;
        soAll= true;
      });
    }
  }

  // GET ALL DROPDOWNS LIST API
  Future<void> getEmpList() async{
    try {
      final response = await http.get(
          Uri.parse('${ApiUrls.baseURL}${ApiUrls.getEmployeeList}?UserID=${globalData.userId}'),
          headers: {
            ApiUrls.key_name: ApiUrls.apikey,
          });

      var res = json.decode(response.body);

      if (response.statusCode == 200 ) {
        gmDropDown.clear();
        stDropDown.clear();
        regionDropDown.clear();
        cityDropDown.clear();
        soDropDown.clear();
        allCityDropDown.clear();
        allRegionDropDown.clear();
        allGmDropDown.clear();
        allStDropDown.clear();
        allSoDropDown.clear();


        var table=res["Table"];
        var table1=res["Table1"];
        var table2=res["Table2"];
        var table3=res["Table3"];
        var table4=res["Table4"];

        for (int i = 0; i < table.length; i++) {
          gmDropDown.add(EMPTable.fromJson(table[i]));
          allGmDropDown.add(EMPTable.fromJson(table[i]));
        }
        for (int i = 0; i < table1.length; i++) {
          stDropDown.add(EMPTable.fromJson(table1[i]));
          allStDropDown.add(EMPTable.fromJson(table1[i]));
        }
        for (int i = 0; i < table2.length; i++) {
          regionDropDown.add(EMPTable.fromJson(table2[i]));
          allRegionDropDown.add(EMPTable.fromJson(table2[i]));
        }
        for (int i = 0; i < table3.length; i++) {
          cityDropDown.add(EMPTable.fromJson(table3[i]));
          allCityDropDown.add(EMPTable.fromJson(table3[i]));
        }
        for (int i = 0; i < table4.length; i++) {
          soDropDown.add(EMPTable.fromJson(table4[i]));
          allSoDropDown.add(EMPTable.fromJson(table4[i]));
        }
        if(mounted) {
          setState(() {
             _selectedGM=gmDropDown[0].gm.toString();
              stDropDown = stDropDown.where((data) => data.gm.toString() ==gmDropDown[0].gm.toString()).toList();
             _selectedST=stDropDown[0].st.toString();
            // regionDropDown = regionDropDown.where((data) => data.st.toString() ==stDropDown[0].st.toString()).toList();
            // _selectedRegion=regionDropDown[0].userId.toString();
            // cityDropDown= cityDropDown.where((data) => data.dm.toString() ==regionDropDown[0].userId.toString()).toList();
            // _selectedCity=cityDropDown[0].userId.toString();
            // soDropDown = soDropDown.where((data) => data.sdm.toString() ==cityDropDown[0].userId.toString()).toList();
            // _selectedSO=soDropDown[0].userId.toString();
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

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    gmDropDown.clear();
    stDropDown.clear();
    regionDropDown.clear();
    cityDropDown.clear();
    soDropDown.clear();
    allCityDropDown.clear();
    allRegionDropDown.clear();
    allGmDropDown.clear();
    allStDropDown.clear();
    allSoDropDown.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: greenBasic,
        title: Text("Attendance Report",style: TextStyle(fontFamily: "Poppins-Medium",fontSize: 16),),
        centerTitle: true,
      ),
      drawer: DrawerWidget(),
      body: LoadingAnimation(
        inAsyncCall: isLoading,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //GM SELECT
                DelayedDisplay(
                    delay: initialDelay,
                    child: Text("Select GM:",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 14,color: greenBasic))),
                SizedBox(height: 10),
                DelayedDisplay(
                  delay: Duration(
                      milliseconds: initialDelay.inMilliseconds + 100),
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
                                    _selectedGM = changedValue!;
                                    _selectedST=null;
                                    _selectedRegion=null;
                                    _selectedCity=null;
                                    _selectedSO=null;
                                    regionDropDown.clear();
                                    cityDropDown.clear();
                                    soDropDown.clear();
                                    stDropDown = allStDropDown.where((data) => data.gm.toString() == _selectedGM.toString()).toList();
                                    if(stDropDown.length==0){
                                      ToastUtils.failureToast("No ST Found", context);
                                    }
                                    else{
                                      _selectedST=stDropDown[0].st.toString();
                                    }
                                  });
                                }

                              },
                              value: _selectedGM,
                              items: gmDropDown.map((item) {
                                return DropdownMenuItem(
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width*0.7,
                                    child: Text(
                                      item.userName.toString(),style: TextStyle(
                                        color: black,
                                        fontSize: 12,
                                        fontFamily: 'Poppins-Medium'),
                                    ),
                                  ),
                                  value: item.gm.toString(),
                                );
                              }).toList(),
                            )),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                //ST SELECT
                DelayedDisplay(
                    delay: Duration(
                        milliseconds: initialDelay.inMilliseconds + 200),
                    child: Text("Select ST:",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 14,color: greenBasic))),
                SizedBox(height: 10),
                DelayedDisplay(
                  delay: Duration(
                      milliseconds: initialDelay.inMilliseconds + 250),
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
                                    _selectedST = changedValue!;
                                    _selectedRegion=null;
                                    _selectedCity=null;
                                    _selectedSO=null;
                                    regionDropDown= allRegionDropDown.where((data) => data.st.toString() == _selectedST.toString()).toList();
                                    if(regionDropDown.length==0){
                                      ToastUtils.failureToast("No Region Found", context);
                                    }
                                    else{
                                      _selectedRegion=regionDropDown[0].userId.toString();
                                    }
                                  });
                                }
                              },
                              value: _selectedST,
                              items: stDropDown.map((item) {
                                return DropdownMenuItem(
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width*0.7,
                                    child: Text(
                                      item.userName.toString(),style: TextStyle(
                                        color: black,
                                        fontSize: 12,
                                        fontFamily: 'Poppins-Medium'),
                                    ),
                                  ),
                                  value: item.st.toString(),
                                );
                              }).toList(),
                            )),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                //REGION SELECT
                DelayedDisplay(
                    delay: Duration(
                        milliseconds: initialDelay.inMilliseconds + 300),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Select Region:",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 14,color: greenBasic)),
                        Row(
                          children: <Widget>[
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                  color:greenBasic.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(3)),
                              child: Theme(
                                data: ThemeData(unselectedWidgetColor: greenBasic.withOpacity(0.2)),
                                child: Checkbox(
                                    value: regionAll,
                                    activeColor: greenBasic,
                                    onChanged: (val){
                                      if(mounted){
                                        setState(() {
                                          regionAll=val!;
                                        });
                                      }
                                    }),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'All',
                              style: TextStyle(fontSize: 14, color: greenBasic,fontFamily: 'Poppins-Medium'),
                            ),
                          ],
                        )
                      ],
                    )),
                SizedBox(height: 10),
                regionAll?const SizedBox():DelayedDisplay(
                  delay: Duration(
                      milliseconds: initialDelay.inMilliseconds + 350),
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
                                    _selectedRegion = changedValue!;
                                    _selectedCity=null;
                                    _selectedSO=null;
                                    cityDropDown.clear();
                                    soDropDown.clear();
                                    cityDropDown = allCityDropDown.where((data) => data.dm.toString() == _selectedRegion.toString()).toList();
                                    if(cityDropDown.length==0){
                                      ToastUtils.failureToast("No City Team Found", context);
                                    }
                                    else{
                                      _selectedCity=cityDropDown[0].userId.toString();
                                    }

                                  });
                                }
                              },
                              value: _selectedRegion,
                              items: regionDropDown.map((item) {
                                return DropdownMenuItem(
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width*0.7,
                                    child: Text(
                                      item.userName.toString(),style: TextStyle(
                                        color: black,
                                        fontSize: 12,
                                        fontFamily: 'Poppins-Medium'),
                                    ),
                                  ),
                                  value: item.userId.toString(),
                                );
                              }).toList(),
                            )),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                //CITY SELECT
                DelayedDisplay(
                    delay: Duration(
                        milliseconds: initialDelay.inMilliseconds + 400),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Select City Team:",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 14,color: greenBasic)),
                        Row(
                          children: <Widget>[
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                  color:greenBasic.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(3)),
                              child: Theme(
                                data: ThemeData(unselectedWidgetColor: greenBasic.withOpacity(0.2)),
                                child: Checkbox(
                                    value: cityAll,
                                    activeColor: greenBasic,
                                    onChanged: (val){
                                      if(mounted){
                                        setState(() {
                                          cityAll=val!;
                                        });
                                      }
                                    }),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'All',
                              style: TextStyle(fontSize: 14, color: greenBasic,fontFamily: 'Poppins-Medium'),
                            ),
                          ],
                        )
                      ],
                    )),
                SizedBox(height: 10),
               cityAll?const SizedBox():DelayedDisplay(
                  delay: Duration(
                      milliseconds: initialDelay.inMilliseconds + 450),
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
                                    _selectedCity = changedValue!;
                                    _selectedSO=null;
                                    soDropDown = allSoDropDown.where((data) => data.sdm.toString() == _selectedCity.toString()).toList();
                                    if(soDropDown.length==0){
                                      ToastUtils.failureToast("No Sale Officer Found", context);
                                    }
                                    else{
                                      _selectedSO=soDropDown[0].userId.toString();
                                    }
                                  });
                                }
                              },
                              value: _selectedCity,
                              items: cityDropDown.map((item) {
                                return DropdownMenuItem(
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width*0.7,
                                    child: Text(
                                      item.userName.toString(),style: TextStyle(
                                        color: black,
                                        fontSize: 12,
                                        fontFamily: 'Poppins-Medium'),
                                    ),
                                  ),
                                  value: item.userId.toString(),
                                );
                              }).toList(),
                            )),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                //SO SELECT
                DelayedDisplay(
                    delay: Duration(
                        milliseconds: initialDelay.inMilliseconds + 500),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Select Sale Officer:",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 14,color: greenBasic)),
                        Row(
                          children: <Widget>[
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                  color:greenBasic.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(3)),
                              child: Theme(
                                data: ThemeData(unselectedWidgetColor: greenBasic.withOpacity(0.2)),
                                child: Checkbox(
                                    value: soAll,
                                    activeColor: greenBasic,
                                    onChanged: (val){
                                      if(mounted){
                                        setState(() {
                                          soAll=val!;
                                        });
                                      }
                                    }),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'All',
                              style: TextStyle(fontSize: 14, color: greenBasic,fontFamily: 'Poppins-Medium'),
                            ),
                          ],
                        )
                      ],
                    )),
                SizedBox(height: 10),
                soAll?const SizedBox():DelayedDisplay(
                  delay: Duration(
                      milliseconds: initialDelay.inMilliseconds + 550),
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
                                    _selectedSO = changedValue!;
                                  });
                                }
                              },
                              value: _selectedSO,
                              items: soDropDown.map((item) {
                                return DropdownMenuItem(
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width*0.7,
                                    child: Text(
                                      item.userName.toString(),style: TextStyle(
                                        color: black,
                                        fontSize: 12,
                                        fontFamily: 'Poppins-Medium'),
                                    ),
                                  ),
                                  value: item.userId.toString(),
                                );
                              }).toList(),
                            )),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                DelayedDisplay(
                    delay: Duration(
                        milliseconds: initialDelay.inMilliseconds + 500),
                    child: Text("Select From & To Date:",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 14,color: greenBasic))),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   DelayedDisplay(
                     delay: Duration(
                         milliseconds: initialDelay.inMilliseconds + 600),
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
                         milliseconds: initialDelay.inMilliseconds + 600),
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
                        milliseconds: initialDelay.inMilliseconds + 650),
                    child: Text("Select Report Name:",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 14,color: greenBasic))),
                SizedBox(height: 10),
                DelayedDisplay(
                  delay: Duration(
                      milliseconds: initialDelay.inMilliseconds + 700),
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
                SizedBox(height: 20),
                DelayedDisplay(
                    delay: Duration(
                        milliseconds: initialDelay.inMilliseconds + 750),
                    child: Align(
                        alignment: Alignment.center,
                        child: CustomButton(onTap: (){
                          if(_selectedGM==null){
                            ToastUtils.failureToast("Please select GM", context);
                          }
                          else if(_selectedST==null){
                            ToastUtils.failureToast("Please select ST", context);
                          }
                          else if(_selectedRegion==null &&regionAll==false){
                            ToastUtils.failureToast("Please select Region", context);
                          }
                          else if(_selectedCity==null&& cityAll==false){
                            ToastUtils.failureToast("Please select City Team", context);
                          }
                          else if(_selectedSO==null && soAll==false){
                            ToastUtils.failureToast("Please select Sale Officer", context);
                          }
                         else if(startDateController.text.isEmpty){
                            ToastUtils.failureToast("Please select start date", context);
                          }
                          else if(endDateController.text.isEmpty){
                            ToastUtils.failureToast("Please select end date", context);
                          }
                       else if(_selectedReport.toString()=="Employee Present Report" && soAll==true){
                          ToastUtils.failureToast("Please select an sale officer", context);
                        }
                        else if(_selectedReport.toString()=="Daily Store Attendance Report" && soAll==true){
                          ToastUtils.failureToast("Please select an sale officer", context);
                        }
                        else{
                          AppRoutes.push(context, PageTransitionType.fade, ReportPDFViewer(isSale: false, DM:regionAll? "0":_selectedRegion.toString(), GM: _selectedGM.toString(), SDM: cityAll? "0":_selectedCity.toString(), SO:soAll? "0": _selectedSO.toString(), ST: _selectedST.toString(), reportName: _selectedReport.toString(), fromDate: startDateController.text.toString(), toDate: endDateController.text.toString()));
                        }

                        }, color: greenBasic, text: "SUBMIT",width: MediaQuery.of(context).size.width*0.85,))),
                SizedBox(height: 20),
              ],
            ),
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
