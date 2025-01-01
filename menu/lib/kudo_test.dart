import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menu/data/providers.dart';
import 'package:menu/kudo_test.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menu/data/providers.dart';
import 'package:menu/data/repository/image_repository.dart';
//import 'package:menu/kudo_test.dart';
import 'data/model/menu.dart';
import 'data/model/user.dart';
import 'data/model/dinner.dart';
import 'data/repository/menu_repository.dart';
import 'data/repository/user_repository.dart';
import 'data/repository/dinner_repository.dart';
//import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KudoTest extends ConsumerWidget {
  List<Menu>? menuList;

  Widget build(BuildContext context, WidgetRef ref) {
    UserModel user = UserModel(
        //createAt: DateTime.now(),
        uid: "OFvJx1IkQ0ZhMtEpaJVr9NoRD7x2");


    Menu menu3 = Menu(
      id: "OFvJx1IkQ0ZhMtEpaJVr9NoRD7x2",
      imagePath: "users/AC3iWb7RnqM4gCmeLOD9/images/1735476387866395_IMG_0111.jpeg"
      );
      Menu menu2 = Menu(
                    name: "唐揚げ",
                    createAt: DateTime.now(),
                    dinnerDate: DateTime.now(),
                    memo: "あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよ",
                    material: [
                    {"name": "にんじん", "quantity": 1, "unit": "本", "price": 100},
                    {"name": "ピーマン", "quantity": 2, "unit": "個", "price": 200},
                    {"name": "キャベツ", "quantity": 3, "unit": "個", "price": 50}
                    ],
                    id: "IzLlkWNi8TLq63NMTJ5z",
                  );
    //Dinner dinner = Dinner(

      //createAt: DateTime.now(),
    //);
    Dinner dinner = Dinner(
        createAt: DateTime.now(),
        select: ["ハンバーグ", "ご飯", "コーンスープ"],
        price: 300,
        id: "XF7TLo7nZdXVYdOrlmc3");
    // providerからメニューリストを取得
    final menuListAsyncValue = ref.watch(menuListProvider);
    final dinnerListAsyncValue = ref.watch(dinnerListProvider);
    final currentUser = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scaffold Example'),
      ),

      body: Column(
        children: [
          menuListAsyncValue.when(
            data: (menuList) {
              //menu2 = menuList[0];
              // メニューリストをリアルタイムで表示
              return Expanded(
                  child: ListView.builder(
                itemCount: menuList.length,
                itemBuilder: (context, index) {
                  final menu = menuList[index];
                  return Card(
                      child: InkWell(
                        onTap: () {
                          print(menu.id);
                          //menu.name = "test";
                          //MenuRepository(user).editMenu(menu);
                        },
                        child: ListTile(
                      title: Text(menu.name!),
                      subtitle: Text(menu.id.toString()+","+menu.createAt.toString()),
                      
                    )
                      )
                    );
                    
                  },
                )
              );
                
              },
              loading: () => Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  Center(child: Text('Error: ${error.toString()}')),
            ),
            Row(
              children: [

                // メニューの追加処理
                ElevatedButton(
                  onPressed: () {
                    // MenuRepositoryインスタンスを作成し、addMenuを呼び出す
                    MenuRepository(currentUser!).addMenu(menu2);
                  },

                child: const Text('Add Menu'),
              ),
            ],
          ),

          //ログイン系
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  UserRepository().createUser("test@test.com", "testtest");
                  //MenuRepositoryインスタンスを作成し、addMenuを呼び出す
                  //MenuRepository(user).deleteMenu(menuList![0]);
                },
                child: const Text('User新規登録'),
              ),
              ElevatedButton(
                onPressed: () {
                  //loginの返り値が非同期のため、結果が確定してからuserに代入する処理とする。
                  UserRepository()
                      .loginWithEmail("test@test.com", "testtest")
                      .then((userModel) {
                    final user = UserRepository().getCurrentUser();
                    print(user!.uid);
                  });
                },
                child: const Text('ログイン'),
              ),
              ElevatedButton(
                onPressed: () {
                  //loginの返り値が非同期のため、結果が確定してからuserに代入する処理とする。
                  UserRepository().logout().then((userModel) {
                    final user = UserRepository().getCurrentUser();
                    print(user);
                  });
                },
                child: const Text('ログアウト'),
              ),
            ],
          ),

          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  ImageRepository(user, menu2)
                      .addImage()
                      .then((value) => print(menu2.imageURL));
                },
                child: const Text('画像追加'),
              ),
              ElevatedButton(
                onPressed: () {
                  print(menu2.id);
                  ImageRepository(user, menu2)
                      .deleteImage()
                      .then((value) => print(menu2.imageURL));
                },
                child: const Text('画像削除'),
              ),
            ],
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  DinnerRepository(currentUser!).addDinner(dinner);
                },
                child: const Text('夕食新規'),
              ),
              ElevatedButton(
                onPressed: () {
                  DinnerRepository(currentUser!).deleteDinner(dinner);
                },
                child: const Text('夕食削除'),
              ),
              ElevatedButton(
                onPressed: () {
                  //print(dinner.id);
                  DinnerRepository(currentUser!).editDinner(dinner);
                },
                child: const Text('夕食編集'),
              ),
            ],
          ),
        ],
      ),

      //Text("test"),
      /*
        StreamBuilder(
         
          stream: MenuRepository(user).getMenuList(), 
          builder: (context, snapshot){
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // ローディング中
            } else if (snapshot.hasError) {
              return Text('エラー: ${snapshot.error}'); // エラーが発生した場合
            } else if (snapshot.hasData) {
              List<Menu> menus = snapshot.data!;
              if (menus.isNotEmpty) {
                String menuName = menus[0].name ?? 'デフォルトの名前';  // `name`がnullの場合のデフォルト値を設定
                return Text(menuName); // メニューリストの最初の項目を表示
              } else {
                return Text("データなし"); // メニューが空の場合
              }
            } else {
              return Text("データなし"); // 他のケース（null など）
            }
             

            //return Text(menus[0].name!);
          },
          ),
        */
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // ボタンが押されたときの処理
          print('FloatingActionButton pressed!');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
