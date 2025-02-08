import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:menu/material/data/model/material.dart';

class MaterialRepository {

  static MaterialRepository? _instance; //MenuReposistoryをシングルトンパターン（アプリ内で同一インスタンス）にする。
  final User user; //Firebaseのauthの型
  final db = FirebaseFirestore.instance;
  //List<MaterialModel> materialList = []; //
  List<Map<String, dynamic>> materialList = []; //
  int count = 0;

  //MaterialRepository(this.user);
  //final UserModel user;
  // プライベートコンストラクタ
  MaterialRepository._(this.user);

  // ファクトリコンストラクタ
  factory MaterialRepository() {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    _instance ??= MaterialRepository._(firebaseUser!); //??=はnullの場合、代入のいみ。
    
    // 既存インスタンスの `userId` が異なる場合
    if (_instance!.user.uid != firebaseUser!.uid) {
      throw Exception("MaterialRepository is already initialized with a different user.");
    }

    return _instance!;
  }

  // インスタンスをリセットするメソッド
  static void resetInstance() {
    _instance = null;
  }

  //データ取得
  //Stream<List<MaterialModel>> getMaterialList() {
  Stream<List<Map<String, dynamic>>> getMaterialList() {
    return FirebaseFirestore.instance
        .collection('users/${user.uid}/materials')
        .orderBy('name', descending: true)
        .snapshots()
        .map((snapshot){
          print("count:${count}");
          count += 1;

          // 変更された部分だけを取得
      for (final change in snapshot.docChanges) {
        final material = MaterialModel.fromFirestore(change.doc.data() as Map<String, dynamic>);
        
        switch (change.type) {
          //追加ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
          case DocumentChangeType.added:
            print("add_material:${material.id}");
            if ((material.id == "noData" && !materialList.any((m) => ( "noData"== material.id)))//データ追加された時にまだidがついていない場合がある。
              || !materialList.any((m) => (m["id"] == material.id))){//すでにリストにある場合は追加しない。初回に2回addしてしまうため。
              materialList.insert(0, material.toMap());
            }
            break;

          //修正（既存アイテムを更新）ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
          case DocumentChangeType.modified:
          print("modify_material:${material.id}");
            final index = materialList.indexWhere((m) => (m["id"] == material.id || m["id"] == "noData"));
            if (index != -1) {
              materialList[index] = material.toMap();
            }
            break;

          //削除ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
          case DocumentChangeType.removed:
            print("remove_material:${material.id}");
            materialList.removeWhere((m) => m["id"] == material.id);
            break;
        }
      }
      return materialList;

      }
    );
  }

  //データ追加
  Future<void> addMaterial(MaterialModel material) async {
    DocumentReference docRef = await db
        .collection('users/${user.uid}/materials')
        .add(_materialToMap(material));

    await docRef.update({'id': docRef.id}); //ドキュメントIDをid要素に保存
  }

  //データ削除
  Future<void> deleteMaterial(MaterialModel material) async {
    db
        .collection('users/${user.uid}/materials')
        .doc(material.id)
        .delete();
  }

  // データ更新
  Future<void> updateMaterial(MaterialModel material) async {
    print("データ更新します。");
    await db
        .collection('users/${user.uid}/materials')
        .doc(material.id)
        .update(_materialToMap(material));
  }

  Map<String, dynamic> _materialToMap(MaterialModel material) {
    return {
      'name': material.name,
      'quantity': material.quantity,
      'unit': material.unit,
      'price': material.price,
      //'id': user.uid,
      'createAt': DateTime.now(),
    };
  }
}
