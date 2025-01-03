import 'package:flutter/material.dart';
import 'package:menu/view_model/material_list_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menu/data/repository/material_repository.dart';
import 'package:menu/data/model/material.dart';
import 'package:menu/data/model/user.dart';
import 'package:menu/data/providers.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MaterialCreateScreen extends StatefulWidget {
  MaterialCreateScreen({super.key, required this.user});

  final UserModel user;

  @override
  _MaterialCreateScreenstate createState() => _MaterialCreateScreenstate();
}

class _MaterialCreateScreenstate extends State<MaterialCreateScreen> {
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
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        // 材料データ取得
        final material = ref.watch(materialProvider);
        final selectButton = ref.watch(selectButtonProvider);

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
                hintText: '例：牛肉',
                controller: materialController,
                keyboardType: TextInputType.text),
            SizedBox(height: 20),
            _buildTextField(
                labelText: '数量',
                controller: quantityController,
                keyboardType: TextInputType.number),
            SizedBox(height: 20),
            _buildTextField(
                labelText: '単位',
                hintText: '例：本、袋',
                controller: unitController,
                keyboardType: TextInputType.text),
            SizedBox(height: 20),
            _buildTextField(
                labelText: '価格',
                controller: priceController,
                keyboardType: TextInputType.number),
            SizedBox(height: 20),
            SizedBox(
              width: 100,
              child: selectButton == 'Resist'
                  ? _resisterButton()
                  : _updateButton(ref),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blueAccent,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('戻る'),
            )
          ]),
        );
      },
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
  }) {
    return SizedBox(
      width: 300,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
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

  // 登録ボタン
  Widget _resisterButton() {
    return FilledButton(
      onPressed: () async {
        final material = MaterialModel(
          name: materialController.text,
          quantity: int.tryParse(quantityController.text),
          unit: unitController.text,
          price: int.tryParse(priceController.text),
          //createAt: DateTime.now(),
        );
        try {
          // 追加
          await MaterialRepository(currentUser!).addMaterial(material);
          clearform();

          Navigator.pop(context);
          // Toast
          Fluttertoast.showToast(gravity: ToastGravity.BOTTOM, msg: '登録しました');
        } catch (e) {
          _showErrorDialog('登録に失敗しました。再度お試しください。');
        }
      },
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      child: const Text('登録'),
    );
  }

  Widget _updateButton(WidgetRef ref) {
    return FilledButton(
      onPressed: () async {
        final material = ref.watch(materialProvider);
        final materials = MaterialModel(
          id: material.id,
          name: materialController.text,
          quantity: int.tryParse(quantityController.text),
          unit: unitController.text,
          price: int.tryParse(priceController.text),
          //createAt: DateTime.now(),
        );
        try {
          // 更新
          await MaterialRepository(currentUser!).updateMaterial(materials);

          clearform();
        } catch (e) {
          _showErrorDialog('更新に失敗しました。再度お試しください。$e');
        }
      },
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      child: const Text('更新'),
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
