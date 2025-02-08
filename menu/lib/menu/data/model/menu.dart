import 'package:cloud_firestore/cloud_firestore.dart';

class Menu {
  Menu({
    this.createAt,
    this.name,
    this.imageURL,
    this.imagePath,
    this.quantity,
    this.tag,
    this.materials,
    this.howToMake,
    this.memo,
    this.isFavorite,
    this.isDinner,
    this.id,
    this.dinnerDate,
    this.dinnerDateBuf,//夕食の履歴の削除時に元に戻すため。
    this.price,
    this.unitPrice,
  });

  DateTime? createAt;
  String? name;
  String? imageURL;
  String? imagePath;
  int? quantity = 1;
  String? tag;
  //List<dynamic>? materials;
  List<Map<String, dynamic>>? materials;
  String? howToMake;
  String? memo;
  bool? isFavorite;
  bool? isDinner;
  String? id;
  DateTime? dinnerDate;
  DateTime? dinnerDateBuf;
  num? price;
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
      //materials: (data['materials'] as List<dynamic>?) ?? [], // nullの場合は空のリストを設定
      //materials: (data['materials'] as List<Map<String,dynamic>>?) ?? [], // nullの場合は空のリストを設定
      materials: (data['materials'] as List<dynamic>?)
        ?.map((e) => e as Map<String, dynamic>) // List<dynamic>の各要素をMap<String, dynamic>に変換
        .toList() ?? [], // nullの場合は空のリストを設定
      howToMake: data['howToMake'] as String? ?? "noData",
      memo: data['memo'] as String? ?? "noData",
      isFavorite: data['isFavorite'] as bool? ?? false,
      isDinner: data['isDinner'] as bool? ?? false,
      id: data['id'] as String? ?? "noData",
      dinnerDate: (data['dinnerDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dinnerDateBuf: (data['dinnerDateBuf'] as Timestamp?)?.toDate() ?? DateTime.now(),
      price: data['price'] as num? ?? 0,
      unitPrice: data['unitPrice'] as int? ?? 0,
    );
  }
}