import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:menu/dinner/data/model/dinner.dart';

class DinnerRepository {

  static DinnerRepository? _instance; //MenuReposistoryをシングルトンパターン（アプリ内で同一インスタンス）にする。
  final User user; //Firebaseのauthの型
  final db = FirebaseFirestore.instance;
  List<Dinner> dinnerList = []; //

  // プライベートコンストラクタ
  DinnerRepository._(this.user);

  // ファクトリコンストラクタ
  factory DinnerRepository() {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    _instance ??= DinnerRepository._(firebaseUser!); //??=はnullの場合、代入のいみ。
    
    // 既存インスタンスの `userId` が異なる場合
    if (_instance!.user.uid != firebaseUser!.uid) {
      throw Exception("DinnerRepository is already initialized with a different user.");
    }
    return _instance!;
  }

  // インスタンスをリセットするメソッド
  static void resetInstance() {
    _instance = null;
  }
  
  //DinnerRepository(this.user);
  //final UserModel user;
  int count = 0;

  //データ取得
  Stream<List<Dinner>> getDinnerList(){
    return db
    .collection('users/${user.uid}/dinners')
    .orderBy('createAt', descending: true)
    .snapshots()
    .map((snapshot){

      print("count:${count}");
      count += 1;

      // 変更された部分だけを取得
      for (final change in snapshot.docChanges) {
        final dinner = Dinner.fromFirestore(change.doc.data() as Map<String, dynamic>);
        
        switch (change.type) {
          //追加ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
          case DocumentChangeType.added:
            print("add:${dinner.id}");
            if ((dinner.id == "noData" && !dinnerList.any((m) => ( "noData"== dinner.id)))//データ追加された時にまだidがついていない場合がある。
              || !dinnerList.any((m) => (m.id == dinner.id))){//すでにリストにある場合は追加しない。初回に2回addしてしまうため。
              dinnerList.insert(0, dinner);
            }
            break;

          //修正（既存アイテムを更新）ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
          case DocumentChangeType.modified:
          print("modify:${dinner.id}");
            final index = dinnerList.indexWhere((m) => (m.id == dinner.id || m.id == "noData"));
            if (index != -1) {
              dinnerList[index] = dinner;
            }
            break;

          //削除ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
          case DocumentChangeType.removed:
          print("remove:${dinner.id}");
            dinnerList.removeWhere((m) => m.id == dinner.id);
            break;
        }
      }
      return dinnerList;
    
  });
  }

  //データ追加
  Future<void> addDinner(Dinner dinner) async{
    DocumentReference docRef = await db
    .collection('users/${user.uid}/dinners')
    .add(_dinnerToMap(dinner));

    await docRef.update({'id': docRef.id});//ドキュメントIDをid要素に保存
  }

  //データ削除
  Future<void> deleteDinner(Dinner dinner) async{
    await db
    .collection('users/${user.uid}/dinners')
    .doc(dinner.id)
    .delete();
  }

  //データ更新
  Future<void> editDinner(Dinner dinner) async{
    
    await db
    .collection('users/${user.uid}/dinners')
    .doc(dinner.id)
    .update(_dinnerToMap(dinner));
    
  }

  Map<String, dynamic> _dinnerToMap(Dinner dinner){
    return{
      'createAt': dinner.createAt,
      'select': dinner.select,
      'selectID': dinner.selectID,
      'price': dinner.price,
      'id': dinner.id,
    };
  }

}