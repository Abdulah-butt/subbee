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




  UserModel _userModel=MyConstant.currentUserModel!;
  bool isExpanded=false;


  @override
  Widget build(BuildContext context) {
    ScreenSize.width=MediaQuery.of(context).size.width;
    ScreenSize.height=MediaQuery.of(context).size.height;
    return SafeArea(
        child: Scaffold(
          backgroundColor: AppColors.appBgColor,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: AppColors.appBgColor,
            leading: IconButton(onPressed: (){
              Navigator.pushNamed(context, MyRoutes.settingScreen);
            }, icon: Icon(Icons.settings)),
            iconTheme: IconThemeData(color: Colors.black),
            titleTextStyle:TextStyle(color: Colors.black),
            actions: [
              IconButton(onPressed: (){
                showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    builder: (context){
                      return ModelSheet();
                    }
                );
              }, icon: Icon(Icons.add))
            ],
            title:InkWell(
              onTap: (){
                filterScreen();
              },
              child: SizedBox(
                width: ScreenSize.width!*0.8,
                height: 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    filterValue=="All"?Text("All Subscriptions",style: headingStyle(fontWeight: FontWeight.bold,fontSize: 18),):
                    Text("$filterValue",style: headingStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                    SizedBox(width: ScreenSize.width!*0.1,),
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
                  height: ScreenSize.height!*0.12,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.btnColor),
                  constraints: BoxConstraints(
                    minHeight:ScreenSize.height! * 0.1,
                  ),

                  child:StreamBuilder<QuerySnapshot>(
                      key: UniqueKey(),
                      stream: SubscriptionModel.getAllSubscriptions(),
                      builder: (context, snapshot) {

                        if(!snapshot.hasData){
                          return Center(child: loadingIndicator());
                        }
                        if(snapshot.data!.docs.isEmpty){
                          return Center(child: Text("No record yet",style: TextStyle(color: AppColors.appBgColor),),);
                        }

                        var allDocs=snapshot.data!.docs;
                        int totalWeekly=0;
                        int totalMonthly=0;
                        int totalYearly=0;

                        for(var doc in allDocs){
                          SubscriptionModel subModel=SubscriptionModel.fromJson(doc);
                          if(subModel.cycle=="Monthly") {
                            totalMonthly=totalMonthly+subModel.price!;
                          }
                          else if(subModel.cycle=="Weekly") {
                            totalWeekly=totalWeekly+subModel.price!;
                          }
                          else if(subModel.cycle=="Yearly") {
                            totalYearly=totalYearly+subModel.price!;
                          }
                          else{
                            print("Incorrect package");
                          }
                        }

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Expected Expenditure",
                                style: headingStyle(fontWeight: FontWeight.bold, fontSize: 22),
                              ),
                              SizedBox(height: 10,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  expectedExpenditure("Per Week","$totalWeekly"),
                                  expectedExpenditure("Per Month","$totalMonthly"),
                                  expectedExpenditure("Per Year","$totalYearly"),

                                ],
                              )
                            ],
                          ),
                        );
                      }
                  ),
                ),

                SizedBox(
                  height: isExpanded?ScreenSize.height! * 0.05:ScreenSize.height! * 0.02,
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
                      stream:SubscriptionModel.getRecentSubscriptions(filterValue: filterValue),
                      builder: (context, snapshot) {
                        if(!snapshot.hasData){
                          return Center(child: loadingIndicator());
                        }
                        if(snapshot.data!.docs.isEmpty){
                          return Center(child: Text("No subscription yet"),);
                        }

                        return ListView.builder(
                          itemCount: snapshot.data!.size,
                          itemBuilder: (context, index) {

                            SubscriptionModel subModel=SubscriptionModel.fromJson(snapshot.data!.docs[index]);

                            return GestureDetector(
                                onTap: (){
                                  MyConstant.clickedSubModel=subModel;
                                  Navigator.pushNamed(context, MyRoutes.detailsScreen);

                                },
                                child: subscriptionTile(imgUrl: subModel.imgUrl,title: subModel.title,price: subModel.price,cycle: subModel.cycle));
                          },
                        );
                      }
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget textAndNumber(String text,String value){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(text,style: headingStyle(fontSize: 16,color: AppColors.appBgColor),),
        Text(value,style: headingStyle(fontSize: 16,color: AppColors.appBgColor))
      ],
    );
  }


  Widget expectedExpenditure(String package,String value){
    return  Column(
      children: <Widget>[
        Text(
          "$package",
          style: headingStyle(fontWeight: FontWeight.bold, fontSize: 16,color: AppColors.appBgColor),
        ),
        SizedBox(height: 5,),
        Text(
          "\$$value",
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
      'channel id',   //Required for Android 8.0 or after
      'channel name', //Required for Android 8.0 or after
      channelDescription: 'channel discription', //Required for Android 8.0 or after
      importance: Importance.max,
      priority: Priority.max
  );
  NotificationDetails? platformChannelSpecifics;
  final _notification=FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    platformChannelSpecifics=NotificationDetails(android: androidPlatformChannelSpecifics);
  }


  String filterValue='All';


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

                    children: [

                      SizedBox(height: 20,),
                      SizedBox(
                          width: ScreenSize.width!*0.3,
                          child: Divider(thickness: 3,)),
                      SizedBox(height: 20,),
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Select Category",style: headingStyle(fontWeight: FontWeight.bold),)),
                      SizedBox(height: 20,),
                      SizedBox(
                          width: ScreenSize.width,
                          child: Divider(thickness: 1,)),
                      ListTile(
                        title: Center(child: Text('All Subscriptions')),
                        onTap: () {
                          setState(() {
                            filterValue='All';
                            Navigator.pop(context);
                          });
                        },
                        trailing: filterValue=="All"?Icon(Icons.check,color: Colors.green,):SizedBox(),
                      ),
                      SizedBox(
                          width: ScreenSize.width,
                          child: Divider(thickness: 1,)),

                      ListTile(
                        title: Center(child: Text('Entertainment')),
                        trailing: filterValue=="Entertainment"?Icon(Icons.check,color: Colors.green,):SizedBox(),
                        onTap: () {
                          setState(() {
                            filterValue='Entertainment';
                            Navigator.pop(context);
                          });
                        },
                      ),
                      SizedBox(
                          width: ScreenSize.width,
                          child: Divider(thickness: 1,)),

                      ListTile(
                        title: Center(child: Text('Work')),
                        trailing: filterValue=="Work"?Icon(Icons.check,color: Colors.green,):SizedBox(),
                        onTap: () {
                          setState(() {
                            filterValue='Work';
                            Navigator.pop(context);
                          });
                        },
                      ),
                      SizedBox(
                          width: ScreenSize.width,
                          child: Divider(thickness: 1,)),

                    ],
                  ),
                )),
          );
        });
  }


}
