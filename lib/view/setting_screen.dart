import 'package:code/constant/my_constant.dart';
import 'package:code/constant/screen_size.dart';
import 'package:code/model/subscription_model.dart';
import 'package:code/util/app_color.dart';
import 'package:code/util/style.dart';
import 'package:code/widgets/custom_widgets.dart';
import 'package:flutter/material.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool isSwitched=false;
  String currentCurrency="USD";
  List<String> currencyList=["USD","NOK","UK","CDN"];

  bool loadingCurrency=true;

  @override
  void initState() {
    SubscriptionModel.getCurrency().whenComplete((){
      setState(() {
        loadingCurrency=false;
        currentCurrency=MyConstant.currency!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      backgroundColor: AppColors.appBgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.appBgColor,
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.keyboard_arrow_down_outlined)),
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle:TextStyle(color: Colors.black),
        title: Text("Settings",style: headingStyle(fontSize: 22,fontWeight: FontWeight.bold)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20,),
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: ScreenSize.screenPadding),
            child: Text("General",style: greyTextStyle(),),
          ),
          customHorizontalLine(),
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: ScreenSize.screenPadding,vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              Text("Security",style: headingStyle(fontSize: 14,fontWeight: FontWeight.bold),),
                Icon(Icons.navigate_next)
              ],
            ),
          ),
          customHorizontalLine(),
              Padding(
                padding:  EdgeInsets.symmetric(horizontal: ScreenSize.screenPadding,vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Drive Sync",style: headingStyle(fontSize: 14,fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 0,
                    child: Switch(
                      value: isSwitched,
                      onChanged: (value) {
                        setState(() {
                          isSwitched = value;
                          print(isSwitched);
                        });
                      },
                      activeTrackColor: Colors.lightGreenAccent,
                      activeColor: Colors.green,
                    ),
                  ),
                ],
            ),
              ),
          customHorizontalLine(),

          SizedBox(height: 30,),
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: ScreenSize.screenPadding),
            child: Text("My Subscriptions",style: greyTextStyle(),),
          ),
          customHorizontalLine(),
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: ScreenSize.screenPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Default Currency",style: headingStyle(fontSize: 14,fontWeight: FontWeight.bold),),
                SizedBox(
                  width: ScreenSize.width!*0.3,
                  height: 30,
                  child:loadingCurrency?Text(''):DropdownButton(
                    value: currentCurrency,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    underline: SizedBox(),
                    // Array list of items
                    items: currencyList.map((String items) {
                      return DropdownMenuItem(
                        value: items,
                        child: Text(items,style: headingStyle(fontSize: 14,fontWeight: FontWeight.bold),),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      SubscriptionModel.changeCurrency(newValue!);
                      setState(() {
                        currentCurrency = newValue;

                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          customHorizontalLine(),


          SizedBox(height: 30,),
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: ScreenSize.screenPadding),
            child: Text("Info",style: greyTextStyle(),),
          ),
          customHorizontalLine(),

          Padding(
            padding:  EdgeInsets.symmetric(horizontal: ScreenSize.screenPadding,vertical: 7),
            child: Text("About",style: headingStyle(fontSize: 14,fontWeight: FontWeight.bold),),
          ),
          customHorizontalLine(),
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: ScreenSize.screenPadding,vertical: 7),
            child: Text("Submit More Subscriptions",style: headingStyle(fontSize: 14,fontWeight: FontWeight.bold),),
          ),
          customHorizontalLine(),


        ],
      ),
    ));
  }
}
