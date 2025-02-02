import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:menu/login/data/repository/auth_repository.dart';

// AuthServiceを一つのインスタンスとして扱うため、プロバイダー管理。
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// ユーザーの認証状態（ログイン・ログアウト）をリアルタイムで監視するストリームを管理
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// エラーメッセージプロバイダー エラーメッセージを監視
final errorMessageProvider = StateProvider<String>((ref) => '');

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
  static const credentialAlreadyInUse = 'その認証情報は既に使用されています';
  static const requiresRecentLogin = '再度ログインしてください';
}

