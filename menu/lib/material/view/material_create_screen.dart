import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menu/common/common_providers.dart';
import 'package:menu/common/common_widget.dart';
import 'package:menu/common/logger.dart';
import 'package:menu/material/data/repository/material_repository.dart';
import 'package:menu/material/data/model/material.dart';

///メモ
///新規登録と編集の見分け方.以下のように見分けることでプロバイダー不要となる。
///　新規登録：widget.material == null editFlg=false
///  編集：widget.material != null editFlg=true

class MaterialCreateScreen extends ConsumerStatefulWidget {
  final MaterialModel? material; //遷移元から選択されたmaterialを受け取る。
  const MaterialCreateScreen({super.key, required this.material});
  //const MaterialCreateScreen({super.key});

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
  int counter = 0; // テキストフィールドの数
  //int? _focusedIndex = 0; // 現在フォーカスされている index を管理
  //List<FocusNode> focusNodes = []; // FocusNode をリストで管理
  bool dialogFlg = false; //単位計算のダイアログの表示中のフラグ
  MaterialModel? _editMaterial; //編集するデータを受け取る。新規登録の場合はnullとなる。
  bool editFlg = false; //編集か機種更新か判断するフラグ

  @override
  // テキストフィールドのコントローラーの破棄
  void dispose() {
    for (var i = 0; i < materialController.length; i++) {
      materialController[i]?.dispose();
      quantityController[i]?.dispose();
      unitController[i]?.dispose();
      priceController[i]?.dispose();
    }
    // for (var node in focusNodes) {
    //   node.dispose();
    // }
    super.dispose(); // 親クラスのdisposeを呼び出す
  }

  @override
  void initState() {
    super.initState();

    //遷移元から受け取ったmaterialを受け取る
    if (widget.material != null) {
      //編集時のみの処理
      _editMaterial = widget.material!;
      editFlg = true;
    }

    // //テキストフィールドのフォーカスの準備
    // for (int i = 0; i < 10; i++) {
    //   focusNodes.add(FocusNode());
    // }

    // // 各 FocusNode にリスナーを追加
    // for (int i = 0; i < 10; i++) {
    //   focusNodes[i].addListener(() {
    //     if (focusNodes[i].hasFocus) {
    //       setState(() {
    //         _focusedIndex = i;
    //       });
    //     }
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width; // 端末の画面幅を取得
    //final screenHeight = MediaQuery.of(context).size.height; // 画面高さ取得

    return SingleChildScrollView(
        //スクロール可能とする
        child: Center(
      child: Column(children: [
        const Text('右スワイプで削除'),
        const SizedBox(height: 10),
        //題目ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
        _title(screenWidth),

        //入力エリアーーーーーーーーーーーーーーーーーーーーーーーーーー
        ListView.builder(
          shrinkWrap: true, // 高さ自動調整
          physics:
              const NeverScrollableScrollPhysics(), // スクロール禁止。singlechildscrollviewとの競合を避けるため。
          itemCount: counter + 1, //初期表示テキストエリア表示のための+1
          itemBuilder: (context, index) {
            while (_materialMap.length <= index) {
              // マップの長さがインデックスより小さい場合エラー回避のため空のマップを作成
              if (editFlg) {
                _materialMap.add({
                  'material': _editMaterial!.name,
                  'quantity': _editMaterial!.quantity.toString(),
                  'unit': _editMaterial!.unit,
                  'price': _editMaterial!.price.toString(),
                });
              } else {
                _materialMap.add({
                  'material': '',
                  'quantity': '',
                  'unit': '',
                  'price': '',
                });
              }
            }

            //テキストフィールドの初期値
            materialController[index] = TextEditingController(
              text: _materialMap[index]['material'],
            );
            quantityController[index] = TextEditingController(
              text: _materialMap[index]['quantity'],
            );
            unitController[index] = TextEditingController(
              text: _materialMap[index]['unit'],
            );
            priceController[index] = TextEditingController(
              text: _materialMap[index]['price'],
            );

            // スワイプで削除
            return Dismissible(
              key: Key(
                  materialController[index].hashCode.toString()), // ハッシュ値をキーに設定
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
                  // メモリリークが発生するためremoveと同時にdisposeを行う。
                  counter--; // テキストフィールドの数を減らす
                  materialController[index]?.dispose();
                  materialController.remove(index);
                  quantityController[index]?.dispose();
                  quantityController.remove(index);
                  unitController[index]?.dispose();
                  unitController.remove(index);
                  priceController[index]?.dispose();
                  priceController.remove(index);
                  _materialMap.removeAt(index);
                  //focusNodes.removeAt(index);
                });
              },

              child: SizedBox(
                  child: Column(children: [
                // //フォーカスされたテキストフィールドの背景色を水色にするためにcontainerで囲む。
                // Container(
                //   color: (_focusedIndex == index)
                //       ? Colors.blue
                //           .withAlpha((255 * 0.2).toInt()) // 50% の透明度にする
                //       : Colors.transparent,
                //   child: _textField(index, screenWidth),
                // ),
                _textField(index, screenWidth),

                const SizedBox(
                  height: 10,
                )
              ])),
            );
          },
        ),
        const SizedBox(width: 10),

        //追加・計算ボタン
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //追加アイコンーーーーーーーーーーーーーーーーーーーーーー
            editFlg //新規登録だけ追加ボタンを機能させる
                ? const SizedBox.shrink()
                : OutlinedButton(
                    //枠線ありボタン
                    onPressed: () {
                      if (counter == 8) {
                        showMessage("最大９個までです！");
                      } else {
                        setState(
                          () {
                            counter++;
                            // テキストフィールドの数を増やす
                            materialController[counter] =
                                TextEditingController();
                            quantityController[counter] =
                                TextEditingController();
                            unitController[counter] = TextEditingController();
                            priceController[counter] = TextEditingController();
                          },
                        );
                      }
                    },

                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2), // パディングを調整
                      minimumSize: const Size(50, 20), // 最小サイズを指定
                      backgroundColor: const Color.fromARGB(255, 255, 119, 0),
                    ),
                    child: const Text(
                      '行追加',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),

            //単位あたり計算ボタンーーーーーーーーーーーーーーーーーーーーーーー
            // Padding(
            //   padding: const EdgeInsets.only(left: 10.0),
            //   child: OutlinedButton(
            //     //枠線ありボタン
            //     onPressed: () async {
            //       await _showUnitCalDialog(context);
            //     },

            //     style: OutlinedButton.styleFrom(
            //       padding: const EdgeInsets.symmetric(
            //           horizontal: 8, vertical: 2), // パディングを調整
            //       minimumSize: const Size(50, 20), // 最小サイズを指定
            //       backgroundColor: Colors.blue,
            //     ),
            //     child: const Text(
            //       '選択行の価格計算',
            //       style: TextStyle(fontSize: 12, color: Colors.white),
            //     ),
            //   ),
            // )
          ],
        ),
        const SizedBox(height: 10),

        //登録ボタンーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
        SizedBox(
          width: 100,
          child: _actionButton(ref, _materialMap, materialController,
              quantityController, unitController, priceController),
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
    ));
  }

//各ウィジェットの設定ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー

  //テキストフィールドのタイトル表示
  Widget _title(double screenWidth) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      SizedBox(
          width: screenWidth * 0.39,
          child: const Text(
            "材料",
            textAlign: TextAlign.center, // テキストを中央揃え),
          )),
      SizedBox(
        width: screenWidth * 0.19,
        child: const Text("数量", textAlign: TextAlign.center),
      ),
      SizedBox(
        width: screenWidth * 0.19,
        child: const Text("単位", textAlign: TextAlign.center),
      ),
      SizedBox(
        width: screenWidth * 0.19,
        child: const Text("価格", textAlign: TextAlign.center),
      ),
    ]);
  }

  //テキストフィールド１行分
  Widget _textField(int index, double screenWidth) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      dialogFlg
          ? _buildTextField(
              //ダイアログの中
              name: 'material',
              hintText: '牛肉',
              controller: materialController[
                  index]!, //?? TextEditingController(), // エラー防止のため空のコントローラーをセット
              keyboardType: TextInputType.text,
              width: screenWidth * 0.39,
              index: index,
            )
          : _buildTextField(
              name: 'material',
              hintText: '牛肉',
              controller: materialController[
                  index]!, //?? TextEditingController(), // エラー防止のため空のコントローラーをセット
              keyboardType: TextInputType.text,
              width: screenWidth * 0.39,
              index: index,
              // focusNode: focusNodes[
              //     index], //1つ目のテキストフィールドのみにフォーカスを設定。全てに設定するとカーソルが全てに表示されてしまうため。
            ),
      _buildTextField(
        name: 'quantity',
        hintText: '10',
        controller: quantityController[index]!, // ?? TextEditingController(),
        keyboardType: TextInputType.number,
        width: screenWidth * 0.19,
        index: index,
        //focusNode: focusNodes[index],
      ),
      _buildTextField(
        name: 'unit',
        hintText: 'g',
        controller: unitController[index]!, //?? TextEditingController(),
        keyboardType: TextInputType.text,
        width: screenWidth * 0.19,
        index: index,
        //focusNode: focusNodes[index],
      ),
      _buildTextField(
        name: 'price',
        hintText: '400',
        controller: priceController[index]!, //?? TextEditingController(),
        keyboardType: TextInputType.number,
        width: screenWidth * 0.19,
        index: index,
        //focusNode: focusNodes[index],
      ),
    ]);
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

  // テキストフィールド1つ分の設定
  Widget _buildTextField({
    required int index,
    required TextEditingController controller,
    //FocusNode? focusNode,
    dynamic name = '',
    final String hintText = '',
    TextInputType keyboardType = TextInputType.text,
    final double width = 130,
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
        //focusNode: focusNode,
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
  Widget _actionButton(WidgetRef ref, material, materialController,
      quantityController, unitController, priceController) {
    // 登録用のマップに値をセット
    for (var i = 0; i < _materialMap.length - 1; i++) {
      _materialMap[i]['material'] = materialController[i]?.text;
      _materialMap[i]['quantity'] = quantityController[i]?.text;
      _materialMap[i]['unit'] = unitController[i]?.text;
      _materialMap[i]['price'] = priceController[i]?.text;
    }

    return FilledButton(
      onPressed: () async {
        try {
          if (editFlg) {
            //編集の場合のみ
            //データ更新するMaterialModelの準備
            _editMaterial!.name = materialController[0].text;
            _editMaterial!.quantity = int.tryParse(quantityController[0].text);
            _editMaterial!.unit = unitController[0].text;
            _editMaterial!.price = int.tryParse(priceController[0].text);
          }

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
            LoggerService.debug("editFlg:$editFlg, ${materials.length}");
            editFlg
                ? await MaterialRepository()
                    .updateMaterial(_editMaterial!) //編集データの更新
                : await MaterialRepository()
                    .addMaterial(materials[i]); // 新規データの登録
          }

          Fluttertoast.showToast(
              // 画面下に一時的にメッセージ表示
              timeInSecForIosWeb: 1,
              gravity: ToastGravity.CENTER, // 位置
              fontSize: 16,
              msg: editFlg ? '更新しました' : '登録しました');

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
      child: Text(editFlg ? '更新' : '登録'),
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

//バリデーションチェック
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

  //単位あたりの計算ダイアログ表示
  // Future<void> _showUnitCalDialog(BuildContext context) {
  //   dialogFlg = true;

  //   TextEditingController numController =
  //       TextEditingController(); // 入力を管理するコントローラ
  //   int? focusPrice = int.tryParse(priceController[_focusedIndex]!.text);
  //   int? focusQuantity = int.tryParse(quantityController[_focusedIndex]!.text);
  //   int dispPrice = 0;
  //   double screenWidth = MediaQuery.of(context).size.width;
  //   int? input = 1;

  //   // フォーカスを外す
  //   //focusNodes[_focusedIndex!].unfocus();

  //   //表示計算価格の初期表示の計算
  //   if (focusPrice == null || focusQuantity == null || focusQuantity == 0) {
  //     dispPrice = 0; // 無効な値の場合は 0 にする
  //   } else {
  //     numController.text = "1";
  //     dispPrice = focusPrice ~/ focusQuantity;
  //   }

  //   return showDialog(
  //     context: context,
  //     builder: (context) {
  //       return StatefulBuilder(//showDialog内だけにsetStateによって再描写させたいため。
  //           builder: (context, setState) {
  //         return Dialog(
  //           insetPadding: const EdgeInsets.symmetric(
  //               horizontal: 5), //画面全体から少し小さいダイアログを表示したいため
  //           child: Container(
  //             constraints: BoxConstraints.expand(
  //                 width: screenWidth, height: 300), // 横幅いっぱい
  //             child: Column(
  //               children: [
  //                 const Padding(
  //                   padding: EdgeInsets.all(20),
  //                   child: Text("数量変更時の価格計算", style: TextStyle(fontSize: 18)),
  //                 ),
  //                 _title(screenWidth), //テキストフィールドのタイトル表示
  //                 const Row(
  //                   children: [
  //                     Text(
  //                       "変更前",
  //                       style: TextStyle(
  //                         color: Colors.blue,
  //                         fontSize: 10,
  //                       ),
  //                     )
  //                   ],
  //                 ),
  //                 _textField(_focusedIndex!, screenWidth), //テキストフィールド１行分の表示
  //                 const Text("↓"),
  //                 const Row(
  //                   children: [
  //                     Text(
  //                       "変更後",
  //                       style: TextStyle(
  //                         color: Colors.red,
  //                         fontSize: 10,
  //                       ),
  //                     )
  //                   ],
  //                 ),

  //                 //変更後の表示１行分
  //                 Container(
  //                   //フォーカスされたテキストフィールドの背景色を水色にするためにcontainerで囲む。
  //                   color: Colors.blue
  //                       .withAlpha((255 * 0.2).toInt()), // 50% の透明度にする
  //                   child: Row(
  //                       //変更後の材料名の表示
  //                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                       children: [
  //                         SizedBox(
  //                             width: screenWidth * 0.39,
  //                             child: Text(
  //                               materialController[_focusedIndex]!
  //                                   .text
  //                                   .toString(),
  //                               textAlign: TextAlign.center, // テキストを中央揃え),
  //                             )),
  //                         SizedBox(
  //                           //変更後の数量を入力するテキストフィールド
  //                           height: 35,
  //                           width: screenWidth * 0.19,
  //                           child: TextField(
  //                             onChanged: (text) {
  //                               setState(() {
  //                                 // テキストフィールドの値が変更された場合
  //                                 input = int.tryParse(text);
  //                                 focusPrice = int.tryParse(
  //                                     priceController[_focusedIndex]!.text);
  //                                 focusQuantity = int.tryParse(
  //                                     quantityController[_focusedIndex]!.text);

  //                                 if (focusPrice == null ||
  //                                     focusQuantity == null ||
  //                                     input == null ||
  //                                     focusQuantity == 0 ||
  //                                     input == 0) {
  //                                   dispPrice = 0; // 無効な値の場合は 0 にする
  //                                 } else {
  //                                   dispPrice = focusPrice! ~/
  //                                       (focusQuantity! / input!);
  //                                 }
  //                               });
  //                             },
  //                             textAlign: TextAlign.center, //hintTextの左右を中央揃え
  //                             controller: numController, // コントローラー
  //                             keyboardType: TextInputType.number, // キーボードタイプ
  //                             decoration: const InputDecoration(
  //                               // テキストフィールドの装飾
  //                               // labelText: labelText,
  //                               hintText: "1",
  //                               //floatingLabelAlignment: FloatingLabelAlignment.center,
  //                               floatingLabelBehavior:
  //                                   FloatingLabelBehavior.always, // ラベルの位置
  //                               border: OutlineInputBorder(),
  //                               contentPadding: EdgeInsets.symmetric(
  //                                   horizontal: 3,
  //                                   vertical: 5), //hintTextの垂直方向を中央に揃える。
  //                               hintStyle: TextStyle(
  //                                   color: Color.fromARGB(
  //                                       255, 198, 198, 198)), // hintTextの色を設定
  //                             ),
  //                           ),
  //                         ),
  //                         SizedBox(
  //                           //変更後の単位の表示
  //                           width: screenWidth * 0.19,
  //                           child: Text(unitController[_focusedIndex]!.text,
  //                               textAlign: TextAlign.center),
  //                         ),
  //                         SizedBox(
  //                           //変更後の価格の表示。リアルタイム表示。
  //                           width: screenWidth * 0.19,
  //                           child:
  //                               Text("$dispPrice", textAlign: TextAlign.center),
  //                         ),
  //                       ]),
  //                 ),
  //                 const SizedBox(
  //                   height: 10,
  //                 ),

  //                 //やめる・決定ボタン
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     //やめるボタン
  //                     ElevatedButton(
  //                       onPressed: () {
  //                         dialogFlg = false;
  //                         Navigator.pop(context);
  //                       },
  //                       child: const Text("やめる"),
  //                     ),
  //                     const SizedBox(
  //                       width: 20,
  //                     ),

  //                     //決定ボタン
  //                     ElevatedButton(
  //                       onPressed: () {
  //                         if (priceController[_focusedIndex]!.text == "") {
  //                           showMessage("変更前を入力してください。");
  //                         } else {
  //                           if (input == null) {
  //                             showMessage("変更後の数量を入力してください");
  //                           } else {
  //                             quantityController[_focusedIndex]!.text =
  //                                 numController.text;
  //                             priceController[_focusedIndex]!.text =
  //                                 dispPrice.toString();
  //                             _materialMap[_focusedIndex!]['quantity'] =
  //                                 numController.text;
  //                             _materialMap[_focusedIndex!]['price'] =
  //                                 dispPrice.toString();
  //                             dialogFlg = false;
  //                             Navigator.pop(context);
  //                           }
  //                         }
  //                       },
  //                       child: const Text("決定"),
  //                     ),
  //                   ],
  //                 )
  //               ],
  //             ),
  //           ),
  //         );
  //       });
  //     },
  //   );
  // }
}
