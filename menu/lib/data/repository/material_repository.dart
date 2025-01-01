import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:menu/data/model/material.dart';
import 'package:menu/data/model/user.dart';

class MaterialRepository {
  MaterialRepository(this.user);
  final UserModel user;

  //データ取得
  Stream<List<MaterialModel>> getMaterialList() {
    return FirebaseFirestore.instance
        .collection('users/${user.uid}/materials')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) =>
            //Material.fromFirestore(doc.data() as Map<String, dynamic>))
            MaterialModel.fromFirestore(doc.data())).toList());
  }

  //データ追加
  Future<void> addMaterial(MaterialModel material) async {
    DocumentReference docRef = await FirebaseFirestore.instance
        .collection('users/${user.uid}/materials')
        .add(_materialToMap(material));

    await docRef.update({'id': docRef.id}); //ドキュメントIDをid要素に保存
  }

  //データ削除
  Future<void> deleteMaterial(MaterialModel material) async {
    FirebaseFirestore.instance
        .collection('users/${user.uid}/materials')
        .doc(material.id)
        .delete();
  }

  // データ更新
  Future<void> updateMaterial(MaterialModel material) async {
    await FirebaseFirestore.instance
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
