import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code/constant/my_constant.dart';
import 'package:code/constant/screen_size.dart';
import 'package:code/model/subscription_model.dart';
import 'package:code/model/user_model.dart';
import 'package:code/util/app_color.dart';
import 'package:code/util/routes.dart';
import 'package:code/util/services/notification_api.dart';
import 'package:code/util/style.dart';
import 'package:code/view/model_sheet.dart';
import 'package:code/widgets/custom_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NewHomeScreen extends StatefulWidget {
  const NewHomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<NewHomeScreen> {

  UserModel _userModel = MyConstant.currentUserModel!;
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {

    ScreenSize.width = MediaQuery.of(context).size.width;
    ScreenSize.height = MediaQuery.of(context).size.height;
    return SafeArea(
        child: Scaffold(
      backgroundColor: AppColors.appBgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.appBgColor,
        leading: IconButton(
            onPressed: () {
              Navigator.pushNamed(context, MyRoutes.settingScreen).whenComplete((){
                setState(() {

                });
              });
            },
            icon: Icon(Icons.settings)),
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(color: Colors.black),
        actions: [
          IconButton(
              onPressed: () {
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
              icon: Icon(Icons.add))
        ],
        title: InkWell(
          onTap: () {
            filterScreen();
          },
          child: SizedBox(
            width: ScreenSize.width! * 0.8,
            height: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                filterValue == "All"
                    ? Text(
                        "All Subscriptions",
                        style: headingStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      )
                    : Text(
                        "$filterValue",
                        style: headingStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                SizedBox(
                  width: ScreenSize.width! * 0.1,
                ),
                Icon(Icons.keyboard_arrow_down_outlined)
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(ScreenSize.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: ScreenSize.width,
              height: ScreenSize.height! * 0.12,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.btnColor),
              constraints: BoxConstraints(
                minHeight: ScreenSize.height! * 0.1,
              ),
              child: StreamBuilder<QuerySnapshot>(
                  key: UniqueKey(),
                  stream: SubscriptionModel.getRecentSubscriptions(filterValue: filterValue),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: loadingIndicator());
                    }
                    if (snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          "No record yet",
                          style: TextStyle(color: AppColors.appBgColor),
                        ),
                      );
                    }

                    var allDocs = snapshot.data!.docs;
                    double totalWeekly = 0;
                    int countWeekly = 0;

                    double totalMonthly = 0;
                    int countMonthly = 0;

                    double totalYearly = 0;
                    int countYearly = 0;

                    for (var doc in allDocs) {
                      SubscriptionModel subModel =
                          SubscriptionModel.fromJson(doc);
                      if (subModel.cycle == "Monthly") {
                        totalMonthly = totalMonthly + subModel.price!;
                        countMonthly++;
                      } else if (subModel.cycle == "Weekly") {
                        totalWeekly = totalWeekly + subModel.price!;
                        countWeekly++;
                      } else if (subModel.cycle == "Yearly") {
                        totalYearly = totalYearly + subModel.price!;
                        countYearly++;
                      } else {
                        print("Incorrect package");
                      }
                    }

                    double avgWeekly = countWeekly==0?0:totalWeekly / countWeekly;
                    double avgMonthly = countMonthly==0?0:totalMonthly / countMonthly;
                    double avgYearly =countYearly==0?0:totalYearly / countYearly;

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Expected Expenditure",
                            style: headingStyle(
                                fontWeight: FontWeight.bold, fontSize: 22),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              expectedExpenditure(
                                  "Per Week", "${avgWeekly.toStringAsFixed(2)}"),
                              expectedExpenditure(
                                  "Per Month", "${avgMonthly.toStringAsFixed(2)}"),
                              expectedExpenditure(
                                  "Per Year", "${avgYearly.toStringAsFixed(2)}"),
                            ],
                          )
                        ],
                      ),
                    );
                  }),
            ),

            SizedBox(
              height: isExpanded
                  ? ScreenSize.height! * 0.05
                  : ScreenSize.height! * 0.02,
            ),
            Text(
              "Subscriptions",
              style: headingStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            SizedBox(
              height: ScreenSize.height! * 0.03,
            ),

            // list of all subscriptions

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  key: UniqueKey(),
                  stream: SubscriptionModel.getRecentSubscriptions(
                      filterValue: filterValue),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: loadingIndicator());
                    }
                    if (snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text("No subscription yet"),
                      );
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.size,
                      itemBuilder: (context, index) {
                        SubscriptionModel subModel = SubscriptionModel.fromJson(
                            snapshot.data!.docs[index]);

                        return InkWell(
                            onTap: () {
                              MyConstant.clickedSubModel = subModel;
                              Navigator.pushNamed(
                                  context, MyRoutes.detailsScreen);
                            },
                            child: subscriptionTile(
                                imgUrl: subModel.imgUrl,
                                title: subModel.title,
                                description: subModel.description,
                                price: subModel.price,
                                cycle: subModel.cycle));
                      },
                    );
                  }),
            ),
          ],
        ),
      ),
    ));
  }

  Widget textAndNumber(String text, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: headingStyle(fontSize: 16, color: AppColors.appBgColor),
        ),
        Text(value,
            style: headingStyle(fontSize: 16, color: AppColors.appBgColor))
      ],
    );
  }

  Widget expectedExpenditure(String package, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "$package",
          style: headingStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.appBgColor),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          "${MyConstant.currency} $value",
          style: headingStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ],
    );
  }

  Widget recentSubscriptions(_url) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CachedNetworkImage(
        imageUrl: _url,
        height: ScreenSize.height! * 0.04,
        imageBuilder: (context, imageProvider) => Container(
          width: ScreenSize.width! * 0.2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.black.withOpacity(0.2)),
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        placeholder: (context, url) =>
            const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) =>
            const Center(child: Icon(Icons.error)),
      ),
    );
  }

  final AndroidNotificationDetails androidPlatformChannelSpecifics =
      const AndroidNotificationDetails(
          'channel id', //Required for Android 8.0 or after
          'channel name', //Required for Android 8.0 or after
          channelDescription: 'channel discription',
          //Required for Android 8.0 or after
          importance: Importance.max,
          priority: Priority.max);
  NotificationDetails? platformChannelSpecifics;
  final _notification = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
  }

  String filterValue = 'All';

  filterScreen() {
    return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (builder) {
          return Container(
            height: 350.0,
            color: Colors.transparent, //could change this to Color(0xFF737373),
            //so you don't have to change MaterialApp canvasColor
            child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20.0),
                        topRight: const Radius.circular(20.0))),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      customLine(),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left:18),
                        child: Text(
                          "Select Category",
                          style: headingStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                          width: ScreenSize.width,
                          child: Divider(
                            thickness: 1,
                          )),

                      Expanded(
                        child: ListTile(

                          title: Text('All Subscriptions'),
                          onTap: () {
                            setState(() {
                              filterValue = 'All';
                              Navigator.pop(context);
                            });
                          },
                          trailing: filterValue == "All"
                              ? Icon(
                                  Icons.check,
                                  color: Colors.green,
                                )
                              : SizedBox(),
                        ),
                      ),
                      SizedBox(
                          width: ScreenSize.width,
                          child: Divider(
                            thickness: 1,
                          )),
                      Expanded(
                        child: ListTile(
                          title: Text('Entertainment'),
                          trailing: filterValue == "Entertainment"
                              ? Icon(
                                  Icons.check,
                                  color: Colors.green,
                                )
                              : SizedBox(),
                          onTap: () {
                            setState(() {
                              filterValue = 'Entertainment';
                              Navigator.pop(context);
                            });
                          },
                        ),
                      ),
                      SizedBox(
                          width: ScreenSize.width,
                          child: Divider(
                            thickness: 1,
                          )),
                      Expanded(
                        child: ListTile(
                          title: Text('Work'),
                          trailing: filterValue == "Work"
                              ? Icon(
                                  Icons.check,
                                  color: Colors.green,
                                )
                              : SizedBox(),
                          onTap: () {
                            setState(() {
                              filterValue = 'Work';
                              Navigator.pop(context);
                            });
                          },
                        ),
                      ),
                      SizedBox(
                          width: ScreenSize.width,
                          child: Divider(
                            thickness: 1,
                          )),
                    ],
                  ),
                )),
          );
        });
  }
}
