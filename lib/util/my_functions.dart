import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class MyFunctions{

  static Future<List<String>> getAllFileNames() async {
    List<String> allFileName=[];
    var assets = await rootBundle.loadString('AssetManifest.json');
    Map jsonMap = json.decode(assets);
    List allNames = jsonMap.keys.where((element) => element.endsWith(".png")).toList();
    for(var name in allNames){
      String nameWithExtention=basename(name);
      if(name.toString().contains('companies/')) {
        allFileName.add(nameWithExtention.toString().replaceAll('.png', '').replaceAll('%20', ' '));
      }
    }
    //print("All images name are ${allFileName}");
    return allFileName;
  }


  static Future<File> getImageFileFromAssets(String path) async {
    await Permission.storage.request();
      final byteData = await rootBundle.load(path);
    final buffer = byteData.buffer;
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    var filePath = tempPath + '/${Timestamp.now()}.png'; // file_01.tmp is dump file, can be anything
    return  File(filePath).writeAsBytes(
        buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  }
}