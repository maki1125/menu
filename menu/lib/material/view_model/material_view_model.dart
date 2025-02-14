import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:menu/material/data/model/material.dart';
import 'package:menu/material/data/repository/material_repository.dart';
import 'package:menu/common/logger.dart';

// 材料データ取得
final materialListProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return MaterialRepository().getMaterialList();
});

// 検索テキストを管理するプロバイダー
final searchTextProvider = StateProvider<String>((ref) => '');

// 材料データの検索フィルタリング
final filteredMaterialsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final materials = ref.watch(materialListProvider).value ?? [];
  final text = ref.watch(searchTextProvider);

  var filteredMaterials = (materials).where((material) {
    //final isMatch = material["name"] == text;　// 材料名が完全一致するか
    final isMatch = material["name"].startsWith(text);
    return isMatch;
  }).toList();

  // もしフィルタ結果が空なら、全てのメニューを返す
  if (filteredMaterials.isEmpty) {
    return materials;
  }

  return filteredMaterials;
});