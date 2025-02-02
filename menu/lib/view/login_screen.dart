import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
//import 'package:firebase_auth/firebase_auth.dart';
//import 'data/repository/o_user_repository.dart';
//import 'package:menu/data/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:menu/view_model/login_screen_view_model.dart';
import 'package:menu/common/common_providers.dart';
import 'package:menu/view/login_forgotpassword_screen.dart';
import 'package:menu/view/main_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:menu/view_model/menu_list_view_model.dart';
import 'package:menu/view_model/material_list_view_model.dart';
import 'package:menu/view_model/dinner_list_view_model.dart';
import 'package:menu/data/repository/menu_repository.dart';
import 'package:menu/data/repository/material_repository.dart';
import 'package:menu/data/repository/dinner_repository.dart';


class UserAuthentication extends ConsumerStatefulWidget {
  UserAuthentication({super.key});

  @override
  _UserAuthentication createState() => _UserAuthentication();
}

class _UserAuthentication extends ConsumerState<UserAuthentication>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;//ログインと新規登録

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this); // タブコントローラーの初期化
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose(); // メモリリークを防ぐために破棄
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // ビルド後にmenuRepositoryインスタンスをリセット
        WidgetsBinding.instance.addPostFrameCallback((_) async{
          MenuRepository.resetInstance(); // インスタンスのリセット
          MaterialRepository.resetInstance(); // インスタンスのリセット
          DinnerRepository.resetInstance(); // インスタンスのリセット
          final refreshedMenu = await ref.refresh(menuListProvider.future);
          final refreshedMaterial = await ref.refresh(materialListProvider.future); 
          final refreshedDinner = await ref.refresh(dinnerListProvider.future);  
          print("refresh:${refreshedMenu}");
          
        });

    final emailController = TextEditingController(); // メールアドレス入力用
    final passwordController = TextEditingController(); // パスワード入力用
    final authService = ref.read(authServiceProvider); // 認証サービス取得
    final authState = ref.watch(authStateChangesProvider); // 認証状態

    return Material(
      
      child: authState.when(
        data: (user) {
          FirebaseAuth.instance.currentUser?.reload();//Googleログイン後もisSnnoymousがtrueのままのため、再取得によりfalseにするため。
          final user = FirebaseAuth.instance.currentUser;
          
          if(user == null){//ログアウト後の匿名ログインもしていない状態
            print("nullです。");
            return _buildAnonymousView(//ログイン前の画面
                context, authService, emailController, passwordController, ref);
          }
          if (user?.isAnonymous == false) {//認証ログイン
            print("Googleログイン後です.${user!.uid}");
            return _buildLoggedInView(//ログイン後の画面
              context, user, authService);
          } else {//匿名ログイン
            
            print("Googleログイン前です.${user!.uid}");
            return _buildAnonymousView(//ログイン前の画面
                context, authService, emailController, passwordController, ref);
          }
        },
        loading: () => const CircularProgressIndicator(),
        error: (error, stackTrace) => const Text('error'),
      ),
    );
  }

 //ログイン後の画面
  Widget _buildLoggedInView(context, user, authService) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          user.photoURL != null
            ? CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(user.photoURL),
                radius: 32,
              )
            : const Icon(Icons.account_circle, size: 64),
          const SizedBox(height: 20),
          const Text('こんにちは'),
          Text("${FirebaseAuth.instance.currentUser!.email}"),//アドレス表示
          const SizedBox(height: 20),
          IconButton(//ログアウトボタン
            onPressed: () async {
              await authService.signOut();
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
    );
  }

 //ログイン前の画面
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

  // ログインタブの画面
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
              ref.read(sendPasswordResetEmailProvider.notifier).state = false; // メール送信状態をリセット
              //パスワードリセット画面
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ForgotPasswordPage()));
            },
            child: const Text('パスワードを忘れた場合はこちら'),
          ),
        ),
        const SizedBox(height: 50),

        //ログインボタン
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

        // 区切り線
        const Divider(
          height: 40,
          thickness: 0.5,
          indent: 50,
          endIndent: 50,
          color: Colors.black,
        ),

        // Googleログインボタン
        SignInButton(
          Buttons.Google,
          onPressed: () async {
            await authService.signInWithGoogle(
                context, ref); 
            setState(() { });
          },
        ),
      ],
    );
  }

  // 新規登録タブの画面
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

        //メールアドレス入力エリア
        _buildTextField(
          labelText: 'メールアドレス',
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),

        //パスワードの入力エリア
        _buildTextField(
          labelText: 'パスワード',
          controller: passwordController,
          obscureText: true,
        ),
        const SizedBox(height: 50),

        //新規登録ボタン
        SizedBox(
          width: 300,
          child: OutlinedButton(
            onPressed: () async {
              await authService.singUpEmailAndPassword(
                  context, 
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

//アプリ立ち上げ時の匿名ログイン画面（画面表示はなく匿名処理完了後はメインページが表示される）
class SignInAnony extends ConsumerStatefulWidget {
  // 匿名ログイン
  const SignInAnony({super.key});

  @override
  ConsumerState<SignInAnony> createState() => _SignInAnony();
}

class _SignInAnony extends ConsumerState<SignInAnony> {

  // 匿名ログイン処理
  Future<void> _signInAnonymously() async {
    try {
      await ref.read(authServiceProvider).signInAnony();// 匿名ログイン処理を呼び出し
    } catch (e) {
      debugPrint('Anonymous sign-in failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // ユーザー情報を取得
      builder: (context, snapshot) {

        // ビルド後にmenuRepositoryインスタンスをリセット
        WidgetsBinding.instance.addPostFrameCallback((_) async{
          MenuRepository.resetInstance(); // インスタンスのリセット
          final refreshedMenu = await ref.refresh(menuListProvider.future); 
          print("refresh:${refreshedMenu}");
          
        });

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator()); // ローディング中のウィジェット
        }
        if (snapshot.hasData) {
          final user = snapshot.data;
          if (user?.isAnonymous ?? false) {
            print("匿名ユーザーです");
            print(user!.uid);
            // 匿名ログイン中の場合の処理を記述
          } else {
            print("通常ユーザーです");
            print(user!.uid);
            // 通常のログイン状態の処理を記述
          }

          // MainPage に遷移
          return MainPage();
        }
        _signInAnonymously(); // 匿名ログイン処理を呼び出し
        return MainPage();
      },
    );
  }
}
