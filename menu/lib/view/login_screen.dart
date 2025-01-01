import 'package:flutter/material.dart';
//import 'package:firebase_auth/firebase_auth.dart';
//import 'data/repository/o_user_repository.dart';
import 'package:menu/data/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:menu/view_model/login_screen_view_model.dart';

class UserAuthentication extends ConsumerWidget {
  //final AuthService _auth;
  UserAuthentication({super.key});
  //: _auth = AuthService(FirebaseAuth.instance);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final authService = ref.read(authServiceProvider);
    final authState = ref.watch(authStateChangesProvider);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            authState.when(
              // 匿名の場合はアイコンを表示
              data: (user) => user?.isAnonymous == true
                  ? Icon(
                      Icons.account_circle,
                      size: 32,
                    )
                  : SizedBox.shrink(),
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
                  await authService.signInEmailAndPassword(context,
                      emailController.text, passwordController.text, ref);
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
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
                  await authService.singUpEmailAndPassword(context,
                      emailController.text, passwordController.text, ref);
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Text('新規登録'),
              ),
            ),
            Divider(
              height: 40,
              thickness: 0.5,
              indent: 50,
              endIndent: 50,
              color: Colors.black,
            ),
            SignInButton(
              Buttons.Google,
              onPressed: () async {
                await authService.signInWithGoogle(context, ref);
              },
            ),
            authState.when(
              data: (user) {
                if (user != null) {
                  return ElevatedButton(
                    onPressed: () async {
                      await authService.signOut();
                    },
                    child: Text('ログアウト'),
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
