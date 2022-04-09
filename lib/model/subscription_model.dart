import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code/constant/my_constant.dart';
import 'package:code/model/GraphModel.dart';
import 'package:code/util/alerts.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';


class SubscriptionModel {
  String? subscriptionId;
  String? title;
  double? price;
  String? category;
  Timestamp? endDate;
  String? cycle;
  String? reminder;
  String? description;
  String? imgUrl;
  bool? isRenewed;

  SubscriptionModel(
      {this.subscriptionId,
        this.title,
        this.price,
        this.category,
        this.endDate,
        this.cycle,
        this.reminder,
        this.description,
        this.isRenewed,
        this.imgUrl});

  SubscriptionModel.fromJson(DocumentSnapshot json) {
    subscriptionId = json['subscriptionId'];
    title = json['title'];
    price = json['price'];
    category = json['category'];
    endDate = json['endDate'];
    cycle = json['cycle'];
    reminder = json['reminder'];
    description = json['description'];
    isRenewed=json['isRenewed'];
    imgUrl = json['imgUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['subscriptionId'] = this.subscriptionId;
    data['title'] = this.title;
    data['price'] = this.price;
    data['category'] = this.category;
    data['endDate'] = this.endDate;
    data['cycle'] = this.cycle;
    data['reminder'] = this.reminder;
    data['description'] = this.description;
    data['imgUrl'] = this.imgUrl;
    data['isRenewed']=false;
    data['timestamp']=Timestamp.now();
    return data;
  }

  // firebase connections

  static CollectionReference users=FirebaseFirestore.instance.collection('users');

  Future<bool> addSubscription()async{
    try{
      subscriptionId=users.doc(MyConstant.currentUserID).collection('subscriptions').doc().id;
      users.doc(MyConstant.currentUserID).collection('subscriptions').doc(subscriptionId).set(toJson());
      return true;
    }catch(e){
      MyAlert.showToast('Something went wrong! $e');
      print(e);
      return false;
    }
  }

  Future<bool> renewSubscription()async{
    try{
      users.doc(MyConstant.currentUserID).collection('subscriptions').doc(subscriptionId).update({
        'isRenewed':true
      });
      return true;
    }catch(e){
      MyAlert.showToast('Something went wrong! $e');
      print(e);
      return false;
    }
  }


  Future<bool> updateSubscription()async{
    try{
      users.doc(MyConstant.currentUserID).collection('subscriptions').doc(subscriptionId).update({
        'price': price,
        'category': category,
        'endDate': endDate,
        'cycle': cycle,
        'reminder': reminder,
        'description': description,
        'timestamp':Timestamp.now(),
      });
      return true;
    }catch(e){
      MyAlert.showToast('Something went wrong! $e');
      print(e);
      return false;
    }
  }


  Future<bool> deleteSubscription()async{
    try{
      users.doc(MyConstant.currentUserID).collection('subscriptions').doc(subscriptionId).delete();
      return true;
    }catch(e){
      MyAlert.showToast('Something went wrong! $e');
      print(e);
      return false;
    }
  }
  
  static Stream<QuerySnapshot> getRecentSubscriptions({String? filterValue}){
    if(filterValue=="All Subscriptions") {
      return users.doc(MyConstant.currentUserID)
          .collection('subscriptions')
          .orderBy('timestamp', descending: true)
          .snapshots();
    }else{
      return users.doc(MyConstant.currentUserID)
          .collection('subscriptions')
          .orderBy('timestamp', descending: true)
          .where('category',isEqualTo:filterValue)
          .snapshots();
    }
  }
  static Stream<QuerySnapshot> getUpcomingSubscriptions(){
    return  users.doc(MyConstant.currentUserID).collection('subscriptions').orderBy('endDate',descending: false).where('endDate',isGreaterThanOrEqualTo:Timestamp.fromDate(DateTime.now())).snapshots();
  }
  static Stream<QuerySnapshot> getPreviousSubscriptions(){
    return  users.doc(MyConstant.currentUserID).collection('subscriptions').orderBy('endDate',descending: false).where('endDate',isLessThan:Timestamp.fromDate(DateTime.now())).snapshots();
  }


  static Future<void> getCurrency() async{
    DocumentSnapshot snapshot=await users.doc(MyConstant.currentUserID).collection('settings').doc('settings').get();
    if(snapshot.exists) {
      MyConstant.currency=snapshot['currency'];
    }else{
    MyConstant.currency='USD';
    }
  }


  static Future<void> changeCurrency(String currency) async{
    await users.doc(MyConstant.currentUserID).collection('settings').doc('settings').set({
      'currency':currency
    });
   MyConstant.currency=currency;
  }

  // renew old subscriptions

  static Future<void> renewSubscriptions() async{
    DateTime now = new DateTime.now();
    DateTime date = new DateTime(now.year, now.month, now.day);
    print("current date is ${date}");
    QuerySnapshot query=await users.doc(MyConstant.currentUserID).collection('subscriptions').orderBy('endDate',descending: false).where('endDate',isLessThan:Timestamp.fromDate(date)).where('isRenewed',isEqualTo: false).get();
    var allDocs=query.docs;
    if(allDocs.isNotEmpty){
      print("${allDocs.length} Subscription to renew");
      for(var doc in allDocs){
        SubscriptionModel subscriptionModel=SubscriptionModel.fromJson(doc);
        DateTime newEndDate;
        // change end date to after 7 days==week
        if(subscriptionModel.cycle=="Weekly"){
          newEndDate =subscriptionModel.endDate!.toDate().add(Duration(days: 7));
        }
        // change end date to after 30 days==month
        else if(subscriptionModel.cycle=="Monthly"){
          newEndDate =subscriptionModel.endDate!.toDate().add(Duration(days: 30));
        }
        // change end date to after 365 days== 1 year
        else{
          newEndDate =subscriptionModel.endDate!.toDate().add(Duration(days:365));
        }

        // change status of previous one
        await subscriptionModel.renewSubscription();

        subscriptionModel.endDate=Timestamp.fromDate(newEndDate);
        await subscriptionModel.addSubscription();

      }
    }else{
      print("No Subscription to renew");
    }
  }
  static Stream<QuerySnapshot> getThisMonthSubscription(){
    var date =  DateTime.now();
    return  users.doc(MyConstant.currentUserID).collection('subscriptions').orderBy('timestamp',descending: true).where('timestamp',isGreaterThanOrEqualTo: new DateTime(date.year, date.month, 1)).where('timestamp', isLessThanOrEqualTo: DateTime(date.year, date.month + 1,1)).snapshots();
  }



  static Stream<QuerySnapshot> getAllSubscriptions(){
    return  users.doc(MyConstant.currentUserID).collection('subscriptions').snapshots();
  }

  static Future<void> getYearlyAvrgs() async{
    QuerySnapshot allRecord=await users.doc(MyConstant.currentUserID).collection('subscriptions').get();
    var allDocs=allRecord.docs;
    double entertainmentAvg=0;
    double workAvg=0;
    for(var doc in allDocs){
      SubscriptionModel subscriptionModel=SubscriptionModel.fromJson(doc);
      if(subscriptionModel.cycle=="Yearly"){
        if(subscriptionModel.category=="Entertainment"){
          entertainmentAvg=entertainmentAvg+subscriptionModel.price!;
        }
        if(subscriptionModel.category=="Work"){
          workAvg=workAvg+subscriptionModel.price!;
        }
      }
    }
    MyConstant.workAvg=workAvg;
    MyConstant.entertainmentAvg=entertainmentAvg;
  }


  static List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  //
  // static Future<List<GraphModel>> getLastSixMonthRecord() async {
  //   List<GraphModel> graphModelList=[];
  //   var date =  DateTime.now();
  //
  //   for(int i=1;i<=6;i++) {
  //     date = date.subtract(Duration(days: 31));
  //     QuerySnapshot snapshot1 = await users.doc(MyConstant.currentUserID)
  //         .collection('subscriptions').where('startDate',
  //         isGreaterThanOrEqualTo: DateTime(date.year, date.month, 1)).where(
  //         'startDate',
  //         isLessThanOrEqualTo: DateTime(date.year, date.month + 1, 1))
  //         .get();
  //     var allDocs = snapshot1.docs;
  //     int monthlySpending = 0;
  //     for (var doc in allDocs) {
  //       SubscriptionModel subscriptionModel = SubscriptionModel.fromJson(doc);
  //       monthlySpending = monthlySpending + subscriptionModel.price!;
  //     }
  //
  //     print("Last month date $date, month name is ${months[date.month - 1]}");
  //     print('amount sent is $monthlySpending');
  //
  //     graphModelList.add(GraphModel(spendAmount: monthlySpending.toDouble(),
  //         monthName: months[date.month-1]));
  //   }
  //
  //   return graphModelList;
  //
  // }

  static FirebaseStorage storage=FirebaseStorage.instance;


  // upload images to storage and let links
 static Future<String> uploadImagesToFirestore(File img) async{
   String url='';
    try{
        var ref=storage.ref().child('product images/${basename(img.path)}');
        await ref.putFile(img).whenComplete(() async {
          await ref.getDownloadURL().then((value){
            print("Image url $value");
            url=value.toString();
          });
        });
      return url;
    }catch(e){
      print("Error while uploading images $e");
      return '';
    }
  }

}