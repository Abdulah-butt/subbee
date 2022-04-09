import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppColors{
 static  Color appBgColor= const Color(0xffffffff);
 static Color appGreyBgColor=const Color(0xfff1f4f8);
 //static Color blueTextColor=const Color(0xFF2196F3);
 static Color blueTextColor=const Color(0xfff14739);
 static Color blackTextColor=const Color(0xFF000000);
 static Color btnColor=const Color(0xff36c688);
 static Color yellowColor=Color(0xfffed420);
 static Color bottomNavColor=const Color(0xff36c688);
 static Color btnTextColor=const Color(0xffffffff);
 static Color appBarColor=const Color(0xff36c688);
 static Color iconColor=const Color(0xfff14739);
 static Color circularIndicatorColor=const Color(0xfff14739);
 static Color lightGreyColor=const Color(0xff707070);
 static Color borderColor=const Color(0xff000000).withOpacity(0.2);
 static Color sliderBgColor=const Color(0xff36c688);

 static MaterialStateProperty<Color?>? customBtnColor=MaterialStateProperty.all<Color>(Color(0xff36c688));
 static MaterialStateProperty<Color?>? whiteBtnColor=MaterialStateProperty.all<Color>(Color(0xffffffff));
 static MaterialStateProperty<Color?>? yellowBtnColor=MaterialStateProperty.all<Color>(Color(0xfffed420));


}