import 'package:riverpod/riverpod.dart';
import 'package:menu/data/model/menu.dart';
import 'package:menu/data/model/user.dart';
import 'package:menu/data/repository/menu_repository.dart';
import 'package:menu/data/repository/user_repository.dart';
import 'package:menu/data/providers.dart';

//ログインユーザ
final _currentUser= UserRepository().getCurrentUser();

//メニューリスト
final menuListProvider = StreamProvider<List<Menu>>((ref) {
  return MenuRepository(currentUser!).getMenuList();
});