import 'package:flutter/material.dart';
import 'dart:io'; //Fileを扱うため
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart'; //画像キャッシュ

import 'package:menu/main_screen.dart';
import 'package:menu/common/common_widget.dart';
import 'package:menu/common/common_providers.dart';
import 'package:menu/common/common_constants.dart';
import 'package:menu/menu/data/model/menu.dart';
import 'package:menu/menu/data/repository/image_repository.dart';
import 'package:menu/menu/view_model/menu_view_model.dart';

class MenuCreateScreen extends ConsumerStatefulWidget {

  final Menu? menu;//遷移元listから選択されたmenuを受け取る。編集の場合は受け取り、新規登録の時は受け取らない。
  const MenuCreateScreen({super.key, required this.menu});//コンストラクタで名前つきでデータを受け取る。

  @override
  MenuCreateScreenState createState() => MenuCreateScreenState();
}

class MenuCreateScreenState extends ConsumerState<MenuCreateScreen> {

  //入力項目の設定。初期値は初期化処理ないで設定。
  late TextEditingController _nameController ;
  late TextEditingController _quantityController ;
  late TextEditingController _materialController;
  late TextEditingController _numController ;
  late TextEditingController _unitController ;
  late TextEditingController _priceController ;
  late TextEditingController _howToMakeController ;
  late TextEditingController _memoController ;

  //変数
  List<Map<String, dynamic>> _savedMaterials= [];  //保存する材料リスト。メソッドで使用するため、widgetの外で定義する。
  //final List<dynamic> _savedMaterials= [];  //保存する材料リスト。メソッドで使用するため、widgetの外で定義する。
  late Menu _menu; //登録するデータをここに入れる
  final List<String> dropdownItems = tabCategories.sublist(3); //タグのプルダウンの項目
  bool _isLoading = false; // 登録処理のローディング状態を管理
  //MaterialModel? _result; //材料一覧から選択時に結果を入れる
  Map<String, dynamic>?  selectedMaterial; // 材料一覧から選択時に再描写のために使用
  double calculatedPrice = 0; // 計算結果を保持する変数.小数点まで計算する
  bool editFlg = false; //編集か機種更新か判断するフラグ
  num sumPrice = 0; //合計金額 intとdoubleどちらも対応できるようにnum型にした。

  //リソース解放。ウィジェット破棄後に、コントローラを破棄。
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

  

  //初期化処理
  @override
  void initState() {
    super.initState();

    //遷移元から受け取ったmenulを受け取る
    if(widget.menu!= null){//編集時のみの処理

      editFlg = true;
      _menu = widget.menu!; //遷移元から受け取ったmenuを受け取る。
      _savedMaterials = _menu.materials!;

      //テキストフィールドの初期値の設定
      _nameController = TextEditingController(text: _menu.name);
      _quantityController = TextEditingController(text: _menu.quantity.toString());
      _materialController = TextEditingController();
      _numController = TextEditingController(text: "1");
      _unitController = TextEditingController();
      _priceController = TextEditingController();
      _howToMakeController = TextEditingController(text: _menu.howToMake);
      _memoController = TextEditingController(text: _menu.memo);

      //合計金額の初期計算
      sumPrice = _savedMaterials.fold(0, (sum, item) => sum + (item["price"] as num));

    }else{//新規登録
      _menu = Menu(); // インスタンスを初期化
      _menu.isFavorite = false; // 初期値を設定

      //テキストフィールドの初期値の設定
      _nameController = TextEditingController(text: _menu.name);
      _quantityController = TextEditingController(text: "1");
      _materialController = TextEditingController();
      _numController = TextEditingController(text: "1");
      _unitController = TextEditingController();
      _priceController = TextEditingController();
      _howToMakeController = TextEditingController();
      _memoController = TextEditingController();

    }

    //新規登録と編集の共通処理
    dropdownItems.insert(0, "カテゴリー無"); //プルダウンの選択しに追加
    _numController.addListener(_calculatePrice);// コントローラのリスナーを追加
    
  }

  // 材料の数量変えた時の値段の計算ロジック（材料一覧から選択時のみ）
  void _calculatePrice() {
    setState(() {
      
      if(selectedMaterial != null){//材料一覧から選択の場合のみ数量テキストを入力したときに計算する。
        int quantity = int.tryParse(_numController.text) ?? 1;
        calculatedPrice = (selectedMaterial!["price"]/selectedMaterial!["quantity"]) * quantity;
      }
    });
  }

  // フォームのクリア
  void _clearform() {

    //材料の削除
    _savedMaterials.clear();
    
    //テキストフィールド
    _nameController.clear();
    _quantityController.clear();
    _materialController.clear();
    _numController.clear();
    _unitController.clear();
    _priceController.clear();
    _howToMakeController.clear();
    _memoController.clear();

    //タグ
    ref.read(dropDownProvider.notifier).state = "全て"; // 値を更新

    //画像のクリア
    ref.read(selectedImageProvider.notifier).state = null;
    _menu.imagePath = "noData";
    _menu.imageURL = "noData";

    //材料一覧から選択の結果のクリア
    selectedMaterial = null;

    //お気に入りアイコン
    setState((){ //これによりtrueの場合でも再描写されるので、材料もクリアされる。
    _menu.isFavorite = false;
    });

  }
  
  @override
  Widget build(BuildContext context) {    
    print("menu_create");
    return SingleChildScrollView(//スクロール可能とする
      child: Stack( //お気に入りボタンを右上に配置するため、stack使用。
        children: [

          //お気に入りボタン
          Positioned(
            top: -5,
            right: 0,
            child: IconButton(
              onPressed: () {
                setState((){ //再描写のためにsetStateを使用。
                  _menu.isFavorite = !(_menu.isFavorite!);
                  });
              },
              // 表示アイコン
              icon: const Icon(Icons.favorite),
              // アイコン色
              color: _menu.isFavorite! == true
              ? Colors.pink
              : Colors.grey,
              // サイズ
              iconSize: 25,
            )
          ),

          /*全項目クリアするアイコンの意味だが、削除と紛らわしいのでやめる。
          //クリアボタン
          Positioned(
            top: -10,
            right: 30,
            child: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _clearform();
            },
            iconSize: 25,
          ),
          ),
          */

          Column(
            children: [
              const SizedBox(height: 5,),//材料名テキストフィールドとアプリバーの間に隙間を設ける

              //料理名ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
              _buildTextField(
                  hintText: '料理名',
                  controller: _nameController,
                  keyboardType: TextInputType.text,
                  setWidth: 250,
              ),

              //材料ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
              Row(//Rowで囲まないと材料が左揃えにならないため。
                children: [
                  _titleText(title: '    材料   '),
                ],
              ),

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
                                      print("削除：${_savedMaterials[index]["price"]}");
                                      sumPrice -= _savedMaterials[index]["price"];
                                      _savedMaterials.removeAt(index); // 指定されたインデックスを削除
                                      //
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
              selectedMaterial == null //材料一覧から選択かどうか
              ? Row( //手入力の場合
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
              )
              
              : Row(//材料一覧から選択の場合
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 100,
                      child:Text(selectedMaterial!["name"],
                      textAlign: TextAlign.center, // テキストを中央揃え),
                      )
                    ),
                    _buildTextField(
                    hintText: '1',
                    controller: _numController,
                    keyboardType: TextInputType.number,
                    setWidth: 50,
                  ),
                    SizedBox(
                      width: 70,
                      child: Text(selectedMaterial!["unit"],
                      textAlign: TextAlign.center
                      ),
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: Text(calculatedPrice.toStringAsFixed(1)[calculatedPrice.toStringAsFixed(1).length -1]=="0"
                            ? calculatedPrice.toStringAsFixed(0)//整数表示
                            : calculatedPrice.toStringAsFixed(1),//少数第一位まで表示
                          textAlign: TextAlign.center),
                          ),
                        const Text(" 円"),
                      ]
                    ),
                    IconButton(
                      icon: const Icon(Icons.control_point_rounded),
                      onPressed: () {
                        _addButton();
                      },
                    ),
                  ],
                ),
                //材料一覧から選択ボタンと合計金額の表示
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,//等間隔（両端空間あり） 
              children: [
                //材料一覧から選択ボタン
                TextButton(
                  onPressed: () async{
                    ref.read(selectMaterialProvider.notifier).state = 1;
                    ref.read(bottomBarProvider.notifier).state = 1;
                    ref.read(pageProvider.notifier).state = 1;
                    ref.read(selectMaterialProvider.notifier).state = 1;
                    Map<String, dynamic> _result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MainPage()),
                    );
                  
                    //初期値の表示
                    setState(() {
                      selectedMaterial = _result; // 結果を保存
                      calculatedPrice = (selectedMaterial!["price"]/selectedMaterial!["quantity"]);
                      _numController.text = "1";
                    });
                  },
                  child: const Text('+材料一覧から選択'),
                ),

                //合計金額の表示
                Text("  合計：$sumPrice円")
              ],
            ),
            const SizedBox(height: 10,),

            //「分量・タグ・作り方題名」と画像の横並----------------------------------                                                
            Row(
              //mainAxisAlignment: MainAxisAlignment.start, // 左寄せ
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // 左寄せ
                    children: [

                      //分量ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
                      Row(
                        children: [
                          _titleText(title: '   分量   '),
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
                          _titleText(title: '   タグ   '),
                          Consumer( //タグ変更時に再描写のエリアを制限するためconsumer使用。
                            builder: (context, ref, child) {
                              final selectedValue = ref.watch(dropDownProvider); // プルダウンの選択項目
                              return DropdownButton<String>(
                                hint: const Text('カテゴリー無'), // ヒント表示
                                value: _menu.tag != "noData"
                                  ? _menu.tag == "全て"
                                    ? "カテゴリー無"
                                    : _menu.tag
                                  : dropdownItems.contains(selectedValue)
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
                                    _menu.tag = "noData";
                                    ref.read(dropDownProvider.notifier).state = newValue; // 値を更新
                                  }
                                },
                              );
                            },
                          ),
                        ]),
                      const SizedBox(height: 10,),
            
                      //作り方の題名------------------------------------------------------
                      Row(//Rowで囲まないと材料が左揃えにならないため。
                        children: [
                          _titleText(title: '   作り方   '),
                        ],
                      ),
                    ],
                  ),
                ),

                //画像選択ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),// 8ピクセルの余白
                    child: GestureDetector(
                      onTap: () async{
                        print("画像選択します。");
                        await ImageRepository(currentUser!, _menu, ref).selectImage();//ここでselectecImageProviderを更新。
                        //.then((value) => print(menu.imageURL));
                      }, // 領域をタップしたら画像選択ダイアログを表示
                      child: Consumer( //画像選択変更時に、ここだけ再描写されるようにconsumer使用。
                        builder: (context, ref, child){
                          final File? selectedImage = ref.watch(selectedImageProvider); //選択画像
                          return Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              color: Colors.grey[200], // 背景色
                              border: Border.all(color: Colors.grey), // 枠線
                              borderRadius: BorderRadius.circular(10), // 角丸
                            ),
                            

                            child: selectedImage != null
                            //①選択された画像がある場合
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10), // 選択画像の角丸
                                child: 
                                Image.file(
                                  selectedImage,
                                  fit: BoxFit.cover, // 領域に合わせて表示
                                  //width: 130,
                                  //height: 130,
                                ),
                              )
                            : editFlg 
                              //編集の場合-----------------------------------
                              ? _menu.imageURL=="noData"
                                //②画像選択してください
                                ? const Center(
                                  child: Text(
                                    '画像を選択',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                                //③編集前の画像表示
                                : ClipRRect(
                              borderRadius: BorderRadius.circular(10), // 選択画像の角丸
                              child:
                                CachedNetworkImage(
                                  imageUrl: _menu.imageURL!.toString(), // ネットワーク画像のURL
                                  placeholder: (context, url) =>  Transform.scale(//sizedboxでは小さくならなかったのでscaleを使用。
                                    scale: 0.3, // 縮小率を指定
                                    child: const CircularProgressIndicator(strokeWidth: 20.0),
                                  ),
                                  
                                  errorWidget: (context, url, error) => Icon(Icons.error), // エラーの場合に表示するウィジェット
                                  fit: BoxFit.cover, // 画像の表示方法を指定（例：全体をカバー）
                                )
                                )
                              //新規登録の場合-----------------------------------
                              //②画像選択してください
                              : const Center(
                                  child: Text(
                                    '画像を選択',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                          );
                        }
                      )
                    ), 
                  ),
                )
              ],
            ),

            //作り方（本文）
            const SizedBox(height: 10,),
            _buildTextField(
              hintText: "1.材料混ぜて、形を作る。\n2.強火で２分焼く",
              controller: _howToMakeController,
              keyboardType: TextInputType.multiline,
              setWidth: 350,
              setHeight: 120,
              setMaxline: 5,
              textAlign: TextAlign.left,
            ),

            //メモーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
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

            
            //登録ボタンーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
            OutlinedButton(//枠線ありボタン
            onPressed: () async{ 
              if(_nameController.text == ""){
                showMessage("料理名を入力してください。");
              }else{
              setState(() {
                _isLoading = true; // ローディング開始
              });

              //メニューのデータ保存
              _menu.createAt = DateTime.now();
              _menu.name = _nameController.text;
              //_menu.imageURL  //addImage()で保存される
              //_menu.imagePath  //addImage()で保存される
              _menu.quantity = int.tryParse(_quantityController.text) ?? 1;
              _menu.tag = ref.read(dropDownProvider.notifier).state;
              _menu.materials = _savedMaterials; //あとで
              _menu.howToMake = _howToMakeController.text;
              _menu.memo = _memoController.text;
              //_menu.id //addMenu()で保存される
              _menu.dinnerDate = DateTime.now(); //新規作成の時は登録日にする。
              _menu.dinnerDateBuf = DateTime.now(); //新規作成の時は登録日にする。
              _menu.price = sumPrice; //addMenu()で計算される
              //_menu.unitPrice = 0; //addMenu()で計算される
              
              ImageRepository(currentUser!, _menu, ref).deleteImage(); 
              if(editFlg){
                await ImageRepository(currentUser!, _menu, ref).editImage(); //画像とデータ保存
                print("変更しました。");
                Navigator.pop(context);//元画面(メニュー詳細)に遷移
              }else{
                
              await ImageRepository(currentUser!, _menu, ref).addImage(); //画像とデータ保存
              print("新規登録しました。");
                resetPageChange(context, ref, 0, 0); //メニュー一覧に遷移
              }

              setState(() {
                _isLoading = false; // ローディング終了
              });
              }
            },
            
            style: OutlinedButton.styleFrom(
	            //padding: EdgeInsets.zero, // 完全にパディングを削除
              //padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2), // パディングを調整
              minimumSize: const Size(50, 30), // 最小サイズを指定
              backgroundColor:  editFlg ?Colors.blue :Colors.orange,
            ),
            child: Text(editFlg ?'変更' :'登録',
              style: const TextStyle(
              //fontSize: 12,
              color: Colors.white
              ),
            ),         
          ),
          ],
        ),
        // ローディングインジケーター.
        Positioned(
            top: MediaQuery.of(context).size.height / 2 , // 高さの中央
            right: MediaQuery.of(context).size.width / 2 , // 幅の中央
            child:_isLoading
            ? const Center(
              child: CircularProgressIndicator(),
            )
            : const SizedBox.shrink()
          )
        ],
      )
  );
}

 //材料追加ボタン（プラスアイコン）
  void _addButton(){
    if (_materialController.text != "" || selectedMaterial != null){
      
      setState((){
        
        selectedMaterial == null
        ?_savedMaterials.add({//手入力の場合
          
          "name": _materialController.text,
          "quantity": int.tryParse(_numController.text) ?? 1,
          "unit": _unitController.text,
          "price":int.tryParse(_priceController.text) ?? 0,
        })
        :_savedMaterials.add({//材料一覧から選択の場合
          
          "name": selectedMaterial!["name"],
          "quantity": int.tryParse(_numController.text) ?? 1,
          "unit": selectedMaterial!["unit"],
          "price":calculatedPrice.round() ?? 0, //小数点を四捨五入して整数にする
        });
        sumPrice += _savedMaterials.last["price"];
        print("追加：${_savedMaterials.last["price"]}");
      });
      _materialController.text = "";
      _numController.text = "";
      _unitController.text = "";
      _priceController.text = "";
      selectedMaterial = null;
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