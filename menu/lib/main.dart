import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:menu/view/main_screen.dart';
//import 'package:menu/data/providers.dart';
//import 'package:menu/kudo_test.dart';
//import 'data/model/menu.dart';
//import 'data/model/user.dart';
//import 'data/repository/menu_repository.dart';
import 'data/repository/o_user_repository.dart';
//import 'package:menu/view/material_create_screen.dart';
//import 'view/main_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDateFormatting('ja');
  runApp(
    ProviderScope(child: MyApp()),
  );
}

class MyApp extends ConsumerWidget {
  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //return MaterialApp(home: KudoTest()
    return const MaterialApp(
        home:
            //MainPage()
            // 匿名ログイン処理ページへ
            SignInAnony()
        //Scaffold(
        //body:
        //CardListExample(),

        //)
        );
  }
}
