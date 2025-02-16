import 'dart:io'; //Fileを扱うため
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart'; //画像キャッシュ
import 'package:intl/intl.dart';//日付のフォーマット

import 'package:menu/main_screen.dart';
import 'package:menu/common/common_providers.dart';
import 'package:menu/common/common_widget.dart';
import 'package:menu/common/logger.dart';
import 'package:menu/menu/data/repository/menu_repository.dart';
import 'package:menu/menu/data/repository/image_repository.dart';
import 'package:menu/menu/view_model/menu_view_model.dart';
import 'package:menu/menu/data/model/menu.dart';
import 'package:menu/dinner/data/model/dinner.dart';
import 'package:menu/dinner/data/repository/dinner_repository.dart';


class MenuList extends ConsumerStatefulWidget {

  //main_screen.dartからカテゴリーを受け取る
  final String category;
  const MenuList({super.key, required this.category}); // コンストラクタ
  @override
  MenuListState createState() => MenuListState();
}
class MenuListState extends ConsumerState<MenuList> {
  late String category;
  int nameMaxLength = 10; //料理名のmax表示
  late TextEditingController menuSearchController; // 検索テキストフィールドのコントローラー

  //初期化処理
  @override
  void initState() {
    super.initState();
    category = widget.category;
    menuSearchController = TextEditingController(); // コントローラーの初期化
  }

  @override
  void dispose() {
    super.dispose();
    menuSearchController.dispose(); // コントローラーの破棄
  }

  @override
  Widget build(BuildContext context) {  
    LoggerService.debug("menu_list");
    final menuListAsyncValue = ref.watch(menuListProvider); //メニューリストを監視して、変更されれば再描写する。
    final searchFilteredMenus = ref.watch(filteredMenusProvider); // フィルタリングされた材料データ
 

    return GestureDetector(// テキストフィールド以外をタッチしたときにキーボードを閉じるためにGestureDetector使用。
        onTap: () {
          // テキストフィールド以外をタッチしたときにキーボードを閉じる。FocusNodeでフォーカスを外す
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child:
    
    Stack( //フローボタンのためにstack使用。
      children: [

        //データの取得状況により表示を分ける
        menuListAsyncValue.when(
          data: (menus){

            //タグのフィルター。メニューリストをフィルター分だけにする。
            final filteredMenus = (category == '全て')
              ? menus
              : category == '夕食'
                ? menus.where((menu) => menu.isDinner == true).toList()
                : category == '予定'
                  ? menus.where((menu) => menu.isPlan == true).toList()
                  : category == 'お気に入り'
                    ? menus.where((menu) => menu.isFavorite == true).toList()
                    : menus.where((menu) => menu.tag == category).toList();

                 // filteredMenus の中から searchFilteredMenus に一致する要素を抽出
                final matchedMenus = filteredMenus.where((menu) {
                  // searchFilteredMenus に menu が含まれているかチェック
                  return searchFilteredMenus.contains(menu);
                }).toList();

            // 「夕食」タブの合計金額の初期計算
            if (category == '夕食') {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref.read(totalPriceNotifierProvider.notifier).updateTotalPrice(filteredMenus, ref);
              });
            }

            //menuListProviderが変更された時に、「夕食」タブの合計金額を再計算
            ref.listen<AsyncValue<List<Menu>>>(
              menuListProvider,
              (previous, next) {
                if (category == '夕食') {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ref.read(totalPriceNotifierProvider.notifier).updateTotalPrice(filteredMenus, ref);
                  });
                }
              },
            );

            // 各 quantityProviderが変更された時に、「夕食」タブの合計金額を再計算
            for (int i = 0; i < filteredMenus.length; i++) {
              ref.listen<int>(
                quantityProvider(i),
                (previous, next) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ref.read(totalPriceNotifierProvider.notifier).updateTotalPrice(filteredMenus, ref);
                  });
                },
              );
            }
            
            //ここからwidget要素
            return 
            //Stack(
                  //children: [
                    
                    
                    Column(
                      children: [
                        Stack(//検索窓の右側にアイコンを配置するため。
                          children: [
                            
                          
                    // 検索テキストフィールド（上部に固定）---------------------------------------
                    searchBox(menuSearchController, ref, menuSearchTextProvider, '材料名'),//ref),//, materials),
            Positioned(
                      top: 0,
                      right: 0,
                      child: 
                    Row(
      mainAxisSize: MainAxisSize.min,  // アイコンを必要な分だけ並べる
      children: [
        
        IconButton(
          // フィルターや並び替えの機能が追加できる
          icon: const Icon(
            Icons.abc,
            size: 25,
          ),
          onPressed: () {
            setState(() {
              //print("ボタンおしまいした");
              //matchedMenus.sort((a, b) => a.name!.compareTo(b.name!));
            });
            
            
          },
        ),
        IconButton(
          // フィルターや並び替えの機能が追加できる
          icon: const Icon(
            Icons.sort,
            size: 25,
          ),
          onPressed: () {
            setState(() {
              //print("ボタンおしまいした");
              //matchedMenus.sort((a, b) => a.createAt!.compareTo(b.createAt!));
            });
          },
        ),
      ]),
                    )
],
                        ),
                    //スクロール可能領域------------------------------------------
                    Expanded(
                      child:SingleChildScrollView(
                        child:
            
             (matchedMenus.isEmpty && category!='夕食') // データがない場合
              ? const Padding(
                padding: EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,//中央よせ
                children: [
                 Text('データがありません',)
                ],
              )
              )
              


          
            
            // 材料カードーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
            : ListView.builder(
              //padding: EdgeInsets.zero, // 隙間を無くす
              shrinkWrap: true, // 高さ自動調整。ListViewが無限広がろうとするのを防ぐ。
              physics: const NeverScrollableScrollPhysics(), // スクロール禁止
              itemCount: matchedMenus.length+1,//+1は「今日の夕飯」タブの最後の「合計金額」テキストのため。
              itemBuilder: (context, index){
                //print("card_"+index.toString());

                //カード一枚分の設定
                if(index < matchedMenus.length){
                  return Card(
                    color: Colors.white,
                    elevation: 1, //影の深さ
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InkWell(//タッチした時にインクが広がる感じのエフェクトを設定
                      onTap: () {
                        ref.read(pageProvider.notifier).state = 5;
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MainPage(menu: matchedMenus[index])),
                        );
                      },
                      child: Padding( //カード内の左側に隙間を設ける
                        padding: const EdgeInsets.only(left: 10.0),
                      child:Row(
                        children: [
                          //テキストエリア===========================================================
                          Expanded(
                            flex: 3,//テキスト領域の比率
                            child: 
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start, // 左寄せ
                                children: [

                                  //１列目（料理名の表示）
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(matchedMenus[index].name!.length > nameMaxLength ? '${matchedMenus[index].name!.substring(0, nameMaxLength)}...' : matchedMenus[index].name!,
                                        style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                                      ),

                                      Row(
                                        children: [
                                          //編集アイコンーーーーーーーーーーーーーーーーーーーーーーー
                              InkWell(
                                //icon: const Icon(Icons.edit),
                                borderRadius: BorderRadius.circular(50), // 丸い波紋効果
                                child: const Padding(
                                  padding: EdgeInsets.all(4.0), // タッチ領域を調整
                                  child: Icon(
                                    Icons.edit,
                                    size: 23,
                                  ),
                                ),
                                onTap: () async{
                                  //画面遷移時に前回選択した画像が一時フォルダに保存されていたら削除する。
                                  final file = File('${Directory.systemTemp.path}/resized_image.jpg');
                                  // ファイルを削除
                                  if (await file.exists()) {
                                    await file.delete();
                                    //print('ファイルが削除されました。');
                                  } else {
                                    //print('ファイルは存在しません。');
                                  }
                                  //メニュー編集画面へ遷移
                                  ref.read(selectedImageProvider.notifier).state = null;
                                  ref.read(pageProvider.notifier).state = 6;
                                  
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => MainPage(menu: matchedMenus[index])),
                                  ).then((_){
                                    
                                    setState((){});//編集ページから戻った時に、編集したデータを表示させるために再描写
                                  });

                                },
                                //iconSize: 10,
                              ),

                                        

                                      //削除アイコンーーーーーーーーーーーーーーーー
                              InkWell(
                                //icon: const Icon(Icons.edit),
                                borderRadius: BorderRadius.circular(50), // 丸い波紋効果
                                child: const Padding(
                                  padding: EdgeInsets.all(4.0), // タッチ領域を調整
                                  child: Icon(
                                    Icons.delete,
                                    size: 23,
                                  ),
                                ),
                                onTap: () async{
                                  final bool? result = await showDialog<bool>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        //title: const Text('確認'),
                                        content: const Text('このメニューを削除しますか？'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(false); // 「いいえ」を選択
                                            },
                                            child: const Text('いいえ'),
                                          ),
                                          TextButton(
                                            onPressed: () async{
                                              await ImageRepository(currentUser!, matchedMenus[index], ref).deleteImage(); 
                                              Navigator.of(context).pop(true); // 「はい」を選択
                                            },
                                            child: const Text('はい'),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (result == true) {
                                    // 「はい」が選択された場合の処理
                                    //print("delete");
                                    //print(currentUser!.uid);
                                    MenuRepository().deleteMenu(matchedMenus[index]); //メニュー削除
                                    //Navigator.pop(context);//元画面(メニュー一覧)に遷移
                                  } else {
                                    // 「いいえ」が選択された場合、何もしない
                                    //print('操作をキャンセルしました');
                                  }

                                },
                                //iconSize: 10,
                              ),

                              
                              ],
                                      )
                                    
                                    ],
                                  ),
                                  //値段
                                  Text("${matchedMenus[index].unitPrice}円(１人前)",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    //decoration: TextDecoration.underline,
                                    ),
                                    ),

                                  //2列目(最近食べた日）
                                  Text("最近食べた日:${matchedMenus[index].dinnerDate!.year != 1970
                                  ? DateFormat('yyyy/MM/dd(E)','ja').format(matchedMenus[index].dinnerDate!) 
                                  : "ー"}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    //decoration: TextDecoration.underline,
                                    ),
                                    ),

                                  //3列目(メモ）
                                  //Text(matchedMenus[index].memo!.length > 37 ? '${matchedMenus[index].memo!.substring(0, 37)}...' : matchedMenus[index].memo!,
                                  //style: const TextStyle(fontSize: 13),), // 余白を挿入

                                  //4列目(ボタンと値段）
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [

                                        

                                      //「夕食」にするボタン
                                      ElevatedButton(//枠線ありボタン
                                        onPressed: () { 
                                          dinnerButton(matchedMenus[index]); 
                                          },
                                        style: ElevatedButton.styleFrom(
                                          elevation: matchedMenus[index].isDinner! ? 0 : 3,//影の深さ
                                          //padding: EdgeInsets.zero, // 完全にパディングを削除
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), // パディングを調整
                                          minimumSize: const Size(60, 25), // 最小サイズを指定
                                          backgroundColor: matchedMenus[index].isDinner! 
                                            ? const Color.fromARGB(255, 157, 210, 244) 
                                            : const Color.fromARGB(255, 228, 228, 228),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5), // 角の丸みを20に設定
                                          ),
                                        ),
                                        child: Text(
                                          matchedMenus[index].isDinner! ? '夕食':'夕食',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black
                                          ),
                                        ),  
                                      ),
                                      const SizedBox(width: 10,),

                                      //「予定」にするボタン
                                      ElevatedButton(//枠線ありボタン
                                        onPressed: () { 
                                          planButton(matchedMenus[index]); 
                                          },
                                        style: ElevatedButton.styleFrom(
                                          elevation: matchedMenus[index].isPlan! ? 0 : 3,//影の深さ
                                          //padding: EdgeInsets.zero, // 完全にパディングを削除
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), // パディングを調整
                                          minimumSize: const Size(60, 25), // 最小サイズを指定
                                          backgroundColor: matchedMenus[index].isPlan! 
                                            ? const Color.fromARGB(255, 244, 157, 240)
                                            : const Color.fromARGB(255, 228, 228, 228),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5), // 角の丸みを20に設定
                                          ),
                                        ),
                                        child: Text(
                                          matchedMenus[index].isPlan! ? '予定':'予定',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black
                                          ),
                                        ),  
                                      ),
                                      ],
                                      ),
                                      //「人前」の表示
                                      category == '夕食'
                                      ? Consumer(builder: (BuildContext context, WidgetRef ref, child){
                                        final dispQuantity = ref.watch(quantityProvider(index));//何人前
                                        return Row(
                                        mainAxisSize: MainAxisSize.min, // ウィジェットが必要な最小限のスペースを占有
                                        children: [

                                          //マイナスアイコン
                                           IconButton(
                                            onPressed: () {
                                              ref.read(quantityProvider(index).notifier).state =
                                                (dispQuantity > 1) ? dispQuantity - 1 : 1;
                                            },
                                            icon: const Icon(Icons.do_not_disturb_on_outlined),
                                            padding: EdgeInsets.zero,
                                            iconSize: 25,
                                          ),
                                          
                                          SizedBox(
                                            width: 50,
                                            child:
                                            
                                          //人前、値段の表示
                                          Column(
                                            children: [
                                              Text("$dispQuantity人前 ",
                                            style: const TextStyle(fontSize: 13, height:0, ),
                                            ),
                                            Text("${matchedMenus[index].unitPrice! * dispQuantity}円  ",
                                            style: const TextStyle(fontSize: 13, height:0, ),
                                            )
                                            ],
                                          )),

                                          //プラスアイコン
                                           IconButton(
                                            onPressed: () {
                                              ref.read(quantityProvider(index).notifier).state =
                                                dispQuantity + 1;
                                            },
                                            icon: const Icon(Icons.control_point_rounded),
                                            padding: EdgeInsets.zero,
                                            iconSize: 25,
                                          )
                                          
                                          ], 
                                        );
                                      })
                                      : const SizedBox.shrink(),
                                      /*
                                      Padding(
                                        padding: const EdgeInsets.only(right:10), // すべての辺に16のスペース
                                        //人前、値段の表示
                                        child:  Column(
                                            children: [
                                              const Text("1人前 ",
                                            style: TextStyle(fontSize: 13, height:0, ),
                                            ),
                                            Text("${matchedMenus[index].unitPrice}円  ",
                                            style: const TextStyle(fontSize: 13, height:0, ),
                                            )
                                            ],
                                          ),
                                      )
                                      */
                                    ],
                                  )
                                ],
                              )
                            ),

                          //画像エリア=============================================================
                          Expanded(
                            flex: 1,//画像領域の比率
                            child: Stack(
                              children: [
                                //画像            
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child:SizedBox(
                                    width: 115,  // 必要に応じてサイズを設定
                                    height: 115, 
                                    child:matchedMenus[index].imageURL.toString() != 'noData'
                          
                                    ? 
                                  CachedNetworkImage(
                                    imageUrl: matchedMenus[index].imageURL.toString(), // ネットワーク画像のURL
                                    
                                    placeholder: (context, url) =>  Transform.scale(//sizedboxでは小さくならなかったのでscaleを使用。
                                      scale: 0.3, // 縮小率を指定
                                      child: const CircularProgressIndicator(strokeWidth: 15.0),
                                    ),
                                    
                                    errorWidget: (context, url, error) => const Icon(Icons.error), // エラーの場合に表示するウィジェット
                                    fit: BoxFit.cover, // 画像の表示方法を指定（例：全体をカバー）
                                  )
                                    /*
                                    Image.network(//画像ある場合
                                    matchedMenus[index].imageURL.toString(), // 画像のURLを指定
                                    fit: BoxFit.cover, // 画像の表示方法を指定（例：全体をカバー）
                                    //fit: BoxFit.fitHeight, 
                                  )
                                  */

                                  :Image.asset( //画像ない場合
                                    'images/no_image.jpg',
                                    //height: 100,
                                    //width: 50,
                                    fit: BoxFit.cover,
                                  ),
                                    )
                                ),
                                

                                //お気に入りアイコン
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    onPressed: () {
                                      favoriteButton(ref, matchedMenus[index]);
                                    },
                                    // 表示アイコン
                                    icon: const Icon(Icons.favorite),
                                    // アイコン色
                                    color: matchedMenus[index].isFavorite!
                                    ? Colors.pink
                                    : Colors.grey,
                                    // サイズ
                                    iconSize: 25,
                                  )
                                ),
                              ],
                            )
                          )
                        ],
                      ),
                      ),
                    ),
                  );
                
                //「夕食」カード下の表示
                }else{
                  return category == '夕食'
                    ? Column(
                    children: [
                      const SizedBox(height: 10),
                     
                      Consumer(builder: (BuildContext context, WidgetRef ref, child){
                        final totalPrice = ref.watch(totalPriceNotifierProvider); //「今日の夕飯」タブの人前を変更した時に、再描写する。
                        final selectDinnerDatePro = ref.watch(selectDinnerDateProvider);

                        return 
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,//中央よせ
                            children: [
                              //日付選択*************************************
                              IconButton(
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
                                    
                                    ref.read(selectDinnerDateProvider.notifier).state = pickDate;//選択日をプロバイダに設定
                                  }
                                },
                                icon: const Icon(Icons.calendar_month),
                                iconSize: 30,
                              ),
                              //選択日付の表示-----------------------------------------
                              Text("${DateFormat('yyyy/MM/dd(E)','ja').format(selectDinnerDatePro) }:合計$totalPrice円")
                              
                            ],
                          );
                        
                      }),

                      matchedMenus.isNotEmpty
                      ? OutlinedButton(//枠線ありボタン
                        onPressed: () { 
                          //dinner作成
                          Dinner dinner = Dinner();
                          dinner.createAt = ref.read(selectDinnerDateProvider.notifier).state;//DateTime.now();
                          dinner.price = ref.read(totalPriceNotifierProvider);
                          dinner.select = matchedMenus.map((menu)=>menu.name!).toList();
                          dinner.selectID = matchedMenus.map((menu)=>menu.id!).toList();
                          DinnerRepository().addDinner(dinner);//データベースにデータ追加
                          
                          //最近食べた日の項目更新
                          for (var menu in matchedMenus){
                             menu.dinnerDateBuf = menu.dinnerDate;//バッファに保存してから
                            menu.dinnerDate = DateTime.now();//更新
                            MenuRepository().updateMenu(menu);
                          }
                          
                          //ページ遷移
                          ref.read(pageProvider.notifier).state = 2;
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const MainPage()),
                          );
                         },
                        child: const Text('夕食決定！'),
                      )
                        : OutlinedButton(//枠線ありボタン
                        onPressed: () { 
                            category = '全て';
                            //ページ遷移
                          ref.read(pageProvider.notifier).state = 0;
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const MainPage()),
                          );

                         },
                        child: const Text('夕飯を選択してね'),
                      ),
                    ],
                  )
                  :const SizedBox.shrink();
                }
              }
         ) 
         )
         )

                  ]);
         //]);

          }, 
          
          error: (e, stackTrace) => Center(child: Text('Error: $e')), 
          loading: () => const Center(child: CircularProgressIndicator()),
          ),

        // フローティングボタンを配置
        Positioned(
          bottom: 16, // 下からの距離
          right: 16,  // 右からの距離
          child: FloatingActionButton(
            onPressed: () async{
              
              //画面遷移時に前回選択した画像が一時フォルダに保存されていたら削除する。
              final file = File('${Directory.systemTemp.path}/resized_image.jpg');
                  // ファイルを削除
                  if (await file.exists()) {
                    await file.delete();
                    //print('ファイルが削除されました。');
                  } else {
                    //print('ファイルは存在しません。');
                  }
                  ref.read(selectedImageProvider.notifier).state = null;

              ref.read(pageProvider.notifier).state = 3;//表示ページの設定
              Navigator.push(
                // ファイルのパスを指定
                  
                  context,
                  
                  MaterialPageRoute(builder: (context) => const MainPage()),
              );
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
   ) );


  }

}
