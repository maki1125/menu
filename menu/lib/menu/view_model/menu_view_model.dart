import 'dart:io'; //Fileを扱うため
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menu/menu/data/model/menu.dart';
import 'package:menu/menu/data/repository/menu_repository.dart';
import 'package:menu/common/common_providers.dart';


//メニューリスト
final menuListProvider = StreamProvider<List<Menu>>((ref) {
  return MenuRepository().getMenuList();
});

//お気に入りボタン
void favoriteButton(WidgetRef ref, Menu menu) {
  // isFavorite の状態をトグル
  menu.isFavorite = !menu.isFavorite!;

  if(menu.id != null){//新規登録の場合は、idがまだないため。
  MenuRepository().updateMenu(menu);

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
  MenuRepository().updateMenu(menu);
}

//「予定」ボタン
void planButton(menu) {
  
  if (menu.isPlan) {
    menu.isPlan = false;
  } else {
    menu.isPlan = true;
  }
  print(currentUser!.uid);
  print(menu.isPlan);
  MenuRepository().updateMenu(menu);
}

//？人前を管理
final quantityProvider = StateProvider.family<int, int>((ref, index) => 1);

//選択した夕食の合計金額の管理
final totalDinnerPriceProvider = StateProvider<int>((ref) => 0);

//選択した夕食日付
final selectDinnerDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

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


// 検索テキストを管理するプロバイダー
final menuSearchTextProvider = StateProvider<String>((ref) => '');

// 材料データの検索フィルタリング
final filteredMenusProvider = Provider<List<Menu>>((ref) {
  final menus = ref.watch(menuListProvider).value ?? [];
  final text = ref.watch(menuSearchTextProvider);

  var filteredMenus = (menus).where((menu) {
    //final isMatch = menu["name"] == text;　// 材料名が完全一致するか
    final isMatch = menu.name!.startsWith(text);
    return isMatch;
  }).toList();

// もしフィルタ結果が空なら、全てのメニューを返す
  if (filteredMenus.isEmpty) {
    return menus;
  }

  return filteredMenus;
});



