import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_storage/firebase_storage.dart';
//import 'package:firebase_storage/firebase_storage.dart';
import 'package:menu/data/model/menu.dart';
import 'package:menu/data/model/user.dart';

class MenuRepository {
  
  MenuRepository(this.user);
  final UserModel user;

  //データ取得
  //Stream<QuerySnapshot> getMenuList(){
  //Stream<List<DocumentChange>> getMenuList(){
  Stream<List<Menu>> getMenuList(){
    return FirebaseFirestore.instance
    .collection('users/${user.uid}/menus')
    .orderBy('createAt', descending: true)
    .snapshots()
    //.map((snapshot) => snapshot.docChanges)
    //.map(_queryToMenuList);
    .map((snapshot) => snapshot.docs
          .map((doc) => Menu.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList());
  }

  //データ追加
  Future<void> addMenu(Menu menu) async{

    menu.price = menu.material!.fold(0, (materialSum, material) {
          return materialSum! + (material['price'] as int) * (material['quantity'] as int);});
    menu.unitPrice = menu.price! ~/ menu.quantity!;

    DocumentReference docRef = await FirebaseFirestore.instance
    .collection('users/${user.uid}/menus')
    .add(_menuToMap(menu));
   
    await docRef.update({'id': docRef.id}); // ドキュメントIDを追加
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

/*
  List<Menu> _queryToMenuList(QuerySnapshot query){
    return query.docs.map((doc){
      return Menu(
        createAt: (doc.get('createAt') as Timestamp).toDate(),
        name: doc.get('name'),
        id: doc.id,
      );
    }).toList();
  }
*/

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
      'price': menu.price,
      'unitPrice': menu.unitPrice,
    };
  }

}