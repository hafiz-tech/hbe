import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:hbe/enums/globals.dart';
import 'package:hbe/service/api_urls.dart';
import 'package:hbe/utils/app_routes.dart';
import 'package:hbe/views/attendance/upload_images/view_images.dart';
import 'package:hbe/widgets/loading_animation.dart';
import 'package:hbe/widgets/navDrawer.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import '../../../utils/color_constants.dart';
import '../../../utils/toast_utils.dart';
import '../../../widgets/custom_drop_down.dart';

class UploadImages extends StatefulWidget {
  const UploadImages({Key? key}) : super(key: key);

  @override
  State<UploadImages> createState() => _UploadImagesState();
}

class _UploadImagesState extends State<UploadImages> {

  bool  isLoading = true;
  final Duration initialDelay = const Duration(milliseconds: 100);
  final imagePicker = ImagePicker();
  File? imageFile;
  var result12, result22;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMappedCustomers();
  }

  var fileName = '';
  var _selectedCustomer;
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

  //UPLOAD IMAGE API
  uploadImage() async{
    try {
      var headers = {
    ApiUrls.key_name: ApiUrls.apikey,
    };
      var request = http.MultipartRequest("POST", (Uri.parse('${ApiUrls.baseURL}${ApiUrls.addNewImage}?LoginUserID=${globalData.userId}&StoreID=$result12')));
      request.headers.addAll(headers);
      if (imageFile != null) {
        var pic = await http.MultipartFile.fromBytes("", imageFile!.readAsBytesSync(),filename: fileName.toString());
        request.files.add(pic);
      }
      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      var res = json.decode(responseString);

      if (response.statusCode == 200 && res["RetMsg"].toString()=="Save") {
        if(mounted) {
          setState(() {
            isLoading = false;
            imageFile=null;
          });
        }
        ToastUtils.successToast("Image Uploaded Successfully", context);
      }
      else if (response.statusCode == 200 && res["RetMsg"].toString()=="Error.. ") {
        if(mounted) {
          setState(() {
            isLoading = false;
            imageFile=null;
          });
        }
        ToastUtils.successToast("Image Uploading Failed", context);
      }
      else {
        if(mounted) {
          setState(() {
            isLoading = false;
          });
        }
        ToastUtils.failureToast("No Image Found", context);
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
        title: Text("Upload Images",style: TextStyle(fontFamily: "Poppins-Medium",fontSize: 16),),
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
                    child:CustomDropDown(
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
                SizedBox(height: 10),
                DelayedDisplay(
                  delay: Duration(
                      milliseconds: initialDelay.inMilliseconds + 200),
                  child: Align( alignment: Alignment.center,
                      child: Text("Send & View Attendance Images",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 14,color: greenBasic))),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    DelayedDisplay(
                      delay: Duration(
                          milliseconds: initialDelay.inMilliseconds + 300),
                      child: InkWell(
                        onTap: (){
                          imagePickerMethod();
                        },
                        child:Container(
                          width: 150,
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
                            child: Column(
                              children: [
                                Icon(FeatherIcons.camera,color: greenBasic),
                                SizedBox(height: 10),
                                Text("Take Picture",style: TextStyle(fontSize: 14,fontFamily: "Poppins-SemiBold",color: greenBasic),)
                              ],
                            ),
                          ),
                        )
                      ),
                    ),
                    DelayedDisplay(
                      delay: Duration(
                          milliseconds: initialDelay.inMilliseconds + 400),
                      child: InkWell(
                        onTap: (){
                          AppRoutes.push(context, PageTransitionType.fade, ViewUploadedImages());
                        },
                        child: Container(
                          width: 150,
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
                            child: Column(
                              children: [
                                Icon(FontAwesome.image,color: greenBasic),
                                SizedBox(height: 10),
                                Text("Show Images",style: TextStyle(fontSize: 14,fontFamily: "Poppins-SemiBold",color: greenBasic),)
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 20),
                imageFile==null?const SizedBox():
                Center(
                  child: DelayedDisplay(
                    delay: Duration(
                        milliseconds: initialDelay.inMilliseconds + 100),
                    child: InkWell(
                      onTap: (){
                        if(_selectedCustomer==null){
                          ToastUtils.failureToast("Please select customer", context);
                        }
                        else if(imageFile==null){
                          ToastUtils.failureToast("Select an image for upload", context);
                        }
                        else{
                          if(mounted){
                            setState(() {
                              isLoading = true;
                            });
                          }
                          uploadImage();
                        }

                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width*0.9,
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: white,
                            boxShadow: [
                              BoxShadow(
                                  color: black.withOpacity(0.25),
                                  blurRadius: 3
                              ),
                            ],
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(FeatherIcons.uploadCloud,color: greenBasic),
                            SizedBox(width: 10),
                            Text("Upload Image",style: TextStyle(fontSize: 14,fontFamily: "Poppins-SemiBold",color: greenBasic),)
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                imageFile==null?const SizedBox():
                DelayedDisplay(
                  delay: Duration(
                      milliseconds: initialDelay.inMilliseconds + 200),
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: white,
                      boxShadow: [
                        BoxShadow(
                          color: black.withOpacity(0.25),
                          blurRadius: 3
                        ),
                      ],
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Image.file(imageFile!,fit: BoxFit.cover,),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  //IMAGE PICKER FROM CAMERA
  Future imagePickerMethod() async {
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
        checkFileSize(croppedFile.path);


      }
    } else {}
  }

  //CHECK FILE SIZE
  checkFileSize(path) {
    var fileSizeLimit = 5000;
    File f = File(path);
    var s = f.lengthSync();
    var fileSizeInKB = s / 5000;
    log(fileSizeInKB.toString());
    if (fileSizeInKB > fileSizeLimit) {
      ToastUtils.warningToast("Image size should be less than 5 MB", context);
      return false;
    } else {
      if (mounted) {
        setState(() {
          imageFile = File(path);

        });
      }
      return true;
    }
  }






}
