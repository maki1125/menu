import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:menu/data/model/user.dart';
import 'package:menu/data/model/material.dart';
import 'package:menu/data/repository/material_repository.dart';
import 'package:menu/data/providers.dart';
import 'package:menu/common/common_providers.dart';

// MaterialRepository を提供するプロバイダー
final materialRepositoryProvider = Provider<MaterialRepository>((ref) {
  return MaterialRepository(currentUser!); // currentUserを適切に設定してください
});

// 材料データ取得
final materialListProvider = StreamProvider<List<MaterialModel>>((ref) {
  return MaterialRepository(currentUser!).getMaterialList();
});

// // 材料データ更新
// final materialProvider =
//     NotifierProvider<MaterialNotifier, MaterialModel>(() => MaterialNotifier());

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
// class MaterialNotifier extends Notifier<MaterialModel> {
//   @override
//   MaterialModel build() => MaterialModel();

//   void updateMaterial(MaterialModel material) {
//     state = material;
//   }
// }

// ボタンの状態管理(edit（編集） or Resist（新規作成？）)
final selectButtonProvider = StateProvider<String>((ref) => '');
