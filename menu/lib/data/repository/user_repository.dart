import 'package:firebase_auth/firebase_auth.dart';
import 'package:menu/data/model/user.dart';

class UserRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //新規登録
  Future<void> createUser(String email, String password) async{
    _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  //ログイン
    Future<UserModel> loginWithEmail(String email, String password) async {
    try {
      final UserCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      //print(firebaseuser);
      return UserModel.fromFirebaseUser(UserCredential.user);
    } catch (e) {
      throw Exception('ログイン失敗: $e');
    }
  }

  // ログアウト処理
  Future<void> logout() async {
    await _auth.signOut();
  }

  // 現在のユーザーを取得
  UserModel? getCurrentUser() {
    final firebaseuser = _auth.currentUser;
    return firebaseuser != null ? UserModel.fromFirebaseUser(firebaseuser) : null;
  }




}