import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menu/data/repository/material_repository.dart';
import 'package:menu/view/material_create_screen.dart';
import 'package:menu/view_model/material_list_view_model.dart';
import 'package:menu/view/main_screen.dart';
import 'package:menu/common/common_providers.dart';
//import 'package:menu/common/common_constants.dart';

class MaterialListScreen extends ConsumerStatefulWidget {
  const MaterialListScreen({super.key});

  @override
  _MaterialListScreenState createState() => _MaterialListScreenState();
}

class _MaterialListScreenState extends ConsumerState<MaterialListScreen> {
  late TextEditingController searchController; // 検索テキストフィールドのコントローラー

  // initstate disposeを適切に行うことでtextfieldの値がリセットされない
  @override
  void initState() {
    super.initState();
    searchController = TextEditingController(); // コントローラーの初期化
  }

  @override
  void dispose() {
    searchController.dispose(); // コントローラーの破棄
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("material_list");
    final materialList = ref.watch(materialListProvider); // 材料データ取得
    final filteredMaterials =
        ref.watch(filteredMaterialsProvider); // フィルタリングされた材料データ

    return Stack(
      children: [
        SingleChildScrollView(
          // スクロール可能なウィジェット
          child: Column(
            children: <Widget>[
              materialList.when(
                // AsyncValueからデータを取るために必要
                // データ取得状態による表示切り替え
                data: (materials) {
                  if (materials.isEmpty) {
                    return const Center(
                      child: Text(
                        '材料が登録されていません',
                        style: TextStyle(height: 10),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      // 検索テキストフィールド---------------------------------------
                      _buildTextField(
                          searchController, ref, materials), 

                      //const SizedBox(height: 10),

                      // 材料カードーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
                      ListView.builder(
                        shrinkWrap: true, // 高さ自動調整。ListViewが無限広がろうとするのを防ぐ。
                        physics: const NeverScrollableScrollPhysics(), // スクロール禁止
                        itemCount: filteredMaterials.length, // リストの数
                        itemBuilder: (context, index) {
                          final material = filteredMaterials[index]; // 材料データ

                          return ListTile(
                            title: Card(
                              elevation: 2.0,
                              margin: const EdgeInsets.all(0), // 余白
                              shape: RoundedRectangleBorder(
                                // カードの形状
                                side: const BorderSide(
                                    color: Colors.blue, width: 1.0), // 枠線
                                borderRadius: BorderRadius.circular(10.0), // 角丸
                              ),
                              child: IgnorePointer(
                              ignoring:  ref.read(selectMaterialProvider.notifier).state == 0, //タッチできる状態の時、タッチ可能とする。                          
                               child: InkWell(//タッチした時にインクが広がる感じのエフェクトを設定
                                onTap: () {
                                    ref.read(selectMaterialProvider.notifier).state = 0;
                                    Navigator.pop(context, material);
                                },
                                child:  ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                // リストの中身
                                title: Text(
                                  '${material.name ?? ''}   ${material.quantity?.toString()}${material.unit}   ${material.price?.toString()}円',
                                  overflow:
                                      TextOverflow.ellipsis, // テキストがはみ出た場合の処理
                                  maxLines: 1,
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min, // 最小サイズ
                                  mainAxisAlignment:
                                      MainAxisAlignment.end, // 右寄せ
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit), // 編集アイコン
                                      onPressed: () {
                                        ref
                                            .read(selectButtonProvider
                                                .notifier) // ボタンの状態を更新
                                            .state = 'edit';
                                        ref
                                            .read(materialProvider.notifier)
                                            .state = material;

                                        /*
                                        // Mainページに自分のページインデックスを渡す
                                        ref.read(pageProvider.notifier).state = 0;
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            // 画面遷移
                                            builder: (context) => MainPage(),
                                          ),
                                        );
                                        */
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const MaterialCreateScreen()),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      // 削除アイコン
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        MaterialRepository(currentUser!)
                                            .deleteMaterial(material);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              )
                              )

                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
                loading: () => const CircularProgressIndicator(), // ローディング中
                error: (error, stackTrace) => Text('エラーが発生しました: $error'),
              ),
            ],
          ),
        ),
        Positioned(
          // 画面右下に配置
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () {
              ref.read(selectButtonProvider.notifier).state =
                  'Resist'; // ボタンの状態を更新

              ref.read(bottomBarProvider.notifier).state = 1; //ボトムバーの選択
              ref.read(pageProvider.notifier).state = 4; //表示ページ
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MainPage()),
              );
            },
            child: const Icon(Icons.add), // 追加アイコン
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(controller, ref, materials) {
    return SizedBox(
      //width: width,
      child: TextField(
        controller: searchController, // コントローラー
        keyboardType: TextInputType.text, // キーボードタイプ
        textInputAction: TextInputAction.search, // 検索ボタンを表示
        onChanged: (text) {
          ref.read(searchTextProvider.notifier).state = text;
        },
        onSubmitted: (value) {}, // テキストフィールドでエンターキーが押されたときの処理
        decoration: InputDecoration(
          // テキストフィールドの装飾
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            // フィルターや並び替えの機能が追加できる
            icon: const Icon(
              Icons.sort,
              size: 20,
            ),
            onPressed: () {},
          ),
          hintText: '材料名',
          border: InputBorder.none, // 枠線を非表示
          hintStyle: const TextStyle(
              color: Color.fromARGB(255, 198, 198, 198)), // hintTextの色を設定
        ),
      ),
    );
  }
}
