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
  var counter = 0; // テキストフィールドの数
  Map<int, TextEditingController> materialController = {};
  Map<int, TextEditingController> quantityController = {};
  Map<int, TextEditingController> unitController = {};
  Map<int, TextEditingController> priceController = {};
  final List<Map<String, dynamic>> _materialMap = []; // 登録用のマップ

  @override
  void dispose() {
    for (var i = 0; i < materialController.length; i++) {
      materialController[i]?.dispose();
      quantityController[i]?.dispose();
      unitController[i]?.dispose();
      priceController[i]?.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 材料データ取得
    final materialMap = ref.watch(materialProvider);
    final selectButton =
        ref.watch(selectButtonProvider.notifier).state; // ボタンの状態取得

    final screenWidth = MediaQuery.of(context).size.width; // 画面幅取得
    // final screenHeight = MediaQuery.of(context).size.height; // 画面高さ取得

    return SafeArea(
      // スマホのノッチ部分に対応
      top: true,
      child: Center(
        child: Column(children: [
          const Text('スワイプで削除'),
          const SizedBox(height: 10),
          //Expanded(
          Flexible(
            child: ListView.builder(
              shrinkWrap: true, // 高さ自動調整
              //physics: const NeverScrollableScrollPhysics(), // スクロール禁止
              itemCount: counter + 1,
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

                if (selectButton != 'edit') {
                  // edit テキストフィールドの初期値
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
                } else {
                  // 編集ボタンが押された場合、フォームに値をセット
                  materialController[0] =
                      TextEditingController(text: materialMap.name);
                  quantityController[0] = TextEditingController(
                      text: materialMap.quantity.toString());
                  unitController[0] =
                      TextEditingController(text: materialMap.unit);
                  priceController[0] =
                      TextEditingController(text: materialMap.price.toString());
                }

                return Dismissible(
                  // スワイプで削除
                  key: Key(materialController[index]
                      .hashCode
                      .toString()), // ハッシュ値をキーに設定
                  direction: DismissDirection.startToEnd, // 右から左へスワイプ
                  background: Container(
                    color: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerLeft,
                    child: const Icon(Icons.delete),
                  ),

                  onDismissed: (direction) {
                    setState(() {
                      counter--; // テキストフィールドの数を減らす
                      materialController.remove(index);
                      quantityController.remove(index);
                      unitController.remove(index);
                      priceController.remove(index);
                      _materialMap.removeAt(index);
                    });
                  },
                  child: ListTile(
                    title: SizedBox(
                      width: screenWidth * 0.9,
                      //height: screenHeight * 0.1,
                      child: LayoutBuilder(builder: (context, constraints) {
                        final screenLayoutWidth = constraints.maxWidth;
                        return Row(children: <Widget>[
                          //const SizedBox(width: 10),
                          Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start, // 左寄せ
                              children: <Widget>[
                                index == 0
                                    ? const Align(
                                        alignment: Alignment.centerLeft, // 左寄せ
                                        child: Text('材料'),
                                      )
                                    : const SizedBox.shrink(),
                                const SizedBox(height: 5),
                                _buildTextField(
                                  name: 'material',
                                  hintText: '牛肉',
                                  controller: materialController[index] ??
                                      TextEditingController(), // エラー防止のため空のコントローラーをセット
                                  keyboardType: TextInputType.text,
                                  //width: 140,
                                  width: screenLayoutWidth * 0.48,
                                  index: index,
                                ),
                              ]),
                          SizedBox(width: screenLayoutWidth * 0.01),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                index == 0
                                    ? const Align(
                                        alignment: Alignment.centerLeft, // 左寄せ
                                        child: Text('数量'))
                                    : const SizedBox.shrink(),
                                const SizedBox(height: 5),
                                _buildTextField(
                                  name: 'quantity',
                                  hintText: '10',
                                  controller: quantityController[index] ??
                                      TextEditingController(),
                                  keyboardType: TextInputType.number,
                                  // width: 60,
                                  width: screenLayoutWidth * 0.15,
                                  index: index,
                                ),
                              ]),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                index == 0
                                    ? const Align(
                                        alignment: Alignment.centerLeft, // 左寄せ
                                        child: Text('単位'))
                                    : const SizedBox.shrink(),
                                const SizedBox(height: 5),
                                _buildTextField(
                                  name: 'unit',
                                  hintText: 'g',
                                  controller: unitController[index] ??
                                      TextEditingController(),
                                  keyboardType: TextInputType.text,
                                  //width: 60,
                                  width: screenLayoutWidth * 0.15,
                                  index: index,
                                ),
                              ]),
                          SizedBox(width: screenLayoutWidth * 0.01),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                index == 0
                                    ? const Align(
                                        alignment: Alignment.centerLeft, // 左寄せ
                                        child: Text('価格'))
                                    : const SizedBox.shrink(),
                                const SizedBox(height: 5),
                                _buildTextField(
                                  name: 'price',
                                  hintText: '400',
                                  controller: priceController[index] ??
                                      TextEditingController(),
                                  keyboardType: TextInputType.number,
                                  //width: 80,
                                  width: screenLayoutWidth * 0.2,
                                  index: index,
                                ),
                              ]),
                        ]);
                      }),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          selectButton != 'Resist'
              ? const SizedBox.shrink()
              : IconButton(
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
          const SizedBox(height: 20),
          SizedBox(
            width: 100,
            //child: selectButton == 'Resist'
            child: _actionButton(
                ref,
                selectButton,
                materialMap,
                materialController,
                quantityController,
                unitController,
                priceController), // 登録、更新ボタン
            //material.id == null ? _resisterButton() : _updateButton(ref),
          ),
          // 戻るボタン
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.blueAccent,
            ),
            onPressed: () {
              //ref.read(pageProvider.notifier).state = initOtherPage;
              Navigator.pop(context);
            },
            child: const Text('戻る'),
          )
        ]),
      ),
      //),
      //),
    );
    // ),
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
    dynamic name = '',
    final String hintText = '',
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    final double width = 130,
    required int index,
  }) {
    return SizedBox(
      width: width,
      child: TextField(
        onChanged: (text) {
          // テキストフィールドの値が変更された場合
          if (index < _materialMap.length) {
            _materialMap[index][name] = text; // マップに値をセット
          }
        },
        controller: controller, // コントローラー
        keyboardType: keyboardType, // キーボードタイプ
        decoration: InputDecoration(
          // テキストフィールドの装飾
          // labelText: labelText,
          hintText: hintText,
          //floatingLabelAlignment: FloatingLabelAlignment.center,
          floatingLabelBehavior: FloatingLabelBehavior.always, // ラベルの位置
          border: const OutlineInputBorder(),
          hintStyle: const TextStyle(
              color: Color.fromARGB(255, 198, 198, 198)), // hintTextの色を設定
        ),
      ),
    );
  }

  // 登録、更新ボタン
  Widget _actionButton(WidgetRef ref, selectButton, material,
      materialController, quantityController, unitController, priceController) {
    final isUpdate = selectButton != 'Resist';

    // 登録できる段階かを判定
    final isButtonDisabled = !isUpdate && _materialMap.isEmpty;

    // 登録用のマップに値をセット
    for (var i = 0; i < materialController.length - 1; i++) {
      _materialMap[i]['material'] = materialController[i]?.text;
      _materialMap[i]['quantity'] = quantityController[i]?.text;
      _materialMap[i]['unit'] = unitController[i]?.text;
      _materialMap[i]['price'] = priceController[i]?.text;
    }

    return FilledButton(
      //onPressed: isButtonDisabled
      // ? null // 一つも追加されていない場合はボタンを無効化
      // : () async {
      onPressed: () async {
        try {
          if (isUpdate) {
            final materials = MaterialModel(
              id: material.id, // ID
              name: materialController[0]?.text, // 材料名
              quantity: int.tryParse(quantityController[0]!.text), // 数量
              unit: unitController[0]?.text, // 単位
              price: int.tryParse(priceController[0]!.text), // 価格
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

          if (mounted) {
            // 戻りたい画面が破棄されていないかチェック
            Navigator.pop(context);
          }
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
