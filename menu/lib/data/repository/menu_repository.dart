import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:menu/data/model/menu.dart';
import 'package:menu/data/model/user.dart';

class MenuRepository {
  
  MenuRepository(this.user);
  final User user;

  //データ取得
  //Stream<QuerySnapshot> getMenuList(){
  //Stream<List<DocumentChange>> getMenuList(){
  Stream<List<Menu>> getMenuList(){
    return FirebaseFirestore.instance
    .collection('users/${user.uid}/menus')
    .orderBy('createAt', descending: true)
    .snapshots()
    //.map((snapshot) => snapshot.docChanges)
    .map(_queryToMenuList);
  }

  //データ追加
  Future<void> addMenu(Menu menu) async{
    FirebaseFirestore.instance
    .collection('users/${user.uid}/menus')
    .add(_menuToMap(menu));
  }

  //データ削除
  Future<void> deleteMenu(Menu menu) async{
    FirebaseFirestore.instance
    .collection('users/${user.uid}/menus')
    .doc(menu.id)
    .delete();
  }

  //データ編集
  Future<void> editMenu(Menu menu) async{
    FirebaseFirestore.instance
    .collection('users/${user.uid}/menus')
    .doc(menu.id)
    .update(_menuToMap(menu));
  }

  List<Menu> _queryToMenuList(QuerySnapshot query){
    return query.docs.map((doc){
      return Menu(
        createAt: (doc.get('createAt') as Timestamp).toDate(),
        name: doc.get('name'),
        id: doc.id,
      );
    }).toList();
  }

  Map<String, dynamic> _menuToMap(Menu menu){
    return{
      'createAt': menu.createAt,
      'name': menu.name,
      'id': menu.id,
    };
  }

}