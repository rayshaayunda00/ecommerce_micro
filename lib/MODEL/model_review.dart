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

  factory ModelReview.fromJson(Map<String, dynamic> json) => ModelReview(
    id: json["id"] ?? 0,
    productId: json["product_id"],
    review: json["review"],
    rating: json["rating"],
  );

  Map<String, dynamic> toJson() => {
    "product_id": productId,
    "review": review,
    "rating": rating,
  };
}
