import 'dart:convert';

List<ModelProduct> modelProductFromJson(String str) {
  final jsonData = json.decode(str);
  // Backend Node.js mengembalikan object { "data": [...] }, jadi kita ambil key 'data'
  final data = jsonData['data'];
  return List<ModelProduct>.from(data.map((x) => ModelProduct.fromJson(x)));
}

String modelProductToJson(List<ModelProduct> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ModelProduct {
  int? id;
  String name;
  double price;
  String description;
  String? createdAt;
  String? updatedAt;

  ModelProduct({
    this.id,
    required this.name,
    required this.price,
    required this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory ModelProduct.fromJson(Map<String, dynamic> json) => ModelProduct(
    id: json["id"],
    name: json["name"],
    // Safety check: convert ke double meski backend kirim int
    price: (json["price"] as num).toDouble(),
    description: json["description"] ?? "",
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "price": price,
    "description": description,
  };
}