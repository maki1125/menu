import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:menu/main_screen.dart';
import 'package:menu/common/common_providers.dart';
import 'package:menu/login/view_model/login_view_model.dart';



class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap; //int引数を受け取りコールバック関数を指定するプロパティ

  const CustomBottomBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap, //BottomNavigationBarが内部的にタップイベントを監視し、indexをonTapに渡す。
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'メニュー一覧',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.filter_vintage),
          label: '材料一覧',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.flatware),
          label: '夕食の履歴',
        ),
      ],
    );
  }
}

//AppBar
class AppBarComponentWidget extends ConsumerWidget
    implements PreferredSizeWidget {
  //AppBarの高さを指定するためのWidget
  final String title;
  const AppBarComponentWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return AppBar(
      title: Text(
        title,
        style: GoogleFonts.pacifico(), //Googleフォントを使用
      ),
      centerTitle: true, //タイトルを中央に配置
      elevation: 10.0, //影の設定
      actions: <Widget>[
        authState.when(
          data: (user) {
            FirebaseAuth.instance.currentUser?.reload();
          final user = FirebaseAuth.instance.currentUser;
            if (user?.isAnonymous == false) {
            return  Padding(
              padding: const EdgeInsets.only(right: 10), 
              child:
            
                user!.photoURL != null
                ? GestureDetector(
                  onTap: () {
                    pageChange(context, ref, 7); // クリック時の処理
                  },
                  child: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(user.photoURL!),
                    radius: 15, // 小さくする（25 → 20）
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.account_circle, size: 32),
                  onPressed: () {
                    pageChange(context, ref, 7);
                  },
                )
                );
            } else {
              return IconButton(
                icon: const Icon(Icons.no_accounts, size: 32), // ユーザーが存在しない場合
                onPressed: () {
                  pageChange(context, ref, 7);
                },
              );
            }
          },

          loading: () => const CircularProgressIndicator(), // ローディング中
          error: (error, stack) => const Icon(Icons.error), // エラー時
        ),
      ],
      //centerTitle: true,
      backgroundColor: Colors.white,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50); //AppBarの高さを指定

  
}

//ポップアップメッセージ(メッセージのみ)
void showMessage(String message) {
  Fluttertoast.showToast(
    msg: message, // メッセージを設定
    timeInSecForIosWeb: 1, // 表示時間
    gravity: ToastGravity.CENTER, // 表示位置
    fontSize: 16.0, // フォントサイズ
    //backgroundColor: Colors.black, // 背景色
    //textColor: Colors.white, // 文字色
  );
}

// showMessageと同じ
void toast(String message){
  Fluttertoast.showToast(
    timeInSecForIosWeb: 1,
    gravity: ToastGravity.CENTER,
    fontSize: 16,
    msg: message,
  ); //
}
//表示の最大文字設定
String maxText(String text, int num) {
  return text.length > num ? '${text.substring(0, num)}...' : text;
}

// エラーダイアログの表示
void showErrorDialog(BuildContext context,String message) {
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

//履歴を削除してページ遷移
void resetPageChange(BuildContext context, WidgetRef ref, int dispPage, int bottomBar){
  ref.read(pageProvider.notifier).state = dispPage;
  ref.read(bottomBarProvider.notifier).state = bottomBar;
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (context) => MainPage(),),
    (Route<dynamic> route) => false, // すべての履歴を削除
  );
}

//ページ遷移
void pageChange(context, ref, int index) {
  ref.read(pageProvider.notifier).state = index;
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MainPage(),
    ),
  );
}

//検索ボックス
//検索テキストフィールドのコントローラを受け取り、検索文字を管理するプロバイダーを書き換える。
Widget searchBox(controller, ref,searchTextProvider, hint){//ref){//}, materials) {
  return SizedBox(
    //width: width,
    child: TextField(
      controller: controller,//searchController, // コントローラー
      keyboardType: TextInputType.text, // キーボードタイプ
      textInputAction: TextInputAction.search, // 検索ボタンを表示
      onChanged: (text) {
        ref.read(searchTextProvider.notifier).state = text;
      },
      onSubmitted: (value) {}, // テキストフィールドでエンターキーが押されたときの処理
      decoration: InputDecoration(
        // テキストフィールドの装飾
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          // フィルターや並び替えの機能が追加できる
          icon: const Icon(
            Icons.sort,
            size: 20,
          ),
          onPressed: () {},
        ),

        hintText: hint,
        border: InputBorder.none, // 枠線を非表示
        hintStyle: const TextStyle(
            color: Color.fromARGB(255, 198, 198, 198)), // hintTextの色を設定
      ),
    ),
  );
}
