import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:menu/data/repository/o_user_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menu/view_model/login_view_model.dart';

// パスワードリセット画面
class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          //title: const Text('パスワードリセット'),
          ),
      body: Consumer(
        builder: (context, ref, _) {
          final auth = ref.read(authServiceProvider); // 認証サービス取得
          final isEmailSent =
              ref.watch(sendPasswordResetEmailProvider); // メール送信状態取得
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: isEmailSent
                ? Center(
                    child: Column(
                      children: <Widget>[
                        // メール送信完了後に表示される画面
                        const SizedBox(height: 30),
                        const Text('パスワードリセット完了',
                            style: TextStyle(fontSize: 24)),
                        const SizedBox(height: 20),
                        const Text('パスワードリセットのリンクを送信しました。\nメールをご確認ください。',
                            textAlign: TextAlign.center),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('ログイン画面に戻る'),
                        ),
                      ],
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.start, // 縦方向で中央揃え
                    children: [
                      // メール送信前に表示される画面
                      const SizedBox(height: 30),
                      const Text('パスワードリセット', style: TextStyle(fontSize: 24)),
                      const SizedBox(height: 20),
                      const Text('登録したメールアドレスを入力してください。\nパスワードリセットのリンクが送信されます。',
                          textAlign: TextAlign.center),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'メールアドレス',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        // パスワードリセットリンクを送信
                        onPressed: () {
                          // メールアドレスのバリデーション
                          final email = _emailController.text.trim();
                          if (email.isEmpty ||
                              !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('有効なメールアドレスを入力してください')),
                            );
                            return;
                          }
                          auth.sendPasswordResetEmail(
                              context, _emailController.text, ref);
                          // メール送信状態を更新後に画面を再描画
                          ref
                              .read(sendPasswordResetEmailProvider.notifier)
                              .state = true;
                        },
                        child: const Text('リセットリンクを送信する'),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}
