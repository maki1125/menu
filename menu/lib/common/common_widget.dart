import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:menu/view/login_screen.dart';

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

class AppBarComponentWidget extends StatelessWidget
    implements PreferredSizeWidget {
  AppBarComponentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        'Cook Dinner',
        style: GoogleFonts.pacifico(),
      ),
      centerTitle: true,
      elevation: 10.0,
      leading: IconButton(
        icon: Icon(Icons.account_circle),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserAuthentication(),
            ),
          );
        },
      ),
      //centerTitle: true,
      backgroundColor: Colors.white,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(40);
}
