import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import 'package:menu/menu/data/model/menu.dart';

class MenuRepository {

  static MenuRepository? _instance; //MenuReposistoryをシングルトンパターン（アプリ内で同一インスタンス）にする。
  final User user; //Firebaseのauthの型
  final db = FirebaseFirestore.instance;
  List<Menu> menuList = []; //

  // プライベートコンストラクタ
  MenuRepository._(this.user);

  // ファクトリコンストラクタ
  factory MenuRepository() {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if(firebaseUser != null){
      _instance ??= MenuRepository._(firebaseUser!); //??=はnullの場合、代入のいみ。
      // 既存インスタンスの `userId` が異なる場合
    if (_instance!.user.uid != firebaseUser!.uid) {
      throw Exception("MenuRepository is already initialized with a different user.");
    }
    }
    return _instance!;
  }

  // インスタンスをリセットするメソッド
  static void resetInstance() {
    _instance = null;
  }
  
  //データ取得
  Stream<List<Menu>> getMenuList(){

    return db
    .collection('users/${user.uid}/menus')
    .orderBy('createAt', descending: false)
    .snapshots()
    .map((snapshot) {

      // 変更された部分だけを取得
      for (final change in snapshot.docChanges) {
        final menu = Menu.fromFirestore(change.doc.data() as Map<String, dynamic>);
        
        switch (change.type) {
          //追加ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
          case DocumentChangeType.added:
            if ((menu.id == "noData" && !menuList.any((m) => ( "noData"== menu.id)))//データ追加された時にまだidがついていない場合がある。
              || !menuList.any((m) => (m.id == menu.id))){//すでにリストにある場合は追加しない。初回に2回addしてしまうため。
              menuList.insert(0, menu);
            }
            break;

          //修正（既存アイテムを更新）ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
          case DocumentChangeType.modified:
            final index = menuList.indexWhere((m) => (m.id == menu.id || m.id == "noData"));
            if (index != -1) {
              menuList[index] = menu;
            }
            break;

          //削除ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
          case DocumentChangeType.removed:
            menuList.removeWhere((m) => m.id == menu.id);
            break;
        }
      }
      return menuList;
    });   
  }

  //データ追加
  Future<void> addMenu(Menu menu) async{

    //1人前の値段(unitPrice)の計算
    if(menu.price == null && menu.material!.isNotEmpty){

      //材料の値段を足し合わせてメニューの値段を計算
      menu.price = menu.material!.fold(0, (materialSum, material) {
        return materialSum! + (material['price'] as int); 
      });

      //メニューの値段を何人前で割って何人前を計算
      menu.unitPrice = menu.price! ~/ menu.quantity!;
    }

    DocumentReference docRef = await db
    .collection('users/${user.uid}/menus')
    .add(_menuToMap(menu));
    await docRef.update({'id': docRef.id}); // ドキュメントIDを追加

  }

  //データ削除
  Future<void> deleteMenu(Menu menu) async{
    await db
    .collection('users/${user.uid}/menus')
    .doc(menu.id)
    .delete();
  }

  //データ更新
  Future<void> updateMenu(Menu menu) async{
    await db
    .collection('users/${user.uid}/menus')
    .doc(menu.id)
    .update(_menuToMap(menu));
  }

  //データ編集(ID指定)
  Future<void> updateMenuIdDinnerDate(String menuId) async{

    //ドキュメント取得
    final docSnapshot = await db
    .collection('users/${user.uid}/menus')
    .doc(menuId) // メニューのIDを指定
    .get();

    if (docSnapshot.exists) {
      //Menuに変換
      final menuData = docSnapshot.data() as Map<String, dynamic>;
      print(menuData["dinnerDateBuf"].toDate());
      final menu = Menu.fromFirestore(menuData);

      //バッファに戻す
      print(menu.dinnerDateBuf);
      menu.dinnerDate = menu.dinnerDateBuf; 

      //データ更新
      db
      .collection('users/${user.uid}/menus')
      .doc(menuId)
      .update(_menuToMap(menu));

      print("Menu name: ${menu.name}");
    } else {
      print("Menu document does not exist.");
    }
  }

//menu型をfirebaseで保存するための型に変換
  Map<String, dynamic> _menuToMap(Menu menu){
    return{
      'createAt': menu.createAt,
      'name': menu.name,
      'imageURL': menu.imageURL,
      'imagePath': menu.imagePath,
      'quantity': menu.quantity,
      'tag': menu.tag,
      'material': menu.material,
      'howToMake': menu.howToMake,
      'memo': menu.memo,
      'isFavorite': menu.isFavorite,
      'isDinner': menu.isDinner,
      'id': menu.id,
      'dinnerDate': menu.dinnerDate,
      'dinnerDateBuf': menu.dinnerDateBuf,
      'price': menu.price,
      'unitPrice': menu.unitPrice,
    };
  }
}