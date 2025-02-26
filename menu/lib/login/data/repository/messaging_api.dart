// メッセージ送信APIの実装
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:menu/common/logger.dart';
import 'package:menu/login/data/model/linefriend.dart';

// LINEにメッセージを送信する関数
Future<void> sendMessageToLine(String message) async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final userIds = [];

  final accessToken =
      await LineSDK.instance.currentAccessToken; // LINEのアクセストークンを取得
  if (accessToken == null) {
    //throw Exception('LINEアクセストークンが取得できませんでした');
    LoggerService.info('LINEアクセストークンが取得できませんでした');
  }
  final url = Uri.parse(
      'https://api.line.me/v2/bot/message/push'); // LINEのメッセージ送信APIのURL
  final headers = <String, String>{
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $accessToken',
  };

  // FirestoreからLINEユーザーIDを取得
  // try {
  //   final snapshot = await _firestore
  //       .collection('lineUsers')
  //       .get(); // FirestoreからLINEユーザーIDを取得
  //   for (final doc in snapshot.docs) {
  //     final lineUser = LineFriendModel.fromFirestore(doc.data());
  //     userIds.add(lineUser.userId);
  //   }
  // } catch (e) {
  //   //throw Exception('Failed to get LINE user IDs');
  //   LoggerService.error('LINEユーザーIDの取得に失敗しました: $e');
  // }
  // 送信するメッセージの内容
  // for (final userId in userIds) {
  //   final body = <String, dynamic>{
  //     'to': userId, // 送信先のLINEユーザーID
  //     'messages': [
  //       {
  //         'type': 'text',
  //         'text': message,
  //       },
  //     ],
  //   };
  //   // LINEにメッセージを送信
  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: headers,
  //       body: body,
  //     );
  //     if (response.statusCode != 200) {
  //       //throw Exception('Failed to send message to LINE');
  //       LoggerService.info('Failed to send message to LINE');
  //     }
  //   } catch (e) {
  //     //throw Exception('Failed to send message to LINE');
  //     LoggerService.error('送信中にエラーが発生しました: $e');
  //   }
  // }

  // 送信テスト用
  final body = <String, dynamic>{
    'to': '送信先のLINEユーザーID', // 送信先のLINEユーザーID
    'messages': [
      {
        'type': 'text',
        'text': message,
      },
    ],
  };
  // LINEにメッセージを送信
  try {
    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );
    if (response.statusCode != 200) {
      //throw Exception('Failed to send message to LINE');
      LoggerService.info('Failed to send message to LINE');
    }
  } catch (e) {
    //throw Exception('Failed to send message to LINE');
    LoggerService.error('送信中にエラーが発生しました: $e');
  }
}
