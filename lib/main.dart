// ignore_for_file: depend_on_referenced_packages


import 'package:hbe/views/splash/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'controllers/multi_provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent, // navigation bar color
    statusBarColor: Colors.transparent, // status bar color
    statusBarBrightness: Brightness.dark,//status bar brigtness
    statusBarIconBrightness:Brightness.dark , //status barIcon Brightness
    systemNavigationBarIconBrightness: Brightness.light, //navigation bar icon
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {


    return MultiProvider(
      providers: multiProvider,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'HGE',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home:const Splash(),
      ),
    );
  }
}

