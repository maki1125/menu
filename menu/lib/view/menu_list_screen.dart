import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menu/view_model/menu_list_view_model.dart';
import 'package:intl/intl.dart';

class MenuList extends ConsumerWidget {
  

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    

    //テストのためのテキスト
    String longText = 'あいうえおかきくけこさしすせそたちつてと';
    int nameMaxLength = 10;
    final menuListAsyncValue= ref.watch(menuListProvider);
    final totalPrice = ref.watch(totalPriceProvider);


    return menuListAsyncValue.when(
      data: (menus){
        return ListView.builder(
        itemCount: menus.length,
        itemBuilder: (context, index){
        return Card(
          elevation: 1, //影の深さ
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(//タッチした時にインクが広がる感じのエフェクトを設定
            onTap: () {
              print("Card tapped!");
            },
            child: Row(
              children: [

                 //テキストエリア
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
                            Text(menus[index].name!.length > nameMaxLength ? '${menus[index].name!.substring(0, nameMaxLength)}...' : menus[index].name!,
                              style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),),
                            //Icon(Icons.favorite),
                            
                          ],
                        ),

                        //2列目(最近食べた日）
                        Text("最近食べた日:${menus[index].dinnerDate != null ? 
                        DateFormat('yyyy/MM/dd(E)','ja').format(menus[index].dinnerDate!) : 
                        "ー"}",
                        style: TextStyle(fontSize: 13),),

                        //3列目(メモ）
                        Text(menus[index].memo!.length > 37 ? '${menus[index].memo!.substring(0, 37)}...' : menus[index].memo!,
                        style: TextStyle(fontSize: 13),), // 余白を挿入

                        //4列目(ボタンと値段）
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            
                            OutlinedButton(//枠線ありボタン
                              onPressed: () { /* ボタンがタップされた時の処理 */ },
                              style: OutlinedButton.styleFrom(
                                //padding: EdgeInsets.zero, // 完全にパディングを削除
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2), // パディングを調整
                                minimumSize: Size(50, 20), // 最小サイズを指定
                              ),
                              child: Text('今日の夕飯にする',
                              style: TextStyle(fontSize: 13),
                              ),  
                            ),
                            Text("1人前:${totalPrice[index]}円",
                            //style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      ],
                    )
                ),

                //画像エリア
                Expanded(
                  flex: 1,//画像領域の比率
                  child: Stack(
                    children: [

                      //画像
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child:Image.asset(
                          'images/no_image.jpg',
                          //height: 100,
                          //width: 50,
                          fit: BoxFit.cover,
                        ),
                      ),

                      //お気に入りアイコン
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          onPressed: () {},
                          // 表示アイコン
                          icon: Icon(Icons.favorite),
                          // アイコン色
                          color: Colors.pink,
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
        );
      }
    );
      }, 
      error: (e, stackTrace) => Center(child: Text('Error: $e')), 
      loading: () => Center(child: CircularProgressIndicator()),
      );
    
  }
}
