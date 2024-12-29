class Menu {
  Menu({
    this.createAt,
    this.name,
    this.imageURL,
    this.quantity,
    this.tag,
    this.material,
    this.howToMake,
    this.memo,
    this.isFavorite,
    this.id
  });

  DateTime? createAt;
  String? name;
  String? imageURL;
  int? quantity;
  String? tag;
  List<Map<String, dynamic>>? material;
  String? howToMake;
  String? memo;
  bool? isFavorite;
  String? id;
}