import 'package:flutter/material.dart';
import 'package:menu/common/common_constants.dart';
import 'package:menu/view_model/material_list_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menu/data/repository/material_repository.dart';
import 'package:menu/data/model/material.dart';
//import 'package:menu/data/model/user.dart';
//import 'package:menu/data/providers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menu/common/common_providers.dart';

class MaterialCreateScreen extends ConsumerStatefulWidget {
  const MaterialCreateScreen({super.key});

  @override
  _MaterialCreateScreenstate createState() => _MaterialCreateScreenstate();
}

class _MaterialCreateScreenstate extends ConsumerState<MaterialCreateScreen> {
  final materialController = TextEditingController();
  final quantityController = TextEditingController();
  final unitController = TextEditingController();
  final priceController = TextEditingController();

  final List<Map<String, dynamic>> _materialMap = []; // 材料リスト

  @override
  void dispose() {
    materialController.dispose();
    quantityController.dispose();
    unitController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // ウィジェットツリーがビルドされた後に状態を変更する
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 状態変更をここで行う
      ref.read(pageProvider.notifier).state = initOtherPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 材料データ取得
    final materialasync = ref.watch(materialProvider);
    final selectButton = ref.watch(selectButtonProvider); // ボタンの状態取得

    if (selectButton == 'Resist') {
      // 登録ボタンが押された場合、フォームをクリア
      clearform();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '材料登録',
        ),
        centerTitle: true,
        elevation: 10.0,
        backgroundColor: Colors.white,
      ),
      body: Material(
        child: SafeArea(
          // スマホのノッチ部分に対応
          top: true,
          child: Center(
            child: materialasync.when(
              data: (material) {
                materialController.text = material?.name ?? '';
                quantityController.text = material?.quantity?.toString() ?? '';
                unitController.text = material?.unit ?? '';
                priceController.text = material?.price?.toString() ?? '';
                print(_materialMap);

                return Column(children: [
                  const SizedBox(height: 10),
                  _materialMap.isEmpty
                      ? SizedBox.shrink()
                      : ListView.builder(
                          shrinkWrap: true, // 高さ自動調整
                          physics:
                              const NeverScrollableScrollPhysics(), // スクロール禁止
                          itemCount: _materialMap.length, // リストの数
                          itemBuilder: (context, index) {
                            final material = _materialMap[index]; // 材料データ

                            return ListTile(
                              title: Card(
                                elevation: 0, // 影の設定
                                margin: const EdgeInsets.all(0), // 余白
                                color: Colors.transparent, // 背景透明
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      //  内部余白
                                      horizontal: 10.0),
                                  // リストの中身
                                  title: Row(
                                    children: <Widget>[
                                      SizedBox(
                                        width: 130,
                                        child: Text(
                                          material['material'],
                                          overflow: TextOverflow
                                              .ellipsis, // テキストがはみ出た場合の処理
                                          maxLines: 1, // 最大行数
                                        ),
                                      ),
                                      SizedBox(
                                        width: 60,
                                        child: Text(
                                          material['quantity'],
                                          overflow: TextOverflow
                                              .ellipsis, // テキストがはみ出た場合の処理
                                          maxLines: 1,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 60,
                                        child: Text(
                                          material['unit'],
                                          overflow: TextOverflow
                                              .ellipsis, // テキストがはみ出た場合の処理
                                          maxLines: 1,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 100,
                                        child: Text(
                                          '${material['price']}円',
                                          overflow: TextOverflow
                                              .ellipsis, // テキストがはみ出た場合の処理
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                  Row(children: <Widget>[
                    const SizedBox(width: 10),
                    _buildTextField(
                      labelText: '材料名',
                      hintText: '牛肉',
                      controller: materialController,
                      keyboardType: TextInputType.text,
                      width: 120,
                    ),
                    const SizedBox(width: 10),
                    _buildTextField(
                      labelText: '数量',
                      hintText: '10',
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      width: 50,
                    ),
                    const SizedBox(width: 10),
                    _buildTextField(
                      labelText: '単位',
                      hintText: 'g',
                      controller: unitController,
                      keyboardType: TextInputType.text,
                      width: 50,
                    ),
                    const SizedBox(width: 10),
                    _buildTextField(
                      labelText: '価格',
                      hintText: '400',
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      width: 80,
                    ),
                    const SizedBox(width: 10),
                    selectButton != 'Resist'
                        ? const SizedBox.shrink()
                        : IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              materialController.text.isEmpty
                                  ? _showErrorDialog('材料名を入力してください')
                                  : quantityController.text.isEmpty
                                      ? _showErrorDialog('数量を入力してください')
                                      : unitController.text.isEmpty
                                          ? _showErrorDialog('単位を入力してください')
                                          : priceController.text.isEmpty
                                              ? _showErrorDialog('価格を入力してください')
                                              : setState(() {
                                                  _materialMap.add({
                                                    'material':
                                                        materialController.text,
                                                    'quantity':
                                                        quantityController.text,
                                                    'unit': unitController.text,
                                                    'price':
                                                        priceController.text,
                                                  });
                                                });
                            },
                          ),
                  ]),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: 100,
                    //child: selectButton == 'Resist'
                    child:
                        _actionButton(ref, selectButton, material), // 登録、更新ボタン
                    //material.id == null ? _resisterButton() : _updateButton(ref),
                  ),
                  // 戻るボタン
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blueAccent,
                    ),
                    onPressed: () {
                      ref.read(pageProvider.notifier).state = initOtherPage;
                      Navigator.pop(context);
                    },
                    child: const Text('戻る'),
                  ),
                ]);
              },
              loading: () =>
                  const CircularProgressIndicator(), // ローディング中はインジケーター表示
              error: (e, stack) => Text('エラーが発生しました: $e'), // エラー時にダイアログ表示
            ),
          ),
        ),
      ),
    );
  }

  // エラーダイアログの表示
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('閉じる'),
            ),
          ],
        );
      },
    );
  }

  // テキストフィールドの作成
  Widget _buildTextField({
    required String labelText,
    final String hintText = '',
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    final double width = 130,
  }) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller, // コントローラー
        keyboardType: keyboardType, // キーボードタイプ
        decoration: InputDecoration(
          // テキストフィールドの装飾
          labelText: labelText,
          hintText: hintText,
          //floatingLabelAlignment: FloatingLabelAlignment.center,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: const OutlineInputBorder(),
          hintStyle: const TextStyle(
              color: Color.fromARGB(255, 198, 198, 198)), // hintTextの色を設定
        ),
      ),
    );
  }

  // 登録、更新ボタン
  Widget _actionButton(WidgetRef ref, selectButton, material) {
    final isUpdate = selectButton != 'Resist';

    // 登録できる段階かを判定
    final isButtonDisabled = !isUpdate && _materialMap.isEmpty;

    return FilledButton(
      onPressed: isButtonDisabled
          ? null // 一つも追加されていない場合はボタンを無効化
          : () async {
              try {
                if (isUpdate) {
                  final materials = MaterialModel(
                    id: material?.id, // ID
                    name: materialController.text, // 材料名
                    quantity: int.tryParse(quantityController.text), // 数量
                    unit: unitController.text, // 単位
                    price: int.tryParse(priceController.text), // 価格
                    //createAt: DateTime.now(),
                  );
                  await MaterialRepository(currentUser!) // データ更新
                      .updateMaterial(materials);
                  // Toast
                  Fluttertoast.showToast(
                    timeInSecForIosWeb: 1,
                    gravity: ToastGravity.CENTER,
                    fontSize: 16,
                    msg: '更新しました',
                  ); //ダイアログ表示
                } else {
                  // 追加
                  final materials = _materialMap.map((e) {
                    return MaterialModel(
                      name: e['material'], // 材料名
                      quantity: int.tryParse(e['quantity']), // 数量
                      unit: e['unit'], // 単位
                      price: int.tryParse(e['price']), // 価格
                      //createAt: DateTime.now(),
                    );
                  }).toList();
                  if (currentUser == null) {
                    // ユーザー情報が取得できない場合
                    _showErrorDialog('ユーザー情報が取得できませんでした。');
                  }
                  for (var i = 0; i < materials.length; i++) {
                    await MaterialRepository(currentUser!) // データ登録
                        .addMaterial(materials[i]);
                  }

                  Fluttertoast.showToast(
                    // 画面下に一時的にメッセージ表示
                    timeInSecForIosWeb: 1,
                    gravity: ToastGravity.CENTER, // 位置
                    fontSize: 16,
                    msg: '登録しました',
                  );
                }

                clearform();

                Navigator.pop(context);
                // Toast
              } catch (e) {
                _showErrorDialog(
                    '${isUpdate ? '更新' : '登録'}に失敗しました。再度お試しください。$e');
              }
            },
      // ボタンのスタイル
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          // ボタンの形
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      child: Text(isUpdate ? '更新' : '登録'),
    );
  }

  // フォームのクリア
  void clearform() {
    materialController.clear();
    quantityController.clear();
    unitController.clear();
    priceController.clear();
  }
}
