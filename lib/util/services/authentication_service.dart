import 'package:code/constant/my_constant.dart';
import 'package:code/util/alerts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/subscription_model.dart';

class AuthenticationService{
  static final FirebaseAuth auth = FirebaseAuth.instance;

  static Future<bool> createUserWithEmailAndPassword(String email,String password) async {
    try {
      UserCredential result =await auth.createUserWithEmailAndPassword(email:email, password:password);
      final User user = result.user!;
      MyConstant.currentUserID=user.uid;
      print("created successfully");
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        MyAlert.showToast("The password provided is too weak.");
        return false;
      } else if (e.code == 'email-already-in-use') {
        MyAlert.showToast("The account already exists for that email.");
        return false;
      } else if (e.code == 'invalid-email') {
        MyAlert.showToast("Please enter valid email address");
        return false;
      }else{
        MyAlert.showToast(e.toString());
        return false;
      }
    } catch (e) {
      print(e.toString());
      MyAlert.showToast(e.toString());
      return false;
    }
    return false;
  }



  static Future<bool> signInWithEmailAndPassword(String email,String password) async {

    try {
      UserCredential result = await auth.signInWithEmailAndPassword(
          email: email,
          password: password
      );
      final User user = result.user!;
      MyConstant.currentUserID=user.uid;
      await SubscriptionModel.renewSubscriptions();
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        MyAlert.showToast('No user found for that email.');
        return false;
      } else if (e.code == 'wrong-password') {
        MyAlert.showToast('Wrong password provided for that user.');
        return false;
      } else if (e.code == 'invalid-email') {
        MyAlert.showToast("Please enter valid email address");
        return false;
      }
      else{
        MyAlert.showToast(e.toString());
        return false;
      }
    }catch (e) {
      print("Error is ${e.toString()}");
      MyAlert.showToast(e.toString());
      return false;
    }
    return false;
  }


  static Future<bool> resetPassword(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);

      return true;
    }on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        MyAlert.showToast('No user found for that email.');
        return false;
      } else if (e.code == 'wrong-password') {
        MyAlert.showToast('Password/Username is in correct');
        return false;
      }else{
        MyAlert.showToast(e.toString());
        return false;
      }
    }catch (e) {
      print("Error is ${e.toString()}");
      MyAlert.showToast(e.toString());
      return false;
    }
  }


  static Future<bool> changePassword(String oldPassword,String newPassword) async {

    bool result=await AuthenticationService.signInWithEmailAndPassword(MyConstant.currentUserModel!.email!, oldPassword);
    if(result) {
      final user = auth.currentUser;
      user!.updatePassword(newPassword).then((_) {
        return true;
      }).catchError((error) {
        MyAlert.showToast(error.toString());
        return false;
      });
      return true;
    }else{
      return false;
    }
  }


  static Future<bool> saveUser(String userID) async {
    try{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("userID", userID);
      return true;
    }catch(e){
      print(e);
      return false;
    }
  }



  static Future<bool> logoutUser() async {
    try{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.clear();
      return true;
    }catch(e){
      print(e);
      return false;
    }
  }

}