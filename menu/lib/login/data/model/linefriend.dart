import 'package:cloud_firestore/cloud_firestore.dart';

class LineFriendModel {
  LineFriendModel({
    this.userId,
    this.timestamp,
  });

  String? userId;
  DateTime? timestamp;

// FirestoreからのデータからMaterialインスタンスを生成する
  factory LineFriendModel.fromFirestore(Map<String, dynamic> data) {
    return LineFriendModel(
      userId: data['userId'] as String? ?? '',
      timestamp: (data['timestamp'] is Timestamp)
          ? (data['timestamp'] as Timestamp)
              .toDate() // Timestampの場合はDateTimeに変換
          : data['timestamp'] as DateTime? ??
              DateTime.now(), // DateTimeの場合、そのまま使用
    );
  }

// 空かどうかを判定するメソッド
  bool isEmpty() {
    return (userId == null || userId!.isEmpty);
  }

// toMap() の定義
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'timestamp': timestamp,
    };
  }
}
