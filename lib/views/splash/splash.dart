
import 'package:hbe/views/login/login.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../distributor/screens/dashboard/distributorDash.dart';
import '../../utils/app_routes.dart';
import '../../utils/color_constants.dart';
import '../dashboard/dash_screen.dart';
class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  final Duration initialDelay = const Duration(milliseconds: 100);

  @override
  void initState() {
    super.initState();
    getPermissions();
   checkIfUserLoggedIn();
  }

  Map<Permission, PermissionStatus>? statuses;
  getPermissions() async {
    statuses = await [
      Permission.location
    ].request();
  }

  checkIfUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var loggedIn = prefs.getBool('remember_me');
    var isLoggedIn = prefs.getBool("IsLoggedIn");
    var userId = prefs.getInt("userID");
    var type = prefs.getString("role");


    if (userId != null) {
      if (loggedIn == false || loggedIn == true && isLoggedIn == false) {
        Future.delayed(const Duration(seconds: 3),
                () => AppRoutes.pushAndRemoveUntil(context, const Login()));
      }

      else if (loggedIn == false || loggedIn == true && isLoggedIn == true) {
        if(type.toString()=="Distributor Salesman"){
          Future.delayed(const Duration(seconds: 3),
                  () => AppRoutes.pushAndRemoveUntil(context,  DistributorDashboard(hit: true,)));
        }
        else{
          Future.delayed(const Duration(seconds: 3),
                  () => AppRoutes.pushAndRemoveUntil(context,  DashScreen(hit: true,)));
        }

      }
      else {
        Future.delayed(const Duration(seconds: 3),
                () => AppRoutes.pushAndRemoveUntil(context, const Login()));
      }
    }
    else {
      Future.delayed(const Duration(seconds: 3),
              () => AppRoutes.pushAndRemoveUntil(context, const Login()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGreen,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DelayedDisplay(
                delay: initialDelay,
                child: Hero(
                    tag: 'splash',
                    child: Image.asset("assets/icons/appLogo.png",width: MediaQuery.of(context).size.width*0.65,))),
          ],
        ),
      )

    );
  }
}
