import 'package:cloud_firestore/cloud_firestore.dart';

class MaterialModel {//flutter/material.dartと名前が被るため、MaterialModelとする。
  MaterialModel(
      {this.createAt,
      this.name,
      this.quantity,
      this.unit,
      this.price,
      this.id});

  DateTime? createAt;
  String? name;
  num? quantity;
  String? unit;
  int? price;
  String? id;

  //FirestoreからのデータからMaterialインスタンスを生成する
  factory MaterialModel.fromFirestore(Map<String, dynamic> data) {
    return MaterialModel(
      price: data['price'] as int? ?? 0,
      name: data['name'] as String? ?? '',
      quantity: data['quantity'] as num? ?? 1,
      unit: data['unit'] as String? ?? '',
      id: data['id'] as String? ?? 'noData',
      //createAt: (data['createAt'] as Timestamp).toDate(),
      createAt: (data['createAt'] is Timestamp)
        ? (data['createAt'] as Timestamp).toDate() // Timestampの場合はDateTimeに変換
        : data['createAt'] as DateTime? ?? DateTime.now(), // DateTimeの場合、そのまま使用
    );
  }

 //空かどうかを判定するメソッド
  bool isEmpty() {
    return (name == null || name!.isEmpty);
  }

  // toMap() の定義
  Map<String, dynamic> toMap() {
    return {
      'createAt': createAt,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'price': price,
      'id': id,
    };
  }
}
