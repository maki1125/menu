import 'package:cloud_firestore/cloud_firestore.dart';

class Dinner {
  DateTime? createAt;
  List<String>? select;
  int? price;
  String? id;

  //コンストラクタ。
  Dinner({
    this.createAt,
    this.select,
    this.price,
    this.id
  });

  

  //FirestoreからのデータからDinnerインスタンスを生成する
  factory Dinner.fromFirestore(Map<String, dynamic> data) {
    return Dinner(
      price: data['price'] as int,
      id: data['id'] as String? ?? '',
      select: (data['select'] as List<dynamic>?)
          ?.map((item) => item as String)
          .toList() ?? [], // nullの場合は空のリストを設定
      createAt: (data['createAt'] as Timestamp).toDate(),
    );
  }

}
