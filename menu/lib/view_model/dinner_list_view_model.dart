import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menu/data/repository/dinner_repository.dart';
//import 'package:menu/view/dinner_list_screen.dart';
import 'package:menu/data/providers.dart';
import 'package:menu/data/model/dinner.dart';
import 'package:intl/intl.dart';

// 日付データ取得
final dinnerDateNotifierProvider =
    NotifierProvider<DinnerDateNotifier, String>(DinnerDateNotifier.new);

// 日付データ更新
class DinnerDateNotifier extends Notifier<String> {
  @override
  String build() {
    DateFormat outputFormat = DateFormat('yyyy-MM-dd');
    return outputFormat.format(DateTime.now()).toString();
  }

  void update(DateTime date) {
    DateFormat outputFormat = DateFormat('yyyy-MM-dd');

    state = outputFormat
        .format(DateTime(date.year, date.month, date.day))
        .toString();
    //state = date;
  }
}

// 夕食データ取得
final dinnerListProvider = StreamProvider<List<Dinner>>((ref) {
  return DinnerRepository(currentUser!).getDinnerList();
});

// 全てのデータ表示
final isAllViewProvider = StateProvider<bool>((ref) => true);

// 夕食データフィルタリング
final filteredDinnersProvider = Provider<List<Dinner>>((ref) {
  final dinners = ref.watch(dinnerListProvider).asData?.value ?? [];
  final isAllView = ref.watch(isAllViewProvider);
  final selectDate = ref.watch(dinnerDateNotifierProvider);

  if (isAllView) {
    return dinners;
  }

  final selectedDateTime = DateTime.parse(selectDate);

  // 年月でフィルタリング
  return dinners.where((dinner) {
    final dinnerDate = DateTime.parse(dinner.createAt.toString());
    return dinnerDate.year == selectedDateTime.year &&
        dinnerDate.month == selectedDateTime.month;
  }).toList();
});

// 夕食データの合計金額取得
final dinnerTotalPriceProvider = FutureProvider<int>((ref) async {
  final dinners = ref.watch(filteredDinnersProvider);
  final totalPrice = dinners.fold<int>(
    0, // 初期値
    (sum, dinner) => sum + (dinner.price ?? 0), // 合計金額を計算
  );
  return totalPrice;
});
