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

//合計金額
final totalPriceProvider = Provider<List<int>>((ref) {
  final menuListAsyncValue = ref.watch(menuListProvider);

  // 合計金額を計算
  return menuListAsyncValue.when(
    data: (menus) {
      return menus.map((menu) {
        // 各メニューのmaterialを使って合計金額を計算
        return menu.material!.fold(0, (materialSum, material) {
          return materialSum + (material['price'] as int) * (material['quantity'] as int);
        });
      }).toList();
    },
    loading: () => [], // ローディング中は空のリストを返す
    error: (e, stack) => [], // エラー時も空のリストを返す
  );
});