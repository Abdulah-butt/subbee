import 'package:cached_network_image/cached_network_image.dart';
import 'package:code/constant/my_constant.dart';
import 'package:code/constant/screen_size.dart';
import 'package:code/util/assets_path.dart';
import 'package:code/util/style.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../util/app_color.dart';






Widget customTextField(
    {String? iconPath,
      String? hint,
      TextEditingController? controller,
      TextInputType? keyboard,
      Icon? icon,
      bool? hide,
      bool? enable,
      Function? onValueChange,
      String? trailingIconPath,
      Function? trailingAction}) {
  return Padding(
    padding: const EdgeInsets.only(top: 10, bottom: 10),
    child: Container(
      height: keyboard == TextInputType.multiline
          ? ScreenSize.height! * 0.2
          : ScreenSize.textFieldHeight,
      width: ScreenSize.width,
      child: Center(
        child: Row(
          children: [
            const SizedBox(
              width: 10,
            ),
            iconPath == null
                ? SizedBox()
                : Align(
                alignment: Alignment.center,
                child: Image.asset(
                  iconPath,
                  height: ScreenSize.iconSize,
                )),
            icon ?? SizedBox(),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Container(
                height: ScreenSize.height! * 0.3,
                child: TextField(
                  controller: controller,
                  keyboardType: keyboard,
                  obscureText: hide ?? false,
                  enabled: enable ?? true,
                  onChanged: (val) {
                    if (onValueChange != null) {
                      onValueChange();
                    }
                  },
                  maxLines: keyboard == TextInputType.multiline ? null : 1,
                  decoration: InputDecoration(
                    hintText: hint,
                    // label: Text(hint!),
                    suffixIcon: trailingIconPath != null
                        ? InkWell(
                        onTap: () {
                          trailingAction!();
                        },
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: 10,
                            left: 10,
                          ),
                          child: Image.asset(trailingIconPath),
                        ))
                        : SizedBox(),
                    suffixIconConstraints: BoxConstraints(
                      minHeight: ScreenSize.iconSize,
                      maxHeight: ScreenSize.iconSize,
                    ),
                    hintStyle: hintStyle(),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      decoration: textFieldDecoration(),
    ),
  );
}





Widget secondaryTextField({TextEditingController? controller,TextInputType? keyboard,String? hint}){
  return Container(
      child: Center(
        child: TextField(
          controller: controller,
          keyboardType: keyboard,
          style:  TextStyle(fontWeight: FontWeight.w600,fontSize: 18),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hint,
            hintStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),
              contentPadding: EdgeInsets.only(
                bottom:12,  // HERE THE IMPORTANT PART
              )
          ),
        ),
      )
  );
}



Widget customProfileAvatar(String _url,{double size=70}) {
  return Container(
    height: size,
    width: size,
    child: CachedNetworkImage(
      height: size,
      width: size,
      imageUrl: _url,
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
       //   borderRadius: BorderRadius.circular(50),
            shape: BoxShape.circle,
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


Widget cacheImage(String _url){
  return CachedNetworkImage(
    imageUrl: _url,
    imageBuilder: (context, imageProvider) => Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: imageProvider,
          fit: BoxFit.cover,
        ),
      ),
    ),
    placeholder: (context, url) =>
     Center(child: loadingIndicator()),
    errorWidget: (context, url, error) =>
    const Center(child: Icon(Icons.error)),
  );
}

Widget customButton(String _text, Function f,
    {MaterialStateProperty<Color?>? btnColor, Color? txtColor,double? width,Icon? icon}) {
  return Container(
    width:width??ScreenSize.width,
    height: 55,
    child: ElevatedButton(
        onPressed: () {
          f();
        },
        child: Row(
            mainAxisAlignment: icon==null?MainAxisAlignment.center:MainAxisAlignment.center,
          children: [
            icon??SizedBox(),
            icon==null?SizedBox():SizedBox(width: 10,),
            Text(
              _text,
              style: btnTextStyle(color: txtColor),
            ),
          ],
        ),
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              )),
          side: MaterialStateProperty.all(
            BorderSide.lerp(
                BorderSide(style: BorderStyle.solid, color: AppColors.btnColor),
                BorderSide(style: BorderStyle.solid, color: AppColors.btnColor),
                8.0),
          ),
          backgroundColor: btnColor ?? AppColors.customBtnColor,
        )),
  );
}


// image logo

Widget imageLogo() {
  return Image.asset(
    AssetPath.logoPath,
    height: ScreenSize.height! * 0.15,
  );
}

// loading widget

Future<dynamic> customloadingIndicator(BuildContext context) {
  return showDialog(
      context: context,
      builder: (context) {
        return Material(
          color: Colors.white.withOpacity(0.3),
          child: const Center(
              child: SizedBox(
                height: 70,

                child: LoadingIndicator(
                    indicatorType: Indicator.ballSpinFadeLoader, /// Required, The loading type of the widget
                    colors: [Color(0xfffed420)],       /// Optional, The color collections
                    strokeWidth: 2,                     /// Optional, The stroke of the line, only applicable to widget which contains line
                    backgroundColor: Colors.transparent,      /// Optional, Background of the widget
                    pathBackgroundColor: Colors.transparent   /// Optional, the stroke backgroundColor
                ),
              )
          ),
        );
      });
}


Widget loadingIndicator(){
  return SizedBox(
    height: 50,
    width: 50,
    child: LoadingIndicator(
        indicatorType: Indicator.ballSpinFadeLoader, /// Required, The loading type of the widget
        colors: [Color(0xfffed420)],       /// Optional, The color collections
        strokeWidth: 2,                     /// Optional, The stroke of the line, only applicable to widget which contains line
        backgroundColor: Colors.transparent,      /// Optional, Background of the widget
        pathBackgroundColor: Colors.transparent   /// Optional, the stroke backgroundColor
    ),
  );
}
Widget customAppBar({Icon? icon, Function? f, String? title}) {
  return Padding(
    padding: EdgeInsets.only(top: ScreenSize.screenPadding),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        InkWell(
          onTap: () {
            f!() ?? print('');
          },
          child: icon!,
        ),
        SizedBox(
          width: 10,
        ),
        title == null
            ? SizedBox()
            : Text(
          title,
          style: forgetPasswordAppbarStyle(),
        )
      ],
    ),
  );
}



Widget customDialogBox(BuildContext context, String title, String subtitle) {
  return Scaffold(
    backgroundColor: Colors.transparent,
    body: Center(
      child: Container(
        height: 200,
        width: ScreenSize.width! * 0.9,
        child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  title,
                  style: headingStyle(),
                  textAlign: TextAlign.center,
                ),
                Text(subtitle, style: greyTextStyle(), textAlign: TextAlign.center),
                Container(
                  width: ScreenSize.width! * 0.5,
                  child: customButton("Close", () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  }),
                ),
              ],
            )),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    ),
  );
}



Widget subscriptionTile({String? imgUrl,String? title,double? price,String? cycle,String? description}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child:  Container(
      height: 70,
      child: PhysicalModel(
        color: Colors.white,
        elevation: 3,
        // shadowColor: Colors.,
        borderRadius: BorderRadius.circular(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            // img + title + desc
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                      height: 50,
                      width: 50,
                      child: cacheImage(imgUrl!)),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        title!,
                        style: headingStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        height:20,
                        child: Text(
                          description!,
                          style: headingStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),


              ],
            ),


            // price + cycle


            // price and cycle

            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "${MyConstant.currency} $price",
                    style: headingStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color:AppColors.btnColor,
                    ),
                  ),
                  Text(
                    "${cycle}",
                    style: headingStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    ),
  );

}

customLine(){
  return Center(
    child: SizedBox(
        width: 50,
        child: Divider(
          thickness: 3,
        )),
  );
}
