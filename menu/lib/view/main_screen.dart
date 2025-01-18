import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menu/common/common_widget.dart';
import 'package:menu/common/common_constants.dart';
import 'package:menu/common/common_providers.dart';
import 'package:menu/data/model/menu.dart';
import 'package:menu/view/material_create_screen.dart';
import 'package:menu/view/menu_create_screen.dart';
//import 'package:menu/view/menu_create_screen.dart';
import 'package:menu/view/menu_list_screen.dart';
import 'package:menu/view/menu_detail_screen.dart';
import 'package:menu/view/menu_edit_screen.dart';
import 'package:menu/view/material_list_screen.dart';
import 'package:menu/view/dinner_list_screen.dart';
//import 'package:menu/view/material_create_screen.dart';
//import 'package:menu/view/login_screen.dart';


class MainPage extends ConsumerStatefulWidget {

  Menu? menu;
  MainPage({Key? key, this.menu}) : super(key: key); //menuデータを受け取ることができるようにする。

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage>
    with SingleTickerProviderStateMixin { //アニメーション制御Tickerに必要。vsynsが使用できる。タブコントローラで使用。
  
  int _bottomBarIndex = 0; //現在ボトムバーの選択
  int _pageIndex = 0; //現在のページ
  late TabController _tabController; //メニュー一覧の上部タブに使用
  late Menu? menu;
  late List<Widget> _pages;

 //初期処理
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabCategories.length, vsync: this);
    _bottomBarIndex = ref.read(bottomBarProvider.notifier).state;
    _pageIndex = ref.read(pageProvider.notifier).state;

    menu = widget.menu;

    //ページリストの初期化.menuを参照するため、初期化内で参照する。
     _pages = [
    MenuList(category: '全て'),
    const MaterialListScreen(),
    DinnerList(),
    const MenuCreateScreen(),
    const MaterialCreateScreen(),
    MenuDetailScreen(menu: menu),
    MenuEditScreen(menu: menu),
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
      
      //appBar: AppBarComponentWidget(),
      //appBar: _currentIndex != 0 || otherPage.state != initOtherPage
           //? AppBarComponentWidget()
          // : null, //空のwidegt

      appBar: AppBar(
        title: Text(_appBarTitles[_pageIndex]),
      ),

      body: Column(
        children: [

          //タブバーの表示
          _pageIndex == 0
          ? SafeArea(//時計、バッテリー表示を避ける
            child: Material(//tabBbarの表示のためにMaterialで囲む。
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
                children: tabCategories.map((category) {
                  return MenuList(category: category);
                }).toList(),
              )
            : _pages[_pageIndex],
          )
        ],
      ),
       /*
       IndexedStack(
         index: _currentIndex,
         children:_pages, //indexのページを表示
         
       ),
       */

      /*
      body: otherPage.state != initOtherPage
          ? _otherPage[otherPage.state]
          : Column(
              children: [
                _currentIndex == 0
                    ? SafeArea(
                        //時計、バッテリー表示を避ける
                        child: Material(
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
                    : SizedBox.shrink(), //空のwidegt

                Expanded(
                  child: _currentIndex == 0
                      ? TabBarView(
                          controller: _tabController,
                          children: tabCategories.map((category) {
                            return MenuList(category: category);
                          }).toList(),
                        )
                      : _pages[_currentIndex],
                )
              ],
            ),
*/
      
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _bottomBarIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
