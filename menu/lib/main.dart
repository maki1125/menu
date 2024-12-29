import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menu/data/providers.dart';
import 'package:menu/kudo_test.dart';
import 'data/model/menu.dart';
import 'data/model/user.dart';
import 'data/repository/menu_repository.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ProviderScope(
      child:  MyApp()
      )
   );
}

class MyApp extends ConsumerWidget {
  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      home: KudoTest()
      //Scaffold(
        //body:
          //CardListExample(),
        
      //)
    );
  }
}
