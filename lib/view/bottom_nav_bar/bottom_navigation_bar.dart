
import 'package:code/constant/my_constant.dart';
import 'package:code/constant/screen_size.dart';
import 'package:code/util/app_color.dart';
import 'package:code/view/bottom_nav_bar/home_screen.dart';
import 'package:code/view/bottom_nav_bar/home_screen.dart';
import 'package:code/view/bottom_nav_bar/profile_screen.dart';
import 'package:code/view/bottom_nav_bar/spending_screen.dart';
import 'package:code/view/model_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({Key? key}) : super(key: key);

  @override
  _BottomNavigationScreenState createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen>
    with SingleTickerProviderStateMixin {


  var pages=[
    HomeScreen(),
    HomeScreen(),
    ProfileScreen()
  ];



  @override
  Widget build(BuildContext context) {
    ScreenSize.height = MediaQuery.of(context).size.height;
    ScreenSize.width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: AppColors.appBgColor,
          body: Center(
            child: pages[MyConstant.currentScreenIndex],
          ),
          bottomNavigationBar: Stack(
            children: [
              SalomonBottomBar(
                duration:Duration(seconds: 1),
                currentIndex: MyConstant.currentScreenIndex,
                onTap: (i){
                  if(i==1){
                    showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        builder: (context) {
                          return ModelSheet();
                        });
                  }else {
                    setState(() {
                      MyConstant.currentScreenIndex = i;
                    });
                  }
                },
                items: [
                  /// Home
                  customBottomNavigationItem("Home",Icon(Icons.home)),


                  /// add subscriptions
                  customBottomNavigationItem("Profile",CircleAvatar(backgroundColor:AppColors.appBgColor,child:Icon(Icons.add,color: AppColors.appBgColor,),)),

                  /// Profile
                  customBottomNavigationItem("Profile",Icon(Icons.person))
                ],
              ),

              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                top: 0,
                child: Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: (){
                        showModalBottomSheet(
                            isScrollControlled: true,
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            builder: (context) {
                              return ModelSheet();
                            });
                      },
                        child: CircleAvatar(backgroundColor: AppColors.btnColor,child:Icon(Icons.add,color: AppColors.appBgColor,),))),
              )
            ],
          ),
        ),
        )
    );
  }

  customBottomNavigationItem(String label, Widget icon) {
    return   SalomonBottomBarItem(
      icon: icon,
      title:Text(label),
      selectedColor: AppColors.btnColor
    );
  }
}
