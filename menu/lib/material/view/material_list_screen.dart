import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:menu/main_screen.dart';
import 'package:menu/common/common_providers.dart';
import 'package:menu/common/common_widget.dart';
import 'package:menu/material/data/repository/material_repository.dart';
import 'package:menu/material/view_model/material_view_model.dart';
import 'package:menu/material/data/model/material.dart';

class MaterialListScreen extends ConsumerStatefulWidget {
  const MaterialListScreen({super.key});

  @override
  MaterialListScreenState createState() => MaterialListScreenState();
}

class MaterialListScreenState extends ConsumerState<MaterialListScreen> {
  late TextEditingController searchController; // 検索テキストフィールドのコントローラー

  // initstate disposeを適切に行うことでtextfieldの値がリセットされない
  @override
  void initState() {
    super.initState();
    searchController = TextEditingController(); // コントローラーの初期化

    //ビルド後に実行
    Future.microtask(() {
      ref.read(searchTextProvider.notifier).state = ""; //検索の文字列を初期化
    });
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose(); // コントローラーの破棄
  }

  @override
  Widget build(BuildContext context) {
    final materialList = ref.watch(materialListProvider); // 材料データ取得
    final filteredMaterials = ref.watch(filteredMaterialsProvider); // フィルタリングされた材料データ

    return GestureDetector(// テキストフィールド以外をタッチしたときにキーボードを閉じるためにGestureDetector使用。
        onTap: () {
          // テキストフィールド以外をタッチしたときにキーボードを閉じる。FocusNodeでフォーカスを外す
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Stack(//フローティングボタンのためにstack使用。
          children: [

            //データの取得状況により表示を分ける
            materialList.when(
              data: (materials) {
                if (materials.isEmpty) {
                  //データがない場合
                  return const Center(
                    child: Text(
                      '材料が登録されていません',
                      style: TextStyle(height: 10),
                    ),
                  );
                }

                return Column(
                  children: [
                    // 検索テキストフィールド（上部に固定）---------------------------------------
                    searchBox(searchController, ref, searchTextProvider, '材料名'),//ref),//, materials),

                    // 材料カードーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
                    Expanded(
                      child: SingleChildScrollView(
                        child: ListView.builder(
                          shrinkWrap: true, // 高さ自動調整。ListViewが無限広がろうとするのを防ぐ。
                          physics: const NeverScrollableScrollPhysics(), // スクロール禁止
                          itemCount: filteredMaterials.length, // リストの数
                          itemBuilder: (context, index) {
                            final material = filteredMaterials[index]; // 材料データ
                            return Card(
                              color: Colors.white,
                              elevation: 1.0,
                              //margin: const EdgeInsets.all(0), // 余白
                              shape: RoundedRectangleBorder(
                                //side: const BorderSide(
                                //color: Colors.blue, width: 1.0), // 枠線
                                borderRadius: BorderRadius.circular(10.0), // 角丸
                              ),
                              child: Stack(//タップ可能領域（条件によりタップ可能）とアイコン(常時タップ可能）を切り分けるためにstack使用
                                children: [
                                  //テキスト領域（タップ可能領域）ーーーーーーーーーーーーーーーーーーー
                                  IgnorePointer(
                                    //タップできる条件をつける。
                                    ignoring: ref.read(selectMaterialProvider.notifier).state == 0, //「材料一覧から選択」時以外はタッチ不可能にする。
                                    child: InkWell(//タッチした時にインクが広がる感じのエフェクトを設定
                                      onTap: () {
                                        ref.read(selectMaterialProvider.notifier).state = 0; //選択後は、タッチ不可にする。
                                        Navigator.pop(context, material);
                                      },
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
                                        title: Row(
                                          children: [

                                            //材料名
                                            SizedBox(
                                              width: 150,
                                              child: Text(
                                                material["name"] ?? '',
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                maxLines: 1,
                                                //style: TextStyle(fontSize: 16), // フォントサイズの調整
                                              ),
                                            ),

                                            //数量と単位
                                            SizedBox(
                                              width: 70,
                                              child: Text(
                                                material["quantity"].toString() + material["unit"],
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                //style: TextStyle(fontSize: 16), // フォントサイズの調整
                                              ),
                                            ),

                                            //値段
                                            SizedBox(
                                              width: 70,
                                              child: Text(
                                                "${material["price"].toString()} 円",
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                //style: TextStyle(fontSize: 16), // フォントサイズの調整
                                              ),
                                            ),
                                          ],
                                        )

                                      ),
                                    )
                                  ),

                                  //アイコンの配置ーーーーーーーーーーーーーーーー
                                  Positioned.fill(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min, // 最小サイズ
                                        mainAxisAlignment: MainAxisAlignment.end, // 右寄せ
                                        children: [
                                          //編集アイコン
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () {
                                              //材料ページ遷移
                                              ref.read(pageProvider.notifier).state = 8;
                                              Navigator.push(context,
                                                MaterialPageRoute(builder: (context) => MainPage(material: MaterialModel.fromFirestore(material),),),
                                              );
                                            },
                                          ),

                                          // 削除アイコン
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () {
                                              MaterialRepository().deleteMaterial(MaterialModel.fromFirestore(material));
                                            },
                                          ),
                                        ],
                                      ),
                                    )
                                  )
                                ]
                              )
                            );
                          },
                        ),
                      )
                    ) 
                  ],
                );
              },
              loading: () => const CircularProgressIndicator(), // ローディング中
              error: (error, stackTrace) => Text('エラーが発生しました: $error'),
            ),

            //材料追加ボタン
            Positioned(
              // 画面右下に配置
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: () {
                  //ref.read(selectButtonProvider.notifier).state = 'Resist'; // ボタンの状態を更新
                  ref.read(bottomBarProvider.notifier).state = 1; //ボトムバーの選択
                  ref.read(pageProvider.notifier).state = 4; //表示ページ
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MainPage()),
                  );
                },
                child: const Icon(Icons.add), // 追加アイコン
              ),
            ),
          ],
        )
    );
  }
}
