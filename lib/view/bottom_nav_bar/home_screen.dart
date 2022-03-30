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
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {



  UserModel _userModel=MyConstant.currentUserModel!;
  bool isExpanded=false;


  @override
  Widget build(BuildContext context) {
    ScreenSize.width=MediaQuery.of(context).size.width;
    ScreenSize.height=MediaQuery.of(context).size.height;
    return SafeArea(
        child: Scaffold(
      backgroundColor: AppColors.appBgColor,
      body: Padding(
        padding: EdgeInsets.all(ScreenSize.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // heading + profile image
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: "Welcome, ",
                        style: headingStyle(
                            fontWeight: FontWeight.bold, fontSize: 24),
                        children: <TextSpan>[
                          TextSpan(
                              text: '${_userModel.name}',
                              style: headingStyle(
                                  color: AppColors.btnColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24)),
                        ],
                      ),
                    ),
                    Text(
                      "Your subscription overview are below.",
                      style: headingStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                GestureDetector(
                  onTap: (){

                     MyConstant.currentScreenIndex=2;
                    Navigator.pushNamed(context, MyRoutes.bottomNavScreen);
                  },
                  child: _userModel.imgUrl=="null"?CircleAvatar(backgroundColor: AppColors.btnColor,radius:30,child: Icon(Icons.person,color: AppColors.appBgColor,size: 40,),):customProfileAvatar(_userModel.imgUrl!,),
                ),
              ],
            ),

            SizedBox(
              height: ScreenSize.height! * 0.02,
            ),
            Text(
              "Summary",
              style: headingStyle(fontWeight: FontWeight.bold, fontSize: 28),
            ),
            SizedBox(
              height: ScreenSize.height! * 0.03,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                GestureDetector(
                  onTap: (){
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
                  },
                  child: Container(
                    height: ScreenSize.height! * 0.1,
                    width: ScreenSize.width! * 0.1,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: AppColors.yellowColor),
                    child: Center(
                      child: Icon(Icons.add),
                    ),
                  ),
                ),



                Container(
                  width: ScreenSize.width! * 0.8,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: AppColors.btnColor),
                  constraints: BoxConstraints(
                    minHeight:ScreenSize.height! * 0.1,
                  ),

                  child:StreamBuilder<QuerySnapshot>(
                    key: UniqueKey(),
                    stream: SubscriptionModel.getAllSubscriptions(),
                    builder: (context, snapshot) {

                      if(!snapshot.hasData){
                        return loadingIndicator();
                      }
                      if(snapshot.data!.docs.isEmpty){
                        return Center(child: Text("No record yet",style: TextStyle(color: AppColors.appBgColor),),);
                      }

                      var allDocs=snapshot.data!.docs;
                       int totalAmount=0;
                       int totalEntertainment=0;
                       int totalWork=0;
                       int totalService=0;

                       for(var doc in allDocs){
                         SubscriptionModel subModel=SubscriptionModel.fromJson(doc);
                         if(subModel.cycle=="Monthly") {
                           totalAmount = totalAmount + subModel.price!;
                           if (subModel.category == "Entertainment") {
                             totalEntertainment =totalEntertainment + subModel.price!;
                           }
                           else if (subModel.category == "Work") {
                             totalWork = totalWork + subModel.price!;
                           }
                           else if (subModel.category == "Service") {
                             totalService = totalService + subModel.price!;
                           }
                         }
                       }

                      return Column(
                        children: [
                          ListTile(
                            title:Text("Total for your subscription",style:headingStyle(color: AppColors.appBgColor,fontSize: 16,fontWeight: FontWeight.bold)),
                            iconColor: AppColors.appBgColor,
                            subtitle: RichText(
                              text: TextSpan(
                                text: "\$${totalAmount}",
                                style: headingStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                  color: AppColors.appBgColor,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: '/per month',
                                      style: headingStyle(
                                          fontWeight: FontWeight.bold, fontSize: 16,)),
                                ],
                              ),
                            ),
                            trailing:IconButton(onPressed: (){
                              setState(() {
                                isExpanded=!isExpanded;
                              });
                            },
                            icon: isExpanded?Icon(Icons.keyboard_arrow_up_outlined,color: AppColors.appBgColor,):Icon(Icons.keyboard_arrow_down_outlined,color: AppColors.appBgColor),
                            ),
                          ),

                          Visibility(
                            visible: isExpanded,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: <Widget>[
                                  Divider(color: AppColors.appBgColor,thickness: 2,),
                                  textAndNumber("Entertainment:","\$${totalEntertainment}"),
                                  textAndNumber("Work:","\$${totalWork}"),
                                  textAndNumber("Services:","\$${totalService}"),

                                ],
                              ),
                            ),
                          )
                        ],
                      );
                    }
                  ),
                ),
              ],
            ),

            SizedBox(
              height: isExpanded?ScreenSize.height! * 0.05:ScreenSize.height! * 0.02,
            ),
            Text(
              "Upcoming Payments (Days)",
              style: headingStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            SizedBox(
              height: ScreenSize.height! * 0.03,
            ),

            // list of upcomming payments

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                key: UniqueKey(),
                  stream:SubscriptionModel.getUpcomingSubscriptions(),
                  builder: (context, snapshot) {
                    if(!snapshot.hasData){
                      return loadingIndicator();
                    }
                    if(snapshot.data!.docs.isEmpty){
                      return Center(child: Text("No Upcoming payment yet"),);
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
            SizedBox(
                height: ScreenSize.height! * 0.15,
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Recent Subscription",
                  style:
                      headingStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                      key: UniqueKey(),
                    stream:SubscriptionModel.getRecentSubscriptions(),
                    builder: (context, snapshot) {
                      if(!snapshot.hasData){
                        return loadingIndicator();
                      }
                      if(snapshot.data!.docs.isEmpty){
                        return Center(child: Text("No Recent Subscription yet"),);
                      }

                      return ListView.builder(
                          itemCount: snapshot.data!.size,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            SubscriptionModel subModel=SubscriptionModel.fromJson(snapshot.data!.docs[index]);
                            return GestureDetector(
                                onTap: (){
                                  MyConstant.clickedSubModel=subModel;
                                  Navigator.pushNamed(context, MyRoutes.detailsScreen);
                                },
                                child: recentSubscriptions(subModel.imgUrl));
                          });
                    }
                  ),
                ),
              ],
            ))
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
}
