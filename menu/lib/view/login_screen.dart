import 'package:flutter/material.dart';
//import 'package:firebase_auth/firebase_auth.dart';
//import 'data/repository/o_user_repository.dart';
//import 'package:menu/data/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:menu/view_model/login_screen_view_model.dart';
//import 'package:menu/data/providers.dart';
import 'package:menu/common/common_providers.dart';
import 'package:menu/view/login_forgotpassword_screen.dart';
import 'package:menu/view/main_screen.dart';

class UserAuthentication extends ConsumerStatefulWidget {
  UserAuthentication({super.key});

  @override
  _UserAuthentication createState() => _UserAuthentication();
}

class _UserAuthentication extends ConsumerState<UserAuthentication>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this); // タブコントローラーの初期化

    // ウィジェットツリーがビルドされた後に状態を変更する
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 状態変更をここで行う
      ref.read(pageProvider.notifier).state = 0;
    });
  }

  @override
  void dispose() {
    _tabController.dispose(); // メモリリークを防ぐために破棄
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController(); // メールアドレス入力用
    final passwordController = TextEditingController(); // パスワード入力用
    final authService = ref.read(authServiceProvider); // 認証サービス取得
    final authState = ref.watch(authStateChangesProvider); // ユーザー情報取得

    return Material(
      child: authState.when(
        data: (user) {
          if (user?.isAnonymous == false) {
            //print('user: $user');
            return _buildLoggedInView(context, user, authService);
          } else {
            //print('user: $user');
            return _buildAnonymousView(
                context, authService, emailController, passwordController, ref);
          }
        },
        loading: () => const CircularProgressIndicator(),
        error: (error, stackTrace) => const Text('error'),
      ),
    );
  }

  Widget _buildLoggedInView(context, user, authService) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          user.photoURL != null
              ? CircleAvatar(
                  backgroundImage: NetworkImage(user.photoURL),
                  radius: 32,
                )
              : const Icon(Icons.account_circle, size: 64),
          const SizedBox(height: 20),
          const Text('こんにちは'),
          const SizedBox(height: 20),
          IconButton(
            onPressed: () async {
              await authService.signOut();
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
    );
  }

  Widget _buildAnonymousView(
      context, authService, emailController, passwordController, ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TabBar(controller: _tabController, tabs: const [
            Tab(text: 'ログイン'),
            Tab(text: '新規登録'),
          ]),
          const SizedBox(height: 20),
          Expanded(
            child: TabBarView(controller: _tabController, children: <Widget>[
              _buildLoginTab(context, emailController, passwordController,
                  authService, ref),
              _buildSignUpTab(context, emailController, passwordController,
                  authService, ref),
            ]),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // テキストフィールドの作成
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

  // ログインタブ
  Widget _buildLoginTab(
    BuildContext context,
    TextEditingController emailController,
    TextEditingController passwordController,
    authService,
    WidgetRef ref,
  ) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 5),
        _buildTextField(
          labelText: 'メールアドレス',
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          labelText: 'パスワード',
          controller: passwordController,
          obscureText: true, // パスワードを非表示
        ),
        SizedBox(
          width: 300,
          child: TextButton(
            onPressed: () {
              ref.read(sendPasswordResetEmailProvider.notifier).state =
                  false; // メール送信状態をリセット
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ForgotPasswordPage()));
            },
            child: const Text('パスワードを忘れた場合はこちら'),
          ),
        ),
        const SizedBox(height: 50),
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
              // ボタンのスタイル
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4), // 角丸
              ),
            ),
            child: const Text('ログイン'),
          ),
        ),
        const Divider(
          // 区切り線
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
      ],
    );
  }

  // 新規登録タブ
  Widget _buildSignUpTab(
    BuildContext context,
    TextEditingController emailController,
    TextEditingController passwordController,
    authService,
    WidgetRef ref,
  ) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 5),
        _buildTextField(
          labelText: 'メールアドレス',
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          labelText: 'パスワード',
          controller: passwordController,
          obscureText: true,
        ),
        const SizedBox(height: 50),
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
            child: const Text('新規登録'),
          ),
        ),
      ],
    );
  }
}
