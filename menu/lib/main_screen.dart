
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:menu/common/common_widget.dart';
import 'package:menu/common/common_constants.dart';
import 'package:menu/common/common_providers.dart';
import 'package:menu/menu/data/model/menu.dart';
import 'package:menu/menu/view/menu_create_screen.dart';
import 'package:menu/menu/view/menu_list_screen.dart';
import 'package:menu/menu/view/menu_detail_screen.dart';
import 'package:menu/menu/view_model/menu_view_model.dart';
import 'package:menu/material/data/model/material.dart';
import 'package:menu/material/view/material_create_screen.dart';
import 'package:menu/material/view/material_list_screen.dart';
import 'package:menu/dinner/view/dinner_list_screen.dart';
import 'package:menu/login/view/login_screen.dart';


class MainPage extends ConsumerStatefulWidget {

  Menu? menu; //menuを受け取れるようにする。
  MaterialModel? material; //materialを受け取れるようにする。
  MainPage({Key? key, this.menu, this.material}) : super(key: key); //menuデータを受け取ることができるようにする。

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage>
    with SingleTickerProviderStateMixin {
  //アニメーション制御Tickerに必要。vsynsが使用できる。タブコントローラで使用。

  int _bottomBarIndex = 0; //現在ボトムバーの選択
  int _pageIndex = 0; //現在のページ
  late TabController _tabController; //メニュー一覧の上部タブに使用
  late Menu? menu;
  late MaterialModel? material;
  late List<Widget> _pages;

  //初期処理
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabCategories.length, vsync: this);
    _bottomBarIndex = ref.read(bottomBarProvider.notifier).state;
    _pageIndex = ref.read(pageProvider.notifier).state;
    menu = widget.menu; //statefulWidgetで受け取ったmenuをstateの中で使えるようにする。
    material = widget.material;

    //「夕飯」タブの変更を監視。「夕飯」タブ切り替え時に日付を今日の日付に変更する。
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        print("今日の夕飯のタブです");
        setState(() {
          ref.read(selectDinnerDateProvider.notifier).state = DateTime.now();
        });
      }
    });

    //ページリストの初期化.menuを参照するため、初期化内で参照する。
    _pages = [
      const MenuList(category: '全て'),
      const MaterialListScreen(),
      DinnerList(),
      MenuCreateScreen(menu: menu),
      MaterialCreateScreen(material: material),
      MenuDetailScreen(menu: menu),
      MenuCreateScreen(menu: menu),
      UserAuthentication(),
      MaterialCreateScreen(material: material),
    ];
  }

  //アプリバーの表示
  final List<String> _appBarTitles = [
    "メニュー一覧",
    "材料一覧",
    "夕食の履歴",
    "メニュー登録",
    "材料登録",
    "メニュー詳細",
    "メニュー編集",
    "ユーザー",
    "材料編集",
  ];

  //タッチしたアイコンの番号を現在のインデックスにセット
  void _onItemTapped(int index) {
    setState(() {
      _bottomBarIndex = index;
      _pageIndex = index;
    });
    //ref.read(pageProvider.notifier).state = 99;
  }

  //ウィジェット
  @override
  Widget build(BuildContext context) {
    print("main");

    //final otherPage = ref.read(pageProvider.notifier);

    return Scaffold(
      resizeToAvoidBottomInset:
          _pageIndex == 7 ? false : true, //キーボード表示時に画面をリサイズしない、エラー対策
      appBar: AppBarComponentWidget(title: _appBarTitles[_pageIndex]),
      //appBar: _currentIndex != 0 || otherPage.state != initOtherPage
      //? AppBarComponentWidget()
      // : null, //空のwidegt

      // appBar: AppBar(
      //   title: Text(_appBarTitles[_pageIndex]),
      // ),

      body: Column(
        children: [
          //タブバーの表示
          _pageIndex == 0
              ? SafeArea(
                  //時計、バッテリー表示を避ける
                  child: Material(
                    //tabBbarの表示のためにMaterialで囲む。
                    color: Colors.white, // TabBar の背景色
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true, // タブをスクロール可能にする
                      tabs: tabCategories
                          .map((category) => Tab(text: category))
                          .toList(),
                      labelColor: Colors.black, // 選択中のタブの色
                      unselectedLabelColor: Colors.grey, // 選択されていないタブの色
                    ),
                  ),
                )
              : const SizedBox.shrink(), //空のwidegt

          //画面の表示
          Expanded(
            child: _pageIndex == 0
                ? TabBarView(
                    controller: _tabController,
                    children: 
                    tabCategories.map((category) {
                      return MenuList(category: category);
                    }).toList(),
                    
                  )
                : _pages[_pageIndex],
          )
        ],
      ),

      bottomNavigationBar: CustomBottomBar(
        currentIndex: _bottomBarIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
