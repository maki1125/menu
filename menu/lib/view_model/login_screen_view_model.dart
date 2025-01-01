import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menu/data/model/user.dart';
import 'package:menu/data/repository/user_repository.dart';
import 'package:menu/data/repository/o_user_repository.dart';

UserModel? currentUser = UserRepository().getCurrentUser();
final userProvider = StateProvider<UserModel?>((ref) => currentUser);

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authServiceProvider = Provider<AuthService>((ref) {
  //AuthServiceを継承
  return AuthService(ref.watch(firebaseAuthProvider));
});

// 認証状態のプロバイダ
// 継続的な変化を監視
// ログイン状態を取得
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

// エラーメッセージプロバイダー
final errorMessageProvider = StateProvider<String>((ref) => '');

// 匿名ログインが完了状態を監視
final anonymousProvider = StateProvider<bool>((ref) => false);
