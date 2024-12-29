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
    this.id
  });

  DateTime? createAt;
  String? name;
  String? imageURL;
  String? imagePath;
  int? quantity;
  String? tag;
  List<Map<String, dynamic>>? material;
  String? howToMake;
  String? memo;
  bool? isFavorite;
  String? id;
}