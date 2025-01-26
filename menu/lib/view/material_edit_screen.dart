import 'package:flutter/material.dart';
import 'package:menu/data/repository/material_repository.dart';
import 'package:menu/data/model/material.dart';
import 'package:menu/common/common_widget.dart';

class MaterialUpdateScreen extends StatefulWidget {
  final MaterialModel? material; //遷移元から選択されたmaterialを受け取る。
  const MaterialUpdateScreen({super.key, required this.material});

  @override
  MaterialUpdateScreenstate createState() => MaterialUpdateScreenstate();
}

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
