import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code/constant/my_constant.dart';
import 'package:code/constant/screen_size.dart';
import 'package:code/model/subscription_model.dart';
import 'package:code/util/alerts.dart';
import 'package:code/util/app_color.dart';
import 'package:code/util/my_functions.dart';
import 'package:code/util/services/date_time_formetting.dart';
import 'package:code/util/services/notification_api.dart';
import 'package:code/util/style.dart';
import 'package:code/widgets/custom_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddSubscriptionScreen extends StatefulWidget {
  String? imgAssetPath;
  String? title;
   AddSubscriptionScreen({Key? key,this.imgAssetPath,this.title}) : super(key: key);

  @override
  _AddSubscriptionScreenState createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {

  // Initial Selected Value
  String currencyValue = 'USD';

  // List of items in our dropdown menu
  var currencyList = [
    'USD',
    'PKR',
    'EUR',
  ];

  // Initial Selected Value
  String categoryValue = 'Entertainment';

  // List of items in our dropdown menu
  var categoryList = [
    'Entertainment',
    'Work',
    'Service'
  ];

  // Initial Selected Value
  String cycleValue = 'Weekly';

  // List of items in our dropdown menu
  var cycleList = [
    'Weekly',
    'Monthly',
    'Yearly'
  ];


  // Initial Selected Value
  String reminderValue = '1';

  // List of items in our dropdown menu
  var reminderList = [
    '1',
    '2',
    '3',
    '4',
    '5'
  ];

  DateTime? startDate,endDate;

  final txtTitle=TextEditingController();
  final txtPrice=TextEditingController();
  final txtUrl=TextEditingController();

  String? title,url;
  int? price;

 void getValues(){
   try {
     title = txtTitle.text;
     price = int.parse(txtPrice.text);
     url = txtUrl.text;
   }catch(e){
     MyAlert.showToast("Please enter price");
   }
 }
 bool isEmpty(){
   if(title!.isEmpty||price.toString().isEmpty||url!.isEmpty){
     return true;
   }else{
     return false;
   }
 }

 Future<void> saveAction() async {
   getValues();
   if(isEmpty()){
     MyAlert.showToast("Please fill fields");
   }else{
     int limit=MyConstant.thisMonthRemainingLimit!;
     if(limit>=price!) {
       // show loading indicator
       customloadingIndicator(context);
       File imgFile = await MyFunctions.getImageFileFromAssets(
           widget.imgAssetPath!);
       String? imgUrl = await SubscriptionModel.uploadImagesToFirestore(
           imgFile);
       print("img url is $imgUrl");
       if (imgUrl != '') {
         SubscriptionModel subscriptionModel = SubscriptionModel(
           title: title,
           price: price,
           imgUrl: imgUrl,
           currency: currencyValue,
           category: categoryValue,
           startDate: Timestamp.fromDate(startDate!),
           endDate: Timestamp.fromDate(endDate!),
           cycle: cycleValue,
           reminder: int.parse(reminderValue),
           url: url,
         );
         bool result = await subscriptionModel.addSubscription();
         Navigator.pop(context);

         if (result) {
           var finalEndDate = endDate!.add(Duration(minutes: 1));
           print("schedule notification at ${finalEndDate.subtract(
               Duration(days: int.parse(reminderValue)))}");
           scheduleNotification(finalEndDate.subtract(Duration(days: int.parse(reminderValue))));

           MyAlert.showToast("Subscription added successfully");
           MyConstant.thisMonthRemainingLimit=MyConstant.thisMonthRemainingLimit!-price!;
           Navigator.pop(context);
           Navigator.pop(context);
         }
       } else {
         Navigator.pop(context);
       }
     }else{
       MyAlert.showToast("Your this month limit reached");
     }
   }
 }

  @override
  Widget build(BuildContext context) {
   print('Image path is ${widget.imgAssetPath!}');
   txtTitle.text=widget.title!;
    return SafeArea(
        child: Scaffold(
      backgroundColor: AppColors.appBgColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal:ScreenSize.screenPadding),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Add Subscription",
                    style:
                        headingStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.clear))
                ],
              ),
              Container(
                height: 120,
                width: ScreenSize.width,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          image: DecorationImage(
                              image: AssetImage(widget.imgAssetPath!)
                          )
                      ),
                    ),
                    SizedBox(width: 20,),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                            width:ScreenSize.width!*0.5,
                            child: secondaryTextField(hint: "Title",controller: txtTitle)),
                        SizedBox(
                            width:ScreenSize.width!*0.5,
                            child: secondaryTextField(hint: "Price",keyboard: TextInputType.number,controller: txtPrice)),
                      ],
                    )
                  ],
                ),
              ),

              SizedBox(height: ScreenSize.height!*0.03,),


              // currency row
              Row(
                children: [
                  Text("Currency",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                  SizedBox(width: ScreenSize.width!*0.13,),
                  SizedBox(
                    width: ScreenSize.width!*0.3,
                    child: DropdownButton(
                      value: currencyValue,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down),

                      // Array list of items
                      items: currencyList.map((String items) {
                        return DropdownMenuItem(
                          value: items,
                          child: Text(items,style: TextStyle(fontWeight: FontWeight.bold),),
                        );
                      }).toList(),
                      // After selecting the desired option,it will
                      // change button value to selected value
                      onChanged: (String? newValue) {
                        setState(() {
                          currencyValue = newValue!;
                        });
                      },
                    ),
                  ),
                ],
              ),



              // category
              Row(
                children: [
                  Text("Category",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                  SizedBox(width: ScreenSize.width!*0.13,),
                  SizedBox(
                    width: ScreenSize.width!*0.3,
                    child: DropdownButton(
                      value: categoryValue,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down),

                      // Array list of items
                      items: categoryList.map((String items) {
                        return DropdownMenuItem(
                          value: items,
                          child: Text(items,style: TextStyle(fontWeight: FontWeight.bold),),
                        );
                      }).toList(),
                      // After selecting the desired option,it will
                      // change button value to selected value
                      onChanged: (String? newValue) {
                        setState(() {
                          categoryValue = newValue!;
                        });
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: ScreenSize.height!*0.03,),


              // date

              dateWidget("Starts",startDate==null?'Not selected':formatDate(startDate!),() async {
                DateTime currentDate=DateTime.now();
                final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: currentDate,
                    firstDate: DateTime(2015, 8),
                    lastDate: DateTime(2101));
                if (picked != null && picked != currentDate) {
                  setState(() {
                    startDate = picked;
                  });
                }
              }),

              SizedBox(height: 10,),
              dateWidget("Expires",endDate==null?'Not selected':formatDate(endDate!),() async {
                DateTime currentDate=DateTime.now();
                final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: currentDate,
                    firstDate: DateTime(2015, 8),
                    lastDate: DateTime(2101));
                if (picked != null && picked != currentDate) {
                  setState(() {
                    endDate = picked;
                  });
                }
              }),

              SizedBox(height: ScreenSize.height!*0.03,),

              // cycle
              Row(
                children: [
                  Text("Cycle",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                  SizedBox(width: ScreenSize.width!*0.2,),
                  SizedBox(
                    width: ScreenSize.width!*0.3,
                    child: DropdownButton(
                      value: cycleValue,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down),

                      // Array list of items
                      items: cycleList.map((String items) {
                        return DropdownMenuItem(
                          value: items,
                          child: Text(items,style: TextStyle(fontWeight: FontWeight.bold),),
                        );
                      }).toList(),
                      // After selecting the desired option,it will
                      // change button value to selected value
                      onChanged: (String? newValue) {
                        setState(() {
                          cycleValue = newValue!;
                        });
                      },
                    ),
                  ),
                ],
              ),



              // reminder

              Row(
                children: [
                  Text("Reminder",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                  SizedBox(width: ScreenSize.width!*0.12,),
                  SizedBox(
                    width: ScreenSize.width!*0.3,
                    child: DropdownButton(
                      value: reminderValue,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down),

                      // Array list of items
                      items: reminderList.map((String items) {
                        return DropdownMenuItem(
                          value: items,
                          child: Text(items,style: TextStyle(fontWeight: FontWeight.bold),),
                        );
                      }).toList(),
                      // After selecting the desired option,it will
                      // change button value to selected value
                      onChanged: (String? newValue) {
                        setState(() {
                          reminderValue = newValue!;
                        });
                      },
                    ),
                  ),
                ],
              ),



              Row(
                children: [
                  Text("URL :",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                  SizedBox(width: ScreenSize.width!*0.2,),
                  Expanded(
                    child:secondaryTextField(hint: "Enter URL here ....",controller: txtUrl)
                  ),
                ],
              ),

              SizedBox(height: 20,),
              customButton("Save",(){
              //  NotificationAPI.showNotification(title: txtTitle.text,body: 'Your subscription for ${txtTitle.text} is ending soon.',payload: 'image.jpg');

                saveAction();
              },icon: Icon(Icons.save))



            ],
          ),
        ),
      ),
    ));
  }

  Widget dateWidget(String title,String value,Function function){
    return GestureDetector(
      onTap: (){
        function();
      },
      child: Container(
        width: ScreenSize.width,
        height: 70,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.black)),
        child: Row(
          children: [
            Icon(Icons.calendar_today),
            SizedBox(width: 30,),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,style: TextStyle(fontWeight: FontWeight.bold),),
                  Text(value,style: TextStyle(fontWeight: FontWeight.bold),),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }


  void scheduleNotification(DateTime dateTime){
    NotificationAPI.showScheduleNotification(title: txtTitle.text.toUpperCase(),body: 'Your subscription for ${txtTitle.text.toUpperCase()} is ending soon.',payload: 'image.jpg',dateTime:dateTime);

  }

}
