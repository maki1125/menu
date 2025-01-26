import 'package:flutter/material.dart';
import 'package:menu/view_model/material_list_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menu/data/repository/material_repository.dart';
import 'package:menu/data/model/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menu/common/common_providers.dart';

class MaterialCreateScreen extends ConsumerStatefulWidget {
  const MaterialCreateScreen({super.key});

  @override
  MaterialCreateScreenstate createState() => MaterialCreateScreenstate();
}

class MaterialCreateScreenstate extends ConsumerState<MaterialCreateScreen> {
  
  //テキストフィールド
  Map<int, TextEditingController> materialController = {};
  Map<int, TextEditingController> quantityController = {};
  Map<int, TextEditingController> unitController = {};
  Map<int, TextEditingController> priceController = {};

  final List<Map<String, dynamic>> _materialMap = []; //登録するデータ
  var counter = 0; // テキストフィールドの数

  @override
  // テキストフィールドのコントローラーの破棄
  void dispose() {
    for (var i = 0; i < materialController.length; i++) {
      materialController[i]?.dispose();
      quantityController[i]?.dispose();
      unitController[i]?.dispose();
      priceController[i]?.dispose();
    }
    super.dispose(); // 親クラスのdisposeを呼び出す
  }

  @override
  Widget build(BuildContext context) {
    final materialMap = ref.watch(materialProvider); // 編集中の材料データ取得
    final screenWidth = MediaQuery.of(context).size.width; // 端末の画面幅を取得
    //final screenHeight = MediaQuery.of(context).size.height; // 画面高さ取得

    return Center(
      child: Column(children: [
        const Text('右スワイプで削除'),
        const SizedBox(height: 10),
        //題目ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
          Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: screenWidth *0.39,
              child:const Text("材料",
              textAlign: TextAlign.center, // テキストを中央揃え),
              )
            ),
            SizedBox(
              width: screenWidth * 0.19,
              child: const Text("数量",
              textAlign: TextAlign.center
              ),
            ),
            SizedBox(
              width: screenWidth * 0.19,
              child: const Text("単位",
              textAlign: TextAlign.center
              ),
            ),
            SizedBox(
              width: screenWidth * 0.19,
              child: const Text("価格",
              textAlign: TextAlign.center
              ),
            ),
          ]
        ),

        //入力エリアーーーーーーーーーーーーーーーーーーーーーーーーーー
        ListView.builder(
          shrinkWrap: true, // 高さ自動調整
          //physics: const NeverScrollableScrollPhysics(), // スクロール禁止
          itemCount: counter + 1, //初期表示テキストエリア表示のための+1
          itemBuilder: (context, index) {
            while (_materialMap.length <= index) {

              // マップの長さがインデックスより小さい場合エラー回避のため空のマップを作成
              _materialMap.add({
                'material': '',
                'quantity': '',
                'unit': '',
                'price': '',
              });
            }

            //テキストフィールドの初期値
            materialController[index] ??= TextEditingController(
              text: _materialMap[index]['material'],
            );
            quantityController[index] ??= TextEditingController(
              text: _materialMap[index]['quantity'],
            );
            unitController[index] ??= TextEditingController(
              text: _materialMap[index]['unit'],
            );
            priceController[index] ??= TextEditingController(
              text: _materialMap[index]['price'],
            );

            // スワイプで削除
            return Dismissible(
              key: Key(materialController[index]
                  .hashCode
                  .toString()), // ハッシュ値をキーに設定
              direction: DismissDirection.startToEnd, // 右から左へスワイプ
              background: Container(
                color: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 20), // 余白
                alignment: Alignment.centerLeft, // 左寄せ
                child: const Icon(Icons.delete),
              ),
              onDismissed: (direction) {
                // スワイプで削除された場合の処理
                setState(() {
                  counter--; // テキストフィールドの数を減らす
                  materialController.remove(index);
                  quantityController.remove(index);
                  unitController.remove(index);
                  priceController.remove(index);
                  _materialMap.removeAt(index);
                });
              },

              child: SizedBox(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildTextField(
                          name: 'material',
                          hintText: '牛肉',
                          controller: materialController[index] ??
                              TextEditingController(), // エラー防止のため空のコントローラーをセット
                          keyboardType: TextInputType.text,
                          width: screenWidth * 0.39,
                          index: index,
                        ),
                        _buildTextField(
                          name: 'quantity',
                          hintText: '10',
                          controller: quantityController[index] ??
                              TextEditingController(),
                          keyboardType: TextInputType.number,
                          width: screenWidth * 0.19,
                          index: index,
                        ),
                        _buildTextField(
                          name: 'unit',
                          hintText: 'g',
                          controller: unitController[index] ??
                              TextEditingController(),
                          keyboardType: TextInputType.text,
                          width: screenWidth * 0.19,
                          index: index,
                        ),
                        _buildTextField(
                          name: 'price',
                          hintText: '400',
                          controller: priceController[index] ??
                              TextEditingController(),
                          keyboardType: TextInputType.number,
                          width: screenWidth * 0.19,
                          index: index,
                        ),
                      ]
                    ),
                    const SizedBox(height: 10,)
                  ]
                )
              ),
            );
          },
        ),
        const SizedBox(width: 10),

        //追加アイコンーーーーーーーーーーーーーーーーーーーーーー
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            setState(
              () {
                counter++;
                // テキストフィールドの数を増やす
                materialController[counter] = TextEditingController();
                quantityController[counter] = TextEditingController();
                unitController[counter] = TextEditingController();
                priceController[counter] = TextEditingController();
              },
            );
          },
        ),
        const SizedBox(height: 10),

        //登録ボタンーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
        SizedBox(
          width: 100,
          child: _actionButton(
            ref,
            materialMap,
            materialController,
            quantityController,
            unitController,
            priceController
          ), 
        ),

        // 戻るボタンーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
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

  // テキストフィールドの設定
  Widget _buildTextField({
    dynamic name = '',
    final String hintText = '',
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    final double width = 130,
    required int index,
  }) {
    return SizedBox(
      height: 35,
      width: width,
      child: TextField(
        onChanged: (text) {
          // テキストフィールドの値が変更された場合
          if (index < _materialMap.length) {
            _materialMap[index][name] = text; // マップに値をセット
          }
        },
        textAlign: TextAlign.center, //hintTextの左右を中央揃え
        controller: controller, // コントローラー
        keyboardType: keyboardType, // キーボードタイプ
        decoration: InputDecoration(
          // テキストフィールドの装飾
          // labelText: labelText,
          hintText: hintText,
          //floatingLabelAlignment: FloatingLabelAlignment.center,
          floatingLabelBehavior: FloatingLabelBehavior.always, // ラベルの位置
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
                horizontal: 3, vertical: 5), //hintTextの垂直方向を中央に揃える。
          hintStyle: const TextStyle(
              color: Color.fromARGB(255, 198, 198, 198)), // hintTextの色を設定
        ),
      ),
    );
  }

  // 登録ボタン
  Widget _actionButton(WidgetRef ref, material,
    materialController, quantityController, unitController, priceController) {

    // 登録用のマップに値をセット
    for (var i = 0; i < materialController.length - 1; i++) {
      _materialMap[i]['material'] = materialController[i]?.text;
      _materialMap[i]['quantity'] = quantityController[i]?.text;
      _materialMap[i]['unit'] = unitController[i]?.text;
      _materialMap[i]['price'] = priceController[i]?.text;
    }

    return FilledButton(
      onPressed: () async {
        try {
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

          // 入力チェック
          if (!validateInputs()) {
            return;
          }

          for (var i = 0; i < materials.length; i++) {
            // 材料データが空の場合は登録しない
            if (materials[i].name == null ||
                materials[i].quantity == null ||
                materials[i].unit == null ||
                materials[i].price == null) {
              continue;
            }
            await MaterialRepository() // データ登録
                .addMaterial(materials[i]);
          }

          Fluttertoast.showToast(
            // 画面下に一時的にメッセージ表示
            timeInSecForIosWeb: 1,
            gravity: ToastGravity.CENTER, // 位置
            fontSize: 16,
            msg: '登録しました',
          );
          
          clearform();

          if (mounted) {
            // 戻りたい画面が破棄されていないかチェック
            Navigator.pop(context);
          }

        } catch (e) {
          _showErrorDialog('登録に失敗しました。再度お試しください。$e');
        }
      },
      // ボタンのスタイル
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          // ボタンの形
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      child: Text('登録'),
    );
  }

  // フォームのクリア
  void clearform() {
    for (var controller in materialController.values) {
      controller.clear();
    }
    for (var controller in quantityController.values) {
      controller.clear();
    }
    for (var controller in unitController.values) {
      controller.clear();
    }
    for (var controller in priceController.values) {
      controller.clear();
    }
  }

  bool validateInputs() {
    for (var i = 0; i < _materialMap.length; i++) {
      if (_materialMap[i]['material'] == null ||
          _materialMap[i]['material'].isEmpty) {
        _showErrorDialog('材料名を入力してください');
        return false;
      }
      if (int.tryParse(_materialMap[i]['quantity'] ?? '') == null) {
        _showErrorDialog('数量を正しく入力してください');
        return false;
      }
      if (_materialMap[i]['unit'] == null || _materialMap[i]['unit'].isEmpty) {
        _showErrorDialog('単位を入力してください');
        return false;
      }
      if (int.tryParse(_materialMap[i]['price'] ?? '') == null) {
        _showErrorDialog('価格を正しく入力してください');
        return false;
      }
    }
    return true;
  }
}
