import 'package:flutter/material.dart';
import 'package:menu/common/common_widget.dart';
import 'package:menu/kudo_test.dart';
//import 'package:menu/kudo_test2.dart';
//import 'package:menu/view/login_screen.dart';
import 'package:menu/view/menu_list_screen.dart';
import 'package:menu/view/material_list_screen.dart';
import 'package:menu/view/dinner_list_screen.dart';
import 'package:menu/view/material_create_screen.dart';
import 'package:menu/data/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menu/view_model/material_list_view_model.dart';
import 'package:menu/view/login_screen.dart';
import 'package:menu/common/gloval_variable.dart';

class MainPage extends ConsumerStatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late TabController _tabController;

  //ページの設定
  final List<Widget> _pages = [
    MenuList(category: '全て'),
    MaterialListScreen(),
    //KudoTest(),
    DinnerList(),
  ];

  final List<Widget> _otherPage = [
    MaterialCreateScreen(user: currentUser!),
    UserAuthentication(),
  ];
  final List<String> tabCategories = [
    '全て',
    'お気に入り',
    '今日の夕食',
    'メイン',
    '汁物',
    '麺類',
    'デザート',
    'ご飯もの'
  ];

  //タッチしたアイコンの番号を現在のインデックスにセット
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabCategories.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final otherPage = ref.read(pageProvider.notifier);

    return Scaffold(
      appBar: _currentIndex != 0 || otherPage.state != initOtherPage
          ? AppBarComponentWidget()
          : null, //空のwidegt
      // body: IndexedStack(
      //   index: _currentIndex,
      //   children: _pages, //indexのページを表示

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
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
