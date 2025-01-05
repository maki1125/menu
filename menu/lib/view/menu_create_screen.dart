import 'dart:io'; //Fileを扱うため
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart'; //数字入力のため

import 'package:flutter/material.dart';
import 'package:menu/data/model/menu.dart';
import 'package:menu/data/model/user.dart';
import 'package:menu/view/menu_list_screen.dart';
import 'package:menu/data/repository/image_repository.dart';
import 'package:menu/view_model/menu_list_view_model.dart';
import 'package:menu/common/common_providers.dart';
import 'package:menu/common/common_constants.dart';


class MenuCreateScreen extends ConsumerStatefulWidget {
  const MenuCreateScreen({Key? key}) : super(key: key);  // Keyの引き渡し

  @override
  _MenuCreateScreenState createState() => _MenuCreateScreenState();
}

class _MenuCreateScreenState extends ConsumerState<MenuCreateScreen>{

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

  @override
  Widget build(BuildContext context) {

    Menu menu = new Menu(); //空のMenuインスタンスを作成
    File? selectedImage = ref.watch(selectedImageProvider);
    final List<String> dropdownItems = tabCategories.sublist(3);//タグのプルダウンの項目
    String? selectedValue; 

    return Scaffold(
      appBar: AppBar(
        title: Text('メニュー登録'),
      ),
      body: 

      Column(
        children: [

          //料理名
          _buildTextField(
              hintText: '料理名',
              controller: _nameController,
              keyboardType: TextInputType.text,
              setWidth: 250,
          ),

          //画像選択
          GestureDetector(
            onTap: (){
              ImageRepository(currentUser!, menu, ref)
                .addImage();
                //.then((value) => print(menu.imageURL));
            }, // 領域をタップしたら画像選択ダイアログを表示
            child: Container(
              width: 350,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200], // 背景色
                border: Border.all(color: Colors.grey), // 枠線
                //borderRadius: BorderRadius.circular(10), // 角丸
              ),
              child: selectedImage == null
                ? Center(
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
              )
            ),
            SizedBox(height: 10,),

          //分量
          Row(
            children: [
              _titleText(title:'    分量   '),
              Row(
                children: [
                  _buildTextField(
                    hintText: '1',
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    setWidth: 50,
                    ),
                    Text(" 人前"),
                ],
              ),    
              SizedBox(height: 10,),
            ],
          ),

          //タグ選択
          Row(
            children: [
              _titleText(title:'    タグ   '),
              
              DropdownButton<String>(
                hint: Text('メイン'), // ヒント表示
                value: selectedValue, // 選択されている値
                items: dropdownItems.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item), // 表示内容
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  //print(newValue);
                  setState(() {
                    selectedValue = newValue; // 新しい値をセット
                    //print(selectedValue);
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 10,),

          //材料
          Row(//Rowで囲まないと材料が左揃えにならないため。
            children: [
              _titleText(title:'    材料   '),
            ],
          ),
          SizedBox(height: 10,),
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
                Text(" 円")
                  ],
                ), 
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(//枠線なしボタン。リンクっぽい？
                  onPressed: () { /* ボタンがタップされた時の処理 */ },
                  child: Text('+材料'),
                ),  
                TextButton(//枠線なしボタン。リンクっぽい？
                  onPressed: () { /* ボタンがタップされた時の処理 */ },
                  child: Text('+材料一覧から選択'),
                ),  
              ],
            ),
            SizedBox(height: 10,),

          //作り方
          Row(//Rowで囲まないと材料が左揃えにならないため。
            children: [
              _titleText(title:'    作り方   '),
            ],
          ),
          SizedBox(height: 10,),
          _buildTextField(
            hintText: "1.材料混ぜて、形を作る。\n2.強火で２分焼く",
            controller: _howToMakeController,
            keyboardType: TextInputType.multiline,
            setWidth: 350,
            setHeight: 60,
            setMaxline: 2,
            textAlign: TextAlign.left,
            ),

          //メモ
          Row(//Rowで囲まないと材料が左揃えにならないため。
            children: [
              _titleText(title:'    メモ   '),
            ],
          ),
          SizedBox(height: 10,),
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
      )
    );
  }
}

//タイトルテキストの設定
Widget _titleText({
  required String title,
}){
  return Text(title,
  style: TextStyle(
    //color: Colors.red, 
    fontSize: 20, fontWeight: 
    FontWeight.bold
    ),
	textAlign: TextAlign.left,);
  
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
    return 
    Column(
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
          contentPadding: EdgeInsets.symmetric(horizontal: 3, vertical: 5), //hintTextの垂直方向を中央に揃える。
          hintStyle: const TextStyle(
              color: Color.fromARGB(255, 198, 198, 198)), // hintTextの色を設定
          
        ),
      ),
    ),
        SizedBox(height: 10,),
      ],
    );
    
  }

                  