import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code/constant/my_constant.dart';
import 'package:code/model/subscription_model.dart';
import 'package:code/model/user_model.dart';
import 'package:code/util/routes.dart';
import 'package:code/util/services/notification_service.dart';
import 'package:code/view/add_subscription_screen.dart';
import 'package:code/view/authentication_screen.dart';
import 'package:code/view/bottom_nav_bar/bottom_navigation_bar.dart';
import 'package:code/view/change_password.dart';
import 'package:code/view/detail_subscription_screen.dart';
import 'package:code/view/forgetpassword_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'util/services/notification_api.dart';

Future<void> main() async {


  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService().init();

  await NotificationAPI.init();

  await Firebase.initializeApp();



  SharedPreferences prefs = await SharedPreferences.getInstance();
  var userID = prefs.getString('userID')??'';
  if(userID!=''){
    MyConstant.currentUserModel= await UserModel.getUser(userID);
    MyConstant.currentUserID=userID;
    print("Saved User id is ${ MyConstant.currentUserModel!.userId}");

    SubscriptionModel.getThisMonthLimit();
  }

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark
  ));


  runApp(

      MaterialApp(
        initialRoute:userID.isEmpty?MyRoutes.authenticationScreen:MyRoutes.bottomNavScreen,
        routes: {
          MyRoutes.authenticationScreen:(context)=>AuthenticationScreen(),
          MyRoutes.forgetPasswordScreen:(context)=>ForgetPasswordScreen(),
          MyRoutes.bottomNavScreen:(context)=>BottomNavigationScreen(),
          MyRoutes.addSubscriptionScreen:(context)=>AddSubscriptionScreen(),
          MyRoutes.detailsScreen:(context)=>DetailSubscriptionScreen(),
          MyRoutes.changePasswordScreen:(context)=>ChangePasswordScreen(),
        },
      )
  );
}
