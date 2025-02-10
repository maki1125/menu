import 'dart:io';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class LoggerService {
  static bool isDebug = true;

  static final Logger _logger = Logger(
    level: isDebug ? Level.debug : Level.info, // 本番環境ではinfo以上のログを出力
    output: MultiOutput([CustomConsoleOutput(), FileLogOutput()]), // ファイル出力
    filter: isDebug ? null : ProductionFilter(), // 本番環境ではデバッグログは出さない
    printer: PrettyPrinter(
      methodCount: 0, // 呼び出し元のメソッドの表示数
      errorMethodCount: 5, // エラー時の呼び出し元のメソッドの表示数
      lineLength: 50, // 1行の最大文字数
      colors: true, // カラー表示
      printEmojis: true, // 絵文字表示
      dateTimeFormat: DateTimeFormat.dateAndTime, // 日時表示フォーマット
    ),
  );

  static void debug(String message) {
    // デバッグログ
    _logger.d(message);
  }

  static void error(String message) {
    // エラーログ
    _logger.e(message);
  }

  static void info(String message) {
    // インフォメーションログ
    _logger.i(message);
  }

  static void warning(String message) {
    // 警告ログ
    _logger.w(message);
  }

  static void fatal(String message) {
    // 致命的なエラーログ
    _logger.f(message);
  }
}

class FileLogOutput extends LogOutput {
  Future<File> _getLogFile() async {
    final dir =
        await getApplicationDocumentsDirectory(); // アプリケーションがファイルを保存するためのディレクトリを取得
    final file = File('${dir.path}/log.txt');
    debugPrint('file.path: ${file.path}');

    // final file = File('log/log.txt');
    if (!file.existsSync()) {
      // ファイルが存在しない場合はファイルを作成
      file.createSync(recursive: true);
    }
    return file;
  }

  @override
  void output(OutputEvent event) async {
    final file = await _getLogFile();
    final sink = file.openWrite(mode: FileMode.append); // ファイルを開いて書き込み
    for (var line in event.lines) {
      sink.writeln(line);
    }
    await sink.flush(); // ファイルに書き込んだデータを書き込む
    await sink.close(); // ファイルを閉じる
  }
}

// 📌 カスタム ConsoleOutput: debugPrint を使う
class CustomConsoleOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    for (var line in event.lines) {
      debugPrint(line); // debugPrint を使ってデバッグコンソールに出す
    }
  }
}
