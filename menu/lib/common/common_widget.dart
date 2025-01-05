import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:menu/view/login_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menu/view_model/login_screen_view_model.dart';
//import 'package:menu/data/providers.dart';
import 'package:menu/view/main_screen.dart';
import 'package:menu/common/common_providers.dart';

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

class AppBarComponentWidget extends ConsumerWidget
    implements PreferredSizeWidget {
  AppBarComponentWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return AppBar(
      title: Text(
        'Cook Dinner',
        style: GoogleFonts.pacifico(),
      ),
      centerTitle: true,
      elevation: 10.0,
      leading: //IconButton(
          //icon: Icon(Icons.account_circle),
          authState.when(
        data: (user) {
          if (user != null && user.photoURL != null) {
            return IconButton(
              icon: CircleAvatar(
                backgroundImage: NetworkImage(user.photoURL!),
                radius: 16,
              ),
              onPressed: () {
                ref.read(pageProvider.notifier).state = 1;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainPage(),
                  ),
                );
              },
            );
          } else {
            return IconButton(
              icon: const Icon(Icons.account_circle, size: 24),
              onPressed: () {
                ref.read(pageProvider.notifier).state = 1;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainPage(),
                  ),
                );
              },
            );
          }
        },

        loading: () => CircularProgressIndicator(), // ローディング中
        error: (error, stack) => Icon(Icons.error), // エラー時
      ),
      //centerTitle: true,
      backgroundColor: Colors.white,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(40);
}

Widget iconButton(context, ref, icon) {
  return IconButton(
    icon: icon,
    onPressed: () {
      ref.read(pageProvider.notifier).state = 1;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserAuthentication(),
        ),
      );
    },
  );
}
