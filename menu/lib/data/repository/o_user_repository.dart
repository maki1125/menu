import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menu/data/model/user.dart';
import 'package:menu/view_model/login_screen_view_model.dart';
import 'package:menu/view/main_screen.dart';

// 認証サービス
class AuthService {
  final FirebaseAuth _auth; // FirebaseAuthを自動でインスタンス化;
  late String errorMessage = ''; // エラーメッセージ

  AuthService([FirebaseAuth? auth])
      : _auth = auth ?? FirebaseAuth.instance; // コンストラクタ.引数なしでもOKとなるようにした。
  //AuthService(this._auth); // コンストラクタ

  //Stream<User?> get authStateChanges => _auth.authStateChanges();
  Stream<UserModel?> get authStateChanges {
    // ユーザー情報を取得
    return _auth.authStateChanges().map((User? firebaseUser) {
      // userModelに変換
      if (firebaseUser != null) {
        return UserModel.fromFirebaseUser(firebaseUser);
      } else {
        return null; // ログアウト時はnullを返す
      }
    });
  }
  //User? get currentUser => _auth.currentUser;

  // サインイン
  Future<void> signInEmailAndPassword(BuildContext context, String email,
      String password, WidgetRef ref) async {
    try {
      ref.watch(errorMessageProvider.notifier).state = ''; // エラーメッセージをクリア
      await _auth.signInWithEmailAndPassword(
          email: email, password: password); // サインイン処理
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          errorMessage = AuthErrorMessages.userNotFound;
        case 'wrong-password':
          errorMessage = AuthErrorMessages.wrongPassword;
        case 'invalid-email':
          errorMessage = AuthErrorMessages.invalidEmail;
        case 'user-disabled':
          errorMessage = AuthErrorMessages.userDisabled;
        default:
          errorMessage = AuthErrorMessages.unknownError;
          debugPrint('その他；$e.code');
      }
      ref.read(errorMessageProvider.notifier).state =
          errorMessage; // エラーメッセージを更新
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessage))); // エラーメッセージを表示
      }
      rethrow;
    }
  }

  // サインアップ(新規登録)
  Future<void> singUpEmailAndPassword(BuildContext context, String email,
      String password, WidgetRef ref) async {
    try {
      ref.watch(errorMessageProvider.notifier).state = ''; // エラーメッセージをクリア
      // サインアップ処理
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      // 確認メール送信
      await userCredential.user!.sendEmailVerification();
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
        case 'invalid-email':
          errorMessage = AuthErrorMessages.invalidEmail;
        case 'oeration-not-allowed':
          errorMessage = AuthErrorMessages.operationNotAllowed;
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
      ref.watch(errorMessageProvider.notifier).state = ''; // エラーメッセージをクリア
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

  // Googleログイン
  Future<UserCredential?> signInWithGoogle(
      BuildContext context, WidgetRef ref) async {
    try {
      // エラーメッセージをクリア
      ref.watch(errorMessageProvider.notifier).state = '';
      // googleサインインを実行
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        return null; // Googleサインインがキャンセルされた場合
      }

      // Googleサインインの認証情報を取得
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Googleサインインの認証情報をFirebaseに渡す
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // サインイン後、ユーザー情報を取得
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      return userCredential; // ユーザー情報を返す
    } on FirebaseAuthException catch (e) {
      // エラーハンドリング
      switch (e.code) {
        case 'account-exists-with-different-credential':
          errorMessage = AuthErrorMessages.accountExistCrediential;
        case 'invalid-credential':
          errorMessage = AuthErrorMessages.invalidCredential;
      }
      ref.read(errorMessageProvider.notifier).state = errorMessage;
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessage)));
      }
      return null; // エラーが発生した場合も null を返す
    }
  }

  // 匿名認証
  //Future<void> signInAnony(BuildContext context, WidgetRef ref) async {
  Future<void> signInAnony(WidgetRef ref) async {
    try {
      ref.watch(errorMessageProvider.notifier).state = '';
      //final userCredential = await FirebaseAuth.instance.signInAnonymously();
      await FirebaseAuth.instance.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "operation-not-allowed":
          errorMessage = AuthErrorMessages.anonymousAuthDisabled;
        default:
          errorMessage = AuthErrorMessages.unknownError;
      }
      // エラーメッセージを更新
      ref.read(errorMessageProvider.notifier).state = errorMessage;
      rethrow;
    }
  }

  // サインアウト
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // 現在のユーザーを取得
  UserModel? getCurrentUser() {
    final firebaseuser = _auth.currentUser;
    return firebaseuser != null
        ? UserModel.fromFirebaseUser(firebaseuser)
        : null;
  }
}

class SignInAnony extends ConsumerStatefulWidget {
  // 匿名ログイン
  const SignInAnony({super.key});

  @override
  ConsumerState<SignInAnony> createState() => _SignInAnony();
}

class _SignInAnony extends ConsumerState<SignInAnony> {
  Future<void> _signInAnonymously() async {
    // 匿名ログイン処理
    try {
      // 匿名ログイン処理を呼び出し
      await ref.read(authServiceProvider).signInAnony(ref);
    } catch (e) {
      debugPrint('Anonymous sign-in failed: $e');
      // エラー処理 (例: エラーメッセージの表示)
      // 必要に応じてリトライ処理などを追加
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // ユーザー情報を取得
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator()); // ローディング中のウィジェット
        }
        if (snapshot.hasData) {
          // ユーザー情報がある場合
          return MainPage();
        }
        _signInAnonymously(); // 匿名ログイン処理

        return MainPage();
      },
    );
  }
}
