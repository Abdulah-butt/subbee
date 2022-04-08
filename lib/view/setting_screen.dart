import 'package:code/constant/screen_size.dart';
import 'package:code/util/app_color.dart';
import 'package:code/util/style.dart';
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
        centerTitle: true,
        title: Text("Settings",style: headingStyle(fontSize: 22,fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding:  EdgeInsets.all(ScreenSize.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("General",style: greyTextStyle(),),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              Text("Security",style: headingStyle(fontSize: 14,fontWeight: FontWeight.bold),),
                Icon(Icons.navigate_next)
              ],
            ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Drive Sync",style: headingStyle(fontSize: 14,fontWeight: FontWeight.bold)),
                  Switch(
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
                ],
              ),

            SizedBox(height: 20,),

            Text("My Subscriptions",style: greyTextStyle(),),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Currency",style: headingStyle(fontSize: 14,fontWeight: FontWeight.bold),),
                SizedBox(
                  width: ScreenSize.width!*0.3,
                  child: DropdownButton(
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
                    // After selecting the desired option,it will
                    // change button value to selected value
                    onChanged: (String? newValue) {
                      setState(() {
                        currentCurrency = newValue!;
                      });
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: 20,),
            Text("Info",style: greyTextStyle(),),

            SizedBox(height: 20,),

            Text("About",style: headingStyle(fontSize: 14,fontWeight: FontWeight.bold),),
            SizedBox(height: 10,),
            Text("Submit More Subscriptions",style: headingStyle(fontSize: 14,fontWeight: FontWeight.bold),)


          ],
        ),
      ),
    ));
  }
}
