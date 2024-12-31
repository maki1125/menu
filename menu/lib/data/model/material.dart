import 'package:cloud_firestore/cloud_firestore.dart';

class MaterialModel {
  MaterialModel(
      {this.createAt,
      this.name,
      this.quantity,
      this.unit,
      this.price,
      this.id});

  DateTime? createAt;
  String? name;
  int? quantity;
  String? unit;
  int? price;
  String? id;

  //FirestoreからのデータからMaterialインスタンスを生成する
  factory MaterialModel.fromFirestore(Map<String, dynamic> data) {
    return MaterialModel(
      price: data['price'] as int? ?? 0,
      name: data['name'] as String? ?? '',
      quantity: data['quantity'] as int? ?? 0,
      unit: data['unit'] as String? ?? '',
      id: data['id'] as String? ?? '',
      createAt: (data['createAt'] as Timestamp).toDate(),
    );
  }
}
