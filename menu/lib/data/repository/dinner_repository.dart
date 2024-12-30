import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_storage/firebase_storage.dart';
//import 'package:menu/data/model/menu.dart';
import 'package:menu/data/model/user.dart';
import 'package:menu/data/model/dinner.dart';

class DinnerRepository {
  
  DinnerRepository(this.user);
  final UserModel user;

  //データ取得
  //Stream<QuerySnapshot> getMenuList(){
  //Stream<List<DocumentChange>> getMenuList(){
  Stream<List<Dinner>> getDinnerList(){
    return FirebaseFirestore.instance
    .collection('users/${user.uid}/dinners')
    .orderBy('createAt', descending: true)
    .snapshots()
    //.map((snapshot) => snapshot.docChanges)
    //.map(_queryToDinnerList);
    .map((snapshot) => snapshot.docs
          .map((doc) => Dinner.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList());
  }

  //データ追加
  Future<void> addDinner(Dinner dinner) async{
    DocumentReference docRef = await FirebaseFirestore.instance
    .collection('users/${user.uid}/dinners')
    .add(_dinnerToMap(dinner));

    await docRef.update({'id': docRef.id});//ドキュメントIDをid要素に保存
  }

  //データ削除
  Future<void> deleteDinner(Dinner dinner) async{
    FirebaseFirestore.instance
    .collection('users/${user.uid}/dinners')
    .doc(dinner.id)
    .delete();
  }

  //データ編集
  Future<void> editDinner(Dinner dinner) async{
    
    FirebaseFirestore.instance
    .collection('users/${user.uid}/dinners')
    .doc(dinner.id)
    .update(_dinnerToMap(dinner));
    
  }

  List<Dinner> _queryToDinnerList(QuerySnapshot query){
    return query.docs.map((doc){
      return Dinner(
        createAt: (doc.get('createAt') as Timestamp).toDate(),
        select: doc.get('select'),
        price: doc.get('price'),
        id: doc.id,
      );
    }).toList();
  }

  Map<String, dynamic> _dinnerToMap(Dinner dinner){
    return{
      'createAt': dinner.createAt,
      'select': dinner.select,
      'price': dinner.price,
      'id': dinner.id,
    };
  }

}