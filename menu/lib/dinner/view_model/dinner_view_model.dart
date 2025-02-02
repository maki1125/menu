import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:menu/dinner/data/repository/dinner_repository.dart';
import 'package:menu/dinner/data/model/dinner.dart';


//プロバイダーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
// 夕食リストの非同期プロバイダ
final dinnerListProvider = StreamProvider<List<Dinner>>((ref) {
  return DinnerRepository().getDinnerList();
});


//選択日付
final selectedDateProvider = StateProvider<DateTime?>((ref) {
  return null;
});


//合計金額
final dinnerTotalPriceProvider = StateProvider<int>((ref){
  return 0;
});

//タグのプルダウンの選択項目
final StateProvider<String> dropDownProvider = StateProvider<String>((ref) {
  return "noSelect";
});

//メソッドーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
// 月曜日の日付取得
DateTime foundMonday(DateTime date) {
  return date.subtract(Duration(days: date.weekday - DateTime.monday));
}

// 日付フォーマット
String dateFormat(date) {
  return DateFormat('yyyy-MM-dd').format(date);
}

//選択日付を含む週の算出
List<DateTime> calWeek(DateTime selectedDate){
  return [
    for (var i = 0; i < 7; i++) foundMonday(selectedDate).add(Duration(days: i))
  ];
}



