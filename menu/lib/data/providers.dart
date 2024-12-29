import 'repository/menu_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'model/user.dart';
import 'model/menu.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

User user = User(
            createAt: DateTime.now(), 
            uid: "AC3iWb7RnqM4gCmeLOD9"
            );

//final menuListProvider = StreamProvider<QuerySnapshot>((ref) {
//  return MenuRepository(user).getMenuList();
//});

final menuListProvider = StreamProvider<List<Menu>>((ref) {
  return MenuRepository(user).getMenuList();
});


