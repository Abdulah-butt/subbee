import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code/constant/my_constant.dart';
import 'package:code/util/alerts.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

class UserModel {
  String? userId;
  String? name;
  String? email;
  String? imgUrl;

  UserModel({this.userId,this.name, this.email, this.imgUrl});

  UserModel.fromJson(DocumentSnapshot json) {
    userId = json['userId'];
    name = json['name'];
    email = json['email'];
    imgUrl = json['imgUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['imgUrl'] = this.imgUrl;
    return data;
  }


  // firebase connections

  static CollectionReference users=FirebaseFirestore.instance.collection('users');

  Future<bool> addUser()async{
    try{
      await users.doc(userId).set(toJson());
      await users.doc(userId).collection('settings').doc('settings').set({
        'currency':"USD"
      });
      return true;
    }catch(e){
      MyAlert.showToast('Something went wrong! $e');
      print(e);
      return false;
    }
  }

  static Future<UserModel?> getUser(String userID) async{
    try{
      DocumentSnapshot document = await FirebaseFirestore.instance.collection('users').doc(userID).get();
      return UserModel.fromJson(document);
    }catch(e){
      MyAlert.showToast('Something went wrong! $e');
      print(e);
      return null;
    }
  }




  // upload images to storage and let links
   Future<String?> uploadImageToFirestore(File img) async{
    String imgUrl='';
    try{
      var ref=storage.ref().child('Profile Images/${basename(img.path)}');
      await ref.putFile(img).whenComplete(() async {
        await ref.getDownloadURL().then((value){
          print("Image url $value");
          imgUrl=value;
        });
      });
      return imgUrl;
    }catch(e){
      print("Error while uploading images $e");
      return "null";
    }
  }

  // update user info
 static Future<bool> updateUser(UserModel userModel) async{
    try{
      await FirebaseFirestore.instance.collection('users').doc(MyConstant.currentUserID).update({
        'imgUrl':userModel.imgUrl??"null",
      });
      return true;
    }catch(e){
      MyAlert.showToast('Something went wrong!');
      return false;
    }
  }


 static FirebaseStorage storage=FirebaseStorage.instance;

  static Future<bool> deleteFromStorage(url) async {
    try{
      await storage.refFromURL(url).delete();
      print("deleted successfully");
      return true;
    }catch(e){
      print(e);
      return false;
    }
  }

}