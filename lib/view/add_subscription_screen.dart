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

  AddSubscriptionScreen({Key? key, this.imgAssetPath, this.title})
      : super(key: key);

  @override
  _AddSubscriptionScreenState createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {
  // Initial Selected Value
  String categoryValue = 'Entertainment';

  // List of items in our dropdown menu
  var categoryList = ['Entertainment', 'Work'];

  // Initial Selected Value
  String cycleValue = 'Weekly';

  // List of items in our dropdown menu
  var cycleList = ['Weekly', 'Monthly', 'Yearly'];

  // Initial Selected Value
  String reminderValue = 'Never';

  // List of items in our dropdown menu
  var reminderList = [
    'Never',
    'Same day',
    '1 day prior',
    '2 day prior',
    '3 day prior'
  ];

  DateTime? endDate;

  final txtTitle = TextEditingController();
  final txtPrice = TextEditingController();
  final txtDescription = TextEditingController();

  String? title, description;
  int? price;

  void getValues() {
    try {
      title = txtTitle.text;
      price = int.parse(txtPrice.text);
      description = txtDescription.text;
    } catch (e) {
      MyAlert.showToast("Please enter price");
    }
  }

  bool isEmpty() {
    if (title!.isEmpty ||
        price.toString().isEmpty ||
        endDate == null) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> saveAction() async {
    getValues();
    if (isEmpty()) {
      MyAlert.showToast("Please fill fields");
    } else {
      // show loading indicator
      customloadingIndicator(context);
      File imgFile =
          await MyFunctions.getImageFileFromAssets(widget.imgAssetPath!);
      String? imgUrl = await SubscriptionModel.uploadImagesToFirestore(imgFile);
      print("img url is $imgUrl");
      if (imgUrl != '') {
        SubscriptionModel subscriptionModel = SubscriptionModel(
          title: title,
          price: price,
          imgUrl: imgUrl,
          category: categoryValue,
          endDate: Timestamp.fromDate(endDate!),
          cycle: cycleValue,
          reminder: reminderValue,
          description: description,
        );
        bool result = await subscriptionModel.addSubscription();
        Navigator.pop(context);

        if (result) {
          // if(reminderValue!="Never"){
          //
          //   int days=getReminderDay();
          //   var finalDate=endDate!.add(Duration(hours: 1,minutes: 1,seconds: 1));
          //   print("schedule notification at ${finalDate.subtract(Duration(days: days))}");
          //   scheduleNotification(finalDate.subtract(Duration(days:days)));
          // }
          MyAlert.showToast("Subscription added successfully");
          Navigator.pop(context);
          Navigator.pop(context);
        }
      } else {
        Navigator.pop(context);
      }
    }
  }

  int getReminderDay() {
    if (reminderValue == "Same day") {
      return 0;
    } else if (reminderValue == "1 day prior") {
      return 1;
    } else if (reminderValue == "2 day prior") {
      return 2;
    } else {
      return 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Image path is ${widget.imgAssetPath!}');
    txtTitle.text = widget.title!;
    return SafeArea(
        child: Scaffold(
      backgroundColor: AppColors.appBgColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: ScreenSize.screenPadding),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back_ios)),
                  Text(
                    "Add Subscription",
                    style:
                        headingStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  IconButton(
                      onPressed: () {
                        saveAction();
                      },
                      icon: Icon(
                        Icons.save,
                        color: Colors.green,
                      ))
                ],
              ),
              SizedBox(
                height: 20,
              ),

              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    image: DecorationImage(
                        image: AssetImage(widget.imgAssetPath!))),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "${txtTitle.text}",
                style: headingStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: 50,
                width: ScreenSize.width! * 0.4,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(3),
                      child: Text(
                        "USD",
                        style: headingStyle(fontWeight: FontWeight.bold),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                        child: secondaryTextField(
                            keyboard: TextInputType.number,
                            controller: txtPrice,
                            hint: "0,00"))
                  ],
                ),
              ),

              SizedBox(
                height: ScreenSize.height! * 0.03,
              ),

              Align(
                  alignment: Alignment.centerLeft,
                  child: secondaryTextField(
                      keyboard: TextInputType.text,
                      controller: txtDescription,
                      hint: "Description")),

              // category
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Category",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  customDropDown(categoryValue, () {
                    showCategoryPicker();
                  })
                ],
              ),

              SizedBox(
                height: ScreenSize.height! * 0.03,
              ),

              // date

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Billing End Date",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(
                    width: 150,
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                            context: context,
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            builder: (context) {
                              return buildDatePicker();
                            });
                      },
                      child: endDate == null
                          ? Text("Not Selected",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18))
                          : Text(
                              formatDate(endDate!),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                    ),
                  ),
                ],
              ),

              SizedBox(
                height: ScreenSize.height! * 0.03,
              ),

              // cycle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Billing Cycle",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  customDropDown(cycleValue, () {
                    showCyclePicker();
                  })
                ],
              ),

              SizedBox(
                height: ScreenSize.height! * 0.03,
              ),

              // reminder

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Remind Me",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  customDropDown(reminderValue, () {
                    showReminderPicker();
                  })
                ],
              ),
            ],
          ),
        ),
      ),
    ));
  }

  customDropDown(String currentValue, Function function) {
    return GestureDetector(
      onTap: () {
        function();
      },
      child: SizedBox(
        width: 150,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              currentValue,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Icon(Icons.keyboard_arrow_down)
          ],
        ),
      ),
    );
  }

  // void scheduleNotification(DateTime dateTime){
  //   NotificationAPI.showScheduleNotification(title: txtTitle.text.toUpperCase(),body: 'Your subscription for ${txtTitle.text.toUpperCase()} is ending soon.',payload: 'image.jpg',dateTime:dateTime);
  //   //NotificationAPI.showScheduleNotification(title: txtTitle.text.toUpperCase(),body: 'Your subscription for ${txtTitle.text.toUpperCase()} is ending soon.',payload: 'image.jpg',dateTime:DateTime.now().add(Duration(seconds: 10)));
  //
  // }
  DateTime currentDateTime = DateTime.now();

  Widget buildDatePicker() => SizedBox(
        height: 250,
        child: Column(
          children: [
            headingRow(title: "Next Billing Date"),
            SizedBox(
              height: 180,
              child: CupertinoDatePicker(
                backgroundColor: Colors.grey.withOpacity(0.2),
                initialDateTime: currentDateTime,
                mode: CupertinoDatePickerMode.date,
                onDateTimeChanged: (dateTime) =>
                    setState(() => this.endDate = dateTime),
              ),
            ),
          ],
        ),
      );

  headingRow({title}) {
    return Container(
      color: Colors.grey.withOpacity(0.3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.blue,
              )),
          Text(
            "$title",
            style: bottomSheetStyle(),
          ),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Done",
                style: bottomSheetStyle(),
              )),
        ],
      ),
    );
  }

  FixedExtentScrollController _controller = FixedExtentScrollController();

  showCategoryPicker() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SizedBox(
            height: 250,
            child: Column(
              children: [
                headingRow(title: "Category"),
                Expanded(
                  child: CupertinoPicker(
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    scrollController: _controller,
                    onSelectedItemChanged: (value) {
                      setState(() {
                        categoryValue = categoryList[value];
                        categoryIndex = value;
                      });
                    },
                    itemExtent: 60.0,
                    children: const [
                      Center(child: Text('Entertainment')),
                      Center(child: Text('Work')),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  int categoryIndex = 0;

  showCyclePicker() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SizedBox(
            height: 250,
            child: Column(
              children: [
                headingRow(title: "Billing Cycle"),
                Expanded(
                  child: CupertinoPicker(
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    onSelectedItemChanged: (value) {
                      setState(() {
                        cycleValue = cycleList[value];
                      });
                    },
                    itemExtent: 60.0,
                    children: const [
                      Center(child: Text('Weekly')),
                      Center(child: Text('Monthly')),
                      Center(child: Text("Yearly")),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  showReminderPicker() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SizedBox(
            height: 250,
            child: Column(
              children: [
                headingRow(title: "Remind Me"),
                Expanded(
                  child: CupertinoPicker(
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    onSelectedItemChanged: (value) {
                      setState(() {
                        reminderValue = reminderList[value];
                      });
                    },
                    itemExtent: 32.0,
                    children: const [
                      Center(child: Text('Never')),
                      Center(child: Text('Same day')),
                      Center(child: Text("1 day prior")),
                      Center(child: Text("2 day prior")),
                      Center(child: Text("3 day prior")),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
}
