import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:menu/data/model/user.dart';
import 'package:menu/data/model/material.dart';
import 'package:menu/data/repository/material_repository.dart';
//import 'package:menu/data/providers.dart';
import 'package:menu/common/common_providers.dart';

// MaterialRepository を提供するプロバイダー
final materialRepositoryProvider = Provider<MaterialRepository>((ref) {
  return MaterialRepository(currentUser!);
});

// 材料データ取得
final materialListProvider = StreamProvider<List<MaterialModel>>((ref) {
  return MaterialRepository(currentUser!).getMaterialList();
});

// 検索テキストを管理するプロバイダー
final searchTextProvider = StateProvider<String>((ref) => '');

final isAllMaterialViewProvider = StateProvider<bool>((ref) => true);

// 材料データフィルタリング
final filteredMaterialsProvider = Provider<List<MaterialModel>>((ref) {
  final materials = ref.watch(materialListProvider).value ?? [];

  final text = ref.watch(searchTextProvider);
  //final isMaterialAllView = ref.watch(isAllMaterialViewProvider);

  var filteredMaterials = (materials).where((material) {
    //final isMatch = material.name!.contains(text); // 材料名に指定された文字列が含まれているか
    final isMatch = material.name! == text;
    print('isMatch: $isMatch');
    return isMatch;
  }).toList();

  if (filteredMaterials.isEmpty) {
    filteredMaterials = materials;
  }

  for (var i = 0; i < filteredMaterials.length; i++) {
    print(filteredMaterials[i].name);
  }
  return filteredMaterials;
});
// // 材料データ更新
// final materialProvider =
//     NotifierProvider<MaterialNotifier, MaterialModel>(() => MaterialNotifier());

// 材料データ更新
final materialProvider =
    StateNotifierProvider<MaterialNotifier, AsyncValue<MaterialModel?>>((ref) {
  return MaterialNotifier(ref.read(materialRepositoryProvider));
});

class MaterialNotifier extends StateNotifier<AsyncValue<MaterialModel?>> {
  final MaterialRepository _materialRepository;

  // コンストラクタ
  MaterialNotifier(this._materialRepository)
      : super(const AsyncValue.data(null));

  // MaterialNotifier(this._materialRepository)
  //     : super(const AsyncValue.loading());

  Future<void> addMaterial(MaterialModel material) async {
    state = const AsyncValue.loading();
    try {
      // 更新処理を非同期で実行
      await _materialRepository.addMaterial(material);
      state = const AsyncValue.data(null); // immutableデータ
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateMaterial(MaterialModel material) async {
    state = const AsyncValue.loading();
    try {
      // 更新処理を非同期で実行
      await _materialRepository.updateMaterial(material);
      state = AsyncValue.data(material);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// ボタンの状態管理(edit（編集） or Resist（新規作成？）)
final selectButtonProvider = StateProvider<String>((ref) => '');
