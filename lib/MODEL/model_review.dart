import 'dart:convert';

List<ModelReview> modelReviewFromJson(String str) =>
    List<ModelReview>.from(json.decode(str).map((x) => ModelReview.fromJson(x)));

String modelReviewToJson(List<ModelReview> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ModelReview {
  int id;
  int productId;
  String review;
  int rating;

  ModelReview({
    this.id = 0,
    required this.productId,
    required this.review,
    required this.rating,
  });

  factory ModelReview.fromJson(Map<String, dynamic> json) {
    return ModelReview(
      id: int.tryParse(json["id"].toString()) ?? 0, // Aman dari error
      productId: int.tryParse(json["product_id"].toString()) ?? 0, // Aman
      review: json["review"]?.toString() ?? "",
      rating: int.tryParse(json["rating"].toString()) ?? 0, // Aman (String "5" jadi Int 5)
    );
  }

  Map<String, dynamic> toJson() => {
    "product_id": productId,
    "review": review,
    "rating": rating,
  };
}