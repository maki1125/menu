import 'package:cloud_firestore/cloud_firestore.dart';

class Menu {
  Menu({
    this.createAt,
    this.name,
    this.imageURL,
    this.imagePath,
    this.quantity,
    this.tag,
    this.material,
    this.howToMake,
    this.memo,
    this.isFavorite,
    this.isDinner,
    this.id,
    this.dinnerDate,
    this.price,
    this.unitPrice,
  });

  DateTime? createAt;
  String? name;
  String? imageURL;
  String? imagePath;
  int? quantity = 1;
  String? tag;
  List<dynamic>? material;
  //List<Map<String, dynamic>>? material;
  String? howToMake;
  String? memo;
  bool? isFavorite;
  bool? isDinner;
  String? id;
  DateTime? dinnerDate;
  int? price;
  int? unitPrice;

    //FirestoreからのデータからDinnerインスタンスを生成する
  factory Menu.fromFirestore(Map<String, dynamic> data) {
    return Menu(
      createAt: (data['createAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      name: data['name'] as String? ?? "noData",
      imageURL: data['imageURL'] as String? ?? "noData",
      imagePath: data['imagePath'] as String? ?? "noData",
      quantity: data['quantity'] as int? ?? 1,
      tag: data['tag'] as String? ?? "noData",
      material: (data['material'] as List<dynamic>?) ?? [], // nullの場合は空のリストを設定
      //material: (data['material'] as List<Map<String,dynamic>>?) ?? [], // nullの場合は空のリストを設定
      howToMake: data['howToMake'] as String? ?? "noData",
      memo: data['memo'] as String? ?? "noData",
      isFavorite: data['isFavorite'] as bool? ?? false,
      isDinner: data['isDinner'] as bool? ?? false,
      id: data['id'] as String? ?? "noData",
      dinnerDate: (data['dinnerDate'] as Timestamp?)?.toDate(),  //nullの可能性あり
      price: data['price'] as int? ?? 0,
      unitPrice: data['unitPrice'] as int? ?? 0,
    );
  }
}