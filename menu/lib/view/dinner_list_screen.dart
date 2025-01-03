import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:menu/view_model/dinner_view_list_model.dart';
//import 'package:intl/intl.dart';

// 夕食の履歴画面
class DinnerList extends StatefulWidget {
  @override
  _DinnerListState createState() => _DinnerListState();
}

class _DinnerListState extends State<DinnerList> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final selectedDate = ref.watch(dinnerDateNotifierProvider);
        final dinnerDateNotifier =
            ref.read(dinnerDateNotifierProvider.notifier);
        final dinnerList = ref.watch(dinnerListProvider);
        //final isAllView = ref.watch(isAllViewProvider);
        final dinnerTotalPrice = ref.watch(dinnerTotalPriceProvider);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    ref.read(isAllViewProvider.notifier).state = true;
                  },
                  child: const Text(
                    '全て',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ), // 全て
                TextButton(
                  onPressed: () {
                    DatePicker.showDatePicker(context,
                        showTitleActions: true,
                        minTime: DateTime(2025, 1, 1),
                        maxTime: DateTime(2026, 12, 31), onChanged: (date) {
                      //print('change $date');
                    }, onConfirm: (date) {
                      dinnerDateNotifier.update(date);
                      ref.read(isAllViewProvider.notifier).state = false;
                    }, currentTime: DateTime.now(), locale: LocaleType.jp);
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
                      fontSize: 20,
                    ),
                    dinnerTotalPrice.when(
                      data: (totalPrice) {
                        return '合計：$totalPrice円';
                      },
                      loading: () => '合計：0円',
                      error: (error, stackTrace) => '合計：0円',
                    )),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(children: <Widget>[
                  dinnerList.when(
                    data: (dinners) {
                      final filteredDinners =
                          ref.watch(filteredDinnersProvider);

                      if (filteredDinners.isEmpty) {
                        return const Text('データがありません');
                      }

                      return ListView.builder(
                        shrinkWrap: true, // サイズ制約を設定
                        physics: NeverScrollableScrollPhysics(), //スクロールが動作する
                        itemCount: filteredDinners.length,
                        itemBuilder: (context, index) {
                          final dinner = filteredDinners[index];

                          return ListTile(
                            title: Card(
                              elevation: 2.0,
                              shape: RoundedRectangleBorder(
                                side:
                                    BorderSide(color: Colors.blue, width: 1.0),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: ListTile(
                                title: Text(
                                    '${dinner.createAt!.year.toString()} / ${dinner.createAt!.month.toString()} / ${dinner.createAt!.day.toString()}'),
                                subtitle: Text(
                                    '${dinner.select?[0]}, ${dinner.select?[1]}, ${dinner.select?[2]}'),
                                trailing: Text('${dinner.price.toString()}円'),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stackTrace) => Text(error.toString()),
                  ),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }
}
