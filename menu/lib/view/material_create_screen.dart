import 'package:flutter/material.dart';
import 'package:menu/data/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menu/data/repository/material_repository.dart';
import 'package:menu/data/model/material.dart';

class MaterialCreateScreen extends ConsumerStatefulWidget {
  MaterialCreateScreen({super.key});

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('材料の登録'),
        centerTitle: true,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
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
              hintText: '250',
              controller: priceController,
              keyboardType: TextInputType.number),
          SizedBox(height: 20),
          SizedBox(
            width: 100,
            child: FilledButton(
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

                  // フォームのクリア
                  materialController.clear();
                  quantityController.clear();
                  unitController.clear();
                  priceController.clear();
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
            ),
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
          hintStyle: TextStyle(color: const Color.fromARGB(255, 198, 198, 198)), // hintTextの色を設定
        ),
      ),
    );
  }
}
