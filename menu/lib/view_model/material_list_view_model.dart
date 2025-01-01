import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:menu/data/model/user.dart';
import 'package:menu/data/model/material.dart';
import 'package:menu/data/repository/material_repository.dart';

import 'package:menu/data/providers.dart';

// 材料データ取得
final materialListProvider = StreamProvider<List<MaterialModel>>((ref) {
  return MaterialRepository(currentUser!).getMaterialList();
});

// 材料データ更新
final materialProvider =
    NotifierProvider<MaterialNotifier, MaterialModel>(() => MaterialNotifier());

class MaterialNotifier extends Notifier<MaterialModel> {
  @override
  MaterialModel build() => MaterialModel();

  void updateMaterial(MaterialModel material) {
    state = material;
  }
}

// appBarタイトル
final selectButtonProvider = StateProvider<String>((ref) => 'Resist');
