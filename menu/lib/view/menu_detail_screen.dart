import 'dart:io'; //Fileを扱うため
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart'; //画像キャッシュ
//import 'package:flutter/services.dart'; //数字入力のため
import 'package:flutter/material.dart';
import 'package:menu/common/common_widget.dart';
//import 'package:menu/common/common_widget.dart';
import 'package:menu/data/model/menu.dart';
//import 'package:menu/data/model/material.dart';
import 'package:menu/data/repository/menu_repository.dart';
//import 'package:menu/data/model/user.dart';
//import 'package:menu/view/menu_list_screen.dart';
import 'package:menu/view/main_screen.dart';
import 'package:menu/data/repository/image_repository.dart';
import 'package:menu/view_model/menu_view_model.dart';
import 'package:menu/common/common_providers.dart';
//import 'package:menu/common/common_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:menu/data/model/user.dart';

class MenuDetailScreen extends ConsumerStatefulWidget {

  Menu? menu;//遷移元listから選択されたmenuを受け取る。
  MenuDetailScreen({required this.menu});//コンストラクタで名前つきでデータを受け取る。

  @override
  _MenuDetailScreenState createState() => _MenuDetailScreenState();
}

class _MenuDetailScreenState extends ConsumerState<MenuDetailScreen> {
  late Menu menu;

  @override
  void initState() {
    super.initState();
    menu = widget.menu!; //widgetからメニューを受け取る。
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(//スクロール可能とする
      child: Stack( //お気に入りボタンを右上に配置するため、stack使用。
        children: [

          //タグの表示
          Positioned(
            top: 10,
            left: 10,
            child: Text(menu.tag!),
          ),

          //お気に入りボタン
          Positioned(
            top: 0,
            right: 60,
            child: IconButton(
              onPressed: () {
                setState((){ //再描写のためにsetStateを使用。
                  menu!.isFavorite = !(menu.isFavorite!);
                  });
              },
              // 表示アイコン
              icon: const Icon(Icons.favorite),
              // アイコン色
              color: menu.isFavorite! == true
              ? Colors.pink
              : Colors.grey,
              // サイズ
              iconSize: 25,
            )
          ),

          //削除ボタン
          Positioned(
            top: 0,
            right: 30,
            child: IconButton(
            icon: const Icon(Icons.delete),
            
            //ポップアップ表示して削除しても良いかを確認する。
            onPressed: () async{
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
                          await ImageRepository(currentUser!, menu, ref).deleteImage(); 
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
                print("delete");
                print(currentUser!.uid);
                MenuRepository().deleteMenu(menu); //メニュー削除
                Navigator.pop(context);//元画面(メニュー一覧)に遷移
              } else {
                // 「いいえ」が選択された場合、何もしない
                print('操作をキャンセルしました');
              }

            },
            iconSize: 25,
          ),
          ),

          //編集ボタン
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
            icon: const Icon(Icons.edit),
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

              ref.read(pageProvider.notifier).state = 6;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MainPage(menu: menu)),
                );
            },
            iconSize: 25,
          ),
          ),


          Center(
            child: Column(
            children: [
              //料理名ーーーーーーーーー
                  Text(
                    maxText(menu.name!, 9),
                    style: const TextStyle(
                      //color: Colors.red,
                      fontSize: 30,
                      fontWeight: FontWeight.bold
                    ),
                    //textAlign: TextAlign.center,
                  ),

              //画像ーーーーーーーーーー
              Container(
                    width: 350,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200], // 背景色
                      border: Border.all(color: Colors.grey), // 枠線
                      //borderRadius: BorderRadius.circular(10), // 角丸
                    ),
                    child: menu.imageURL == "noData"
                    ? Image.asset( //画像ない場合
                        'images/no_image.jpg',
                        //height: 100,
                        //width: 50,
                        fit: BoxFit.cover,
                      )
                    : CachedNetworkImage(
                        imageUrl: menu.imageURL!.toString(), // ネットワーク画像のURL
                        
                        placeholder: (context, url) =>  Transform.scale(//sizedboxでは小さくならなかったのでscaleを使用。
                          scale: 0.3, // 縮小率を指定
                          child: const CircularProgressIndicator(strokeWidth: 20.0),
                        ),
                        
                        errorWidget: (context, url, error) => Icon(Icons.error), // エラーの場合に表示するウィジェット
                        fit: BoxFit.cover, // 画像の表示方法を指定（例：全体をカバー）
                      )),
                    /*
                    ClipRRect(
                        //borderRadius: BorderRadius.circular(10), // 選択画像の角丸
                        child: Image.network(
                          menu.imageURL!,
                          fit: BoxFit.cover, // 領域に合わせて表示
                          width: 350,
                          height: 200,
                        ),
                      ),
              ),
              */
              const SizedBox(height: 10,),


            //材料ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
            Row(//Rowで囲まないと材料が左揃えにならないため。
              children: [
                _titleText(title: '    材料   '),
                Row(
                  children: [
                    Text(menu.quantity.toString()),
                    Text("人前"),
                  ],
                ),
                const SizedBox(height: 10,),
              ],
            ),
            const SizedBox(height: 10,),

            //材料表示のエリア
                Column(                  
                  children: 
                    List.generate(menu.material!.length, (index){//index取得のためList.generate使用。mapではindex取得できないため。
                      final map = menu.material![index];
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 100,
                                child:Text(map['name'],
                                textAlign: TextAlign.center, // テキストを中央揃え),
                                )
                              ),
                              SizedBox(
                                width: 50,
                                child: Text(map['quantity'].toString()+map['unit'],
                                textAlign: TextAlign.center
                                ),
                              ),
/*
                              SizedBox(
                                width: 70,
                                child: Text(map['unit'],
                                textAlign: TextAlign.center
                                ),
                              ),
                              */
                              Row(
                                children: [
                                  SizedBox(
                                    width: 80,
                                    child: Text(map['price'].toString()+" 円",
                                    textAlign: TextAlign.center),
                                    ),
                                  //const Text(" 円"),
                                ]
                              ),
                             
                            ],
                          ),
                          SizedBox(//完全にパディングをなくした横線
                            height: 0.5, // Divider の厚みに合わせる
                            child: Container(
                              color: Colors.grey, // Divider の色に合わせる
                              margin: EdgeInsets.only(left: 20, right: 20), // indent と endIndent を再現
                            ),
                          ),
                          const SizedBox(height: 2,),
                        ]
                      );
                    }
                  )
                ),

            const SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
            Text(
              "合計："+ menu.price.toString()+" 円",
              ),
              const SizedBox(width: 20,),
              ],
            ),


            //メモ------------------------------------------------------
            Row(//Rowで囲まないと材料が左揃えにならないため。
              children: [
                _titleText(title: '    メモ   '),
              ],
            ),
            const SizedBox(height: 5,),
            Row(//Rowで囲まないと材料が左揃えにならないため。
              children: [
                SizedBox(width: 20.0), 
                Text(menu.memo!),
              ],
            ),
            
            const SizedBox(height: 10,),

            //メモ------------------------------------------------------
            Row(//Rowで囲まないと材料が左揃えにならないため。
              children: [
                _titleText(title: '    作り方   '),
              ],
            ),
            const SizedBox(height: 5,),
            Row(//Rowで囲まないと材料が左揃えにならないため。
              children: [
                SizedBox(width: 20.0), 
                Text(menu.howToMake!),
              ],
            ),
            
            const SizedBox(height: 10,),

            ]
          )
          )
       ]
 )
    );

  }
}

//タイトルテキストの設定
Widget _titleText({
  required String title,
}) {
  return Text(
    title,
    style: const TextStyle(
      //color: Colors.red,
      fontSize: 20,
      fontWeight: FontWeight.bold
    ),
    textAlign: TextAlign.left,
  );
}
