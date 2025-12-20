// --- FILE: lib/MODEL/model_cart.dart ---
import 'dart:convert';

ModelCart modelCartFromJson(String str) => ModelCart.fromJson(json.decode(str));
String modelCartToJson(ModelCart data) => json.encode(data.toJson());

class ModelCart {
  List<ModelCartItem> items;
  double total;

  ModelCart({
    required this.items,
    required this.total,
  });

  factory ModelCart.fromJson(Map<String, dynamic> json) => ModelCart(
    items: List<ModelCartItem>.from((json["items"] ?? []).map((x) => ModelCartItem.fromJson(x))),
    // Pastikan konversi ke double aman (kadang API kirim int)
    total: (json["total"] is int)
        ? (json["total"] as int).toDouble()
        : (json["total"] ?? 0.0),
  );

  Map<String, dynamic> toJson() => {
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
    "total": total,
  };
}

class ModelCartItem {
  int id;
  String name;
  int quantity;
  double price;

  ModelCartItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory ModelCartItem.fromJson(Map<String, dynamic> json) => ModelCartItem(
    id: json["id"],
    name: json["name"],
    quantity: json["quantity"],
    price: (json["price"] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "quantity": quantity,
    "price": price,
  };
}