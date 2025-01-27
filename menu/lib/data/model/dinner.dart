import 'package:cloud_firestore/cloud_firestore.dart';

class Dinner {
  DateTime? createAt;
  List<String>? select;
  List<String>? selectID;//menuのIDを記録して、最近食べた日の更新時に使用。
  int? price;
  String? id;

  //コンストラクタ。
  Dinner({
    this.createAt,
    this.select,
    this.selectID,
    this.price,
    this.id
  });

  

  //FirestoreからのデータからDinnerインスタンスを生成する
  factory Dinner.fromFirestore(Map<String, dynamic> data) {
    return Dinner(
      price: data['price'] as int,
      id: data['id'] as String? ?? 'noData',
      select: (data['select'] as List<dynamic>?)
          ?.map((item) => item as String)
          .toList() ?? [], // nullの場合は空のリストを設定
      selectID: (data['selectID'] as List<dynamic>?)
          ?.map((item) => item as String)
          .toList() ?? [], // nullの場合は空のリストを設定
      createAt: (data['createAt'] as Timestamp).toDate(),
    );
  }

}
