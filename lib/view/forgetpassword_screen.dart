
import 'package:code/constant/screen_size.dart';
import 'package:code/util/app_color.dart';
import 'package:code/util/assets_path.dart';
import 'package:code/util/services/authentication_service.dart';
import 'package:code/util/style.dart';
import 'package:code/widgets/custom_widgets.dart';
import 'package:flutter/material.dart';


class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgetPasswordScreenState createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final txtEmail=TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.appBgColor,
        body:Padding(
          padding: EdgeInsets.only(left: ScreenSize.screenPadding,right: ScreenSize.screenPadding),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                customAppBar(icon:Icon(Icons.arrow_back_ios_outlined),title:"Send Link",f: (){
                  Navigator.pop(context);
                }),

                Center(
                  child: imageLogo(),
                ),

                SizedBox(height: ScreenSize.height!*0.1,),
                Column(
                  children: [
                    Text('''   Enter your registered email below to receive password reset instruction''',style: greyTextStyle(),textAlign: TextAlign.center,),
                    SizedBox(height:ScreenSize.height!*0.05,),
                    customTextField(hint: "Email",controller:txtEmail,iconPath: AssetPath.emailIcon),
                    SizedBox(height:ScreenSize.height!*0.3,),
                    customButton("Send Link",() async {
                      resetAction();
                    }),
                  ],
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  void resetAction() async{

    // show loading indicator while async completes
  customloadingIndicator(context);

  bool result=await AuthenticationService.resetPassword(txtEmail.text.trim());
  //close loading indicator
  Navigator.pop(context);

    if(result){

      showDialog(
          context: context,
          builder: (ctx){
            return customDialogBox(context,"Password Reset","Password reset link has been sent to your email address");
          }
      );
    }
  }



}




