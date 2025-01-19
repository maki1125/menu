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
    print("menu.price");
    //print(menu.price);
    if(menu.price == null && menu.material!.isNotEmpty){
      print("price計算します。");
      print(menu.material![0]['price'].toString()+"_"+menu.material![0]['quantity'].toString());
      menu.price = menu.material!.fold(0, (materialSum, material) {
        //print(material['price']+"_"+material['quantity']);
        //return materialSum! + (material['price'] as int) * (material['quantity'] as int);
        return materialSum! + (material['price'] as int); 
        });
      menu.unitPrice = menu.price! ~/ menu.quantity!;
      
    }
    print("menu_add");
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

  //データ編集(ID指定)
  Future<void> editMenuIdDinnerDate(String menuId) async{

    //ドキュメント取得
    final docSnapshot = await FirebaseFirestore.instance
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
      FirebaseFirestore.instance
      .collection('users/${user.uid}/menus')
      .doc(menuId)
      .update(_menuToMap(menu));
      print("データ更新しました。");


      print("Menu name: ${menu.name}");
    } else {
      print("Menu document does not exist.");
    }

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
      'dinnerDateBuf': menu.dinnerDateBuf,
      'price': menu.price,
      'unitPrice': menu.unitPrice,
    };
  }


}