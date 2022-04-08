// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:code/constant/my_constant.dart';
// import 'package:code/constant/screen_size.dart';
// import 'package:code/model/subscription_model.dart';
// import 'package:code/util/app_color.dart';
// import 'package:code/util/routes.dart';
// import 'package:code/util/style.dart';
// import 'package:code/view/charts/spending_graph.dart';
// import 'package:code/view/charts/subscription_detail_graph.dart';
// import 'package:code/widgets/custom_widgets.dart';
// import 'package:flutter/material.dart';
//
// class SpendingScreen extends StatefulWidget {
//   const SpendingScreen({Key? key}) : super(key: key);
//
//   @override
//   _SpendingScreenState createState() => _SpendingScreenState();
// }
//
// class _SpendingScreenState extends State<SpendingScreen> {
//   @override
//   Widget build(BuildContext context) {
//     ScreenSize.width = MediaQuery.of(context).size.width;
//     ScreenSize.height = MediaQuery.of(context).size.height;
//
//     return SafeArea(
//         child: Scaffold(
//       backgroundColor: AppColors.appBgColor,
//       body: Padding(
//         padding: EdgeInsets.all(ScreenSize.screenPadding),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               Text(
//                 "History of Transactions",
//                 style: headingStyle(fontWeight: FontWeight.bold, fontSize: 24),
//               ),
//               SizedBox(
//                 height: ScreenSize.height! * 0.02,
//               ),
//               SizedBox(
//                 height: 120,
//                 width: ScreenSize.width,
//                 child: Row(
//                   children: [
//                     remainingTransaction(),
//                     Expanded(
//                       child: StreamBuilder<QuerySnapshot>(
//                           stream: SubscriptionModel.getUpcomingSubscriptions(),
//                           builder: (context, snapshot) {
//                             if (!snapshot.hasData) {
//                               return loadingIndicator();
//                             }
//                             if (snapshot.data!.docs.isEmpty) {
//                               return Center(
//                                 child: Text("No upcoming payment"),
//                               );
//                             }
//                             var allDoc = snapshot.data!.docs;
//                             List<int> remainingDaysList = [];
//                             for (var doc in allDoc) {
//                               SubscriptionModel subModel =
//                                   SubscriptionModel.fromJson(doc);
//                               final endDate = subModel.endDate!.toDate();
//                               final date2 = DateTime.now();
//                               final difference =
//                                   endDate.difference(date2).inDays;
//                               remainingDaysList.add(difference);
//                             }
//                             return ListView.builder(
//                                 itemCount: allDoc.length,
//                                 scrollDirection: Axis.horizontal,
//                                 itemBuilder: (context, index) {
//                                   SubscriptionModel subModel =
//                                       SubscriptionModel.fromJson(allDoc[index]);
//                                   return GestureDetector(
//                                     onTap: () {
//                                       MyConstant.clickedSubModel=subModel;
//                                       Navigator.pushNamed(context, MyRoutes.detailsScreen);
//                                     },
//                                     child: remainingDays(
//                                         imgUrl: subModel.imgUrl,
//                                         days: remainingDaysList[index]),
//                                   );
//                                 });
//                           }),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(
//                 height: ScreenSize.height! * 0.03,
//               ),
//               Text(
//                 "Last Six Months",
//                 style: headingStyle(fontWeight: FontWeight.bold, fontSize: 20),
//               ),
//               SpendingGraph(),
//               SizedBox(
//                 height: ScreenSize.height! * 0.02,
//               ),
//               Text(
//                 "Yours subscription this month",
//                 style: headingStyle(fontWeight: FontWeight.bold, fontSize: 20),
//               ),
//               Container(
//                 constraints: BoxConstraints(
//                   maxHeight: ScreenSize.height! * 0.3,
//                   minHeight: ScreenSize.height! * 0.3,
//                 ),
//                 child: StreamBuilder<QuerySnapshot>(
//                     key: UniqueKey(),
//                     stream: SubscriptionModel.getThisMonthSubscription(),
//                     builder: (context, snapshot) {
//                       if (!snapshot.hasData) {
//                         return loadingIndicator();
//                       }
//                       if (snapshot.data!.docs.isEmpty) {
//                         return Center(
//                           child: Text("No subscription this month"),
//                         );
//                       }
//
//                       return ListView.builder(
//                         itemCount: snapshot.data!.size,
//                         itemBuilder: (context, index) {
//                           SubscriptionModel subModel =
//                               SubscriptionModel.fromJson(
//                                   snapshot.data!.docs[index]);
//
//                           return GestureDetector(
//                               onTap: () {
//                                 Navigator.pushNamed(
//                                     context, MyRoutes.detailsScreen);
//                               },
//                               child: subscriptionTile(
//                                   imgUrl: subModel.imgUrl,
//                                   title: subModel.title,
//                                   price: subModel.price,
//                                   cycle: subModel.cycle));
//                         },
//                       );
//                     }),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ));
//   }
//
//   Widget remainingTransaction() {
//     return StreamBuilder<QuerySnapshot>(
//         key: UniqueKey(),
//         stream: SubscriptionModel.getThisMonthSubscription(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return loadingIndicator();
//           }
//           if (snapshot.data!.docs.isEmpty) {
//             return Center(
//               child:  Container(
//                 width: ScreenSize.width! * 0.5,
//                 height: 120,
//                 decoration: BoxDecoration(
//                     color: Colors.blueAccent.withOpacity(0.5),
//                     borderRadius: BorderRadius.circular(15)),
//                 padding: EdgeInsets.all(10),
//                 child: Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       FittedBox(child: Text("Your remaining limit for this month")),
//                       Text(
//                         "\$${MyConstant.currentUserModel!.monthyLimit}",
//                         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
//                       ),
//                     ],
//                   ),
//                 ),
//               )
//             );
//           }
//
//           var allDocs = snapshot.data!.docs;
//           int totalSpentThisMonth = 0;
//
//           for (var doc in allDocs) {
//             SubscriptionModel subModel = SubscriptionModel.fromJson(doc);
//             totalSpentThisMonth = totalSpentThisMonth + subModel.price!;
//           }
//           int remainingThisMonth =MyConstant.currentUserModel!.monthyLimit! - totalSpentThisMonth;
//           return Container(
//             width: ScreenSize.width! * 0.5,
//             height: 120,
//             decoration: BoxDecoration(
//                 color: Colors.blueAccent.withOpacity(0.5),
//                 borderRadius: BorderRadius.circular(15)),
//             padding: EdgeInsets.all(10),
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   FittedBox(child: Text("Your remaining limit for this month")),
//                   Text(
//                     "\$${remainingThisMonth}",
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         });
//   }
//
//   Widget remainingDays({String? imgUrl, int? days}) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 8),
//       child: Container(
//         height: 120,
//         width: ScreenSize.width! * 0.2,
//         padding: EdgeInsets.all(10),
//         decoration: BoxDecoration(
//             color: Colors.grey.withOpacity(0.3),
//             borderRadius: BorderRadius.circular(15)),
//         child: Center(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               customProfileAvatar("$imgUrl", size: 40),
//               Text(
//                 "$days",
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
//               ),
//               Text(
//                 "Days Remaining",
//                 style: TextStyle(
//                   fontSize: 12,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
