import 'package:code/util/app_color.dart';
import 'package:flutter/material.dart';

BoxDecoration textFieldDecoration(){
  return BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.black.withOpacity(0.2))
    //shape: BoxShape.circle,
  );
}
TextStyle btnTextStyle({Color? color}){
  return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: color??AppColors.btnTextColor
  );
}

TextStyle headingStyle({double fontSize=20,Color color=Colors.black,FontWeight fontWeight=FontWeight.normal}){
  return  TextStyle(
      fontWeight: fontWeight,
      fontSize: fontSize,
      color: color
   
  );
}

TextStyle hintStyle(){
  return  TextStyle(
      fontSize: 14,
  );
}

TextStyle subHeadingStyle(){
  return  TextStyle(
      fontSize: 14,
    fontWeight: FontWeight.bold
  );
}


TextStyle greyTextStyle(){
  return  TextStyle(
    fontSize: 14,
    color: AppColors.lightGreyColor
  );
}


TextStyle simpleItalic(){
  return  TextStyle(
      fontSize: 14,
      color: AppColors.lightGreyColor.withOpacity(0.8),
      fontStyle: FontStyle.italic
  );
}


TextStyle bottomSheetStyle(){
  return  TextStyle(
      fontSize: 18,
      color:Colors.blue,
      decoration: TextDecoration.underline,
  );
}

TextStyle appbarSubtitleStyle(){
  return  TextStyle(
      fontSize: 14,
      color: Colors.white
  );
}


TextStyle forgetPasswordAppbarStyle(){
  return  TextStyle(
      fontSize: 20,
      color: Colors.black,
      fontWeight: FontWeight.w600
  );
}

TextStyle appbarTitleStyle(){
  return  TextStyle(
      fontSize: 20,
      color: AppColors.appBgColor,
    fontWeight: FontWeight.w600
  );
}