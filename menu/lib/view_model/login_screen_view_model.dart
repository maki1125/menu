import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menu/data/model/user.dart';
import 'package:menu/data/repository/user_repository.dart';
import 'package:menu/data/repository/o_user_repository.dart';

// 現在ログインユーザー
UserModel? currentUser = UserRepository().getCurrentUser();

final userProvider = StateProvider<UserModel?>((ref) => currentUser);

// final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
//   return FirebaseAuth.instance;
// });

// 認証サービス ログイン処理を行う
final authServiceProvider = Provider<AuthService>((ref) {
  //AuthServiceを継承
  //return AuthService(ref.watch(firebaseAuthProvider));
  return AuthService(FirebaseAuth.instance);
});

// 認証状態のプロバイダ
// 継続的な変化を監視
// ログイン状態を取得
final authStateChangesProvider = StreamProvider<User?>((ref) {
  //return ref.watch(firebaseAuthProvider).authStateChanges();
  return FirebaseAuth.instance.authStateChanges();
});

// エラーメッセージプロバイダー エラーメッセージを監視
final errorMessageProvider = StateProvider<String>((ref) => '');

// 匿名ログインが完了状態を監視 true:ログイン完了 false:未ログイン
final anonymousProvider = StateProvider<bool>((ref) => false);

// パスワードリセットのメール送信状況を監視  true:送信完了 false:未送信
final sendPasswordResetEmailProvider = StateProvider<bool>((ref) => false);

// エラーメッセージクラス
class AuthErrorMessages {
  static const userNotFound = 'ユーザーが見つかりません';
  static const wrongPassword = 'パスワードが間違っています';
  static const invalidEmail = '無効なメールアドレスです';
  static const weakPassword = 'パスワードが脆弱です, 6文字以上で入力してください';
  static const emailAlreadyInUse = 'そのアカウント名は既に使用されています';
  static const unknownError = 'エラーが発生しました';
  static const operationNotAllowed = 'アカウントが有効ではありません';
  static const userDisabled = 'ユーザーが存在しません';
  static const anonymousAuthDisabled = 'このプロジェクトでは匿名認証が有効になっていません';
  static const accountExistCrediential = '異なる認証情報を持つアカウントが存在します';
  static const invalidCredential = '無効な認証情報です';
}
