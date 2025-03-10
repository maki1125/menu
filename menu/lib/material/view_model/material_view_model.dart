import 'package:flutter_riverpod/flutter_riverpod.dart';

//import 'package:menu/material/data/model/material.dart';
import 'package:menu/material/data/repository/material_repository.dart';
import 'package:menu/common/logger.dart';

// 材料データ取得
final materialListProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return MaterialRepository().getMaterialList();
});

// 検索テキストを管理するプロバイダー
final searchTextProvider = StateProvider<String>((ref) => '');

// 材料データ全表示フラグ
//final isAllMaterialViewProvider = StateProvider<bool>((ref) => true);

// 材料データフィルタリング

final filteredMaterialsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final materials = ref.watch(materialListProvider).value ?? [];
  final text = ref.watch(searchTextProvider);
  //final isMaterialAllView = ref.watch(isAllMaterialViewProvider);

  var filteredMaterials = (materials).where((material) {
    //final isMatch = material.name!.contains(text); // 材料名に指定された文字列が含まれているか
    // 材料名が完全一致するか
    //final isMatch = material["name"] == text;
    final isMatch = material["name"].startsWith(text);

    return isMatch;
  }).toList();

  if (filteredMaterials.isEmpty) {
    // 検索結果がない場合は全ての材料を表示
    //filteredMaterials = materials;
    //filteredMaterials = [];
    LoggerService.debug("データ無しです。");
  }

  return filteredMaterials;
});

// 編集中の材料データ
//final materialProvider = StateProvider<MaterialModel>((ref) => MaterialModel());

// ボタンの状態管理(edit（編集） or new（新規作成？）)
//final materialSelectButtonProvider = StateProvider<String>((ref) => '');
