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
  int? price;
  String? currency;
  String? category;
  Timestamp? startDate;
  Timestamp? endDate;
  String? cycle;
  int? reminder;
  String? url;
  String? imgUrl;

  SubscriptionModel(
      {this.subscriptionId,
        this.title,
        this.price,
        this.currency,
        this.category,
        this.startDate,
        this.endDate,
        this.cycle,
        this.reminder,
        this.url,
        this.imgUrl});

  SubscriptionModel.fromJson(DocumentSnapshot json) {
    subscriptionId = json['subscriptionId'];
    title = json['title'];
    price = json['price'];
    currency = json['currency'];
    category = json['category'];
    startDate = json['startDate'];
    endDate = json['endDate'];
    cycle = json['cycle'];
    reminder = json['reminder'];
    url = json['url'];
    imgUrl = json['imgUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['subscriptionId'] = this.subscriptionId;
    data['title'] = this.title;
    data['price'] = this.price;
    data['currency'] = this.currency;
    data['category'] = this.category;
    data['startDate'] = this.startDate;
    data['endDate'] = this.endDate;
    data['cycle'] = this.cycle;
    data['reminder'] = this.reminder;
    data['url'] = this.url;
    data['imgUrl'] = this.imgUrl;
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
  
  static Stream<QuerySnapshot> getRecentSubscriptions(){
    return  users.doc(MyConstant.currentUserID).collection('subscriptions').orderBy('timestamp',descending: true).snapshots();
  }
  static Stream<QuerySnapshot> getUpcomingSubscriptions(){
    return  users.doc(MyConstant.currentUserID).collection('subscriptions').orderBy('endDate',descending: false).where('endDate',isGreaterThanOrEqualTo:Timestamp.fromDate(DateTime.now())).snapshots();
  }
  static Stream<QuerySnapshot> getPreviousSubscriptions(){
    return  users.doc(MyConstant.currentUserID).collection('subscriptions').orderBy('endDate',descending: false).where('endDate',isLessThan:Timestamp.fromDate(DateTime.now())).snapshots();
  }
  static Stream<QuerySnapshot> getThisMonthSubscription(){
    var date =  DateTime.now();
    return  users.doc(MyConstant.currentUserID).collection('subscriptions').orderBy('timestamp',descending: true).where('timestamp',isGreaterThanOrEqualTo: new DateTime(date.year, date.month, 1)).where('timestamp', isLessThanOrEqualTo: DateTime(date.year, date.month + 1,1)).snapshots();
  }

  static Future<void> getThisMonthLimit() async{
    var date =  DateTime.now();
    QuerySnapshot snapshot=  await users.doc(MyConstant.currentUserID).collection('subscriptions').orderBy('timestamp',descending: true).where('timestamp',isGreaterThanOrEqualTo: new DateTime(date.year, date.month, 1)).where('timestamp', isLessThanOrEqualTo: DateTime(date.year, date.month + 1,1)).get();
    var allDocs=snapshot.docs;
    if(allDocs.isEmpty){
      MyConstant.thisMonthRemainingLimit=MyConstant.currentUserModel!.monthyLimit!;
    }else{
      int totalSpentThisMonth = 0;

      for (var doc in allDocs) {
        SubscriptionModel subModel = SubscriptionModel.fromJson(doc);
        totalSpentThisMonth = totalSpentThisMonth + subModel.price!;
      }
      int remainingThisMonth =MyConstant.currentUserModel!.monthyLimit! - totalSpentThisMonth;
      MyConstant.thisMonthRemainingLimit=remainingThisMonth;
    }

  }

  static Stream<QuerySnapshot> getAllSubscriptions(){
    return  users.doc(MyConstant.currentUserID).collection('subscriptions').snapshots();
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


  static Future<List<GraphModel>> getLastSixMonthRecord() async {
    List<GraphModel> graphModelList=[];
    var date =  DateTime.now();

    for(int i=1;i<=6;i++) {
      date = date.subtract(Duration(days: 31));
      QuerySnapshot snapshot1 = await users.doc(MyConstant.currentUserID)
          .collection('subscriptions').where('startDate',
          isGreaterThanOrEqualTo: DateTime(date.year, date.month, 1)).where(
          'startDate',
          isLessThanOrEqualTo: DateTime(date.year, date.month + 1, 1))
          .get();
      var allDocs = snapshot1.docs;
      int monthlySpending = 0;
      for (var doc in allDocs) {
        SubscriptionModel subscriptionModel = SubscriptionModel.fromJson(doc);
        monthlySpending = monthlySpending + subscriptionModel.price!;
      }

      print("Last month date $date, month name is ${months[date.month - 1]}");
      print('amount sent is $monthlySpending');

      graphModelList.add(GraphModel(spendAmount: monthlySpending.toDouble(),
          monthName: months[date.month-1]));
    }

    return graphModelList;

  }

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