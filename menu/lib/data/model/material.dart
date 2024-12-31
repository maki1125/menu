import 'package:cloud_firestore/cloud_firestore.dart';

class Material {
  Material(
      {this.createAt, this.name, this.num, this.unit, this.price, this.id});

  DateTime? createAt;
  String? name;
  int? num;
  String? unit;
  int? price;
  String? id;

  //FirestoreからのデータからMaterialインスタンスを生成する
  factory Material.fromFirestore(Map<String, dynamic> data) {
    return Material(
      price: data['price'] as int? ?? 0,
      name: data['name'] as String? ?? '',
      num: data['num'] as int? ?? 0,
      unit: data['unit'] as String? ?? '',
      id: data['id'] as String? ?? '',
      createAt: (data['createAt'] as Timestamp).toDate(),
    );
  }
}
