import 'package:flutter/material.dart';
import 'package:menu/view_model/material_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menu/data/repository/material_repository.dart';
import 'package:menu/data/model/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menu/common/common_providers.dart';
import 'package:menu/common/common_widget.dart';

class MaterialUpdateScreen extends ConsumerStatefulWidget {
  final MaterialModel? material; //遷移元から選択されたmaterialを受け取る。
  const MaterialUpdateScreen({super.key, required this.material});

  @override
  MaterialUpdateScreenstate createState() => MaterialUpdateScreenstate();
}
class MaterialUpdateScreenstate extends ConsumerState<MaterialUpdateScreen> {
  
  //テキストフィールド
  Map<int, TextEditingController> materialController = {};
  Map<int, TextEditingController> quantityController = {};
  Map<int, TextEditingController> unitController = {};
  Map<int, TextEditingController> priceController = {};

  final List<Map<String, dynamic>> _materialMap = []; //登録するデータ
  int counter = 0; // テキストフィールドの数
  int? _focusedIndex = 0;// 現在フォーカスされている index を管理
  List<FocusNode> focusNodes = [];// FocusNode をリストで管理
  bool dialogFlg = false; //単位計算のダイアログの表示中のフラグ
  late MaterialModel _material; //更新するデータをここに入れる

  
  @override
  // テキストフィールドのコントローラーの破棄
  void dispose() {
    for (var i = 0; i < materialController.length; i++) {
      materialController[i]?.dispose();
      quantityController[i]?.dispose();
      unitController[i]?.dispose();
      priceController[i]?.dispose();
    }
    for (var node in focusNodes) {
    node.dispose();
  }
    super.dispose(); // 親クラスのdisposeを呼び出す
  }

@override
  void initState() {
  super.initState();
   _material = widget.material!; //遷移元から受け取ったmaterialを受け取る

 //テキストフィールドのフォーカスの準備
  for (int i = 0; i < 10; i++) { 
    focusNodes.add(FocusNode());
  }

  // 各 FocusNode にリスナーを追加
  for (int i = 0; i < 10; i++) {
    focusNodes[i].addListener(() {
      if (focusNodes[i].hasFocus) {
        setState(() {
          _focusedIndex = i;
        });  
      }
    });
  }
}

  @override
  Widget build(BuildContext context) {
    //final materialMap = ref.watch(materialProvider); // 編集中の材料データ取得
    final screenWidth = MediaQuery.of(context).size.width; // 端末の画面幅を取得
    //final screenHeight = MediaQuery.of(context).size.height; // 画面高さ取得

    return Center(
      child: Column(children: [
        const Text('右スワイプで削除'),
        const SizedBox(height: 10),
        //題目ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
        _title(screenWidth),

        //入力エリアーーーーーーーーーーーーーーーーーーーーーーーーーー
        ListView.builder(
          shrinkWrap: true, // 高さ自動調整
          //physics: const NeverScrollableScrollPhysics(), // スクロール禁止
          itemCount: counter + 1, //初期表示テキストエリア表示のための+1
          itemBuilder: (context, index) {

            while (_materialMap.length <= index) {

              // マップの長さがインデックスより小さい場合エラー回避のため空のマップを作成
              _materialMap.add({
                'material': _material.name,
                'quantity': _material.quantity.toString(),
                'unit': _material.unit,
                'price': _material.price.toString(),
              });

            }

            //テキストフィールドの初期値
            materialController[index] ??= TextEditingController(text: _material.name,);
            quantityController[index] ??= TextEditingController(text: _material.quantity.toString(),);
            unitController[index] ??= TextEditingController(text: _material.unit,);
            priceController[index] ??= TextEditingController(text: _material.price.toString(),);

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
                  focusNodes.removeAt(index);
                });
              },

              child: SizedBox(
                child: Column(
                  children: [

                    //フォーカスされたテキストフィールドの背景色を水色にするためにcontainerで囲む。
                    Container(
                    color: (_focusedIndex == index) ? Colors.blue.withOpacity(0.2) : Colors.transparent,
                    child: _textField(index, screenWidth),
                    ),
                    
                    const SizedBox(height: 10,)
                  ]
                )
              ),
            );
          },
        ),
        const SizedBox(width: 10),

        //追加・計算ボタン
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
                
            //追加アイコンーーーーーーーーーーーーーーーーーーーーーー
            /*
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                if(counter == 8){
                  showMessage("最大９個までです！"); 
                }else{
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
                }
              },
            ),
            */

            //単位あたり計算ボタンーーーーーーーーーーーーーーーーーーーーーーー
            OutlinedButton(//枠線ありボタン
              onPressed: () async{ 
                await _showUnitCalDialog(context);
               },

              style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), // パディングを調整
              minimumSize: const Size(50, 20), // 最小サイズを指定
              backgroundColor:  Colors.blue,
              ),
              child: const Text('数量あたりの価格計算',
                style: TextStyle(
                fontSize: 12,
                color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        //登録ボタンーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
        SizedBox(
          width: 100,
          child: _actionButton(
            ref,
            _materialMap,
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


//各ウィジェットの設定ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー

 //テキストフィールドのタイトル表示
  Widget _title(double screenWidth){
    return Row(
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
    );
  }
  
  //テキストフィールド１行分
  Widget _textField(int index, double screenWidth){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        dialogFlg
        ? _buildTextField(//ダイアログの中
          name: 'material',
          hintText: '牛肉',
          controller: materialController[index] ??
              TextEditingController(), // エラー防止のため空のコントローラーをセット
          keyboardType: TextInputType.text,
          width: screenWidth * 0.39,
          index: index,

        )
        : _buildTextField(
          name: 'material',
          hintText: '牛肉',
          controller: materialController[index] ??
              TextEditingController(), // エラー防止のため空のコントローラーをセット
          keyboardType: TextInputType.text,
          width: screenWidth * 0.39,
          index: index,
          focusNode: focusNodes[index],//1つ目のテキストフィールドのみにフォーカスを設定。全てに設定するとカーソルが全てに表示されてしまうため。

        ),
        _buildTextField(
          name: 'quantity',
          hintText: '10',
          controller: quantityController[index] ??
              TextEditingController(),
          keyboardType: TextInputType.number,
          width: screenWidth * 0.19,
          index: index,
          //focusNode: focusNodes[index],
        ),
        _buildTextField(
          name: 'unit',
          hintText: 'g',
          controller: unitController[index] ??
              TextEditingController(),
          keyboardType: TextInputType.text,
          width: screenWidth * 0.19,
          index: index,
          //focusNode: focusNodes[index],
        ),
        _buildTextField(
          name: 'price',
          hintText: '400',
          controller: priceController[index] ??
              TextEditingController(),
          keyboardType: TextInputType.number,
          width: screenWidth * 0.19,
          index: index,
          //focusNode: focusNodes[index],
        ),
      ]
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

  // テキストフィールド1つ分の設定
  Widget _buildTextField({
    required int index,
    required TextEditingController controller,
    FocusNode? focusNode,
    dynamic name = '',
    final String hintText = '',
    TextInputType keyboardType = TextInputType.text,
    final double width = 130,
  }){
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
        focusNode: focusNode,
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

          //データ更新するMaterialModelの準備
          _material.name = materialController[0].text;
          _material.quantity = int.tryParse(quantityController[0].text);
          _material.unit = unitController[0].text;
          _material.price = int.tryParse(priceController[0].text);

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
            await //MaterialRepository().addMaterial(materials[i]);
            MaterialRepository().updateMaterial(_material);
          }

          Fluttertoast.showToast(
            // 画面下に一時的にメッセージ表示
            timeInSecForIosWeb: 1,
            gravity: ToastGravity.CENTER, // 位置
            fontSize: 16,
            msg: '更新しました',
          );
          
          clearform();

          if (mounted) {
            // 戻りたい画面が破棄されていないかチェック
            Navigator.pop(context);
          }

        } catch (e) {
          _showErrorDialog('更新に失敗しました。再度お試しください。$e');
        }
      },
      // ボタンのスタイル
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          // ボタンの形
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      child: const Text('更新'),
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
    print("vali:${_materialMap.length},${_materialMap[0]['material']}");
    
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
  Future<void> _showUnitCalDialog(BuildContext context) {
    dialogFlg = true;

    TextEditingController numController = TextEditingController(); // 入力を管理するコントローラ
    int? focusPrice = int.tryParse(priceController[_focusedIndex]!.text);
    int? focusQuantity = int.tryParse(quantityController[_focusedIndex]!.text);
    int dispPrice = 0;
    double screenWidth = MediaQuery.of(context).size.width; 
    int? input=1;

    // フォーカスを外す
    //focusNodes[_focusedIndex!].unfocus();
    
    //表示計算価格の初期表示の計算
    if (focusPrice == null || focusQuantity == null  || focusQuantity == 0 ) {
      dispPrice = 0; // 無効な値の場合は 0 にする
    } else {
      numController.text = "1";
      dispPrice = focusPrice ~/ focusQuantity ;
    }
  
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(//showDialog内だけにsetStateによって再描写させたいため。
          builder: (context, setState){

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 5),//画面全体から少し小さいダイアログを表示したいため
          child: Container(
            constraints: BoxConstraints.expand(width: screenWidth, height: 300), // 横幅いっぱい
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("数量変更時の価格計算", style: TextStyle(fontSize: 18)),
                ),
                _title(screenWidth),//テキストフィールドのタイトル表示
                const Row(
                  children: [
                    Text("変更前",
                    style: TextStyle(color: Colors.blue, fontSize: 10, ),)
                  ],
                ),
                _textField(_focusedIndex!,screenWidth),//テキストフィールド１行分の表示
                const Text("↓"),
                const Row(
                  children: [
                    Text("変更後",
                    style: TextStyle(color: Colors.red, fontSize: 10, ),)
                  ],
                ),

                //変更後の表示１行分
                Container(//フォーカスされたテキストフィールドの背景色を水色にするためにcontainerで囲む。
                color:  Colors.blue.withOpacity(0.2),
                child: Row(//変更後の材料名の表示
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: screenWidth *0.39,
                        child: Text(materialController[_focusedIndex]!.text.toString(),
                          textAlign: TextAlign.center, // テキストを中央揃え),
                        )
                      ),

                      SizedBox(//変更後の数量を入力するテキストフィールド
                        height: 35,
                        width: screenWidth *0.19,
                        child: TextField(
                          onChanged: (text) {
                            setState(() {// テキストフィールドの値が変更された場合
                              input = int.tryParse(text);
                              focusPrice = int.tryParse(priceController[_focusedIndex]!.text);
                              focusQuantity = int.tryParse(quantityController[_focusedIndex]!.text);

                              if (focusPrice == null || focusQuantity == null || input == null || focusQuantity == 0 || input == 0) {
                                dispPrice = 0; // 無効な値の場合は 0 にする
                              } else {
                                dispPrice = focusPrice! ~/ (focusQuantity! / input!);
                              }
                            });
                          },
                          textAlign: TextAlign.center, //hintTextの左右を中央揃え
                          controller: numController, // コントローラー
                          keyboardType: TextInputType.number, // キーボードタイプ
                          decoration: const InputDecoration(
                            // テキストフィールドの装飾
                            // labelText: labelText,
                            hintText: "1",
                            //floatingLabelAlignment: FloatingLabelAlignment.center,
                            floatingLabelBehavior: FloatingLabelBehavior.always, // ラベルの位置
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                  horizontal: 3, vertical: 5), //hintTextの垂直方向を中央に揃える。
                            hintStyle: TextStyle(
                                color: Color.fromARGB(255, 198, 198, 198)), // hintTextの色を設定
                          ),
                        ),
                      ),

                      SizedBox(//変更後の単位の表示
                        width: screenWidth * 0.19,
                        child: Text(unitController[_focusedIndex]!.text,
                        textAlign: TextAlign.center
                        ),
                      ),
                      SizedBox(//変更後の価格の表示。リアルタイム表示。
                        width: screenWidth * 0.19,
                        child: Text("$dispPrice",
                        textAlign: TextAlign.center
                        ),
                      ),
                    ]
                  ),
                ),
                const SizedBox(height: 10,),

                //やめる・決定ボタン
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    //やめるボタン
                    ElevatedButton(
                      onPressed: (){
                        dialogFlg = false;
                        Navigator.pop(context);

                        },
                        child: const Text("やめる"),
                    ),
                    const SizedBox(width: 20,),

                    //決定ボタン
                    ElevatedButton(
                      onPressed: (){
                        if(priceController[_focusedIndex]!.text == ""){
                          showMessage("変更前を入力してください。");
                        }else{
                          if(input == null){
                            showMessage("変更後の数量を入力してください");
                          }else{
                          quantityController[_focusedIndex]!.text = numController.text;
                          priceController[_focusedIndex]!.text = dispPrice.toString();
                          dialogFlg = false;
                          Navigator.pop(context);    
                          }
                        }
                      },
                      child: const Text("決定"),
                    ),
                  ],
                )              
              ],
            ),
          ),
        );
      });
    },
  );
}
}


/*
class MaterialUpdateScreenstate extends State<MaterialUpdateScreen> {

  //テキストフィールド
  late TextEditingController materialController;
  late TextEditingController quantityController;
  late TextEditingController unitController;
  late TextEditingController priceController;

  late MaterialModel _material; //更新するデータをここに入れる

  @override
  // テキストフィールドのコントローラーの破棄
  void dispose() {
      materialController.dispose();
      quantityController.dispose();
      unitController.dispose();
      priceController.dispose();

    super.dispose(); // 親クラスのdisposeを呼び出す
  }

//初期化処理
  @override
  void initState() {
    super.initState();
    _material = widget.material!; //遷移元から受け取ったmenuを受け取る。
    
    //テキストフィールドに編集するデータを初期値として入れる
    materialController = TextEditingController(text: _material.name);
    quantityController = TextEditingController(text: _material.quantity.toString());
    unitController = TextEditingController(text: _material.unit);
    priceController = TextEditingController(text: _material.price.toString());   
    
  }

  @override
  Widget build(BuildContext context) {
    //final screenWidth = MediaQuery.of(context).size.width; // 端末の画面幅を取得
    //final screenHeight = MediaQuery.of(context).size.height; // 画面高さ取得

    return Center(
      child: Column(
        children: [
          const SizedBox(height: 10,),

          //題目ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 150,
                child:Text("材料",
                textAlign: TextAlign.center, // テキストを中央揃え),
                )
              ),
              SizedBox(
                width: 70,
                child: Text("数量",
                textAlign: TextAlign.center
                ),
              ),
              SizedBox(
                width: 70,
                child: Text("単位",
                textAlign: TextAlign.center
                ),
              ),
              SizedBox(
                width: 70,
                child: Text("価格",
                textAlign: TextAlign.center
                ),
              ),
            ]
          ),

          //入力エリアーーーーーーーーーーーーーーーーーーーーーーーーーーーー
          Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTextField(
              hintText: '牛肉',
              controller: materialController,
              keyboardType: TextInputType.text,
              setWidth: 150,
            ),
            _buildTextField(
              hintText: '1',
              controller: quantityController,
              keyboardType: TextInputType.number,
              setWidth: 70,
            ),
            _buildTextField(
              hintText: 'g',
              controller: unitController,
              keyboardType: TextInputType.text,
              setWidth: 70,
            ),
            _buildTextField(
              hintText: '250',
              controller: priceController,
              keyboardType: TextInputType.text,
              setWidth: 70,
            ),
          ]),

          //更新ボタンーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
          SizedBox(
            width: 100,
            child: _actionButton(), 
          ),
  
          // 戻るボタンーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.blueAccent,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('戻る'),
          )
        ]
      )
    );
  }

//テキストフィールドの設定
Widget _buildTextField({
  required TextEditingController controller,
  String hintText = '',
  TextInputType keyboardType = TextInputType.text,
  double setWidth = 300,
  double setHeight = 35,
  int setMaxline = 1,
  TextAlign textAlign = TextAlign.center,
}){
  return Column(
    children: [
      SizedBox(
        height: setHeight,
        width: setWidth,
        child: TextField(
          maxLines: setMaxline,
          textAlign: textAlign, //hintTextの左右を中央揃え
          controller: controller, // コントローラー
          keyboardType: keyboardType, // キーボードタイプ
          decoration: InputDecoration(
            // テキストフィールドの装飾
            //labelText: labelText,
            hintText: hintText,
            //floatingLabelAlignment: FloatingLabelAlignment.center,//ラベルがテキストフィールドの中央に配置されます。
            //floatingLabelBehavior: FloatingLabelBehavior.always,//ラベルは常に浮き上がった状態で表示されます。
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 3, vertical: 5), //hintTextの垂直方向を中央に揃える。
            hintStyle: const TextStyle(
                color: Color.fromARGB(255, 198, 198, 198)), // hintTextの色を設定
          ),
        ),
      ),
      const SizedBox(height: 10,),
    ],
  );
}

  // 更新ボタンの設定
  Widget _actionButton() {
    return FilledButton(
      onPressed: () async {
        try {
          //データ更新するMaterialModelの準備
          _material.name = materialController.text;
          _material.quantity = int.tryParse(quantityController.text);
          _material.unit = unitController.text;
          _material.price = int.tryParse(priceController.text);

          // 入力項目のバリデーションチェック（エラーの時はダイアログを表示）
          if (!validateInputs()) {
            return;
          }

          // データ更新
          await MaterialRepository() .updateMaterial(_material);
          
          //ポップアップ表示
          showMessage("更新しました");
          
          //clearform();

          if (mounted) {
            // 戻りたい画面が破棄されていないかチェック
            Navigator.pop(context);
          }
          // Toast
        } catch (e) {
          showErrorDialog(context, '更新に失敗しました。再度お試しください。$e');
        }
      },

      // ボタンのスタイル
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          // ボタンの形
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      child: const Text( '更新' ),
    );
  }

  // フォームのクリア
  void clearform() {
      materialController.clear();
      quantityController.clear();
      unitController.clear();
      priceController.clear();
  }

  //入力項目のバリデーションチェック
  bool validateInputs() {
      if (materialController.text == "") {
        showErrorDialog(context, '材料名を入力してください');
        return false;
      }
      if (quantityController?.text == "") {
        showErrorDialog(context, '数量を正しく入力してください');
        return false;
      }
      if (unitController?.text == "") {
        showErrorDialog(context, '単位を入力してください');
        return false;
      }
      if (priceController?.text == "") {
        showErrorDialog(context, '価格を正しく入力してください');
        return false;
      }
    return true;
  }
}
*/
