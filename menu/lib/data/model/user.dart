class UserModel {//UserにするとfirebaseAuthのUserと被るためUserModelとする。
  UserModel({
    this.createAt,
    this.uid,
    this.email,
  });

  DateTime? createAt;
  String? uid;
  String? email;

  //firebaseユーザからユーザモデルに変換
  factory UserModel.fromFirebaseUser(firebaseuser) {
    return UserModel(
      uid: firebaseuser.uid,
      email: firebaseuser.email ?? '',
    );
  }

}