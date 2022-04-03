import 'dart:convert';
import 'dart:io';

import 'package:code/constant/my_constant.dart';
import 'package:code/constant/screen_size.dart';
import 'package:code/model/subscription_model.dart';
import 'package:code/model/user_model.dart';
import 'package:code/util/alerts.dart';
import 'package:code/util/app_color.dart';
import 'package:code/util/my_functions.dart';
import 'package:code/util/routes.dart';
import 'package:code/util/services/authentication_service.dart';
import 'package:code/util/style.dart';
import 'package:code/view/authentication_screen.dart';
import 'package:code/widgets/custom_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel userModel=MyConstant.currentUserModel!;
final txtMonthlyLimit=TextEditingController();

  @override
  Widget build(BuildContext context) {
    ScreenSize.width=MediaQuery.of(context).size.width;
    ScreenSize.height=MediaQuery.of(context).size.height;
    txtMonthlyLimit.text=userModel.monthyLimit.toString();
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.appBgColor,
        body: Padding(
          padding: EdgeInsets.all(ScreenSize.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Profile",
                    style:
                        headingStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  Column(
                    children: [
                      IconButton(onPressed: () {
                        saveProfileAction();
                      }, icon: Icon(Icons.save,color: AppColors.btnColor,)),
                    ],
                  )
                ],
              ),

              // profile list tile


                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        _image==null&&userModel.imgUrl=="null"?CircleAvatar(
                            backgroundColor: AppColors.appBarColor,
                            radius: 40,
                            child: Icon(Icons.person,size: 45,color: AppColors.appBgColor,)
                        ):_image!=null?CircleAvatar(
                          radius: 40.0,
                          backgroundImage:FileImage(_image!),
                          backgroundColor: Colors.transparent,
                        ):customProfileAvatar(userModel.imgUrl!,size: 80),
                        Positioned(
                          bottom: 0,
                          right: -10,
                          child: CircleAvatar(
                            backgroundColor: AppColors.appBgColor,
                            child: IconButton(
                              icon: Icon(Icons.edit,color:AppColors.blackTextColor),
                              onPressed: (){
                                _showPicker(context);
                              },
                            ),
                          ),
                        )
                      ],
                    ),

                    SizedBox(width: ScreenSize.width!*0.05,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text(
                          "${userModel.name}",
                          style:
                          headingStyle(fontWeight: FontWeight.bold, fontSize: 22),
                        ),
                        SizedBox(height: 10,),
                        Text(
                          "${userModel.email}",
                          style: headingStyle(fontSize: 14),
                        ),
                      ],
                    )
                  ],
                ),

              customTextField(hint: "Monthly Limit",controller:txtMonthlyLimit,icon: Icon(Icons.label_important)),

              SizedBox(
                height: ScreenSize.height! * 0.03,
              ),
              Text(
                "Account Settings",
                style: headingStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),

              SizedBox(
                height: ScreenSize.height! * 0.03,
              ),
              customListTile("Change Password", () async {
                Navigator.pushNamed(context, MyRoutes.changePasswordScreen);
              }),
              customListTile("Terms and Service", () {
                _launchURL("https://www.Subbee.com/termsandconditions");
              }),
              customListTile("Contact Us", () {
                launchEmail();

              }),


              SizedBox(
                height: ScreenSize.height! * 0.05,
              ),

              Align(
                alignment: Alignment.center,
                child: customButton("Logout",() async {
                  AuthenticationService.logoutUser();
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AuthenticationScreen()
                      ),
                          (Route<dynamic> route) => false
                  );
                },width: ScreenSize.width!*0.35,icon: Icon(Icons.logout,color: Colors.white,)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget customListTile(String title, Function action) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: (){
          action();
        },
        child: PhysicalModel(
          color: Colors.white,
          elevation: 10,
          // shadowColor: Colors.,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            width: ScreenSize.width,
            height: 70,
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(title),
                Icon(Icons.navigate_next),

              ],
            ),
          ),
        ),
      ),
    );
  }


  File? _image;


  _imgFromCamera() async {
    XFile? image = await ImagePicker().pickImage(
        source: ImageSource.camera, imageQuality: 50
    );

    setState(() {
      _image = File(image!.path);
    });
  }

  _imgFromGallery() async {
    XFile? image = await  ImagePicker().pickImage(
        source: ImageSource.gallery, imageQuality: 50
    );

    setState(() {
      _image = File(image!.path);
    });
  }


  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child:  Wrap(
                children: <Widget>[
                  ListTile(
                      leading:  Icon(Icons.photo_library),
                      title:  Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  ListTile(
                    leading:  Icon(Icons.photo_camera),
                    title:  Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  saveProfileAction() async {

    if(txtMonthlyLimit.text.isEmpty){
      MyAlert.showToast("Please enter monthly limit");
    }else {
      customloadingIndicator(context);

      // delete previous image from storage
      if (_image != null) {
        if (userModel.imgUrl != "null") {
          await UserModel.deleteFromStorage(userModel.imgUrl);
        }
      }

      String? imgUrl;
      // upload image to fire storage
      if (_image != null) {
        imgUrl = await UserModel().uploadImageToFirestore(_image!);
      } else {
        imgUrl = userModel.imgUrl;
      }
      print("User Image uploaded Image is ${imgUrl}");

      UserModel uModel = UserModel(
          imgUrl: imgUrl,
          monthyLimit: int.parse(txtMonthlyLimit.text)
      );
      bool result = await UserModel.updateUser(uModel);
      Navigator.pop(context);
      if (result) {
        MyConstant.currentUserModel!.imgUrl = imgUrl;
        MyConstant.currentUserModel!.monthyLimit =  int.parse(txtMonthlyLimit.text);
        SubscriptionModel.getThisMonthLimit();

        MyAlert.showToast("Profile updated");
        setState(() {

        });
      }
    }
  }



  void _launchURL(var _url) async {
    if (!await launch(_url)) throw 'Could not launch $_url';
  }

  void launchEmail() async{
    final Uri params = Uri(
      scheme: 'mailto',
      path: 'contact@subbee.com',
      query: 'subject=&body=', //add subject and body here
    );

    var url = params.toString();
    if (await canLaunch(url)) {
    await launch(url);
    } else {
    throw 'Could not launch $url';
    }
  }
}
