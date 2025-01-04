import 'package:menu/common/gloval_variable.dart';
import 'package:menu/data/repository/user_repository.dart';
import 'repository/menu_repository.dart';
//import 'repository/dinner_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'model/user.dart';
import 'model/menu.dart';
//import 'model/dinner.dart';
//import 'repository/o_user_repository.dart';
//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_storage/firebase_storage.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

//final userProvider = StateProvider<UserModel?>((ref) =>UserRepository().getCurrentUser());
UserModel? currentUser = UserRepository().getCurrentUser();
final userProvider = StateProvider<UserModel?>((ref) => currentUser);
/*
            UserModel(
            //createAt: DateTime.now(), 
            uid: "AC3iWb7RnqM4gCmeLOD9"
            );
*/

//final menuListProvider = StreamProvider<QuerySnapshot>((ref) {
//  return MenuRepository(user).getMenuList();
//});

final menuListProvider = StreamProvider<List<Menu>>((ref) {
  return MenuRepository(currentUser!).getMenuList();
});

// final dinnerListProvider = StreamProvider<List<Dinner>>((ref) {
//   return DinnerRepository(currentUser!).getDinnerList();
// });

// FirebaseAuthインスタンスのプロバイダ
// final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
//   return FirebaseAuth.instance;
// });

//final authServiceProvider = Provider<AuthService>((ref) {
//  //AuthServiceを継承
//  return AuthService(ref.watch(firebaseAuthProvider));
//});

// 認証状態のプロバイダ
// 継続的な変化を監視
// ログイン状態を取得
//final authStateChangesProvider = StreamProvider<User?>((ref) {
//  return ref.watch(firebaseAuthProvider).authStateChanges();
//});

// 匿名ログインが完了状態を監視
//final anonymousProvider = StateProvider<bool>((ref) => false);

final indexProvider = StateProvider<int>((ref) => 0); // メニュー画面のインデックス

final pageProvider = StateProvider<int>((ref) => initOtherPage); // メニュー画面以外のページ
