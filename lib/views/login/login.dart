// ignore_for_file: use_build_context_synchronously, no_leading_underscores_for_local_identifiers, depend_on_referenced_packages

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:hbe/enums/globals.dart';
import 'package:hbe/service/api_urls.dart';
import 'package:hbe/utils/app_routes.dart';
import 'package:hbe/utils/toast_utils.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_icon_button/loading_icon_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../distributor/screens/dashboard/distributorDash.dart';
import '../../utils/color_constants.dart';
import '../../utils/shared_pref.dart';
import 'package:http/http.dart' as http;

import '../dashboard/dash_screen.dart';


class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passController = TextEditingController();
  final Duration initialDelay = const Duration(milliseconds: 100);
  bool isBioLogin = false;
  bool _passwordVisible = true;
  bool _rememberMe = false;
  List items =["Company","Distributor Salesman"];
  String selected = "Distributor Salesman";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initPlatformState();
    loadUserNamePassword();
  }

  void loadUserNamePassword() async {
    try {
      var _username = await SharedPref.getUserName();
      var _password = await SharedPref.getUserPassword();
      var _remeberMe = await SharedPref.getRememberMe();

      if (_remeberMe) {
        setState(() {
          _rememberMe = true;
          isBioLogin = true;
          usernameController.text = _username;
          passController.text = _password;
        });
      } else {
        setState(() {
          _rememberMe = false;
          usernameController.text = _username;
          passController.text = _password;
        });
      }
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  void dispose() {
    super.dispose();
    usernameController.dispose();
    passController.dispose();
  }
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  AndroidDeviceInfo? androidInfo;
  IosDeviceInfo? iosInfo;
  Map<String, dynamic> deviceData = <String, dynamic>{};

  Future<void> initPlatformState() async {
    try {
      if (Platform.isAndroid) {
        androidInfo = await deviceInfoPlugin.androidInfo;
      } else if (Platform.isIOS) {
        iosInfo = await deviceInfoPlugin.iosInfo;
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }
  }

  final LoadingButtonController _btnController = LoadingButtonController();

  //LOGIN API
  Future<void> userLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var username = Uri.encodeComponent(usernameController.text.toString());
    var password = Uri.encodeComponent(passController.text.toString());

    var deviceId = Platform.isAndroid
        ? androidInfo!.androidId.toString()
        : iosInfo!.identifierForVendor;

    try {
      var response = await http.get(
        Uri.parse(
          selected=="Distributor Salesman"?  '${ApiUrls.distributorUrl}${ApiUrls.getLoginUser}?UserName=$username&Password=$password&DeviceID=$deviceId&Auth_Key=':
          '${ApiUrls.baseURL}${ApiUrls.getLoginUserDetails}?UserName=$username&Password=$password&DeviceID=$deviceId&Auth_Key='),
        headers: {
          ApiUrls.key_name: ApiUrls.apikey,
          "Content-Type": "application/json; charset=utf-8"
        },
      );

      var res = jsonDecode(response.body);
      log(res[0]["MessageCode"].toString());
      if (response.statusCode == 200 && res[0]["MessageCode"].toString()=="0001") {

        if(mounted){
          setState(() {
            globalData.userName=res[0]["UserName"].toString();
            globalData.role=selected.toString();
            globalData.designationName=res[0]["DesignationName"].toString();
            globalData.userTypeName=res[0]["UserTypeName"].toString();
          });
        }
        prefs.setBool("IsLoggedIn", true);
        prefs.setInt("userID", res[0]["UserID"]);
        prefs.setString("userName", res[0]["UserName"].toString());
        prefs.setString("role", selected.toString());
        prefs.setString("empName", res[0]["EmpName"].toString());
        prefs.setString("phoneNo", res[0]["PhoneNo"].toString());
        prefs.setString("empCode", res[0]["EmpCode"].toString());
        prefs.setString("departmentName", res[0]["DepartmentName"].toString());
        prefs.setString("branchName", res[0]["BranchName"].toString());
        prefs.setString("designationName", res[0]["DesignationName"].toString());
        prefs.setInt("userTypeID", res[0]["UserTypeID"]);
        prefs.setString("userTypeName", res[0]["UserTypeName"].toString());
        prefs.setInt("sO", res[0]["SO"]);
        if(selected=="Company"){
          prefs.setInt("gM", res[0]["GM"]);
          prefs.setString("gMName", res[0]["GMName"].toString());
          prefs.setInt("sT", res[0]["ST"]);
          prefs.setString("sTName", res[0]["STName"].toString());
          prefs.setInt("dM", res[0]["DM"]);
          prefs.setString("dMName", res[0]["DMName"].toString());
          prefs.setInt("sDM", res[0]["SDM"]);
          prefs.setString("sDMName", res[0]["SDMName"].toString());

          prefs.setString("sOName", res[0]["SOName"].toString());
        }



        ToastUtils.successToast("Login Success", context);

        _btnController.success();
        Future.delayed(const Duration(seconds: 1), () {
          _btnController.reset();
        });

        navigateToDashboard();
      }
      else if(response.statusCode == 200  && res[0]["MessageCode"].toString()=="0000"){
        _btnController.error();
        Future.delayed(const Duration(seconds: 1), () {
          _btnController.reset();
        });
        ToastUtils.failureToast("User not found", context);
      }
      else {

        _btnController.error();
        Future.delayed(const Duration(seconds: 1), () {
          _btnController.reset();
        });
        ToastUtils.failureToast("Something went wrong", context);
        throw Exception('Failed to load data');
      }
    } on SocketException {
      ToastUtils.failureToast("No Internet Connection", context);
      _btnController.error();
      Future.delayed(const Duration(seconds: 1), () {
        _btnController.reset();
      });

    } on HttpException {

      _btnController.error();
      Future.delayed(const Duration(seconds: 1), () {
        _btnController.reset();
      });
      ToastUtils.failureToast("Couldn't find the data 😱", context);

    } on FormatException {

      ToastUtils.failureToast("Internal Server Error ", context);
      _btnController.error();
      Future.delayed(const Duration(seconds: 1), () {
        _btnController.reset();
      });
    }

  }

  void navigateToDashboard() {
    if(selected=="Distributor Salesman"){
      Future.delayed(
          const Duration(seconds: 1),
              () => AppRoutes.pushAndRemoveUntil(
              context,
                  DistributorDashboard(hit: true,)));

    }
    else{
      Future.delayed(
          const Duration(seconds: 1),
              () => AppRoutes.pushAndRemoveUntil(
              context,
              DashScreen(hit: true,)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: lightGreen,
      body: SafeArea(
        child: SizedBox(
          height: size.height,
          child: Stack(
            children: <Widget>[
              //left side background design. I use a svg image here
              Positioned(
                left: -34,
                top: 181.0,
                child: SvgPicture.string(
                  // Group 3178
                  '<svg viewBox="-34.0 181.0 99.0 99.0" ><path transform="translate(-34.0, 181.0)" d="M 74.25 0 L 99 49.5 L 74.25 99 L 24.74999618530273 99 L 0 49.49999618530273 L 24.7500057220459 0 Z" fill="none" stroke="#0A4122" stroke-width="1" stroke-opacity="0.25" stroke-miterlimit="4" stroke-linecap="butt" /><path transform="translate(-26.57, 206.25)" d="M 0 0 L 42.07500076293945 16.82999992370605 L 84.15000152587891 0" fill="none" stroke="#0A4122" stroke-width="1" stroke-opacity="0.25" stroke-miterlimit="4" stroke-linecap="butt" /><path transform="translate(15.5, 223.07)" d="M 0 56.42999649047852 L 0 0" fill="none" stroke="#0A4122" stroke-width="1" stroke-opacity="0.25" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
                  width: 99.0,
                  height: 99.0,
                ),
              ),

              //right side background design. I use a svg image here
              Positioned(
                right: -52,
                top: 45.0,
                child: SvgPicture.string(
                  // Group 3177
                  '<svg viewBox="288.0 45.0 139.0 139.0" ><path transform="translate(288.0, 45.0)" d="M 104.25 0 L 139 69.5 L 104.25 139 L 34.74999618530273 139 L 0 69.5 L 34.75000762939453 0 Z" fill="none" stroke="#0A4122" stroke-width="1" stroke-opacity="0.25" stroke-miterlimit="4" stroke-linecap="butt" /><path transform="translate(298.42, 80.45)" d="M 0 0 L 59.07500076293945 23.63000106811523 L 118.1500015258789 0" fill="none" stroke="#0A4122" stroke-width="1" stroke-opacity="0.25" stroke-miterlimit="4" stroke-linecap="butt" /><path transform="translate(357.5, 104.07)" d="M 0 79.22999572753906 L 0 0" fill="none" stroke="#0A4122" stroke-width="1" stroke-opacity="0.25" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
                  width: 139.0,
                  height: 139.0,
                ),
              ),

              //content ui
              Positioned(
                top: 8.0,
                child: SizedBox(
                  width: size.width,
                  height: size.height,
                  child: Padding(
                    padding:
                    EdgeInsets.symmetric(horizontal: size.width * 0.06),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //logo section
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              DelayedDisplay(
                                  delay:initialDelay,
                                  child: logo(size.height / 4, size.height / 4)),
                              DelayedDisplay(
                                  delay: Duration(
                                      milliseconds: initialDelay.inMilliseconds + 100),
                                  child: richText(25)),
                              const SizedBox(
                                height: 10,
                              ),
                              DelayedDisplay(
                                delay: Duration(
                                    milliseconds: initialDelay.inMilliseconds + 100),
                                child: const Text(
                                  'Fill in the fields to login.',
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    fontFamily: 'Poppins-Regular',
                                    color: greenBasic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              DelayedDisplay(
                                  delay: Duration(
                                      milliseconds: initialDelay.inMilliseconds + 200),
                                  child: emailTextField(size)),
                              const SizedBox(
                                height: 8,
                              ),
                              DelayedDisplay(
                                  delay: Duration(
                                      milliseconds: initialDelay.inMilliseconds + 300),
                                  child: passwordTextField(size)),
                              const SizedBox(
                                height: 8,
                              ),
                              // DelayedDisplay(
                              //   delay: Duration(
                              //       milliseconds: initialDelay.inMilliseconds + 350),
                              //   child:  Container(
                              //     alignment: Alignment.center,
                              //     height: size.height / 12,
                              //     decoration: BoxDecoration(
                              //       borderRadius: BorderRadius.circular(10.0),
                              //       color:  greenBasic.withOpacity(0.2),
                              //     ),
                              //     child: Padding(
                              //       padding:
                              //       const EdgeInsets.only(left: 10.0, right: 10.0),
                              //       child: DropdownButtonHideUnderline(
                              //           child: DropdownButton<String>(
                              //
                              //             menuMaxHeight: 350,
                              //             borderRadius: BorderRadius.circular(10),
                              //             icon: const Icon(
                              //               FeatherIcons.chevronDown,
                              //               size: 20,
                              //             ),
                              //             isExpanded: false,
                              //             style: const TextStyle(
                              //               fontSize: 14.0,
                              //               color: greenBasic,
                              //               fontFamily: 'Poppins-Regular',),
                              //             onChanged: (String? changedValue) {
                              //               if(mounted) {
                              //                 setState(() {
                              //                   selected = changedValue!;
                              //                 });
                              //               }
                              //             },
                              //             value: selected,
                              //             items: items.map((item) {
                              //               return DropdownMenuItem(
                              //                 value: item.toString(),
                              //                 child: SizedBox(
                              //                   width: MediaQuery.of(context).size.width*0.7,
                              //                   child: Text(
                              //                     item,style: const TextStyle(
                              //                     fontSize: 14.0,
                              //                     color: greenBasic,
                              //                     fontFamily: 'Poppins-Regular',),
                              //                   ),
                              //                 ),
                              //               );
                              //             }).toList(),
                              //           )),
                              //     ),
                              //   ),
                              //
                              // ),
                              const SizedBox(
                                height: 16,
                              ),
                              DelayedDisplay(
                                  delay: Duration(
                                      milliseconds: initialDelay.inMilliseconds + 400),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    rememberMeCheckbox(_rememberMe, handleRememberMe),
                                  ],
                                )),
                            ],
                          ),
                        ),
                        //sign in button & continue with text here
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              DelayedDisplay(
                                  delay: Duration(
                                      milliseconds: initialDelay.inMilliseconds + 500),
                                  child:  LoadingButton(
                                    loaderSize: 25,
                                    primaryColor: greenBasic,
                                    height: 50,
                                    width: MediaQuery.of(context).size.width,
                                    borderRadius: 5,
                                    onPressed: () => buttonPressed(),
                                    controller: _btnController,
                                    child: const Text('Login', style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontFamily: "Poppins-Medium")),
                                  ),
                              ),

                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

    void buttonPressed() async{
      if(usernameController.text.isEmpty){
        _btnController.error();
        Future.delayed(const Duration(seconds: 1), () {
          _btnController.reset();
        });
        ToastUtils.failureToast("Enter username", context);
      }
      else if(passController.text.isEmpty){
        _btnController.error();
        Future.delayed(const Duration(seconds: 1), () {
          _btnController.reset();
        });
        ToastUtils.failureToast("Enter password", context);
      }
      else{
        userLogin();
      }
}

  Widget logo(double height_, double width_) {
    return Hero(
      tag: 'splash',
      child: Image.asset(
        'assets/icons/appLogo.png',
        height: height_,
        width: width_,
      ),
    );
  }

  Widget richText(double fontSize) {
    return Text("LOGIN",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: fontSize, color: greenBasic));
  }

  Widget emailTextField(Size size) {
    return Container(
      alignment: Alignment.center,
      height: size.height / 12,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color:  greenBasic.withOpacity(0.2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            //mail icon
            const Icon(
              Icons.mail_rounded,
              color: greenBasic,
            ),
            const SizedBox(
              width: 16,
            ),

            //divider svg
            SvgPicture.string(
              '<svg viewBox="99.0 332.0 1.0 15.5" ><path transform="translate(99.0, 332.0)" d="M 0 0 L 0 15.5" fill="none" fill-opacity="0.6" stroke="#0A4122" stroke-width="1" stroke-opacity="0.6" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
              width: 1.0,
              height: 15.5,
            ),
            const SizedBox(
              width: 16,
            ),

            //email address textField
            Expanded(
              child: TextField(
                controller: usernameController,
                maxLines: 1,
                cursorColor: Colors.white70,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                  fontSize: 14.0,
                  color: greenBasic,
                  fontFamily: 'Poppins-Regular',
                ),
                decoration: const InputDecoration(
                    hintText: 'Enter your username',
                    hintStyle: TextStyle(
                      fontFamily: 'Poppins-Regular',
                      fontSize: 14,
                      color: greenBasic,
                    ),
                    border: InputBorder.none),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget passwordTextField(Size size) {
    return Container(
      alignment: Alignment.center,
      height: size.height / 12,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color:  greenBasic.withOpacity(0.2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            //lock logo here
            const Icon(
              Icons.lock,
              color: greenBasic,
            ),
            const SizedBox(
              width: 16,
            ),

            //divider svg
            SvgPicture.string(
              '<svg viewBox="99.0 332.0 1.0 15.5" ><path transform="translate(99.0, 332.0)" d="M 0 0 L 0 15.5" fill="none" fill-opacity="0.6" stroke="#0A4122" stroke-width="1" stroke-opacity="0.6" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
              width: 1.0,
              height: 15.5,
            ),
            const SizedBox(
              width: 16,
            ),

            //password textField
            Expanded(
              child: TextField(
                maxLines: 1,
                controller: passController,
                cursorColor: Colors.white70,
                keyboardType: TextInputType.visiblePassword,
                obscureText: _passwordVisible,
                style: const TextStyle(
                  fontSize: 14.0,
                  color: greenBasic,
                  fontFamily: 'Poppins-Regular',
                ),
                decoration: InputDecoration(
                    hintText: 'Enter your password',
                    hintStyle: const TextStyle(
                      fontFamily: 'Poppins-Regular',
                      fontSize: 14,
                      color: greenBasic,
                    ),
                    suffixIcon: InkWell(
                        onTap: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                           _passwordVisible? Icons.visibility:Icons.visibility_off_outlined,
                            color: greenBasic,
                          ),
                        )),
                    border: InputBorder.none),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget rememberMeCheckbox(
      bool _rememberMe, void Function(bool?) handleRememberMe) {
    return Row(
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
                value: _rememberMe,
                activeColor: greenBasic,
                onChanged: handleRememberMe),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'Remember me!',
          style: TextStyle(fontSize: 14, color: greenBasic,fontFamily: 'Poppins-Regular'),
        ),
      ],
    );
  }

  Widget signInButton(Size size) {
    return Container(
      alignment: Alignment.center,
      height: size.height / 13,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: greenBasic,
      ),
      child: const Text(
        'Login',
        style: TextStyle(
          fontSize: 18,
          fontFamily: 'Poppins-SemiBold',
          color: white,
        ),
      ),
    );
  }

  Widget buildContinueText() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
            child: Divider(
              color: white,
            )),
        Expanded(
          child: Text(
            'Or Continue with',
            style: TextStyle(
              fontSize: 12.0,
              color: white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
            child: Divider(
              color: white,
            )),
      ],
    );
  }

  Widget signInGoogleFacebookButton(Size size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        //sign in google button
        Container(
          alignment: Alignment.center,
          width: size.width / 2.8,
          height: size.height / 13,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              width: 1.0,
              color: white,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //icon of google
              SvgPicture.string(
                '<svg viewBox="63.54 641.54 22.92 22.92" ><path transform="translate(63.54, 641.54)" d="M 22.6936149597168 9.214142799377441 L 21.77065277099609 9.214142799377441 L 21.77065277099609 9.166590690612793 L 11.45823860168457 9.166590690612793 L 11.45823860168457 13.74988651275635 L 17.93386268615723 13.74988651275635 C 16.98913192749023 16.41793632507324 14.45055770874023 18.33318138122559 11.45823860168457 18.33318138122559 C 7.661551475524902 18.33318138122559 4.583295345306396 15.25492572784424 4.583295345306396 11.45823860168457 C 4.583295345306396 7.661551475524902 7.661551475524902 4.583295345306396 11.45823860168457 4.583295345306396 C 13.21077632904053 4.583295345306396 14.80519008636475 5.244435787200928 16.01918983459473 6.324374675750732 L 19.26015281677246 3.083411931991577 C 17.21371269226074 1.176188230514526 14.47633838653564 0 11.45823860168457 0 C 5.130426406860352 0 0 5.130426406860352 0 11.45823860168457 C 0 17.78605079650879 5.130426406860352 22.91647720336914 11.45823860168457 22.91647720336914 C 17.78605079650879 22.91647720336914 22.91647720336914 17.78605079650879 22.91647720336914 11.45823860168457 C 22.91647720336914 10.68996334075928 22.83741569519043 9.940022468566895 22.6936149597168 9.214142799377441 Z" fill="#ffffff" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /><path transform="translate(64.86, 641.54)" d="M 0 6.125000953674316 L 3.764603137969971 8.885863304138184 C 4.78324031829834 6.363905429840088 7.250198841094971 4.583294868469238 10.13710117340088 4.583294868469238 C 11.88963890075684 4.583294868469238 13.48405265808105 5.244434833526611 14.69805240631104 6.324373722076416 L 17.93901443481445 3.083411693572998 C 15.89257335662842 1.176188111305237 13.15520095825195 0 10.13710117340088 0 C 5.735992908477783 0 1.919254422187805 2.484718799591064 0 6.125000953674316 Z" fill="#ffffff" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /><path transform="translate(64.8, 655.32)" d="M 10.20069408416748 9.135653495788574 C 13.16035556793213 9.135653495788574 15.8496036529541 8.003005981445312 17.88286781311035 6.161093711853027 L 14.33654403686523 3.160181760787964 C 13.14749050140381 4.064460277557373 11.69453620910645 4.553541660308838 10.20069408416748 4.55235767364502 C 7.220407009124756 4.55235767364502 4.689855575561523 2.6520094871521 3.736530303955078 0 L 0 2.878881216049194 C 1.896337866783142 6.589632034301758 5.747450828552246 9.135653495788574 10.20069408416748 9.135653495788574 Z" fill="#ffffff" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /><path transform="translate(75.0, 650.71)" d="M 11.23537635803223 0.04755179211497307 L 10.31241607666016 0.04755179211497307 L 10.31241607666016 0 L 0 0 L 0 4.583295345306396 L 6.475625038146973 4.583295345306396 C 6.023715496063232 5.853105068206787 5.209692478179932 6.962699413299561 4.134132385253906 7.774986743927002 L 4.135851383209229 7.773841857910156 L 7.682177066802979 10.77475357055664 C 7.431241512298584 11.00277233123779 11.45823955535889 8.020766258239746 11.45823955535889 2.291647672653198 C 11.45823955535889 1.523372769355774 11.37917804718018 0.773431122303009 11.23537635803223 0.04755179211497307 Z" fill="#ffffff" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
                width: 22.92,
                height: 22.92,
              ),
              const SizedBox(
                width: 16,
              ),
              //google txt
              const Text(
                'Google',
                style: TextStyle(
                  fontSize: 14.0,
                  color: white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(
          width: 16,
        ),

        //sign in facebook button
        Container(
          alignment: Alignment.center,
          width: size.width / 2.8,
          height: size.height / 13,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              width: 1.0,
              color: white,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //facebook icon
              SvgPicture.string(
                '<svg viewBox="0.3 0.27 22.44 22.44" ><defs><linearGradient id="gradient" x1="0.500031" y1="0.970054" x2="0.500031" y2="0.0"><stop offset="0.0" stop-color="#ffffffff"  /><stop offset="1.0" stop-color="#ffffffff"  /></linearGradient></defs><path transform="translate(0.3, 0.27)" d="M 9.369577407836914 22.32988739013672 C 4.039577960968018 21.3760986328125 0 16.77546882629395 0 11.22104930877686 C 0 5.049472332000732 5.049472808837891 0 11.22105026245117 0 C 17.39262962341309 0 22.44210624694824 5.049472332000732 22.44210624694824 11.22104930877686 C 22.44210624694824 16.77546882629395 18.40252304077148 21.3760986328125 13.07252502441406 22.32988739013672 L 12.45536518096924 21.8249397277832 L 9.986735343933105 21.8249397277832 L 9.369577407836914 22.32988739013672 Z" fill="url(#gradient)" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /><path transform="translate(6.93, 4.65)" d="M 8.976840972900391 9.986734390258789 L 9.481786727905273 6.844839572906494 L 6.508208274841309 6.844839572906494 L 6.508208274841309 4.656734466552734 C 6.508208274841309 3.759051322937012 6.844841003417969 3.085787773132324 8.191367149353027 3.085787773132324 L 9.650103569030762 3.085787773132324 L 9.650103569030762 0.2244201600551605 C 8.864629745483398 0.1122027561068535 7.966946125030518 0 7.181471347808838 0 C 4.600629806518555 0 2.805262804031372 1.570946097373962 2.805262804031372 4.376209735870361 L 2.805262804031372 6.844839572906494 L 0 6.844839572906494 L 0 9.986734390258789 L 2.805262804031372 9.986734390258789 L 2.805262804031372 17.8975715637207 C 3.422420024871826 18.00978851318359 4.039577484130859 18.06587600708008 4.656735897064209 18.06587600708008 C 5.273893356323242 18.06587600708008 5.89105224609375 18.009765625 6.508208274841309 17.8975715637207 L 6.508208274841309 9.986734390258789 L 8.976840972900391 9.986734390258789 Z" fill="#21899c" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
                width: 22.44,
                height: 22.44,
              ),
              const SizedBox(
                width: 16,
              ),

              //facebook txt
              const Text(
                'Facebook',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.0,
                  color: white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildFooter(Size size) {
    return const Align(
      alignment: Alignment.center,
      child: Text.rich(
        TextSpan(
          style: TextStyle(
            fontSize: 16.0,
            color: white,
          ),
          children: [
            TextSpan(
              text: 'Don’t have account? ',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: 'Sign up',
              style: TextStyle(
                color: Color(0xFFF9CA58),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void handleRememberMe(bool? value) async {
    _rememberMe = value!;
    SharedPref.saveRememberMe(value);
    SharedPref.saveUserName(usernameController.text);
    SharedPref.saveUserPassword(passController.text);

    setState(() {
      _rememberMe = value;
    });
  }

}
