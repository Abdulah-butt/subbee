import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code/constant/my_constant.dart';
import 'package:code/constant/screen_size.dart';
import 'package:code/model/subscription_model.dart';
import 'package:code/util/app_color.dart';
import 'package:code/util/routes.dart';
import 'package:code/util/style.dart';
import 'package:code/view/charts/spending_graph.dart';
import 'package:code/view/charts/subscription_detail_graph.dart';
import 'package:code/widgets/custom_widgets.dart';
import 'package:flutter/material.dart';


class DetailSubscriptionScreen extends StatefulWidget {
  const DetailSubscriptionScreen({Key? key}) : super(key: key);

  @override
  _DetailSubscriptionScreenState createState() => _DetailSubscriptionScreenState();
}

class _DetailSubscriptionScreenState extends State<DetailSubscriptionScreen> {
  SubscriptionModel subscriptionModel=MyConstant.clickedSubModel!;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          backgroundColor: AppColors.appBgColor,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: AppColors.appBgColor,
            iconTheme: IconThemeData(color: Colors.black),
            title:  Text(
              "Subscription Details",
              style:
              headingStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
          body: Padding(
            padding: EdgeInsets.all(ScreenSize.screenPadding),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  // for image
                  Center(
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          // color: Colors.grey
                      ),
                      child: cacheImage(subscriptionModel.imgUrl!),
                    ),
                  ),
                  Center(
                    child: Text(
                      "${subscriptionModel.title}",
                      style: headingStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Center(child: Text("${subscriptionModel.url}")),

                  SizedBox(
                    height: ScreenSize.height! * 0.03,
                  ),

                  //SubscriptionDetailsGraph(),
                  SpendingGraph(),

                  SizedBox(
                    height: ScreenSize.height! * 0.02,
                  ),

                  Text(
                    "Previous subscriptions",
                    style: headingStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),

                  Container(
                    constraints: BoxConstraints(
                      minHeight: 400,
                      maxHeight: 400
                    ),
                    child: StreamBuilder<QuerySnapshot>(
                        key: UniqueKey(),
                        stream:SubscriptionModel.getPreviousSubscriptions(),
                        builder: (context, snapshot) {
                          if(!snapshot.hasData){
                            return loadingIndicator();
                          }
                          if(snapshot.data!.docs.isEmpty){
                            return Center(child: Text("No Previous Subscription Yet"),);
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
          ),
        ));
  }


}
