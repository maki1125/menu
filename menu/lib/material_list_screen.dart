import 'package:flutter/material.dart';
import 'package:menu/view_model/material_list_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menu/data/repository/material_repository.dart';
import 'package:menu/view/material_create_screen.dart';
import 'package:menu/data/providers.dart';

class MaterialListScreen extends ConsumerWidget {
  MaterialListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materialList = ref.watch(materialListProvider); // 材料データ取得

    return Scaffold(
      body: Column(
        children: <Widget>[
          materialList.when(
            // データ取得状態による表示切り替え
            data: (materials) {
              return Expanded(
                child: ListView.builder(
                  itemCount: materials.length, // リストの数
                  itemBuilder: (context, index) {
                    final material = materials[index]; // 材料データ

                    return ListTile(
                      title: Card(
                        elevation: 2.0,
                        margin: EdgeInsets.all(0), // 余白
                        shape: RoundedRectangleBorder(
                          // カードの形状
                          side: BorderSide(color: Colors.blue, width: 1.0),
                          borderRadius: BorderRadius.circular(10.0), // 角丸
                        ),
                        child: ListTile(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10.0),
                          title: Text(
                            '${material.name ?? ''}${material.quantity?.toString()}${material.unit}   ${material.price?.toString()}円',
                            overflow: TextOverflow.ellipsis, // テキストがはみ出た場合の処理
                            maxLines: 1,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min, // 最小サイズ
                            mainAxisAlignment: MainAxisAlignment.end, // 右寄せ
                            children: [
                              IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    ref // ボタンの状態を更新
                                        .read(selectButtonProvider.notifier)
                                        .state = 'edit';
                                    ref // 材料データを更新
                                        .read(materialProvider.notifier)
                                        .updateMaterial(material);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            MaterialCreateScreen(
                                                // 材料登録画面へ遷移
                                                user: currentUser!),
                                      ),
                                    );
                                  }),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  // 材料データ削除
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
                ),
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (error, stackTrace) => const Text('エラーが発生しました'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(selectButtonProvider.notifier).state = 'Resist'; // ボタンの状態を更新
          Navigator.push(
            context, // 材料登録画面へ遷移
            MaterialPageRoute(
              builder: (context) => MaterialCreateScreen(user: currentUser!),
            ),
          );
        },
        child: const Icon(Icons.add), // 追加アイコン
      ),
    );
  }
}
