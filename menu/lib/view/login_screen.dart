import 'package:flutter/material.dart';
//import 'package:firebase_auth/firebase_auth.dart';
//import 'data/repository/o_user_repository.dart';
//import 'package:menu/data/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:menu/view_model/login_screen_view_model.dart';
import 'package:menu/data/providers.dart';
import 'package:menu/common/common_constants.dart';
import 'package:menu/common/common_providers.dart';

class UserAuthentication extends ConsumerStatefulWidget {
  UserAuthentication({super.key});

  @override
  _UserAuthentication createState() => _UserAuthentication();
}

class _UserAuthentication extends ConsumerState<UserAuthentication> {
  @override
  void initState() {
    super.initState();

    // ウィジェットツリーがビルドされた後に状態を変更する
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 状態変更をここで行う
      ref.read(pageProvider.notifier).state = initOtherPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController(); // メールアドレス入力用
    final passwordController = TextEditingController(); // パスワード入力用
    final authService = ref.read(authServiceProvider); // 認証サービス取得
    final authState = ref.watch(authStateChangesProvider); // ユーザー情報取得

    return Material(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            authState.when(
              data: (user) {
                if (user != null && user.photoURL != null) {
                  // ユーザーが存在し、写真URLがある場合
                  return CircleAvatar(
                    backgroundImage: NetworkImage(user.photoURL!), // 写真URLを表示
                    radius: 32,
                  );
                } else {
                  return Icon(Icons.account_circle,
                      size: 64); // ユーザーが存在しない場合はアイコンを表示
                }
              },
              // // 匿名の場合はアイコンを表示
              // data: (user) => user?.isAnonymous == true
              //     ? Icon(
              //         Icons.account_circle,
              //         size: 64,
              //       )
              //     : SizedBox.shrink(),
              loading: () => CircularProgressIndicator(),
              error: (error, stackTrace) => Text('error'),
            ),
            SizedBox(height: 40),
            _buildTextField(
              labelText: 'メールアドレス',
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            _buildTextField(
              labelText: 'パスワード',
              controller: passwordController,
              obscureText: true,
            ),
            SizedBox(height: 50),
            SizedBox(
              width: 300,
              child: FilledButton(
                onPressed: () async {
                  await authService.signInEmailAndPassword(
                      context, // メールアドレスとパスワードでログイン
                      emailController.text,
                      passwordController.text,
                      ref);
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4), // 角丸
                  ),
                ),
                child: Text('ログイン'),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: 300,
              child: OutlinedButton(
                onPressed: () async {
                  await authService.singUpEmailAndPassword(
                      context, // メールアドレスとパスワードで新規登録
                      emailController.text,
                      passwordController.text,
                      ref);
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Text('新規登録'),
              ),
            ),
            const Divider(
              height: 40,
              thickness: 0.5,
              indent: 50,
              endIndent: 50,
              color: Colors.black,
            ),
            SignInButton(
              Buttons.Google,
              onPressed: () async {
                await authService.signInWithGoogle(
                    context, ref); // Googleアカウントでログイン
              },
            ),
            SizedBox(height: 40),
            authState.when(
              data: (user) {
                if (user != null) {
                  return IconButton(
                    onPressed: () async {
                      await authService.signOut(); // ログアウト
                    },
                    icon: const Icon(Icons.logout),
                  );
                } else {
                  return Container();
                }
              },
              loading: () => CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    // テキストフィールドの作成
    required String labelText,
    required TextEditingController controller,
    bool obscureText = false, // 表示、非表示を切り替える
    TextInputType keyboardType = TextInputType.text,
  }) {
    return SizedBox(
      width: 300,
      child: TextField(
        controller: controller,
        obscureText: obscureText, // パスワードの表示切り替え
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
