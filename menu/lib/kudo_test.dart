import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menu/data/providers.dart';
import 'package:menu/kudo_test.dart';
import 'data/model/menu.dart';
import 'data/model/user.dart';
import 'data/repository/menu_repository.dart';

class KudoTest extends ConsumerWidget{

  List<Menu>? menuList;

  Widget build(BuildContext context, WidgetRef ref){
    User user = User(
            createAt: DateTime.now(), 
            uid: "AC3iWb7RnqM4gCmeLOD9"
            );
    // providerからメニューリストを取得
    final menuListAsyncValue= ref.watch(menuListProvider);
    
    return Scaffold(
        appBar: AppBar(
          title: const Text('Scaffold Example'),
        ),

        body: Column(
          children: [
            menuListAsyncValue.when(
              data: (menuList) {
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
                          menu.name = "test";
                          MenuRepository(user).editMenu(menu);
                        },
                        child: ListTile(
                      title: Text(menu.name ?? "No Name"),
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
            ElevatedButton(
              onPressed: () {
                // メニューの追加処理
                  Menu menu = Menu(
                    name: "唐揚げ",
                    createAt: DateTime.now(),
                  );

                  // MenuRepositoryインスタンスを作成し、addMenuを呼び出す
                  MenuRepository(user).addMenu(menu);
                },
              child: const Text('Add Menu'),
            ),
            ElevatedButton(
              onPressed: () {

                //MenuRepositoryインスタンスを作成し、addMenuを呼び出す
                 //MenuRepository(user).deleteMenu(menuList![0]);
                 
                },
              child: const Text('Delete Menu'),
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
