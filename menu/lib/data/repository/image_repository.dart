import 'dart:io';

//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:menu/data/model/menu.dart';
import 'package:menu/data/model/user.dart';
import 'package:file_picker/file_picker.dart';
import 'package:menu/data/repository/menu_repository.dart';

class ImageRepository {
  
  ImageRepository(this.user, this.menu);
  final UserModel user;
  final Menu menu;


  //画像追加
  Future<void> addImage() async{
    //画像ファイル選択
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if(result != null){
      final int timestamp = DateTime.now().microsecondsSinceEpoch; //735496096789000
      final File file = File(result.files.single.path!); //選択したファイルパスの取得.'/Users/maki/Library/Developer/CoreSimulator/Devices/D3DA9B85-B1E2-44EB-BB5C-C04B9B3328A0/data/Containers/Data/Application/CBC9AFE6-6064-4375-AB03-12608EDF94D4/tmp/IMG_0111.jpeg'
      final String name = file.path.split('/').last;
      final String filename = '${timestamp}_$name';
      final TaskSnapshot task = await FirebaseStorage.instance
        .ref()
        .child('users/${user.uid}/images')
        .child(filename)
        .putFile(file);
      final String imageURL = await task.ref.getDownloadURL();
      final String imagePath = task.ref.fullPath;// 画像削除時に使用。users/AC3iWb7RnqM4gCmeLOD9/images/1735480514815890_IMG_0111.jpeg
      menu.imageURL = imageURL;
      menu.imagePath = imagePath;
      MenuRepository(user).editMenu(menu);
    }
  }

  //画像削除
  Future<void> deleteImage() async{
     FirebaseStorage.instance
      .ref(menu.imagePath)
      .delete();
  }

}