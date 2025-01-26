import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:menu/data/repository/menu_repository.dart';
import 'package:menu/view_model/dinner_list_view_model.dart';
import 'package:menu/data/repository/dinner_repository.dart';
import 'package:menu/common/common_providers.dart';
import 'package:menu/common/common_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:menu/data/model/user.dart';

 ///メモ
 ///dinnerList（カードの削除など）, selectDate（日付選択）, 
 /// selectFilter（プルダウン選択）の値が変わるとき、再描写する。
 ///
 ///dinnerTotalPrice(合計金額)もwatch（監視）しているのは、
 ///初回のページ描写時にbuild後に計算結果がわかるため、
 ///そのタイミングで再描写することにより合計金額を表示するため。



// 夕食の履歴画面
class DinnerList extends StatefulWidget {
  @override
  DinnerListState createState() => DinnerListState();
}

class DinnerListState extends State<DinnerList> {

  //再描写で更新されたくない変数
  List<DateTime> selectWeek = []; //フィルタで選択された週.
  
  @override
  Widget build(BuildContext context) {
    print("dinner_list");
    
    return Consumer(
      builder: (context, ref, child) {
        final selectDate = ref.watch(selectedDateProvider); // 選択した日付
        final dinnerList = ref.watch(dinnerListProvider); // 夕食リスト  
        int dinnerTotalPrice = ref.watch(dinnerTotalPriceProvider); // 夕食合計金額
        final String selectFilter = ref.read(dropDownProvider); // プルダウンの選択項目  
        
        return Column(
          mainAxisSize: MainAxisSize.min, // 画面いっぱいに表示
          children:[

            //フィルターの設定・金額表示ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround, // 中央寄せ
              children: [
                //全てボタン==========================================================
                TextButton(
                  onPressed: () {
                    ref.read(dropDownProvider.notifier).state = "noSelect"; //プルダウンの選択を初期化
                    ref.read(selectedDateProvider.notifier).state = null; //選択日付を初期化

                  },
                  child: const Text(
                    '全て',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),

                //フィルタープルダウンの表示================================================
                _dropDownFileter(ref), 
                
                //合計の表示=============================================================
                Text(
                  style: const TextStyle(
                    fontSize: 18,
                    //fontWeight: FontWeight.bold,
                  ),
                  "合計：$dinnerTotalPrice円"
                ),
              ],
            ),

            //フィルター選択・カード表示ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
            Expanded(// 画面いっぱいに表示
              child: SingleChildScrollView(// スクロール可能
                child: Column(
                  children: [

                    //選択週の表示＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
                    (selectFilter != "noSelect")//フィルタ選択あり
                    ? Row(
                      children: [

                        //日付選択*************************************
                        TextButton(
                          onPressed: () async{
                            DateTime? pickDate;
                            pickDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(), // 初期表示日
                            firstDate: DateTime(2000), // 選択可能な最小日付
                            lastDate: DateTime(2100), // 選択可能な最大日付
                            locale: const Locale('ja'), // カレンダーを日本語表示
                            );

                            if(pickDate != null){//日付選択されなかったときは今日の日付を設定
                              selectWeek = calWeek(pickDate); //選択日の１週間リスト
                              ref.read(selectedDateProvider.notifier).state = pickDate;//選択日をプロバイダに設定
                            }
                          },
                          child: const Text(
                            "日付選択",
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),

                        //選択されたフィルタの表示**********************************
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                selectDate == null //日付選択がまだの状態
                                ? "日付選択して下さい"
                                : selectFilter == "月" //フィルタ選択が月の場合
                                  ? '${selectDate.year}年${selectDate.month}月'
                                  : '${dateFormat(selectWeek[0])} ～ ${dateFormat(selectWeek[6])}', //フィルタ選択が週の場合
                                style: const TextStyle(
                                  fontSize: 16,
                                  //fontWeight: FontWeight.bold
                                ),
                              ),
                            ]
                          ) ,// 週の表示 
                        )
                      ],
                    )
                    : const SizedBox.shrink(),//フィルタない場合

                    //カードの設定＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
                    dinnerList.when(
                      data: (dinners) {

                        //フィルター処理
                        final filteredDinners = (selectFilter == "noSelect")//フィルタ選択ない状態
                        ? dinners
                        : selectDate == null //フィルターは選択されているが、日付選択していない。
                          ? dinners
                            : (selectFilter == "月") //月フィルター
                              ? dinners.where((dinner) => dinner.createAt!.year == selectDate.year && dinner.createAt!.month == selectDate.month).toList()                  
                              : dinners.where((dinner){//週フィルター
                              return dinner.createAt!.isAfter(selectWeek[0]) && dinner.createAt!.isBefore(selectWeek[6].add(Duration(days: 1)));
                              }).toList();

                        //build完了後に合計金額のプロバイダーを更新する
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ref.read(dinnerTotalPriceProvider.notifier).state = filteredDinners.fold(0,(total, dinner) => total + dinner.price!);
                          });
                    
                      if (filteredDinners.isEmpty) {// データがない場合
                        return const Text('データがありません');
                      }else{
                      
                      return ListView.builder(
                        //padding: EdgeInsets.zero, // 隙間を無くす
                        shrinkWrap: true, // サイズ制約を設定
                        physics: const NeverScrollableScrollPhysics(), //スクロールが動作する.これがないと跳ね返される。
                        itemCount: filteredDinners.length,
                        itemBuilder: (context, index) {
                          final dinner = filteredDinners[index]; // 夕食データ

                          //カードの表示＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
                          return Card(
                              color: dinner.createAt!.weekday == 6 //土曜日
                              ? const Color.fromARGB(255, 225, 246, 255)
                              : dinner.createAt!.weekday == 7 //日曜日
                                ? const Color.fromARGB(255, 255, 229, 242)
                                : Colors.white,
                              elevation: 1.0, // 影の設定
                              //margin: const EdgeInsets.all(0), // 余白
                              shape: RoundedRectangleBorder(// カードの形状
                                //side: const BorderSide(
                                    //color: Colors.blue, width: 1.0), // 枠線
                                borderRadius:BorderRadius.circular(10.0), // 角丸
                              ),
                              child: SizedBox(
                                height: 70,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,//等間隔 （両端空間なし）
                                      children: [
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,// 中央寄せ
                                          crossAxisAlignment: CrossAxisAlignment.start,//左寄せ
                                          children: [
                                            Text(
                                              DateFormat('yyyy/MM/dd(E)','ja').format(dinner.createAt!),
                                              style: TextStyle(fontSize: 13),
                                              ),
                                            Text(
                                              maxText(dinner.select!.join(", "), 25),
                                              style: TextStyle(fontSize: 15,
                                              //fontWeight: FontWeight.bold
                                              ),
                                              overflow:TextOverflow.ellipsis, // テキストがはみ出た場合の処理
                                              maxLines: 1,
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text('${dinner.price.toString()}円',
                                              style: const TextStyle(fontSize: 14)),
                                            IconButton(
                                              icon: const Icon(Icons.delete),
                                              onPressed: () async {
                                                try {

                                                  //最近食べた日の更新（バッファに戻す）
                                                  dinner.selectID!.forEach((id){
                                                    print(id);
                                                    MenuRepository().updateMenuIdDinnerDate(id);
                                                  });
                                                  
                                                  // 夕食データ削除
                                                  await DinnerRepository(currentUser!).deleteDinner(dinner); 
                                                } catch (e) {
                                                  showMessage(
                                                      '削除に失敗しました。再度お試しください。$e');
                                                }
                                              },
                                            ),
                                          ],
                                        )
                                      ],
                                    )
                                  )
                                )
                              )
                            );
                          },
                        );
                      }
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
  );
}

  // フィルターのドロップダウン
  Widget _dropDownFileter(ref) {
    final selectedValue = ref.watch(dropDownProvider); // プルダウンの選択項目    
    final List<String> dropdownItems = ["月", "週"]; //タグのプルダウンの項目
    return DropdownButton(
      hint: const Text('フィルタ'),
      value: dropdownItems.contains(selectedValue)
            ? selectedValue
            : null, // 選択値がリストに含まれていない場合は`null`
      alignment: Alignment.center,
      items: dropdownItems.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item), // 表示内容
              );
            }).toList(),
      onChanged: (value) {
        ref.read(dropDownProvider.notifier).state = value; // 値を更新
      },
    );
  }
}
