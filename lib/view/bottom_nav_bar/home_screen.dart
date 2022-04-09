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

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel _userModel = MyConstant.currentUserModel!;
  bool isExpanded = false;



  @override
  Widget build(BuildContext context) {
    SubscriptionModel.getYearlyAvrgs();

    ScreenSize.width = MediaQuery.of(context).size.width;
    ScreenSize.height = MediaQuery.of(context).size.height;
    return SafeArea(
        child: Scaffold(
      backgroundColor: AppColors.appGreyBgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.appGreyBgColor,
        leading: IconButton(
            onPressed: () {
              Navigator.pushNamed(context, MyRoutes.settingScreen)
                  .whenComplete(() {
                setState(() {});
              });
            },
            icon: Icon(Icons.settings)),
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(color: Colors.black),

        title: InkWell(
          onTap: () {
            showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                ),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                builder: (context) {
                  return filterScreen();
                });
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
              height: 100,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.btnColor),

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
                        child: Text(
                          "No record yet",
                          style: TextStyle(color: AppColors.appBgColor),
                        ),
                      );
                    }

                    var allDocs = snapshot.data!.docs;
                    double totalWeekly = 0;

                    double totalMonthly = 0;

                    double totalYearly = 0;

                    for (var doc in allDocs) {
                      SubscriptionModel subModel =
                          SubscriptionModel.fromJson(doc);
                      if (subModel.cycle == "Monthly") {
                        totalMonthly = totalMonthly + subModel.price!;

                      } else if (subModel.cycle == "Weekly") {
                        totalWeekly = totalWeekly + subModel.price!;

                      } else if (subModel.cycle == "Yearly") {
                        totalYearly = totalYearly + subModel.price!;
                      } else {
                        print("Incorrect package");
                      }
                    }

                    double newWeekly =totalWeekly+(totalMonthly/4)+(totalYearly/48);
                    double newMonthly =newWeekly*4;
                    double newYearly =newWeekly*48;

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
                              expectedExpenditure("Per Week",
                                  "${newWeekly.toStringAsFixed(2)}"),
                              expectedExpenditure("Per Month",
                                  "${newMonthly.toStringAsFixed(2)}"),
                              expectedExpenditure("Per Year",
                                  "${newYearly.toStringAsFixed(2)}"),
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

  String filterValue = 'All Subscriptions';

  List<String> allFilters=["All Subscriptions","Entertainment","Work"];

  filterScreen() {
    return Container(
        height: ScreenSize.height! * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
        ),
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
                padding:
                    EdgeInsets.symmetric(horizontal:10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Select Category",
                      style: headingStyle(
                          fontWeight: FontWeight.bold, fontSize: 22),
                    ),
                    IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.add,
                          size: 30,
                        ))
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                      Text('Categories',style: headingStyle(color: Colors.grey,fontSize: 16,fontWeight: FontWeight.bold),),
                      Text('Average per year',style: headingStyle(color: Colors.grey,fontSize: 16,fontWeight: FontWeight.bold),),

                    ],),
                    customHorizontalLine(),
                  ],
                ),
              ),
              for(var indexValue in allFilters)
              filterRow(title: "$indexValue",avgValue: getValue(indexValue),onClick: (){
                setState(() {
                  filterValue = indexValue;
                  Navigator.pop(context);
                });
              },isSelected:filterValue==indexValue),


            ],
          ),
        ));
  }

  getValue(value){
    if(value=="Entertainment"){
      return MyConstant.entertainmentAvg.toString();
    }

    else if(value=="Work"){
      return MyConstant.workAvg.toString();
    }

    else{
      double total=MyConstant.entertainmentAvg!+MyConstant.workAvg!;
      return total.toString();
    }
  }

  filterRow({String? title,String? avgValue,onClick,bool isSelected=false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
        onTap: (){
          onClick();
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  isSelected?Icon(
                    Icons.check,
                    color: Colors.red,
                  ):SizedBox(),
                  isSelected?SizedBox(
                    width: 10,
                  ):SizedBox(),
                  Text(
                    '$title',
                    style: headingStyle(
                        color: isSelected?Colors.red:Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                    '$avgValue',
                    style: headingStyle(
                          color: isSelected?Colors.red:Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                      ))
                ],
              ),
            ),
            customHorizontalLine(),
          ],
        ),
      ),
    );
  }
}
