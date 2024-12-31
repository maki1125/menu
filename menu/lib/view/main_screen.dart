import 'package:flutter/material.dart';
import 'package:menu/common/common_widget.dart';
import 'package:menu/kudo_test.dart';
import 'package:menu/kudo_test2.dart';
import 'package:menu/view/login_screen.dart';
import 'package:menu/view/menu_list_screen.dart';
import 'package:menu/view/material_list_screen.dart';
import 'package:menu/view/dinner_list_screen.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  //ページの設定
  final List<Widget> _pages = [
    MenuList(),
    MaterialList(),
    KudoTest(),
  ];

  //タッチしたアイコンの番号を現在のインデックスにセット
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("test")
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,//indexのページを表示
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}