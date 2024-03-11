import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {

  static saveUserName(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('username', username);
    log(username.toString());
  }

  static getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    return username;
  }

  static saveUserPassword(String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('password', password);
  }

  static getUserPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? value = prefs.getString('password');
    return value;
  }

  static saveIsLoggedIn(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', value);
  }

  static getUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? boolValue = prefs.getBool('isLoggedIn');
    return boolValue;
  }

  static saveRememberMe(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('remember_me', value);
  }

  static getRememberMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? boolValue = prefs.getBool('remember_me');
    return boolValue;
  }

  static saveBioLogin(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('bio_login', value);
  }

  static getBiologin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? boolValue = prefs.getBool('bio_login');
    return boolValue;
  }
}
