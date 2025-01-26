import 'dart:io'; //Fileを扱うため
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menu/data/model/menu.dart';
//import 'package:menu/data/model/user.dart';
import 'package:menu/data/repository/menu_repository.dart';
import 'package:menu/data/repository/user_repository.dart';
import 'package:menu/view/menu_create_screen.dart';
import 'package:menu/view_model/login_screen_view_model.dart';
import 'package:menu/common/common_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:menu/data/model/user.dart';

//ログインユーザ
//final _currentUser = UserRepository().getCurrentUser();

//メニューリポジトリをプロバイダーで管理
final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  final currentUser = ref.watch(currentUserProvider); // 現在のユーザーを取得
  return MenuRepository();
});

//メニューリスト
final menuListProvider = StreamProvider<List<Menu>>((ref) {
  //final menuRepository = ref.watch(menuRepositoryProvider);
  return MenuRepository().getMenuList();
});

/*
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
*/

//お気に入りボタン
void favoriteButton(WidgetRef ref, Menu menu) {
  // isFavorite の状態をトグル
  menu.isFavorite = !menu.isFavorite!;

  if(menu.id != null){//新規登録の場合は、idがまだないため。
  final menuRepository = ref.read(menuRepositoryProvider);
  menuRepository.editMenu(menu);

  }
}

//「今日の夕飯」ボタン
void dinnerButton(menu) {
  if (menu.isDinner) {
    menu.isDinner = false;
  } else {
    menu.isDinner = true;
  }
  print(currentUser!.uid);
  MenuRepository().editMenu(menu);
}

//？人前を管理
final quantityProvider = StateProvider.family<int, int>((ref, index) => 1);

//選択した夕食の合計金額の管理
final totalDinnerPriceProvider = StateProvider<int>((ref) => 0);

//夕食の合計金額をfilterdMenusが変更したらリアルタイムに計算するクラス
class TotalPriceNotifier extends StateNotifier<int> {
  TotalPriceNotifier() : super(0);

  void updateTotalPrice(List<Menu> menus, WidgetRef ref) {
    // メニューと quantityProvider の値を元に合計金額を計算
    int total = menus.asMap().entries.fold(
      0,
      (sum, entry) {
        final index = entry.key;
        final menu = entry.value;
        final quantity = ref.read(quantityProvider(index));
        return sum + (menu.unitPrice ?? 0) * quantity;
      },
    );
    state = total;
  }
}

final totalPriceNotifierProvider =
    StateNotifierProvider<TotalPriceNotifier, int>((ref) {
  return TotalPriceNotifier();
});

//メニュー新規作成から選択したファイル
final selectedImageProvider = StateProvider<File?>((ref) => null);


//タグのプルダウンの選択項目
final StateProvider<String> dropDownProvider = StateProvider<String>((ref) {
  return '全て';
});





