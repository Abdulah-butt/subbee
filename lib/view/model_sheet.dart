import 'package:code/constant/screen_size.dart';
import 'package:code/util/assets_path.dart';
import 'package:code/util/my_functions.dart';
import 'package:code/util/routes.dart';
import 'package:code/util/style.dart';
import 'package:code/view/add_subscription_screen.dart';
import 'package:code/widgets/custom_widgets.dart';
import 'package:flutter/material.dart';

class ModelSheet extends StatefulWidget {
  const ModelSheet({Key? key}) : super(key: key);

  @override
  _ModelSheetState createState() => _ModelSheetState();
}

class _ModelSheetState extends State<ModelSheet> {
  final txtSearch=TextEditingController();
  List<String> logos=[];
  List<String> tempLogos=[];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      height: 450.0,
      color: Colors.transparent, //could change this to Color(0xFF737373),
      //so you don't have to change MaterialApp canvasColor
      child: Container(
          decoration:  const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0))),
          child:  Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: [
                SizedBox(
                    width: ScreenSize.width!*0.4,
                    child: Divider(thickness: 3,)),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text("New Subscription",style: headingStyle(fontWeight: FontWeight.bold),)),
                customTextField(hint: "Search",controller:txtSearch,iconPath: AssetPath.searchIcon,onValueChange:(){
                  setState(() {

                  });
                }),
                SizedBox(
                  height: 300,
                  child: FutureBuilder<List<String>>(
                    future: MyFunctions.getAllFileNames(),
                    builder: (context,logos) {
                      if(!logos.hasData){
                        return Center(child: const CircularProgressIndicator(),);
                      }
                      var allDocs=logos.data;
                      tempLogos.clear();
                      for(var doc in allDocs!){
                        if(txtSearch.text.isEmpty) {
                          tempLogos.add(doc);
                        }else{
                          if(doc.toLowerCase().startsWith(txtSearch.text.toLowerCase())){
                            tempLogos.add(doc);
                          }
                        }
                      }
                      return ListView.builder(
                        itemCount:tempLogos.length,
                        itemBuilder: (context,index){
                          return Card(
                            child:ListTile(
                              onTap: (){
                                Navigator.push(context,MaterialPageRoute(
                                        builder: (context) => AddSubscriptionScreen(imgAssetPath: 'assets/companies/${tempLogos[index]}.png',title:tempLogos[index],)
                                    )
                                );
                              },
                              leading: Image.asset('assets/companies/${tempLogos[index]}.png',height: 30,width: 30,),
                              title: Text(tempLogos[index]),
                              trailing: Icon(Icons.add),
                            )
                          );
                        },
                      );
                    }
                  ),
                )
              ],
            ),
          )
      ),
    );
  }
}
