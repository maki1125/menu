import 'dart:io'; //Fileを扱うため
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:flutter/services.dart'; //数字入力のため
import 'package:flutter/material.dart';
import 'package:menu/data/model/menu.dart';
//import 'package:menu/data/model/user.dart';
//import 'package:menu/view/menu_list_screen.dart';
import 'package:menu/data/repository/image_repository.dart';
import 'package:menu/view_model/menu_list_view_model.dart';
import 'package:menu/common/common_providers.dart';
import 'package:menu/common/common_constants.dart';

class MenuCreateScreen extends ConsumerStatefulWidget {
  const MenuCreateScreen({Key? key}) : super(key: key); // Keyの引き渡し

  @override
  _MenuCreateScreenState createState() => _MenuCreateScreenState();
}

class _MenuCreateScreenState extends ConsumerState<MenuCreateScreen> {

  //入力項目の設定
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _materialController = TextEditingController();
  final TextEditingController _numController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _howToMakeController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _materialController.dispose();
    _numController.dispose();
    _unitController.dispose();
    _priceController.dispose();
    _howToMakeController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _savedMaterials= [];  //保存する材料リスト。メソッドで使用するため、widgetの外で定義する。
  late Menu _menu; //登録するデータをここに入れる
  final List<String> dropdownItems = tabCategories.sublist(3); //タグのプルダウンの項目
  bool _isLoading = false; // 登録処理のローディング状態を管理

  @override
  void initState() {
    super.initState();
    _menu = Menu(); // インスタンスを初期化
    _menu.isFavorite = false; // 初期値を設定
  }
  
  @override
  Widget build(BuildContext context) {    
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('メニュー登録'),

        //アプリバーの右側のアイテム
        actions: [
          OutlinedButton(//枠線ありボタン
            onPressed: () async{ 
              setState(() {
                _isLoading = true; // ローディング開始
              });
              //メニューのデータ保存
              _menu.createAt = DateTime.now();
              _menu.name = _nameController.text;
              //_menu.imageURL  //addImage()で保存される
              //_menu.imagePath  //addImage()で保存される
              _menu.quantity = int.tryParse(_quantityController.text);
              _menu.tag = "全て";
              _menu.material = []; //あとで
              _menu.howToMake = _howToMakeController.text;
              _menu.memo = _memoController.text;
              //_menu.id //addMenu()で保存される
              _menu.dinnerDate = DateTime.now(); //新規作成の時は登録日にする。
              //_menu.price //addMenu()で計算される
              //_menu.unitPrice = 0; //addMenu()で計算される

              await ImageRepository(currentUser!, _menu, ref).addImage(); //画像とデータ保存
              print("メニューの画像とデータを保存しました。");

              Navigator.pop(context);//元画面(メニュー一覧)に遷移

              setState(() {
                _isLoading = false; // ローディング終了
              });
            },
            style: OutlinedButton.styleFrom(
	            //padding: EdgeInsets.zero, // 完全にパディングを削除
              //padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2), // パディングを調整
              minimumSize: Size(50, 30), // 最小サイズを指定
              backgroundColor:  Colors.orange,
            ),
            child: const Text('登録',
              style: TextStyle(
              //fontSize: 12,
              color: Colors.white
              ),
            ),         
          ),

          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              print('削除ボタン');
            },
          ),
        ],
      ),

      body: SingleChildScrollView(//スクロール可能とする
      child: Stack( //お気に入りボタンを右上に配置するため、stack使用。
        children: [

          //お気に入りボタン
          Positioned(
            top: -10,
            right: 0,
            child: IconButton(
              onPressed: () {
                setState((){ //再描写のためにsetStateを使用。
                  _menu.isFavorite = !(_menu.isFavorite!);
                  });
              },
              // 表示アイコン
              icon: Icon(Icons.favorite),
              // アイコン色
              color: _menu.isFavorite! == true
              ? Colors.pink
              : Colors.grey,
              // サイズ
              iconSize: 25,
            )
          ),

          Column(
            children: [

          //料理名ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
          _buildTextField(
              hintText: '料理名',
              controller: _nameController,
              keyboardType: TextInputType.text,
              setWidth: 250,
          ),

          //画像選択ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
          GestureDetector(
              onTap: () {
                ImageRepository(currentUser!, _menu, ref).selectImage();
                //.then((value) => print(menu.imageURL));
              }, // 領域をタップしたら画像選択ダイアログを表示
              child: Consumer( //画像選択変更時に、ここだけ再描写されるようにconsumer使用。
                builder: (context, ref, child){
                  final File? selectedImage = ref.watch(selectedImageProvider); //選択画像
                  return Container(
                    width: 350,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200], // 背景色
                      border: Border.all(color: Colors.grey), // 枠線
                      //borderRadius: BorderRadius.circular(10), // 角丸
                    ),
                    child: selectedImage == null
                    ? const Center(
                        child: Text(
                          '画像を選択',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ClipRRect(
                        //borderRadius: BorderRadius.circular(10), // 選択画像の角丸
                        child: Image.file(
                          selectedImage,
                          fit: BoxFit.cover, // 領域に合わせて表示
                          width: 350,
                          height: 200,
                        ),
                      ),
                  );
                })
              ),
  
            const SizedBox(height: 10,),

            //分量ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
            Row(
              children: [
                _titleText(title: '    分量   '),
                Row(
                  children: [
                    _buildTextField(
                      hintText: '1',
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      setWidth: 50,
                    ),
                    const Text(" 人前"),
                  ],
                ),
                const SizedBox(height: 10,),
              ],
            ),

            //タグ選択ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
            Row(
              children: [
                _titleText(title: '    タグ   '),
                Consumer( //タグ変更時に再描写のエリアを制限するためconsumer使用。
                  builder: (context, ref, child) {
                    final selectedValue = ref.watch(dropDownProvider); // プルダウンの選択項目
                    return DropdownButton<String>(
                      hint: const Text('メイン'), // ヒント表示
                      value: dropdownItems.contains(selectedValue)
                          ? selectedValue
                          : null, // 選択値がリストに含まれていない場合は`null`
                      items: dropdownItems.map((String item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(item), // 表示内容
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          ref.read(dropDownProvider.notifier).state = newValue; // 値を更新
                        }
                      },
                    );
                  },
                ),
              ]),
            const SizedBox(height: 10,),

            //材料ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
            Row(//Rowで囲まないと材料が左揃えにならないため。
              children: [
                _titleText(title: '    材料   '),
              ],
            ),
            const SizedBox(height: 10,),

            //材料表示のエリア
            _savedMaterials.isNotEmpty//確定した材料の表示
              ? Column(                  
                  children: 
                    List.generate(_savedMaterials.length, (index){//index取得のためList.generate使用。mapではindex取得できないため。
                      final map = _savedMaterials[index];
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: 100,
                                child:Text(map['name'],
                                textAlign: TextAlign.center, // テキストを中央揃え),
                                )
                              ),
                              SizedBox(
                                width: 50,
                                child: Text(map['quantity'].toString(),
                                textAlign: TextAlign.center
                                ),
                              ),
                              SizedBox(
                                width: 70,
                                child: Text(map['unit'],
                                textAlign: TextAlign.center
                                ),
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 80,
                                    child: Text(map['price'].toString(),
                                    textAlign: TextAlign.center),
                                    ),
                                  const Text(" 円"),
                                ]
                              ),
                              IconButton(//材料表示の削除アイコン
                                icon: const Icon(Icons.delete), 
                                onPressed: () {
                                  setState(() {
                                    _savedMaterials.removeAt(index); // 指定されたインデックスを削除
                                  });
                                },
                              ), 
                            ],
                          ),
                          SizedBox(//完全にパディングをなくした横線
                            height: 0.5, // Divider の厚みに合わせる
                            child: Container(
                              color: Colors.grey, // Divider の色に合わせる
                              margin: EdgeInsets.only(left: 10, right: 50), // indent と endIndent を再現
                            ),
                          ),
                        ]
                      );
                    }
                  )
                )
              :const SizedBox.shrink(),
            const SizedBox(height: 10,),

            //材料入力のエリア
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTextField(
                  hintText: '牛肉',
                  controller: _materialController,
                  keyboardType: TextInputType.text,
                  setWidth: 100,
                ),
                _buildTextField(
                  hintText: '1',
                  controller: _numController,
                  keyboardType: TextInputType.number,
                  setWidth: 50,
                ),
                _buildTextField(
                  hintText: 'g',
                  controller: _unitController,
                  keyboardType: TextInputType.text,
                  setWidth: 70,
                ),
                Row(
                  children: [
                    _buildTextField(
                      hintText: '250',
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      setWidth: 80,
                    ),
                    const Text(" 円")
                  ],  
                ),
                IconButton(
                  icon: const Icon(Icons.control_point_rounded),
                  onPressed: () {
                    _addButton();
                  },
                ),
              ],
            ),

            //材料一覧から選択ボタン
            TextButton(
              onPressed: () {/* ボタンがタップされた時の処理 */},
              child: const Text('+材料一覧から選択'),
            ),
            const SizedBox(height: 10,),

            //作り方ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
            Row(//Rowで囲まないと材料が左揃えにならないため。
              children: [
                _titleText(title: '    作り方   '),
              ],
            ),
            const SizedBox(height: 10,),
            _buildTextField(
              hintText: "1.材料混ぜて、形を作る。\n2.強火で２分焼く",
              controller: _howToMakeController,
              keyboardType: TextInputType.multiline,
              setWidth: 350,
              setHeight: 60,
              setMaxline: 2,
              textAlign: TextAlign.left,
            ),

            //メモ------------------------------------------------------
            Row(//Rowで囲まないと材料が左揃えにならないため。
              children: [
                _titleText(title: '    メモ   '),
              ],
            ),
            const SizedBox(height: 10,),
            _buildTextField(
              hintText: '美味しかった。また作りたい。',
              controller: _memoController,
              keyboardType: TextInputType.multiline,
              setWidth: 350,
              setHeight: 60,
              setMaxline: 2,
              textAlign: TextAlign.left,
            ),
          ],
        ),
        // ローディングインジケーター.
        Positioned(
            top: MediaQuery.of(context).size.height / 2 - 50, // 高さの中央
            right: MediaQuery.of(context).size.width / 2 - 50, // 幅の中央
            child:_isLoading
            ? const Center(
              child: CircularProgressIndicator(),
            )
            : const SizedBox.shrink()
          )
        ],
      )
    ) 
  );
}

  void _addButton(){
    if (_materialController.text != ""){
      setState((){
        _savedMaterials.add({
          "name": _materialController.text,
          "quantity": _numController.text,
          "unit": _unitController.text,
          "price":_priceController.text != "" ? _priceController.text : 0
        });
      });
      _materialController.text = "";
      _numController.text = "";
      _unitController.text = "";
      _priceController.text = "";
    }
  }
}

//タイトルテキストの設定
Widget _titleText({
  required String title,
}) {
  return Text(
    title,
    style: const TextStyle(
      //color: Colors.red,
      fontSize: 20,
      fontWeight: FontWeight.bold
    ),
    textAlign: TextAlign.left,
  );
}

//テキストフィールドの設定
Widget _buildTextField({
  //required String labelText,
  final String hintText = '',
  required TextEditingController controller,
  TextInputType keyboardType = TextInputType.text,
  double setWidth = 300,
  double setHeight = 30,
  int setMaxline = 1,
  TextAlign textAlign = TextAlign.center,
}) {
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
            contentPadding: EdgeInsets.symmetric(
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


