import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menu/view_model/login_screen_view_model.dart';
import 'package:menu/common/common_widget.dart';
import 'package:menu/view/main_screen.dart';
import 'package:menu/view_model/menu_list_view_model.dart';
import 'package:menu/data/repository/menu_repository.dart';



// 認証サービス
class AuthService {

  final FirebaseAuth _auth  = FirebaseAuth.instance; 
  late String errorMessage = ''; // エラーメッセージ

  // サインイン（アドレス＋パスワード）
  Future<void> signInEmailAndPassword(
    BuildContext context, String email, String password, WidgetRef ref) async {
    try {
      ref.read(errorMessageProvider.notifier).state = ''; // エラーメッセージをクリア
      await _auth.signInWithEmailAndPassword(email: email, password: password); // サインイン処理
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('ログインしました'))); // メッセージ表示
        
        //メニュー一覧ページへ遷移
        resetPageChange(context, ref, 0, 0);
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found': errorMessage = AuthErrorMessages.userNotFound;
        case 'wrong-password': errorMessage = AuthErrorMessages.wrongPassword;
        case 'invalid-email': errorMessage = AuthErrorMessages.invalidEmail;
        case 'user-disabled': errorMessage = AuthErrorMessages.userDisabled;
        default: errorMessage = AuthErrorMessages.unknownError;
        debugPrint('その他；$e.code');
      }
      ref.read(errorMessageProvider.notifier).state = errorMessage; // エラーメッセージを更新
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessage))); // エラーメッセージを表示
      }
      rethrow;
    }
  }

  // サインアップ(新規登録　アドレス＋パスワード)
  Future<void> singUpEmailAndPassword(BuildContext context, String email,
      String password, WidgetRef ref) async {
    try {
      ref.read(errorMessageProvider.notifier).state = ''; // エラーメッセージをクリア
      // // サインアップ処理
      // UserCredential userCredential = await _auth
      //     .createUserWithEmailAndPassword(email: email, password: password);
      // if (_auth.currentUser == null ||
      //     !(_auth.currentUser?.isAnonymous ?? false)) {
      //   return;
      // }

      // メール認証情報を作成
      UserCredential? linkedUserCredential;
      if (_auth.currentUser?.isAnonymous ?? false) {
        AuthCredential credential =
            EmailAuthProvider.credential(email: email, password: password);

        // メール認証情報を匿名ユーザーにリンク
        linkedUserCredential =
            await _auth.currentUser!.linkWithCredential(credential);

        print('linkedUser: ${linkedUserCredential.user?.uid}');

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  "リンク成功: UID=${linkedUserCredential.user?.uid}, Email=${linkedUserCredential.user?.email}")));
        }
      }

      // 確認メール送信
      await linkedUserCredential?.user?.sendEmailVerification();
      if (context.mounted) {
        ScaffoldMessenger.of(context) // メッセージ表示
            .showSnackBar(const SnackBar(content: Text('確認メールを送信しました')));
      }
    } on FirebaseAuthException catch (e) {
      // エラーハンドリング
      switch (e.code) {
        case 'weak-password':
          errorMessage = AuthErrorMessages.weakPassword;
        case 'email-already-in-use':
          errorMessage = AuthErrorMessages.emailAlreadyInUse;
        case 'invalid-credential':
          errorMessage = AuthErrorMessages.invalidCredential;
        case 'requires-recent-login':
          errorMessage = AuthErrorMessages.requiresRecentLogin;
        default:
          errorMessage = AuthErrorMessages.unknownError;
          debugPrint('その他：$e.code');
      }
      ref.read(errorMessageProvider.notifier).state =
          errorMessage; // エラーメッセージを更新
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessage)));
      }
      rethrow;
    }
  }

  // パスワードリセット
  Future<void> sendPasswordResetEmail(
      BuildContext context, String email, WidgetRef ref) async {
    try {
      _auth.setLanguageCode('ja'); // 言語設定
      ref.read(errorMessageProvider.notifier).state = ''; // エラーメッセージをクリア
      await _auth.sendPasswordResetEmail(email: email); // パスワードリセット
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('パスワードリセットメールを送信しました')));
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          errorMessage = AuthErrorMessages.invalidEmail;
        case 'user-not-found':
          errorMessage = AuthErrorMessages.userNotFound;
        default:
          errorMessage = AuthErrorMessages.unknownError;
          debugPrint('その他：$e.code');
      }
      ref.read(errorMessageProvider.notifier).state =
          errorMessage; // エラーメッセージを更新
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessage)));
      }
      rethrow;
    }
  }

  //google認証情報を使ってFirebaseにログイン
  Future<void> signInWithGoogle(
    BuildContext context, WidgetRef ref) async {
    try {
      // エラーメッセージをクリア
      ref.read(errorMessageProvider.notifier).state = '';

      // Google認証情報の取得
      final credential = await gooleSingIn(); 

      // Googleサインインの認証情報を匿名ユーザーにリンク
        try{//とりあえずリンクしておく
          await _auth.currentUser!.linkWithCredential(credential);
        }on FirebaseAuthException catch (e) {//すでにリンク済みである時
          await _auth.signInWithCredential(credential);
        }

        //ログイン結果のメッセージ表示
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Googleアカウントにログインしました'))); 

        //メニュー一覧ページへ遷移
        resetPageChange(context, ref, 0, 0);

    } on FirebaseAuthException catch (e) {
      // エラーハンドリング
      switch (e.code) {
        case 'credential-already-in-use':
          errorMessage = AuthErrorMessages.accountExistCrediential;
          print('このGoogleアカウントは既に使用されています。サインインを試みます。');
          final credential = await gooleSingIn();
          final userCredential =
              await FirebaseAuth.instance.signInWithCredential(credential);
          print('Googleアカウントでサインインしました: ${userCredential.user?.uid}');
        case 'invalid-credential':
          errorMessage = AuthErrorMessages.invalidCredential;
        case 'requiers-recent-login':
          errorMessage = AuthErrorMessages.requiresRecentLogin;
        default:
          errorMessage = AuthErrorMessages.unknownError;
          print('その他：$e.code');
      }

      //エラーメッセージの表示
      ref.read(errorMessageProvider.notifier).state = errorMessage;
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    }
  }

  //google認証情報の取得（googleログイン画面表示、アカウント選択）
  Future gooleSingIn() async {

    // googleログイン画面表示しアカウント選択
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
      return null; // Googleサインインがキャンセルされた場合
    }

    // Googleサインインの認証情報を取得（IDトークン & アクセストークン）
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Firebase認証用のCredentialを作成
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return credential;
  }

  // 匿名認証
  //Future<void> signInAnony(WidgetRef ref) async {
  Future<void> signInAnony() async {
    try {
      //ref.read(errorMessageProvider.notifier).state = '';
      await _auth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "operation-not-allowed":
          errorMessage = AuthErrorMessages.anonymousAuthDisabled;
        default:
          errorMessage = AuthErrorMessages.unknownError;
      }
      // エラーメッセージを更新
      //ref.read(errorMessageProvider.notifier).state = errorMessage;
      rethrow; //例外を上位に伝播する
    }
  }

  // サインアウト
  Future<void> signOut() async {
    await _auth.signOut();
    await signInAnony();//サインアウト後に匿名ログインする。
  }
}
