import 'dart:convert';
import 'dart:io';
import 'dart:developer';
import 'dart:typed_data';
import 'package:hbe/distributor/widgets/distributorDrawer.dart';
import 'package:hbe/enums/globals.dart';
import 'package:hbe/widgets/loading_animation.dart';
import 'package:http/http.dart' as http;
import 'package:hbe/utils/mapAsset.dart';
import 'package:hbe/widgets/custom_button_icon.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geocoding/geocoding.dart';

import '../../../../service/api_urls.dart';
import '../../../../utils/color_constants.dart';
import '../../../../utils/toast_utils.dart';
import '../../../../widgets/custom_drop_down.dart';


class DistributorMarkAttendance extends StatefulWidget {
  final bool from;
  final String? customerId;
  const DistributorMarkAttendance({Key? key,required this.from,this.customerId}) : super(key: key);

  @override
  State<DistributorMarkAttendance> createState() => _DistributorMarkAttendanceState();
}

class _DistributorMarkAttendanceState extends State<DistributorMarkAttendance> {

  final Duration initialDelay = const Duration(milliseconds: 100);
  var _selectedCustomer;
  bool isLoading = true;
  bool showOther = false;
  GoogleMapController? googleMapController;
  Uint8List? markerIcon;
  Marker? marker;
  final Set<Marker> _markers = {};
  static const CameraPosition initialCameraPosition = CameraPosition(target: LatLng(0.0,0.0), zoom: 12);
  final TextEditingController searchController = TextEditingController();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.from==false){
      getMappedCustomers();
    }
    else{
      isLoading = false;
    }

  }

  List mappedCustomers = [];
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
            _selectedCustomer = mappedCustomers[0]["CustomerID"].toString() + "~" + mappedCustomers[0]["CustomerName"].toString();
            result12 = _selectedCustomer.substring(0, _selectedCustomer.indexOf('~'));
            result22 = _selectedCustomer.substring(_selectedCustomer.indexOf("~") + 1).trim();
            isLoading = false;
            showOther = false;
          });
        }
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
    searchController.dispose();
  }

  //UPDATE SHOP VISIT API
  Future<void> updateVisit() async {

    log('${ApiUrls.distributorUrl}${ApiUrls.updateShopVisit}?UserID=${globalData.userId}&CustomerID=${widget.from?widget.customerId.toString():result12}&Lat=$lat&Long=$lng&Location=$address&Remarks=${remarksController.text.toString()}');
    try {
      var headers = {
        ApiUrls.key_name: ApiUrls.apikey,
      };

      var request = http.MultipartRequest(
          'POST',
          Uri.parse('${ApiUrls.distributorUrl}${ApiUrls.updateShopVisit}?UserID=${globalData.userId}&CustomerID=${widget.from?widget.customerId.toString():result12}&Lat=$lat&Long=$lng&Location=$address&Remarks=${remarksController.text.toString()}'));

      if (imageFile != null) {
        request.files
            .add(await http.MultipartFile.fromPath('Shop-Front', imageFile!.path));
      }
      if (imageFile2 != null) {
        request.files
            .add(await http.MultipartFile.fromPath('Stock-Shevle', imageFile2!.path));
      }

      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();

      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      var data = json.decode(responseString);

      if (response.statusCode == 200 && data["RetCode"].toString() == "0001") {
        if(mounted) {
          setState(() {
            isLoading = false;
            showOther = false;
          });
        }
        ToastUtils.successToast(data["RetMsg"].toString(), context);
        if(widget.from){
          Navigator.of(context).pop();
        }

      }
      else if (response.statusCode == 200 && data.toString() == "0000") {
        if(mounted) {
          setState(() {
            isLoading = false;
            showOther = true;
          });
        }
        ToastUtils.failureToast(data["RetMsg"].toString(), context);
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
          isLoading = false;
          showOther = true;
        });
      }
    } on HttpException {
      if(mounted) {
        setState(() {
          isLoading = false;
          showOther = true;
        });
      }
      ToastUtils.warningToast("Couldn't find the data 😱", context);
    } on FormatException {
      if(mounted) {
        setState(() {
          isLoading = false;
          showOther = true;
        });
      }
      ToastUtils.warningToast("Something went wrong ", context);
    }

  }

  TextEditingController remarksController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        leading:widget.from? IconButton(
          icon: const Icon(FeatherIcons.arrowLeft),
          color: white,
          onPressed: (){
            Navigator.of(context).pop();
          },
        ):null,
        backgroundColor: greenBasic,
        title: const Text("Daily Shop Visit",style: TextStyle(fontFamily: "Poppins-Medium",fontSize: 16),),
        centerTitle: true,
      ),
      drawer:widget.from? null:const DistributorDrawer(),
      body: LoadingAnimation(
        inAsyncCall: isLoading,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                if(widget.from==false)...[
                  const SizedBox(height: 10),
                  DelayedDisplay(
                      delay: initialDelay,
                      child: const Text("Select Customer:",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 14,color: greenBasic))),
                  const SizedBox(height: 10),
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
                            value:item["CustomerID"].toString() + "~" + item["CustomerName"].toString(),
                            child: SizedBox(
                              width:
                              MediaQuery.of(context).size.width *
                                  0.7,
                              child: Text(
                                item["CustomerName"].toString(),
                                style: const TextStyle(
                                    color: black,
                                    fontSize:14,
                                    fontFamily: 'Poppins-Regular'),
                              ),
                            ),
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
                ],
               const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    DelayedDisplay(
                      delay: Duration(
                          milliseconds: initialDelay.inMilliseconds + 300),
                      child: InkWell(
                        onTap: (){
                          imagePickerMethod("1");
                        },
                        child:imageFile==null?  Container(
                          height: 120,
                          width: 160,
                          decoration: BoxDecoration(
                              color: white,
                              boxShadow: [
                                BoxShadow(
                                    color: black.withOpacity(0.25),
                                    blurRadius: 4
                                ),
                              ],
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(FeatherIcons.camera,color: greenBasic),
                                SizedBox(height: 10),
                                Text("Shop Front",style: TextStyle(fontSize: 14,fontFamily: "Poppins-Medium",color: greenBasic),)
                              ],
                            ),
                          ),
                        )
                            :Container(
                          height: 120,
                          width: 160,
                          decoration: BoxDecoration(
                              color: white,
                              boxShadow: [
                                BoxShadow(
                                    color: black.withOpacity(0.25),
                                    blurRadius: 4
                                ),
                              ],
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Image.file(
                              File(imageFile!.path),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    DelayedDisplay(
                      delay: Duration(
                          milliseconds: initialDelay.inMilliseconds + 400),
                      child: InkWell(
                        onTap: (){
                          imagePickerMethod("2");
                        },
                        child:imageFile2==null?  Container(
                          height: 120,
                          width: 160,
                          decoration: BoxDecoration(
                              color: white,
                              boxShadow: [
                                BoxShadow(
                                    color: black.withOpacity(0.25),
                                    blurRadius: 4
                                ),
                              ],
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(FontAwesome.camera,color: greenBasic),
                                SizedBox(height: 10),
                                Text("Stock Shelve",style: TextStyle(fontSize: 13,fontFamily: "Poppins-Medium",color: greenBasic),)
                              ],
                            ),
                          ),
                        )
                            :Container(
                          height: 120,
                          width: 160,
                          decoration: BoxDecoration(
                              color: white,
                              boxShadow: [
                                BoxShadow(
                                    color: black.withOpacity(0.25),
                                    blurRadius: 4
                                ),
                              ],
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Image.file(
                              File(imageFile2!.path),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
               DelayedDisplay( delay: Duration(
                   milliseconds: initialDelay.inMilliseconds + 200),
                 child:  Container(
                 padding: EdgeInsets.zero,
                 margin: const EdgeInsets.all(10),
                 decoration: BoxDecoration(
                     border:
                     Border.all(color: Colors.black.withOpacity(0.25), width: 1),
                     color: Colors.white,
                     borderRadius: BorderRadius.circular(10)),
                 child: TextFormField(
                   maxLines: 5,
                   textInputAction: TextInputAction.done,
                   controller: remarksController,
                   decoration: InputDecoration(
                     isDense: true,
                     fillColor: white,
                     filled: true,
                     labelText: 'Remarks',
                     labelStyle: const TextStyle(
                         color: greenBasic,
                         fontFamily: "Poppins-Regular",
                         fontSize: 14),
                     floatingLabelBehavior:
                     FloatingLabelBehavior.always,
                     hintText: "Enter your remarks",
                     hintStyle: const TextStyle(
                       color: greenBasic,
                       fontFamily: "Poppins-Regular",
                       fontSize: 14,
                     ),
                     enabledBorder: UnderlineInputBorder(
                         borderRadius: BorderRadius.circular(10),
                         borderSide:
                         const BorderSide(color: white, width: 1)),
                     focusedBorder: UnderlineInputBorder(
                         borderRadius: BorderRadius.circular(10),
                         borderSide:
                         const BorderSide(color: white, width: 1)),
                   ),
                 ),
               ),),
                const SizedBox(height: 10),
                DelayedDisplay(
                 delay: Duration(
                     milliseconds: initialDelay.inMilliseconds + 200),
                 child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomButtonIcon(onTap: (){
                        if(imageFile==null){
                         ToastUtils.failureToast("Add Shop Front Image", context);
                        }
                        else if(imageFile2==null){
                          ToastUtils.failureToast("Add Stock Shelve Image", context);
                        }
                        else{
                          if(mounted){
                            setState(() {
                              isLoading = true;
                            });
                          }
                          updateVisit();
                        }

                      }, color: greenBasic, text: "Mark Visit",width:  MediaQuery.of(context).size.width*0.9, iconData: FeatherIcons.checkCircle, textColor: white,),
                    ],
                  ),
               ),
                const SizedBox(height: 20,),
                DelayedDisplay(delay: Duration(
                    milliseconds: initialDelay.inMilliseconds + 300),
                  child: const Text("Your Current Location:",style: TextStyle(fontFamily: 'Poppins-SemiBold',color: greenBasic,fontSize: 18)),),
                const SizedBox(height: 10,),
                DelayedDisplay(
                    delay: Duration(
                        milliseconds: initialDelay.inMilliseconds + 300),
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
                      getUserLoc();
                  },
                ),
                    )),
                const SizedBox(height: 10,),
                DelayedDisplay(
                    delay: Duration(
                        milliseconds: initialDelay.inMilliseconds + 400),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Address:",style: TextStyle(fontFamily: 'Poppins-SemiBold',color: greenBasic,fontSize: 12)),
                            Text(address.toString()==""?"N/A":address.toString(),style: const TextStyle(fontFamily: 'Poppins-Regular',color: black,fontSize: 14)),
                          ],
                        ),
                        Row(
                          children: [
                            const Text("Latitude:",style: TextStyle(fontFamily: 'Poppins-SemiBold',color: greenBasic,fontSize: 12)),
                            const SizedBox(width: 10,),
                            Text(lat.toString(),style: const TextStyle(fontFamily: 'Poppins-Regular',color: black,fontSize: 14)),
                          ],
                        ),
                        Row(
                          children: [
                            const Text("Longitude:",style: TextStyle(fontFamily: 'Poppins-SemiBold',color: greenBasic,fontSize: 12)),
                            const SizedBox(width: 10,),
                            Text(lng.toString(),style: const TextStyle(fontFamily: 'Poppins-Regular',color: black,fontSize: 14)),
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


  final imagePicker = ImagePicker();
  File? imageFile;
  File? imageFile2;
  var fileName = '';

  //IMAGE PICKER FROM CAMERA
  Future imagePickerMethod(type) async {
    final pick = await imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 30,
    );

    if (pick != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pick.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Image Cropper',
              toolbarColor: greenBasic,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            title: 'Cropper',
          ),
        ],
      );
      if (croppedFile != null) {
        if(mounted){
          setState(() {
            fileName = croppedFile.path.split('/').last;
          });
        }
        checkFileSize(croppedFile.path,type);


      }
    } else {}
  }

  //CHECK FILE SIZE
  checkFileSize(path,type) {
    var fileSizeLimit = 5000;
    File f = File(path);
    var s = f.lengthSync();
    var fileSizeInKB = s / 5000;
    log(fileSizeInKB.toString());
    if (fileSizeInKB > fileSizeLimit) {
      ToastUtils.warningToast("Image size should be less than 5 MB", context);
      return false;
    } else {
      if(type=="1"){
        if (mounted) {
          setState(() {
            imageFile = File(path);
          });
        }
      }
      else if(type=="2"){
        if (mounted) {
          setState(() {
            imageFile2 = File(path);
          });
        }
      }
      return true;
    }
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
    if(mounted)
   {
     setState(() {
       setMarker();
     });
   }
  }


}
