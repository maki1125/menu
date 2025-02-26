import 'package:flutter/material.dart';
//import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:menu/login/data/repository/messaging_api.dart';

class AddLineFriend extends StatelessWidget {
  const AddLineFriend({super.key});

  final String qrCodeUrl = 'https://qr-official.line.me/sid/L/896hhpmv.png';
  final String lineUrl = 'https://line.me/R/ti/p/%40sample';

  void openLineUrl() async {
    final Uri uri = Uri.parse(lineUrl); // URLを解析
    if (await canLaunchUrl(uri)) {
      // URLを開けるか確認
      await launchUrl(uri,
          mode: LaunchMode.externalApplication); // URLを開く mode: 外部アプリを使用して開く
    } else {
      throw 'Could not launch $uri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('QRコードをスキャンして友達追加してね！',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Image.network(qrCodeUrl, width: 200, height: 200),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: openLineUrl,
              child: const Text('友達追加する', style: TextStyle(fontSize: 20)),
            ),
            ElevatedButton(
              onPressed: () => sendMessageToLine('メッセージを見た？'),
              child: const Text('送信する', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
