import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; //日本語設定
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:menu/login/view/login_screen.dart';
import 'package:menu/common/logger.dart';

void main() async {
  LoggerService.info('アプリケーションスタート');

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('ja');
  LineSDK.instance.setup('2005288659').then((_) {
    LoggerService.info('LineSDKのセットアップ完了');
  });
  runApp(
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const MaterialApp(

        //日本語設定
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('ja'), // 日本語
          Locale('en'), // 英語
        ],
        locale: Locale('ja'), // アプリのデフォルト言語を日本語に設定

        home: SignInAnony()); //匿名ログインの処理
  }
}
