import 'package:code/constant/screen_size.dart';
import 'package:code/util/alerts.dart';
import 'package:code/util/app_color.dart';
import 'package:code/util/assets_path.dart';
import 'package:code/util/services/authentication_service.dart';
import 'package:code/util/style.dart';
import 'package:code/widgets/custom_widgets.dart';
import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {

  final txtOldPassword=TextEditingController();
  final txtPassword=TextEditingController();
  final txtConfirmPassword=TextEditingController();
  bool hidePassword=true;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor:AppColors.appBgColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.appBgColor,
          iconTheme: IconThemeData(color: Colors.black),
          title:  Text(
            "Change Password",
            style:
            headingStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [

              Padding(
                padding: EdgeInsets.only(left: ScreenSize.screenPadding,right: ScreenSize.screenPadding),
                child: Column(
                  children: <Widget>[

                    SizedBox(height: ScreenSize.height!*0.2,),
                    customTextField(hint: "Old Password",controller:txtOldPassword,hide: hidePassword,iconPath: AssetPath.passwordIcon,trailingIconPath:hidePassword==true?AssetPath.notVisibleIcon:AssetPath.visibleIcon,trailingAction: (){
                      setState(() {
                        hidePassword=!hidePassword;
                      });
                    }),

                    customTextField(hint: "New Password",controller:txtPassword,hide: hidePassword,iconPath: AssetPath.passwordIcon,trailingIconPath:hidePassword==true?AssetPath.notVisibleIcon:AssetPath.visibleIcon,trailingAction: (){
                      setState(() {
                        hidePassword=!hidePassword;
                      });
                    }),

                    customTextField(hint: "Confirm New Password",controller:txtConfirmPassword,hide: hidePassword,iconPath: AssetPath.passwordIcon,trailingIconPath:hidePassword==true?AssetPath.notVisibleIcon:AssetPath.visibleIcon,trailingAction: (){
                      setState(() {
                        hidePassword=!hidePassword;
                      });
                    }),
                    SizedBox(height:ScreenSize.height!*0.15,),
                    customButton("Change",() async {
                      changePassword();
                    }),
                    SizedBox(height:20,),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? oldPassword,password,confirmPassword;


  void getValues(){
    oldPassword=txtOldPassword.text;
    password=txtPassword.text;
    confirmPassword=txtConfirmPassword.text;
  }

  bool passwordMatches(){
    if(password==confirmPassword){
      return true;
    }else{
      return false;
    }
  }

  bool isEmpty(){
    if(oldPassword!.isEmpty||password!.isEmpty||confirmPassword!.isEmpty){
      return true;
    }else{
      return false;
    }
  }

  Future<void> changePassword() async {
    getValues();
    if(isEmpty()){
      MyAlert.showToast("Please Enter Passwords");
    }else{
      if(passwordMatches()){
        customloadingIndicator(context);
        bool result=await AuthenticationService.changePassword(oldPassword!, password!);
        Navigator.pop(context);
        if(result){
          MyAlert.showToast("Password updated");
          Navigator.pop(context);
        }
      }else{
        MyAlert.showToast("Password Doesn't matches");
      }
    }
  }
}
