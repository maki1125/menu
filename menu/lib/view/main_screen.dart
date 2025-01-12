import 'package:flutter/material.dart';
//import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menu/common/common_widget.dart';
import 'package:menu/common/common_constants.dart';
//import 'package:menu/common/common_providers.dart';
//import 'package:menu/view/menu_create_screen.dart';
import 'package:menu/view/menu_list_screen.dart';
import 'package:menu/view/material_list_screen.dart';
import 'package:menu/view/dinner_list_screen.dart';
//import 'package:menu/view/material_create_screen.dart';
//import 'package:menu/view/login_screen.dart';


class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin { //アニメーション制御Tickerに必要。vsynsが使用できる。タブコントローラで使用。
  
  int _currentIndex = 0; //現在のページ
  late TabController _tabController; //メニュー一覧の上部タブに使用

  //ページの設定
  final List<Widget> _pages = [
    MenuList(category: '全て'),
    const MaterialListScreen(),
    DinnerList(),
  ];

/*
  final List<Widget> _otherPage = [
    MaterialCreateScreen(),
    UserAuthentication(),
    MenuCreateScreen(),
  ];
*/
   
  //アプリバーの表示
  final List<String> _appBarTitles = [
   "メニュー一覧",
   "材料一覧",
   "夕食の履歴"
  ];

  //タッチしたアイコンの番号を現在のインデックスにセット
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    //ref.read(pageProvider.notifier).state = 99;
  }

 //初期処理
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabCategories.length, vsync: this);
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
        title: Text(_appBarTitles[_currentIndex]),
      ),

      body: Column(
        children: [

          //タブバーの表示
          _currentIndex == 0
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
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
