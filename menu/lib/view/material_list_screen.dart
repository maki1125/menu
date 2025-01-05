import 'package:flutter/material.dart';
//import 'package:menu/data/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menu/data/repository/material_repository.dart';
import 'package:menu/view/material_create_screen.dart';
import 'package:menu/view_model/material_list_view_model.dart';
import 'package:menu/view/main_screen.dart';
//import 'package:menu/data/providers.dart';
import 'package:menu/common/common_providers.dart';
import 'package:menu/common/common_constants.dart';

class MaterialListScreen extends ConsumerWidget {
  MaterialListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materialList = ref.watch(materialListProvider);

    return Stack(
      children: [
        SingleChildScrollView(
          // スクロール可能なウィジェット
          child: Column(
            children: <Widget>[
              materialList.when(
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

                  return ListView.builder(
                    shrinkWrap: true, // 高さ自動調整
                    physics: NeverScrollableScrollPhysics(), // スクロール禁止
                    itemCount: materials.length, // リストの数
                    itemBuilder: (context, index) {
                      final material = materials[index]; // 材料データ

                      return ListTile(
                        title: Card(
                          elevation: 2.0,
                          margin: EdgeInsets.all(0), // 余白
                          shape: RoundedRectangleBorder(
                            // カードの形状
                            side: BorderSide(
                                color: Colors.blue, width: 1.0), // 枠線
                            borderRadius: BorderRadius.circular(10.0), // 角丸
                          ),
                          child: ListTile(
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10.0),
                            // リストの中身
                            title: Text(
                              '${material.name ?? ''}   ${material.quantity?.toString()}${material.unit}   ${material.price?.toString()}円',
                              overflow: TextOverflow.ellipsis, // テキストがはみ出た場合の処理
                              maxLines: 1,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min, // 最小サイズ
                              mainAxisAlignment: MainAxisAlignment.end, // 右寄せ
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit), // 編集アイコン
                                  onPressed: () {
                                    ref
                                        .read(selectButtonProvider
                                            .notifier) // ボタンの状態を更新
                                        .state = 'edit';
                                    ref
                                        .read(materialProvider
                                            .notifier) // 材料データを更新
                                        .updateMaterial(
                                            material); // 選択した材料データを更新
                                    // ref.read(indexProvider.notifier).state =
                                    //     index;
                                    ref.read(pageProvider.notifier).state = 0;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        // 画面遷移
                                        builder: (context) => MainPage(),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  // 削除アイコン
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    MaterialRepository(currentUser!)
                                        .deleteMaterial(material);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => CircularProgressIndicator(), // ローディング中
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

              ref.read(selectButtonProvider.notifier).state = 'Resist'; // ボタンの状態を更新
              ref.read(pageProvider.notifier).state = 0;
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) =>
              //         MaterialCreateScreen(user: currentUser!), // 画面遷移
              //   ),
              // );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MainPage(), // 画面遷移
                ),
              );
            },
            child: const Icon(Icons.add), // 追加アイコン
          ),
        ),
      ],
    );
  }
}
