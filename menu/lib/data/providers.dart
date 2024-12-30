import 'package:menu/data/repository/user_repository.dart';

import 'repository/menu_repository.dart';
import 'repository/dinner_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'model/user.dart';
import 'model/menu.dart';
import 'model/dinner.dart';
//import 'package:firebase_storage/firebase_storage.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

//final userProvider = StateProvider<UserModel?>((ref) =>UserRepository().getCurrentUser());
UserModel? currentUser = UserRepository().getCurrentUser();
final userProvider = StateProvider<UserModel?>((ref) =>currentUser);
/*
            UserModel(
            //createAt: DateTime.now(), 
            uid: "AC3iWb7RnqM4gCmeLOD9"
            );
*/

//final menuListProvider = StreamProvider<QuerySnapshot>((ref) {
//  return MenuRepository(user).getMenuList();
//});

final menuListProvider = StreamProvider<List<Menu>>((ref) {
  return MenuRepository(currentUser!).getMenuList();
});

final dinnerListProvider = StreamProvider<List<Dinner>>((ref) {
  return DinnerRepository(currentUser!).getDinnerList();
});

