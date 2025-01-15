import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menu/data/model/user.dart';
//import 'package:menu/common/common_constants.dart';
import 'package:menu/data/repository/o_user_repository.dart';

//現在ログインユーザー
UserModel? currentUser = AuthService().getCurrentUser();

//ページ
final pageProvider = StateProvider<int>((ref) => 0); 

//ボトムバーの選択
final bottomBarProvider = StateProvider<int>((ref) => 0); 

//材料一覧から選択のフラグ
final selectMaterialProvider = StateProvider<int>((ref) => 0);