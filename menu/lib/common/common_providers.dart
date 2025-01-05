import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menu/data/model/user.dart';
import 'package:menu/common/common_constants.dart';
import 'package:menu/data/repository/o_user_repository.dart';

//現在ログインユーザー
UserModel? currentUser = AuthService().getCurrentUser();

// メニュー画面以外のページ
final pageProvider = StateProvider<int>((ref) => initOtherPage); 