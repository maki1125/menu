import 'dart:io'; //Fileを扱うため
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menu/data/repository/dinner_repository.dart';
import 'package:menu/data/repository/menu_repository.dart';
import 'package:cached_network_image/cached_network_image.dart'; //画像キャッシュ
//import 'package:menu/view/menu_detail_screen.dart';
import 'package:menu/view_model/menu_view_model.dart';
import 'package:intl/intl.dart';//日付のフォーマット
import 'package:menu/data/model/menu.dart';
import 'package:menu/data/model/dinner.dart';
//import 'package:menu/view/menu_create_screen.dart';
import 'package:menu/view/main_screen.dart';
//import 'package:menu/view/menu_detail_screen.dart';
import 'package:menu/common/common_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:menu/data/model/user.dart';

class MenuList extends ConsumerWidget {

  //main_screen.dartからカテゴリーを受け取る
  String category;
  MenuList({required this.category}); // コンストラクタ

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print("menu_list");

    int nameMaxLength = 10; //料理名のmax表示
    final menuListAsyncValue = ref.watch(menuListProvider); //メニューリストを監視して、変更されれば再描写する。
    
    return Stack( //フローボタンのためにstack使用。
      children: [

        //カードの表示
        menuListAsyncValue.when(
          data: (menus){

            //タグのフィルター。メニューリストをフィルター分だけにする。
            final filteredMenus = (category == '全て')
                ? menus
                :category == '今日の夕食'
                ? menus.where((menu) => menu.isDinner == true).toList()
                : category == 'お気に入り'
                  ? menus.where((menu) => menu.isFavorite == true).toList()
                  : menus.where((menu) => menu.tag == category).toList();

            // 「今日の夕食」タブの合計金額の初期計算
            if (category == '今日の夕食') {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref.read(totalPriceNotifierProvider.notifier).updateTotalPrice(filteredMenus, ref);
              });
            }

            //menuListProviderが変更された時に、「今日の夕食」タブの合計金額を再計算
            ref.listen<AsyncValue<List<Menu>>>(
              menuListProvider,
              (previous, next) {
                if (category == '今日の夕食') {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ref.read(totalPriceNotifierProvider.notifier).updateTotalPrice(filteredMenus, ref);
                  });
                }
              },
            );

            // 各 quantityProviderが変更された時に、「今日の夕食」タブの合計金額を再計算
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
            
            if (filteredMenus.isEmpty && category!='今日の夕食') {// データがない場合
              return Padding(
                padding: EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,//中央よせ
                children: [
                  const Text('データがありません',)
                ],
              )
              );
              
            }else{

            return ListView.builder(
              //padding: EdgeInsets.zero, // 隙間を無くす
              itemCount: filteredMenus.length+1,//+1は「今日の夕飯」タブの最後の「合計金額」テキストのため。
              itemBuilder: (context, index){
                //print("card_"+index.toString());

                //カード一枚分の設定
                if(index < filteredMenus.length){
                  return Card(
                    color: filteredMenus[index].isDinner! ? const Color.fromARGB(255, 251, 237, 237) : Colors.white,
                    elevation: 1, //影の深さ
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InkWell(//タッチした時にインクが広がる感じのエフェクトを設定
                      onTap: () {
                        ref.read(pageProvider.notifier).state = 5;
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MainPage(menu: filteredMenus[index])),
                        );
                      },
                      child: Padding( //カード内の左側に隙間を設ける
                        padding: EdgeInsets.only(left: 10.0),
                      child:Row(
                        children: [
                          //テキストエリア===========================================================
                          Expanded(
                            flex: 2,//テキスト領域の比率
                            child: 
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start, // 左寄せ
                                children: [

                                  //１列目（料理名の表示）
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(filteredMenus[index].name!.length > nameMaxLength ? '${filteredMenus[index].name!.substring(0, nameMaxLength)}...' : filteredMenus[index].name!,
                                        style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),),
                                    ],
                                  ),

                                  //2列目(最近食べた日）
                                  Text("最近食べた日:${filteredMenus[index].dinnerDate != null 
                                  ? DateFormat('yyyy/MM/dd(E)','ja').format(filteredMenus[index].dinnerDate!) 
                                  : "ー"}",
                                  style: const TextStyle(
                                    fontSize: 10,
                                    //decoration: TextDecoration.underline,
                                    ),),

                                  //3列目(メモ）
                                  Text(filteredMenus[index].memo!.length > 37 ? '${filteredMenus[index].memo!.substring(0, 37)}...' : filteredMenus[index].memo!,
                                  style: const TextStyle(fontSize: 13),), // 余白を挿入

                                  //4列目(ボタンと値段）
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      //「今日の夕食」にするボタン
                                      OutlinedButton(//枠線ありボタン
                                        onPressed: () { 
                                          dinnerButton(filteredMenus[index]); 
                                          },
                                        style: OutlinedButton.styleFrom(
                                          //padding: EdgeInsets.zero, // 完全にパディングを削除
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), // パディングを調整
                                          minimumSize: const Size(50, 20), // 最小サイズを指定
                                          backgroundColor: filteredMenus[index].isDinner! ? Colors.blue : Colors.orange
                                        ),
                                        child: Text(
                                          filteredMenus[index].isDinner! ? 'やめる':'今日の夕飯にする',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white),
                                        ),  
                                      ),
                                      
                                      //「人前」の表示
                                      Consumer(builder: (BuildContext context, WidgetRef ref, child){
                                        final dispQuantity = ref.watch(quantityProvider(index));//何人前
                                        return Row(
                                        mainAxisSize: MainAxisSize.min, // ウィジェットが必要な最小限のスペースを占有
                                        children: [

                                          //マイナスアイコン
                                          category == '今日の夕食'
                                          ? IconButton(
                                            onPressed: () {
                                              ref.read(quantityProvider(index).notifier).state =
                                                (dispQuantity > 1) ? dispQuantity - 1 : 1;
                                            },
                                            icon: const Icon(Icons.do_not_disturb_on_outlined),
                                            padding: EdgeInsets.zero,
                                            iconSize: 25,
                                          )
                                          : const SizedBox.shrink(),
                                          
                                          //人前、値段の表示
                                          Column(
                                            children: [
                                              Text("${dispQuantity}人前 ",
                                            style: const TextStyle(fontSize: 13, height:0, ),
                                            ),
                                            Text("${filteredMenus[index].unitPrice! * dispQuantity}円  ",
                                            style: const TextStyle(fontSize: 13, height:0, ),
                                            )
                                            ],
                                          ),

                                          //プラスアイコン
                                          category == '今日の夕食'
                                          ? IconButton(
                                            onPressed: () {
                                              ref.read(quantityProvider(index).notifier).state =
                                                dispQuantity + 1;
                                            },
                                            icon: const Icon(Icons.control_point_rounded),
                                            padding: EdgeInsets.zero,
                                            iconSize: 25,
                                          )
                                          : const SizedBox(width: 30,),
                                          ], 
                                        );
                                      }),
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
                                  child:Container(
                                    width: 130,  // 必要に応じてサイズを設定
                                    height: 130, 
                                    child:filteredMenus[index].imageURL.toString() != 'noData'
                          
                                    ? 
                                  CachedNetworkImage(
                                    imageUrl: filteredMenus[index].imageURL.toString(), // ネットワーク画像のURL
                                    
                                    placeholder: (context, url) =>  Transform.scale(//sizedboxでは小さくならなかったのでscaleを使用。
                                      scale: 0.3, // 縮小率を指定
                                      child: const CircularProgressIndicator(strokeWidth: 15.0),
                                    ),
                                    
                                    errorWidget: (context, url, error) => Icon(Icons.error), // エラーの場合に表示するウィジェット
                                    fit: BoxFit.cover, // 画像の表示方法を指定（例：全体をカバー）
                                  )
                                    /*
                                    Image.network(//画像ある場合
                                    filteredMenus[index].imageURL.toString(), // 画像のURLを指定
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
                                      favoriteButton(ref, filteredMenus[index]);
                                    },
                                    // 表示アイコン
                                    icon: Icon(Icons.favorite),
                                    // アイコン色
                                    color: filteredMenus[index].isFavorite!
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
                
                //「今日の夕食」カード下の表示
                }else{
                  return category == '今日の夕食'
                    ? Column(
                    children: [
                      const SizedBox(height: 10),
                      Consumer(builder: (BuildContext context, WidgetRef ref, child){
                        final totalPrice = ref.watch(totalPriceNotifierProvider); //「今日の夕飯」タブの人前を変更した時に、再描写する。
                        return Text("${DateFormat('yyyy/MM/dd(E)','ja').format(DateTime.now()) }の夕食  合計${totalPrice}円");
                      }),

                      filteredMenus.isNotEmpty
                      ? OutlinedButton(//枠線ありボタン
                        onPressed: () { 
                          //dinner作成
                          Dinner dinner = Dinner();
                          dinner.createAt = DateTime.now();
                          dinner.price = ref.read(totalPriceNotifierProvider);
                          dinner.select = filteredMenus.map((menu)=>menu.name!).toList();
                          dinner.selectID = filteredMenus.map((menu)=>menu.id!).toList();
                          DinnerRepository().addDinner(dinner);//データベースにデータ追加
                          
                          //最近食べた日の項目更新
                          filteredMenus.forEach((menu){
                            menu.dinnerDateBuf = menu.dinnerDate;//バッファに保存してから
                            menu.dinnerDate = DateTime.now();//更新
                            MenuRepository().updateMenu(menu);
                          });

                          //ページ遷移
                          ref.read(pageProvider.notifier).state = 2;
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MainPage()),
                          );
                         },
                        child: const Text('今日の夕飯はこれで決まり！'),
                      )
                        : OutlinedButton(//枠線ありボタン
                        onPressed: () { 
                            category = '全て';
                            //ページ遷移
                          ref.read(pageProvider.notifier).state = 0;
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MainPage()),
                          );

                         },
                        child: const Text('夕飯を選択してね'),
                      ),
                    ],
                  )
                  :const SizedBox.shrink();
                }
              }
            );
                      }
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
                    print('ファイルが削除されました。');
                  } else {
                    print('ファイルは存在しません。');
                  }
                  ref.read(selectedImageProvider.notifier).state = null;

              ref.read(pageProvider.notifier).state = 3;//表示ページの設定
              Navigator.push(
                // ファイルのパスを指定
                  
                  context,
                  
                  MaterialPageRoute(builder: (context) => MainPage()),
              );
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
