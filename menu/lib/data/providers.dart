import 'package:menu/data/repository/user_repository.dart';
import 'repository/menu_repository.dart';
import 'repository/dinner_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'model/user.dart';
import 'model/menu.dart';
import 'model/dinner.dart';
//import 'package:firebase_storage/firebase_storage.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'repository/o_user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';


//ログインユーザ
UserModel? currentUser = UserRepository().getCurrentUser();
final userProvider = StateProvider<UserModel?>((ref) => currentUser);

//メニューリスト
//final menuListProvider = StreamProvider<List<Menu>>((ref) {
  //return MenuRepository(currentUser!).getMenuList();
//});

//夕食リスト
final dinnerListProvider = StreamProvider<List<Dinner>>((ref) {
  return DinnerRepository(currentUser!).getDinnerList();
});

// FirebaseAuthインスタンスのプロバイダ
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

//ボトムバーのインデックス
//final bottomBarIndex = StateProvider<int>((ref) => 0);


