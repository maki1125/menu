import 'dart:io'; //Fileを扱うため
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image/image.dart' as img; //画像のリサイズ
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:menu/menu/data/model/menu.dart';
import 'package:menu/menu/data/repository/menu_repository.dart';
import 'package:menu/menu/view_model/menu_view_model.dart';


class ImageRepository {
  final User user;
  final Menu menu;
  final WidgetRef ref;

  ImageRepository(this.user, this.menu, this.ref);
  
  //画像選択
  Future<void> selectImage() async{
    //画像ファイル選択
    //final FilePickerResult? result = await FilePicker.platform.pickFiles(//ファイル選択のメソッド
      //type: FileType.image,
    //);
    final XFile? result = await ImagePicker().pickImage(
      source: ImageSource.gallery, // ギャラリーから画像を選択
    );

    if(result != null){
      //final int timestamp = DateTime.now().microsecondsSinceEpoch; //735496096789000
      final File file = File(result.path); //選択したファイルパスの取得.'/Users/maki/Library/Developer/CoreSimulator/Devices/D3DA9B85-B1E2-44EB-BB5C-C04B9B3328A0/data/Containers/Data/Application/CBC9AFE6-6064-4375-AB03-12608EDF94D4/tmp/IMG_0111.jpeg'
      final bytes = await file.readAsBytes();
      final originalImage = img.decodeImage(bytes);
      final resizedImage = img.copyResize(originalImage!,height: 200);//高さ基準でリサイズ。画像が切れる可能性あり。
      final resizedBytes = img.encodeJpg(resizedImage);
      final resizedFile = File('${Directory.systemTemp.path}/resized_image.jpg'); //一時ファイルに保存。アプリ終了後は消える。
      print("resizedFileを準備しました。${file.parent.path}");
      await resizedFile.writeAsBytes(resizedBytes);
      print("データ保存しました。");
      ref.read(selectedImageProvider.notifier).state = resizedFile;//resizedFile;//file;  // Riverpodで状態管理
      //file!.delete(); //一時ファイルに保存したデータを削除する。
    }
  }

  //画像を保存するときに一緒にデータも保存する。
  Future<void> addImage() async{
    final File? file = ref.read(selectedImageProvider);  // Riverpodで値取得
    if(file != null){
    final int timestamp = DateTime.now().microsecondsSinceEpoch; //735496096789000
    final String name = file!.path.split('/').last;
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
    file!.delete(); //一時ファイルに保存したデータを削除する。
    }
    MenuRepository().addMenu(menu);
    print(menu.imageURL);
    ref.read(selectedImageProvider.notifier).state = null;
    
  }

    //画像を保存するときに一緒にデータも保存する。
  Future<void> editImage() async{
    final File? file = ref.read(selectedImageProvider);  // Riverpodで値取得
    if(file != null){
    final int timestamp = DateTime.now().microsecondsSinceEpoch; //735496096789000
    final String name = file!.path.split('/').last;
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
    }
    MenuRepository().updateMenu(menu);
    print(menu.imageURL);
    ref.read(selectedImageProvider.notifier).state = null;
  }


  //画像削除
  Future<void> deleteImage() async{
    if(menu.imagePath != "noData"){
     FirebaseStorage.instance
      .ref(menu.imagePath)
      .delete();
    }
  }

}