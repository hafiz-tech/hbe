import 'dart:convert';

import 'dart:io';

import 'package:hbe/enums/globals.dart';
import 'package:hbe/service/api_urls.dart';
import 'package:hbe/utils/app_routes.dart';
import 'package:hbe/widgets/custom_buttons.dart';
import 'package:hbe/widgets/loading_animation.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import '../../utils/color_constants.dart';
import '../../utils/shared_pref.dart';
import '../../utils/toast_utils.dart';
class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isLoading = false;
  bool passwordVisible = true;
  bool newPasswordVisible = true;
  bool confirmPasswordVisible = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPass();
  }

  //GET USER CURRENT PASSWORD
  var password;
  getPass() async{
    var pass= await SharedPref.getUserPassword();
  if(mounted){
    setState(() {
     password = pass;
    });
  }
  }

  @override
  void dispose() {
    super.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
  }


  //CHANGE PASSWORD API
  Future<void> changePassword() async {

    try {
      var response = await http.post(
        Uri.parse(
            '${ApiUrls.baseURL}${ApiUrls.resetPassword}?UserID=${globalData.userId}&OldPassword=${Uri.encodeComponent(currentPasswordController.text.toString())}&NewPassword=${Uri.encodeComponent(newPasswordController.text.toString())}'),
        headers: {
          ApiUrls.key_name: ApiUrls.apikey,
          "Content-Type": "application/json; charset=utf-8"
        },
      );

      var res = jsonDecode(response.body);

      if (response.statusCode == 200 && res["Message"].toString() =="Successfully Update") {
        SharedPref.saveUserPassword(newPasswordController.text);
        if (mounted) {
          setState(() {
            isLoading = false;
            newPasswordController.text="";
            currentPasswordController.text="";
            confirmPasswordController.text="";
          });
        }
        AppRoutes.pop(context);
        ToastUtils.successToast(res["Message"].toString(), context);


      } else if (response.statusCode == 200 && res["Message"].toString() =="Old password and new password must be change") {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        ToastUtils.failureToast(res["Message"].toString(), context);
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        ToastUtils.failureToast("Failed to update password", context);
        throw Exception('Failed to load data');
      }
    } on SocketException {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      ToastUtils.failureToast("No Internet Connection", context);
    } on HttpException {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      ToastUtils.failureToast("Couldn't find the data 😱", context);
    } on FormatException {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      ToastUtils.failureToast("Internal Server Error ", context);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: greenBasic,
        title: Text("Change Password",style: TextStyle(fontFamily: "Poppins-Medium",fontSize: 16),),
        centerTitle: true,
      ),
      body: LoadingAnimation(
        inAsyncCall: isLoading,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.only(left: 30.0,right: 30.0),
                  child: Lottie.asset("assets/animations/change_pass.json",height: 200),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.zero,
                  decoration: BoxDecoration(
                      border:
                      Border.all(color: Colors.black.withOpacity(0.25), width: 1),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: TextFormField(
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    ],
                    controller: currentPasswordController,
                    obscureText: passwordVisible,
                    decoration: InputDecoration(
                      suffixIcon: InkWell(
                          onTap: () {
                            setState(() {
                              passwordVisible = !passwordVisible;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                                passwordVisible?
                                    FeatherIcons.eye
                                    : FeatherIcons.eyeOff,
                              color: greenBasic,
                            ),
                          )),
                      isDense: true,
                      fillColor: white,
                      filled: true,
                      labelText: 'Current Password',
                      labelStyle: TextStyle(
                          color: greenBasic,
                          fontFamily: "Poppins-Regular",
                          fontSize: 14),
                      floatingLabelBehavior:
                      FloatingLabelBehavior.always,
                      hintText: "Enter your current password",
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
                SizedBox(
                  height: 20,
                ),
                Container(
                  padding: EdgeInsets.zero,
                  decoration: BoxDecoration(
                      border:
                      Border.all(color: Colors.black.withOpacity(0.25), width: 1),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: TextFormField(
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    ],
                    controller: newPasswordController,
                    obscureText: newPasswordVisible,
                    decoration: InputDecoration(
                      suffixIcon: InkWell(
                          onTap: () {
                            setState(() {
                              newPasswordVisible = !newPasswordVisible;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                                newPasswordVisible?
                                FeatherIcons.eye
                                    : FeatherIcons.eyeOff,
                              color: greenBasic,
                            ),
                          )),
                      isDense: true,
                      fillColor: white,
                      filled: true,
                      labelText: 'New Password',
                      labelStyle: TextStyle(
                          color: greenBasic,
                          fontFamily: "Poppins-Regular",
                          fontSize: 14),
                      floatingLabelBehavior:
                      FloatingLabelBehavior.always,
                      hintText: "Enter your new password",
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
                SizedBox(
                  height: 20,
                ),
                Container(
                  padding: EdgeInsets.zero,
                  decoration: BoxDecoration(
                      border:
                      Border.all(color: Colors.black.withOpacity(0.25), width: 1),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: TextFormField(
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    ],
                    controller: confirmPasswordController,
                    obscureText: confirmPasswordVisible,
                    decoration: InputDecoration(
                      suffixIcon: InkWell(
                          onTap: () {
                            setState(() {
                              confirmPasswordVisible = !confirmPasswordVisible;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                                confirmPasswordVisible?
                                FeatherIcons.eye
                                    : FeatherIcons.eyeOff,
                              color: greenBasic,
                            ),
                          )),
                      isDense: true,
                      fillColor: white,
                      filled: true,
                      labelText: 'Confirm Password',
                      labelStyle: TextStyle(
                          color: greenBasic,
                          fontFamily: "Poppins-Regular",
                          fontSize: 14),
                      floatingLabelBehavior:
                      FloatingLabelBehavior.always,
                      hintText: "Enter your confirm password",
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
                SizedBox(
                  height: 20,
                ),

                CustomButton(
                    width: MediaQuery.of(context).size.width*0.6,
                    onTap: (){
                  if(currentPasswordController.text.isEmpty){
                    ToastUtils.failureToast(
                        "Enter current password", context);
                  }
                  else if(currentPasswordController.text.toString()!=password.toString()){
                    ToastUtils.failureToast(
                        "Current password is incorrect", context);
                  }
                  else if (newPasswordController.text.isEmpty) {
                    ToastUtils.failureToast(
                        "Enter new password", context);
                  } else if (confirmPasswordController.text.isEmpty) {
                    ToastUtils.failureToast(
                        "Enter confirm password", context);
                  } else if (confirmPasswordController.text
                      .toString() !=
                      newPasswordController.text.toString()) {
                    ToastUtils.failureToast(
                        "Password not matched", context);
                  }
                  // else if (newPasswordController.text
                  //     .toString() ==
                  //     currentPasswordController.text.toString()) {
                  //   ToastUtils.failureToast(
                  //       "Use a different password", context);
                  // }
                  else{
                    if(mounted){
                      setState(() {
                        isLoading = true;
                      });
                    }
                    changePassword();
                  }
                }, color: greenBasic, text: "Submit")
              ],
            ),
          ),
        ),
      ),
    );
  }
}
