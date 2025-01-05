import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:menu/view_model/dinner_list_view_model.dart';
import 'package:menu/data/repository/dinner_repository.dart';
import 'package:menu/data/providers.dart';
import 'package:menu/common/common_providers.dart';
//import 'package:intl/intl.dart';

// 夕食の履歴画面
class DinnerList extends StatefulWidget {
  @override
  _DinnerListState createState() => _DinnerListState();
}

class _DinnerListState extends State<DinnerList> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer(
        builder: (context, ref, child) {
          final selectedDate = ref.watch(dinnerDateNotifierProvider); // 日付
          final dinnerDateNotifier =
              ref.read(dinnerDateNotifierProvider.notifier); // 日付の更新
          final dinnerList = ref.watch(dinnerListProvider); // 夕食リスト
          //final isAllView = ref.watch(isAllViewProvider);
          final dinnerTotalPrice =
              ref.watch(dinnerTotalPriceProvider); // 夕食合計金額

          return Column(
            mainAxisSize: MainAxisSize.min, // 画面いっぱいに表示
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround, // 中央寄せ
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      ref.read(isAllViewProvider.notifier).state = true; // 全て表示
                    },
                    child: const Text(
                      '全て',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ), // 全て
                  TextButton(
                    onPressed: () {
                      DatePicker.showDatePicker(context,
                          showTitleActions: true, // アクションボタン表示
                          minTime: DateTime(2025, 1, 1), // 最小日付
                          maxTime: DateTime(2026, 12, 31), onChanged: (date) {
                        // 最大日付
                        //print('change $date');
                      }, onConfirm: (date) {
                        dinnerDateNotifier.update(date); // 日付の更新
                        ref.read(isAllViewProvider.notifier).state =
                            false; // 日付指定表示
                      },
                          currentTime: DateTime.now(),
                          locale: LocaleType.jp); // 現在日時
                    },
                    child: Text(
                      selectedDate,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Text(
                      style: TextStyle(
                        fontSize: 16,
                      ),
                      dinnerTotalPrice.when(
                        // 合計金額
                        data: (totalPrice) {
                          return '合計：$totalPrice円';
                        },
                        loading: () => '合計：0円',
                        error: (error, stackTrace) => '合計：0円',
                      )),
                ],
              ),
              Expanded(
                // 画面いっぱいに表示
                child: SingleChildScrollView(
                  // スクロール可能
                  child: Column(children: <Widget>[
                    dinnerList.when(
                      // データ取得状態による表示切り替え
                      data: (dinners) {
                        final filteredDinners =
                            ref.watch(filteredDinnersProvider); // フィルター後のデータ

                        if (filteredDinners.isEmpty) {
                          // データがない場合
                          return const Text('データがありません');
                        }

                        return ListView.builder(
                          // リスト表示
                          shrinkWrap: true, // サイズ制約を設定
                          physics: NeverScrollableScrollPhysics(), //スクロールが動作する
                          itemCount: filteredDinners.length,
                          itemBuilder: (context, index) {
                            final dinner = filteredDinners[index]; // 夕食データ

                            return ListTile(
                              title: Card(
                                elevation: 2.0, // 影の設定
                                margin: EdgeInsets.all(0), // 余白
                                shape: RoundedRectangleBorder(
                                  // カードの形状
                                  side: BorderSide(
                                      color: Colors.blue, width: 1.0), // 枠線
                                  borderRadius:
                                      BorderRadius.circular(10.0), // 角丸
                                ),
                                child: ListTile(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 10.0),
                                  title: Text(
                                      '${dinner.createAt!.year.toString()} / ${dinner.createAt!.month.toString()} / ${dinner.createAt!.day.toString()}'),
                                  subtitle: Text(
                                    '${dinner.select?[0]}, ${dinner.select?[1]}, ${dinner.select?[2]}',
                                    overflow:
                                        TextOverflow.ellipsis, // テキストがはみ出た場合の処理
                                    maxLines: 1,
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min, // 最小サイズ
                                    mainAxisAlignment:
                                        MainAxisAlignment.end, // 右寄せ
                                    children: [
                                      Text('${dinner.price.toString()}円',
                                          style: const TextStyle(fontSize: 14)),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () async {
                                          try {
                                            print(dinner.price);
                                            await DinnerRepository(currentUser!)
                                                .deleteDinner(
                                                    dinner); // 夕食データ削除
                                            print(
                                                'Dinner deleted successfully');
                                          } catch (e) {
                                            print('Error: deeleteDinner: $e');
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      loading: () =>
                          const CircularProgressIndicator(), // ローディング
                      error: (error, stackTrace) => Text(error.toString()),
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
