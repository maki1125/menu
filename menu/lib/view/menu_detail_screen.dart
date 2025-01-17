import 'dart:io'; //Fileを扱うため
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:flutter/services.dart'; //数字入力のため
import 'package:flutter/material.dart';
import 'package:menu/common/common_widget.dart';
import 'package:menu/data/model/menu.dart';
import 'package:menu/data/model/material.dart';
//import 'package:menu/data/model/user.dart';
//import 'package:menu/view/menu_list_screen.dart';
import 'package:menu/view/main_screen.dart';
import 'package:menu/data/repository/image_repository.dart';
import 'package:menu/view_model/menu_list_view_model.dart';
import 'package:menu/common/common_providers.dart';
import 'package:menu/common/common_constants.dart';

class MenuDetailScreen extends StatefulWidget {

  Menu? menu;//遷移元listから選択されたmenuを受け取る。
  MenuDetailScreen({required this.menu});//コンストラクタで名前つきでデータを受け取る。

  @override
  _MenuDetailScreenState createState() => _MenuDetailScreenState();
}

class _MenuDetailScreenState extends State<MenuDetailScreen> {
  late Menu menu;

  @override
  void initState() {
    super.initState();
    menu = widget.menu!;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(//スクロール可能とする
      child: 

      Stack( //お気に入りボタンを右上に配置するため、stack使用。
        children: [
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

          //クリアボタン
          Positioned(
            top: 0,
            right: 30,
            child: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              //_clearform();
            },
            iconSize: 25,
          ),
          ),

          //クリアボタン
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              //_clearform();
            },
            iconSize: 25,
          ),
          ),


          Center(
            child: 
          
          Column(
            children: [

              //料理名ーーーーーーーーー

                  
                  Text(
                    menu.name!,
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
                    ? const Center(
                        child: Text(
                          'noImage',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ClipRRect(
                        //borderRadius: BorderRadius.circular(10), // 選択画像の角丸
                        child: Image.network(
                          menu.imageURL!,
                          fit: BoxFit.cover, // 領域に合わせて表示
                          width: 350,
                          height: 200,
                        ),
                      ),
              ),
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
              menu.price.toString()+" 円",
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
