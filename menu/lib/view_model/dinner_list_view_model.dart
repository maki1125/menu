import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menu/data/repository/dinner_repository.dart';
//import 'package:menu/view/dinner_list_screen.dart';
//import 'package:menu/data/providers.dart';
import 'package:menu/data/model/dinner.dart';
import 'package:intl/intl.dart';
import 'package:menu/common/common_providers.dart';

// 全てのデータ表示管理
final isAllViewProvider = StateProvider<bool>((ref) => true);

// 週か月かの選択管理
final isSelectedValueProvider = StateProvider<String>((ref) => 'month');

// 日付データ（フォーマットあり）での夕食データ取得
final dinnerDateNotifierProvider =
    NotifierProvider<DinnerDateNotifier, String>(DinnerDateNotifier.new);

class DinnerDateNotifier extends Notifier<String> {
  late DateFormat outputFormat;
  //DateFormat outputFormat = DateFormat('yyyy-MM-dd'); // 日付フォーマット設定

  @override
  String build() {
    // 日付フォーマット設定
    final isSelected = ref.watch(isSelectedValueProvider);
    outputFormat = (isSelected == 'week')
        ? DateFormat('yyyy-MM-dd') // 週の場合
        : DateFormat('yyyy-MM'); // 月の場合
    return outputFormat.format(DateTime.now()).toString();
  }

  // 日付データ更新（（フォーマットあり）
  void update(DateTime date) {
    state = outputFormat
        .format(DateTime(date.year, date.month, date.day))
        .toString();
  }
}

// 夕食リストの非同期プロバイダ
final dinnerListProvider = StreamProvider<List<Dinner>>((ref) {
  return DinnerRepository(currentUser!).getDinnerList();
});

// 2025-01と表示するにはdateTime.parseではエラーがでるのでカスタムパース関数を作成
DateTime parseDate(String yearMonth) {
  final parts = yearMonth.split('-');
  if (parts.length != 2) {
    throw const FormatException('Invalid date format');
  }
  final year = int.parse(parts[0]);
  final month = int.parse(parts[1]);
  return DateTime(year, month);
}

// 月曜日の日付取得
DateTime foundMonday(DateTime date) {
  return date.subtract(Duration(days: date.weekday - DateTime.monday));
}

// ２箇所で使用するため、プロバイダにして共通化
final selectedDateProvider = Provider<DateTime>((ref) {
  final isSelected = ref.watch(isSelectedValueProvider);
  final dinnerDate = ref.watch(dinnerDateNotifierProvider);

  // 年月または年月日を選択した場合に分岐
  return (isSelected == 'week')
      ? DateTime.parse(dinnerDate) // 年月日で表示（週の場合）
      : parseDate(dinnerDate); // 年月で表示（月の場合）
});

// 週の日付リストを計算するプロバイダ
final selectWeekProvider = Provider<List<DateTime>>((ref) {
  // 現在の選択された日付を取得（例：dinnerDateNotifierProviderから取得）
  final selectedDate = ref.watch(selectedDateProvider);
  // 1週間分の日付を計算
  return [
    for (var i = 0; i < 7; i++) foundMonday(selectedDate).add(Duration(days: i))
  ];
});

// 夕食データフィルタリング
final filteredDinnersProvider = Provider<List<Dinner>>((ref) {
  final dinners = ref.watch(dinnerListProvider).asData?.value ?? []; // 夕食リスト
  final isAllView = ref.watch(isAllViewProvider);
  final isSelected = ref.watch(isSelectedValueProvider);
  final selectWeek = ref.watch(selectWeekProvider);
  final selectedDate = ref.watch(selectedDateProvider);

  // 全て表示の場合
  if (isAllView) {
    return dinners;
  }

  // 週か月かでデータをフィルタリング
  return dinners.where((dinner) {
    final dinnerDate = DateTime.parse(
        DateFormat('yyyy-MM-dd').format(dinner.createAt!)); // 夕食データの日付取得
    return (isSelected == 'week')
        ? selectWeek.contains(dinnerDate) // 週の場合
        : dinnerDate.year == selectedDate.year && // 月の場合
            dinnerDate.month == selectedDate.month;
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
