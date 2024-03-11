// ignore_for_file: must_be_immutable

import 'package:hbe/distributor/widgets/distributorDrawer.dart';
import 'package:hbe/enums/globals.dart';
import 'package:hbe/utils/toast_utils.dart';
import 'package:hbe/views/profile/change_password.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_routes.dart';
import '../../utils/color_constants.dart';
import '../../widgets/navDrawer.dart';
import '../../widgets/profile_list_items.dart';
import '../login/login.dart';
class ProfileScreen extends StatefulWidget {
  bool fromTab;
   ProfileScreen({Key? key,required this.fromTab}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
  }

  var empName, userName, empCode, phoneNo, branchName, depName, designationName,userType,role;
  getUser() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(mounted){
      setState(() {
        empName=  prefs.getString("empName");
        userName= prefs.getString("userName");
        empCode= prefs.getString("empCode");
        phoneNo=prefs.getString("phoneNo");
        branchName= prefs.getString("branchName");
        depName=  prefs.getString("departmentName");
        designationName=  prefs.getString("designationName");
        userType= prefs.getString("userTypeName");
        role= prefs.getString("role");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading:widget.fromTab? true:false,
        backgroundColor: greenBasic,
        title: Text("Profile",style: TextStyle(fontFamily: "Poppins-Medium",fontSize: 16),),
        centerTitle: true,
      ),
      drawer: widget.fromTab?role.toString()=="Distributor"? DistributorDrawer():DrawerWidget():null,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("Personal Information",style: TextStyle(fontFamily: "Poppins-SemiBold",fontSize: 18)),
              ProfileListItem(icon: FeatherIcons.user, text: "Employee Name", hasNavigation: false,textValue: empName.toString()),
              ProfileListItem(icon: IonIcons.person_sharp, text: "Username",hasNavigation: false,textValue:userName.toString()),
              ProfileListItem(icon: FeatherIcons.userCheck, text: "Employee Code",hasNavigation: false,textValue: empCode.toString()),
              ProfileListItem(icon: FeatherIcons.phone, text: "Phone No",hasNavigation: false,textValue:phoneNo.toString()),
              ProfileListItem(icon: IonIcons.home, text: "Branch Name",hasNavigation: false,textValue: branchName.toString()),
              ProfileListItem(icon: IonIcons.briefcase_sharp, text: "Department Name",hasNavigation: false,textValue: depName.toString()),
              ProfileListItem(icon: IonIcons.id_card_sharp, text: "Designation Name",hasNavigation: false,textValue: designationName.toString()),
              ProfileListItem(icon: IonIcons.person_circle, text: "User Type",hasNavigation: false,textValue: userType.toString()),
              SizedBox(height: 10),
              Text("Password",style: TextStyle(fontFamily: "Poppins-SemiBold",fontSize: 18)),
              InkWell(
                  onTap: (){
                    AppRoutes.push(context, PageTransitionType.fade, ChangePassword());
                  },
                  child: ProfileListItem(icon: FeatherIcons.lock, text: "Change Password", hasNavigation: true,textValue: "")),
              SizedBox(height: 10),
              Text("Settings",style: TextStyle(fontFamily: "Poppins-SemiBold",fontSize: 18)),
              InkWell(
                  onTap: () async{
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.clear();
                    if(mounted){
                      setState(() {
                        globalData.userName ="";
                        globalData.designationName ="";
                        globalData.menuItems.clear();
                      });
                    }
                    ToastUtils.successToast("Logout Successfully", context);
                    Future.delayed(const Duration(seconds: 1),
                            () => AppRoutes.pushAndRemoveUntil(context, const Login()));
                  },
                  child: ProfileListItem(icon: FeatherIcons.logOut, text: "Logout", hasNavigation: true,textValue: "")),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),

    );
  }
}
