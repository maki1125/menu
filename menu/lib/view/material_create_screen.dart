import 'package:flutter/material.dart';
import 'package:menu/common/common_constants.dart';
import 'package:menu/view_model/material_list_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menu/data/repository/material_repository.dart';
import 'package:menu/data/model/material.dart';
import 'package:menu/data/model/user.dart';
import 'package:menu/data/providers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menu/common/common_providers.dart';

class MaterialCreateScreen extends ConsumerStatefulWidget {
  MaterialCreateScreen({super.key, required this.user});

  final UserModel user;

  @override
  _MaterialCreateScreenstate createState() => _MaterialCreateScreenstate();
}

class _MaterialCreateScreenstate extends ConsumerState<MaterialCreateScreen> {
  final materialController = TextEditingController();
  final quantityController = TextEditingController();
  final unitController = TextEditingController();
  final priceController = TextEditingController();

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

    // フォームにデータをセット

    materialasync.when(
      data: (material) {
        materialController.text = material?.name ?? '';
        quantityController.text = material?.quantity?.toString() ?? '';
        unitController.text = material?.unit ?? '';
        priceController.text = material?.price?.toString() ?? '';
      },
      loading: () => const CircularProgressIndicator(), // ローディング中はインジケーター表示
      error: (e, stack) => Text('エラーが発生しました: $e'), // エラー時にダイアログ表示
    );

    if (selectButton == 'Resist') {
      // 登録ボタンが押された場合、フォームをクリア
      clearform();
    }

    return Material(
      child: SafeArea(
        top: true,
        child: Consumer(
          builder: (context, ref, child) {
            // 材料データ取得
            final material = ref.watch(materialProvider);
            final selectButton = ref.watch(selectButtonProvider); // ボタンの状態取得

            // フォームにデータをセット
            materialController.text = material.name ?? '';
            quantityController.text = material.quantity?.toString() ?? '';
            unitController.text = material.unit ?? '';
            priceController.text = material.price?.toString() ?? '';

            if (selectButton == 'Resist') {
              // 登録ボタンが押された場合、フォームをクリア
              clearform();
            }

            return Center(
              child: Column(children: <Widget>[
                SizedBox(height: 20),
                _buildTextField(
                    labelText: '材料',
                    hintText: '牛肉',
                    controller: materialController,
                    keyboardType: TextInputType.text),
                SizedBox(height: 20),
                _buildTextField(
                    labelText: '数量',
                    hintText: '100',
                    controller: quantityController,
                    keyboardType: TextInputType.number),
                SizedBox(height: 20),
                _buildTextField(
                    labelText: '単位',
                    hintText: 'g',
                    controller: unitController,
                    keyboardType: TextInputType.text),
                SizedBox(height: 20),
                _buildTextField(
                    labelText: '価格',
                    hintText: '200',
                    controller: priceController,
                    keyboardType: TextInputType.number),
                SizedBox(height: 20),
                SizedBox(
                  width: 100,
                  child: selectButton == 'Resist'
                      ? _resisterButton()
                      : _updateButton(ref),

                ),
              ),
            ),
            SizedBox(height: 20),
            _buildTextField(
              labelText: '価格',
              controller: priceController,
              keyboardType: TextInputType.number,
              width: 300,
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 100,
              //child: selectButton == 'Resist'
              child: _actionButton(ref, selectButton), // 登録、更新ボタン
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
            )
          ]),
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
          title: const Text('エラー'),
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
          floatingLabelAlignment: FloatingLabelAlignment.center,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: const OutlineInputBorder(),
          hintStyle: const TextStyle(
              color: Color.fromARGB(255, 198, 198, 198)), // hintTextの色を設定
        ),
      ),
    );
  }

  // 登録、更新ボタン
  Widget _actionButton(WidgetRef ref, selectButton) {
    final materialasync = ref.watch(materialProvider);
    return materialasync.when(
      data: (material) {
        final isUpdate = selectButton != 'Resist';
        print('通過');

        return FilledButton(
          onPressed: () async {
            final materials = MaterialModel(
              id: isUpdate ? material?.id : null, // ID
              name: materialController.text, // 材料名
              quantity: int.tryParse(quantityController.text), // 数量
              unit: unitController.text, // 単位
              price: int.tryParse(priceController.text), // 価格
              //createAt: DateTime.now(),
            );
            try {
              if (isUpdate) {
                await MaterialRepository(currentUser!)
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
                if (currentUser == null) {
                  _showErrorDialog('ユーザー情報が取得できませんでした。');
                }
                await MaterialRepository(currentUser!).addMaterial(materials);
                Fluttertoast.showToast(
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
              _showErrorDialog('${isUpdate ? '更新' : '登録'}に失敗しました。再度お試しください。$e');
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
      },
      //loading: () => const CircularProgressIndicator(),
      loading: () => Text('ローティング'),
      error: (e, stack) => Text('エラーが発生しました: $e'),
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
