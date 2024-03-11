import 'dart:convert';
import 'dart:io';
import 'dart:developer';
import 'dart:typed_data';
import 'package:hbe/enums/globals.dart';
import 'package:hbe/widgets/loading_animation.dart';
import 'package:http/http.dart' as http;
import 'package:hbe/utils/mapAsset.dart';
import 'package:hbe/widgets/custom_button_icon.dart';
import 'package:hbe/widgets/navDrawer.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../service/api_urls.dart';
import '../../../utils/color_constants.dart';
import 'package:geocoding/geocoding.dart';

import '../../../utils/toast_utils.dart';
import '../../../widgets/custom_drop_down.dart';

class MarkAttendance extends StatefulWidget {
  const MarkAttendance({Key? key}) : super(key: key);

  @override
  State<MarkAttendance> createState() => _MarkAttendanceState();
}

class _MarkAttendanceState extends State<MarkAttendance> {

  final Duration initialDelay = const Duration(milliseconds: 100);
  var _selectedCustomer;
  var _leaveType;
  bool isLoading = true;
  bool showOther = false;
  String type = "";
  bool checkIn=false;
  bool checkOut=false;
  GoogleMapController? googleMapController;
  Uint8List? markerIcon;
  Marker? marker;
  final Set<Marker> _markers = {};
  static const CameraPosition initialCameraPosition = CameraPosition(target: LatLng(0.0,0.0), zoom: 12);
  var result12, result22;
  final TextEditingController searchController = TextEditingController();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    leaveDateController.text = DateFormat('yyyy-MM-dd').format(selectedDate).toString();
    getMappedCustomers();
    getPermissions();
  }

  Map<Permission, PermissionStatus>? statuses;
  getPermissions() async {
    statuses = await [
      Permission.location
    ].request();
    var status = await Permission.location.status;
    if(status.isGranted){
      getUserLoc();
    }
    else{
      await Geolocator.openAppSettings().then((value){
        if(value){
          getUserLoc();
        }
      });
    }
  }


  List mappedCustomers = [];
  //GET MAPPED CUSTOMERS API
  void getMappedCustomers() async{
    try {
      final response = await http.get(
          Uri.parse('${ApiUrls.baseURL}${ApiUrls.getMappedCustomer}?UserID=${globalData.userId}'),
          headers: {
            ApiUrls.key_name: ApiUrls.apikey,
          });

      var res = json.decode(response.body);

      if (response.statusCode == 200 ) {
        if(mounted) {
          setState(() {
            mappedCustomers= res as List;
            _selectedCustomer = mappedCustomers[0]["CustomerID"].toString() + "~" + mappedCustomers[0]["CustomerName"].toString();
            result12 = _selectedCustomer.substring(0, _selectedCustomer.indexOf('~'));
            result22 = _selectedCustomer.substring(_selectedCustomer.indexOf("~") + 1).trim();
            isLoading = false;
            showOther = false;
          });
        }
        getLeaveTypes();
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

  List leaveTypes = [];
  //GET LEAVE TYPES API
  void getLeaveTypes() async{
    try {
      final response = await http.get(
          Uri.parse('${ApiUrls.baseURL}${ApiUrls.getLeaveType}'),
          headers: {
            ApiUrls.key_name: ApiUrls.apikey,
          });

      var res = json.decode(response.body);

      if (response.statusCode == 200 ) {
        if(mounted) {
          setState(() {
            leaveTypes= res as List;
            _leaveType = leaveTypes[0]["LeaveID"].toString();
            isLoading = false;
            showOther = false;
          });
        }
      }
      else {
        if(mounted) {
          setState(() {
            leaveTypes =[];
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

  //SET CUSTOM MARKER
  void setMarker() async{
    markerIcon = await mapAsset.getBytesFromAsset("assets/icons/locationMarker.png", 100);
    if (mounted) {
      setState(() {
        marker = Marker(
            markerId: const MarkerId("home"),
            position: LatLng(lat, lng),
            icon: BitmapDescriptor.fromBytes(markerIcon!),
        );
        _markers.add(marker!);
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    mappedCustomers.clear();
    googleMapController!.dispose();
  }

  //MARK ATTENDANCE API
  void markUserAttendance() async{
    try {
      final response = await http.post(
          Uri.parse('${ApiUrls.baseURL}${ApiUrls.markAttendance}?LoginUserID=${globalData.userId}&Lat=$lat&Long=$lng&Location=${Uri.encodeComponent(address.toString())}&StoreID=$result12&AttenType=$type'),
          headers: {
            ApiUrls.key_name: ApiUrls.apikey,
          });

      var res = jsonDecode(response.body);
      log(res.toString());
      if (response.statusCode == 200 && res["RetMsg"].toString()=="Attendance Marked") {
        ToastUtils.successToast("Attendance Marked", context);
        if(mounted) {
          setState(() {
            isLoading = false;
            showOther = false;
          });
        }
      }
     else if (response.statusCode == 200 && res["RetMsg"].toString()=="Error..") {
        ToastUtils.failureToast("Error..", context);
        if(mounted) {
          setState(() {
            isLoading = false;
            showOther = false;
          });
        }
      }
      else {
        ToastUtils.failureToast("Something went wrong", context);
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

  bool isLeaveLoading=false;
  //MARK LEAVE API
  void markUserLeave(leaveID,leaveDate,remarks,setter) async{
    try {
      final response = await http.post(
          Uri.parse('${ApiUrls.baseURL}${ApiUrls.markLeave}?LoginUserID=${globalData.userId}&LeaveID=$leaveID&LeaveDate=$leaveDate&Remarks=$remarks&Lat=$lat&Long=$lng&Location=${Uri.encodeComponent(address.toString())}&StoreID=$result12'),
          headers: {
            ApiUrls.key_name: ApiUrls.apikey,
          });

      var res = jsonDecode(response.body);

      if (response.statusCode == 200 && res["RetMsg"].toString()=="Leaved Marked") {
        ToastUtils.successToast("Leave Marked", context);
        if(mounted) {
          setter(() {
            isLeaveLoading = false;
            remarksController.text ="";
            leaveDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
          });
        }
        Navigator.pop(context);
      }

      else {
        ToastUtils.failureToast("Something went wrong", context);
        if(mounted) {
          setter(() {
            isLeaveLoading = false;
          });
        }
        throw Exception('Unexpected error occurred!');
      }
    } on SocketException {
      if(mounted) {
        setter(() {
          isLeaveLoading = false;
        });
      }
      ToastUtils.warningToast("No Internet Connection", context);
    } on HttpException {
      if(mounted) {
        setter(() {
          isLeaveLoading = false;
        });
      }
      ToastUtils.warningToast("Couldn't find the data 😱", context);
    } on FormatException {
      if(mounted) {
        setter(() {
          isLeaveLoading = false;
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
        title: Text("Mark Attendance",style: TextStyle(fontFamily: "Poppins-Medium",fontSize: 16),),
        centerTitle: true,
      ),
      drawer: DrawerWidget(),
      body: LoadingAnimation(
        inAsyncCall: isLoading,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
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
                          value:item["CustomerID"].toString() + "~" + item["CustomerName"].toString(),
                        );
                      }).toList(),
                      onChanged: (changedValue) {
                        if (mounted) {
                          setState(() {
                            _selectedCustomer = changedValue!;
                            result12 = _selectedCustomer.substring(0, _selectedCustomer.indexOf('~'));
                            result22 = _selectedCustomer.substring(_selectedCustomer.indexOf("~") + 1).trim();
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
                SizedBox(height: 20),
                DelayedDisplay(
                  delay: Duration(
                      milliseconds: initialDelay.inMilliseconds + 200),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                    CustomButtonIcon(textColor:checkIn? white:greenBasic, iconData: FeatherIcons.checkCircle, onTap: (){
                      if(mounted){
                        setState(() {
                          type= "CheckIn";
                          checkIn=true;
                          checkOut=false;
                        });
                      }
                      if(_selectedCustomer==null){
                        ToastUtils.failureToast("Please select customer", context);
                      }
                      else{
                        if(mounted){
                          setState(() {
                            isLoading = true;
                          });
                        }
                        markUserAttendance();
                      }
                    }, color:checkIn? greenBasic: white, text: "Check In"),
                    CustomButtonIcon(textColor:checkOut? white: greenBasic, iconData: FeatherIcons.logOut, onTap: (){
                      if(mounted){
                        setState(() {
                          type= "CheckOut";
                          checkIn=false;
                          checkOut=true;
                        });
                      }
                      if(_selectedCustomer==null){
                        ToastUtils.failureToast("Please select customer", context);
                      }
                      else{
                        if(mounted){
                          setState(() {
                            isLoading = true;
                          });
                        }
                        markUserAttendance();
                      }
                    }, color:checkOut? greenBasic: white, text: "Check Out")
                    ],
                  ),
                ),
               SizedBox(height: 20),
               DelayedDisplay(
                 delay: Duration(
                     milliseconds: initialDelay.inMilliseconds + 300),
                 child: Align( alignment: Alignment.center,
                     child: Text("Please mark your attendance OR leave",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 14,color: greenBasic))),
               ),
               SizedBox(height: 20),
               DelayedDisplay(
                 delay: Duration(
                     milliseconds: initialDelay.inMilliseconds + 400),
                 child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                   /*   CustomButton(onTap: (){
                        if(_selectedCustomer==null){
                          ToastUtils.failureToast("Please select customer", context);
                        }
                        else if(type==""){
                          ToastUtils.failureToast("Please select attendance type", context);
                        }
                        else{
                          if(mounted){
                            setState(() {
                              isLoading = true;
                            });
                          }
                          markUserAttendance();
                        }

                      }, color: greenBasic, text: "Mark Attendance"),*/
                      CustomButtonIcon(onTap: (){
                        showLeaveDialog(context);
                      }, color: redBasic, text: "Mark Leave",width:  MediaQuery.of(context).size.width*0.85, iconData: FeatherIcons.checkCircle, textColor: white,),
                    ],
                  ),
               ),
                SizedBox(height: 20,),
                Text("Your Current Location:",style: TextStyle(fontFamily: 'Poppins-SemiBold',color: greenBasic,fontSize: 18)),
                SizedBox(height: 10,),
                DelayedDisplay(
                    delay: Duration(
                        milliseconds: initialDelay.inMilliseconds + 500),
                    child:Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: white,
                        boxShadow: [
                          BoxShadow(
                            color: black.withOpacity(0.25),
                            blurRadius: 4
                          )
                        ],
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: GoogleMap(
                  initialCameraPosition: initialCameraPosition,
                  markers: _markers,
                  zoomControlsEnabled: false,
                  mapType: MapType.normal,
                  onMapCreated: (GoogleMapController controller) {
                      googleMapController = controller;
                      getPermissions();
                  },
                ),
                    )),
                SizedBox(height: 10,),
                DelayedDisplay(
                    delay: Duration(
                        milliseconds: initialDelay.inMilliseconds + 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Address:",style: TextStyle(fontFamily: 'Poppins-SemiBold',color: greenBasic,fontSize: 12)),
                            Text(address.toString()==""?"N/A":address.toString(),style: TextStyle(fontFamily: 'Poppins-Regular',color: black,fontSize: 14)),
                          ],
                        ),
                        Row(
                          children: [
                            Text("Latitude:",style: TextStyle(fontFamily: 'Poppins-SemiBold',color: greenBasic,fontSize: 12)),
                            SizedBox(width: 10,),
                            Text(lat.toString(),style: TextStyle(fontFamily: 'Poppins-Regular',color: black,fontSize: 14)),
                          ],
                        ),
                        Row(
                          children: [
                            Text("Longitude:",style: TextStyle(fontFamily: 'Poppins-SemiBold',color: greenBasic,fontSize: 12)),
                            SizedBox(width: 10,),
                            Text(lng.toString(),style: TextStyle(fontFamily: 'Poppins-Regular',color: black,fontSize: 14)),
                          ],
                        )
                      ],
                    )
                )

              ],
            ),
          ),
        ),
      ),
    );
  }

  getUserLoc() async{
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {

      await _getAddress(position.latitude,position.longitude);
      getCurrentLocation(position.latitude,position.longitude);
    }).catchError((e) {

    });

  }

  var address="", lat=0.0, lng=0.0;
  _getAddress(var ulat,var ulng) async {
    try {

      List<Placemark> placemarks = await placemarkFromCoordinates(ulat, ulng);
      Placemark place = placemarks[0];


      if(mounted){
        setState(() {
          address = '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
          lat = ulat;
          lng = ulng;
        });
      }

    } catch (e) {
      //print(e);
    }
  }

  getCurrentLocation(var ulat,var ulng) async{
    googleMapController
    !.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(ulat,ulng), zoom: 14)));
    setState(() {
      setMarker();
    });
  }

  TextEditingController remarksController = TextEditingController();
  TextEditingController leaveDateController=TextEditingController();
  //SHOW LEAVE DIALOG
  showLeaveDialog(BuildContext context){
    return showDialog(
      barrierDismissible: isLeaveLoading?false:true,
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            elevation: 10,
            insetPadding: const EdgeInsets.all(20),
            backgroundColor: white,
            child: StatefulBuilder(
              builder: (context,setter){
                return SingleChildScrollView(
                  child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child:Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DelayedDisplay(
                              delay: initialDelay,
                              child: Text("Select Leave Type",style: TextStyle(fontSize: 12,color: black,fontFamily: "Poppins-SemiBold"))),
                          SizedBox(height: 5),
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
                                        ),
                                        isExpanded: false,
                                        style: TextStyle(
                                            color: black,
                                            fontSize: 15,
                                            fontFamily: 'Poppins-Regular'),
                                        onChanged: (String? changedValue) {
                                          if(mounted) {
                                            setter(() {
                                              _leaveType = changedValue!;
                                            });
                                          }
                                        },
                                        value: _leaveType,
                                        items: leaveTypes.map((item) {
                                          return DropdownMenuItem(
                                            child: Text(
                                              item["LeaveTitle"].toString(),style: TextStyle(
                                                color: black,
                                                fontSize: 13,
                                                fontFamily: 'Poppins-Medium'),
                                            ),
                                            value: item["LeaveID"].toString(),
                                          );
                                        }).toList(),
                                      )),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          DelayedDisplay(
                              delay: Duration(
                                  milliseconds: initialDelay.inMilliseconds + 200),
                              child: Text("Select Leave Date",style: TextStyle(fontSize: 12,color: black,fontFamily: "Poppins-SemiBold"))),
                          SizedBox(height: 5),
                          DelayedDisplay(
                            delay: Duration(
                                milliseconds: initialDelay.inMilliseconds + 300),
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
                                  selectDateTo(context,setter);
                                },
                                child: AbsorbPointer(
                                  child: TextFormField(
                                    readOnly: true,
                                    textAlignVertical: TextAlignVertical.center,
                                    controller: leaveDateController,
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
                          SizedBox(height: 5),
                          DelayedDisplay(
                              delay: Duration(
                                  milliseconds: initialDelay.inMilliseconds + 400),
                              child: Text("Remarks",style: TextStyle(fontSize: 12,color: black,fontFamily: "Poppins-SemiBold"))),
                          SizedBox(height: 5),
                          DelayedDisplay(
                            delay: Duration(
                                milliseconds: initialDelay.inMilliseconds + 500),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color:  white,
                                boxShadow: [
                                  BoxShadow(
                                    color: greenBasic.withOpacity(0.25),
                                    blurRadius: 2
                                  )
                                ]
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: TextField(
                                  controller: remarksController,
                                  maxLines: 4,
                                  cursorColor: Colors.white70,
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: greenBasic,
                                    fontFamily: 'Poppins-Regular',
                                  ),
                                  decoration: InputDecoration(
                                      hintText: 'Enter Your Remarks..',
                                      hintStyle: TextStyle(
                                        fontFamily: 'Poppins-Regular',
                                        fontSize: 14,
                                        color: greenBasic,
                                      ),
                                      border: InputBorder.none),
                                )
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          DelayedDisplay(
                            delay: Duration(
                                milliseconds: initialDelay.inMilliseconds + 600),
                            child:isLeaveLoading? Center(
                              child: CircularProgressIndicator(
                                color: greenBasic,
                              ),
                            ):Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    width: 122,
                                    height: 47,
                                    decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                              color: black.withOpacity(0.25),
                                              blurRadius: 4
                                          )
                                        ],
                                        color: white,
                                        borderRadius: BorderRadius.circular(
                                            10)
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Cancel",
                                        style: TextStyle(color: black,
                                            fontFamily: 'Poppins-Medium',
                                            fontSize: 14),
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () async {
                                    if(remarksController.text.isEmpty){
                                      ToastUtils.failureToast("Please provide remarks", context);

                                    }
                                    else{
                                      if(mounted){
                                        setter((){
                                          isLeaveLoading = true;
                                        });
                                      }
                                      markUserLeave(double.parse(_leaveType.toString()).toStringAsFixed(0),leaveDateController.text.toString(),remarksController.text.toString(),setter);
                                    }
                                  },
                                  child: Container(
                                    width: 122,
                                    height: 47,
                                    decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                              color: black.withOpacity(0.25),
                                              blurRadius: 4
                                          )
                                        ],
                                        color: greenBasic,
                                        borderRadius: BorderRadius.circular(
                                            10)
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Submit",
                                        style: TextStyle(color: white,
                                            fontFamily: 'Poppins-Medium',
                                            fontSize: 14),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                      )
                  ),
                );
              },
            )
          );
        });
  }

  DateTime selectedDate = DateTime.now();

  selectDateTo(BuildContext context,StateSetter setter) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1920),
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
    if (selected != null && selected != selectedDate) {
      setter(() {
        selectedDate = selected;
        leaveDateController.text =
            DateFormat('yyyy-MM-dd').format(selectedDate).toString();
      });
    } else if (selected != null && selected == selectedDate) {
      setter(() {
        selectedDate = selected;
        leaveDateController.text =
            DateFormat('yyyy-MM-dd').format(selectedDate).toString();
      });
    }
  }

}
