import 'package:code/constant/my_constant.dart';
import 'package:code/constant/screen_size.dart';
import 'package:code/model/subscription_model.dart';
import 'package:code/model/user_model.dart';
import 'package:code/util/alerts.dart';
import 'package:code/util/app_color.dart';
import 'package:code/util/assets_path.dart';
import 'package:code/util/routes.dart';
import 'package:code/util/services/authentication_service.dart';
import 'package:code/util/style.dart';
import 'package:code/view/bottom_nav_bar/bottom_navigation_bar.dart';
import 'package:code/widgets/custom_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({Key? key}) : super(key: key);

  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {

  final txtEmail=TextEditingController();
  final txtName=TextEditingController();

  final txtPassword=TextEditingController();
  final txtConfirmPassword=TextEditingController();

  bool hidePassword=true;
  bool isLogin=true;
  @override
  Widget build(BuildContext context) {
    ScreenSize.width=MediaQuery.of(context).size.width;
    ScreenSize.height=MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor:AppColors.appBgColor,
        body: Padding(
          padding: EdgeInsets.only(left: ScreenSize.screenPadding,right: ScreenSize.screenPadding),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[

                SizedBox(height: ScreenSize.height!*0.05,),
                Center(child: imageLogo()),
                SizedBox(height: ScreenSize.height!*0.05,),
                Row(
                  children: [
                    GestureDetector(
                        onTap: (){
                          setState(() {
                            isLogin=true;
                          });
                        },
                        child: Text("Sign In",style: headingStyle(fontSize: 28,fontWeight: FontWeight.bold,color: isLogin?Colors.black:Colors.grey),)),
                    SizedBox(width: 30,),
                    GestureDetector(
                        onTap: (){
                          setState(() {
                            isLogin=false;
                          });
                        },
                        child: Text("Sign Up",style: headingStyle(fontSize: 28,fontWeight: FontWeight.bold,color: !isLogin?Colors.black:Colors.grey),)),

                  ],
                ),

                SizedBox(height: ScreenSize.height!*0.02,),
                Text(isLogin?"Sign in to your account below":"Get started by creating an account below",style:greyTextStyle(),),
                SizedBox(height: ScreenSize.height!*0.02,),

                Visibility(
                  visible: !isLogin,
                  child:customTextField(hint: "Full Name",controller:txtName,icon: Icon(Icons.person,color: Colors.grey.withOpacity(0.5),)),
                ),
                customTextField(hint: "Your email address",controller:txtEmail,iconPath: AssetPath.emailIcon),
                customTextField(hint: "Password",controller:txtPassword,hide: hidePassword,iconPath: AssetPath.passwordIcon,trailingIconPath:hidePassword==true?AssetPath.notVisibleIcon:AssetPath.visibleIcon,trailingAction: (){
                  setState(() {
                    hidePassword=!hidePassword;
                  });
                }),

                Visibility(
                  visible: !isLogin,
                  child: customTextField(hint: "Confirm Password",controller:txtConfirmPassword,hide: hidePassword,iconPath: AssetPath.passwordIcon,trailingIconPath:hidePassword==true?AssetPath.notVisibleIcon:AssetPath.visibleIcon,trailingAction: (){
                    setState(() {
                      hidePassword=!hidePassword;
                    });
                  }),
                ),

                SizedBox(height: ScreenSize.height!*0.02,),
                Visibility(
                  visible: isLogin,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: (){
                          Navigator.pushNamed(context, MyRoutes.forgetPasswordScreen);
                        },
                        child: Padding(
                          padding: EdgeInsets.only(top: 8,bottom: 8,left: 8),
                          child: Align(
                              alignment: Alignment.topRight,
                              child: Text("Forgot Password?",style:TextStyle(fontSize: 14,color:AppColors.blueTextColor,fontWeight: FontWeight.bold),)),
                        ),
                      ),

                      customButton("Sign In",() async {
                        signInAction();
                         //Navigator.pushNamed(context, MyRoutes.bottomNavScreen);
                      },width: ScreenSize.width!*0.35,icon: Icon(Icons.person,color: Colors.white,)),
                    ],
                  ),
                ),



                Visibility(
                  visible: !isLogin,
                  child:   Align(
                    alignment: Alignment.centerRight,
                    child: customButton("Sign Up",() async {
                      signUpAction();
                      // Navigator.pushNamed(context, MyRoutes.bottomNavigationBarScreen);
                    },width: ScreenSize.width!*0.35,icon: Icon(Icons.navigate_next_outlined,color: Colors.white,)),
                  ),
                ),


              ],
            ),
          ),
        ),
      ),
    );
  }

  String? email,name;
  String? password;
String? cnfrmPassowrd;

  void getValues(){
    email=txtEmail.text.trim();
    password=txtPassword.text;
    name=txtName.text;
    cnfrmPassowrd=txtConfirmPassword.text;
  }

  bool isLoginEmpty(){
    if(email!.isEmpty||password!.isEmpty){
      return true;
    }else{
      return false;
    }
  }


  bool isSignUpEmpty(){
    if(email!.isEmpty||password!.isEmpty||cnfrmPassowrd!.isEmpty||name!.isEmpty){
      return true;
    }else{
      return false;
    }
  }

void signInAction() async{
  getValues();
  if(isLoginEmpty()){
    MyAlert.showToast("Enter Email and Password");
  }else{

    // show loading indicator
    customloadingIndicator(context);

    bool result= await AuthenticationService.signInWithEmailAndPassword(email!, password!);


    if(result){
      MyConstant.currentUserModel=await UserModel.getUser(MyConstant.currentUserID!);

      // save into shared prefference
      AuthenticationService.saveUser(MyConstant.currentUserID!);




      if(MyConstant.currentUserModel!=null){
        print("login username is ${ MyConstant.currentUserModel!.name}");
      }

      SubscriptionModel.getThisMonthLimit();

      // close indicator

      Navigator.pop(context);
      //
       Navigator.pushNamed(context, MyRoutes.bottomNavScreen);
    }else{
      Navigator.pop(context);
    }

  }
}

  bool passwordMatches() {
    if (password == cnfrmPassowrd) {
      return true;
    } else {
      return false;
    }
  }


  void signUpAction() async {
    getValues();
    if (isSignUpEmpty()) {
      MyAlert.showToast("Please fill all fields");
    } else {
      if (passwordMatches()) {
        // show loading indicator
        customloadingIndicator(context);

        bool result =
        await AuthenticationService.createUserWithEmailAndPassword(
            email!, password!);

        if (result) {
          UserModel _userModel = UserModel(
              userId: MyConstant.currentUserID,
               name: name,
              monthyLimit:0,
              email: email,
              imgUrl: "null");
          result = await _userModel.addUser();

          if (result) {
            MyConstant.currentUserModel = _userModel;

            // save into shared prefference
            AuthenticationService.saveUser(MyConstant.currentUserID!);

            SubscriptionModel.getThisMonthLimit();

            // close indicator

            Navigator.pop(context);

            Navigator.push(
                context, MaterialPageRoute(builder: (context) => BottomNavigationScreen()));
          }
        } else {
          // close indicator

          Navigator.pop(context);
        }
      } else {
        MyAlert.showToast("Password doesn't matches");
      }
    }
  }
}


