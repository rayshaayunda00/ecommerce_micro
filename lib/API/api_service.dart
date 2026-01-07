import 'dart:convert';
import 'package:http/http.dart' as http;

// PERBAIKAN IMPORT (Gunakan huruf kecil 'model')
import '../model/model_user.dart';
import '../model/model_product.dart';
import '../model/model_cart.dart';
import '../model/model_review.dart';

class ApiService {
  // =========================
  // KONFIGURASI IP & PORT
  // =========================
  final String _ipAddress = 'localhost'; // Ganti dengan IP LAN jika pakai HP fisik (misal: 192.168.1.x)

  late final String productBaseUrl = 'http://$_ipAddress:3000'; // MySQL
  late final String userBaseUrl    = 'http://$_ipAddress:3001'; // PostgreSQL
  late final String reviewBaseUrl  = 'http://$_ipAddress:5002'; // MongoDB
  late final String cartBaseUrl    = 'http://$_ipAddress:8001'; // Lumen

  // ==================
  // 1. FUNGSI PRODUK (MySQL)
  // ==================
  Future<List<ModelProduct>> getProducts() async {
    try {
      final response = await http.get(Uri.parse('$productBaseUrl/products'));
      if (response.statusCode == 200) {
        return modelProductFromJson(response.body);
      }
      return [];
    } catch (e) {
      print('Error getProducts: $e');
      return [];
    }
  }

  Future<bool> addProduct(ModelProduct product) async {
    try {
      final response = await http.post(
        Uri.parse('$productBaseUrl/products'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(product.toJson()),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateProduct(int id, ModelProduct product) async {
    try {
      final response = await http.put(
        Uri.parse('$productBaseUrl/products/$id'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(product.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteProduct(int id) async {
    try {
      final response = await http.delete(Uri.parse('$productBaseUrl/products/$id'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ==================
  // 2. FUNGSI REVIEW (MongoDB)
  // ==================
  Future<List<ModelReview>> getReviewsByProductId(int productId) async {
    try {
      final response = await http.get(Uri.parse('$reviewBaseUrl/reviews/product/$productId'));

      if (response.statusCode == 200) {
        final dynamic jsonResponse = json.decode(response.body);

        if (jsonResponse is Map && jsonResponse.containsKey('data')) {
          final List<dynamic> data = jsonResponse['data'];
          return data.map((e) => ModelReview.fromJson(e)).toList();
        }
        else if (jsonResponse is List) {
          return jsonResponse.map((e) => ModelReview.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Exception getReviews: $e');
      return [];
    }
  }

  Future<bool> addReview(ModelReview review) async {
    try {
      final response = await http.post(
        Uri.parse('$reviewBaseUrl/reviews'),
        body: {
          'product_id': review.productId.toString(),
          'review': review.review,
          'rating': review.rating.toString(),
        },
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Exception addReview: $e');
      return false;
    }
  }

  // ==================
  // 3. FUNGSI CART (Lumen)
  // ==================
  Future<ModelCart> getCart() async {
    try {
      final response = await http.get(Uri.parse('$cartBaseUrl/carts'));
      if (response.statusCode == 200) {
        return ModelCart.fromJson(json.decode(response.body));
      } else {
        return ModelCart(items: [], total: 0);
      }
    } catch (e) {
      print('Exception getCart: $e');
      return ModelCart(items: [], total: 0);
    }
  }

  Future<ModelCartItem?> getCartItem(int id) async {
    try {
      final response = await http.get(Uri.parse('$cartBaseUrl/carts/$id'));
      if (response.statusCode == 200) {
        return ModelCartItem.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteCartItem(int id) async {
    try {
      final response = await http.delete(Uri.parse('$cartBaseUrl/carts/$id'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> addItemToCart(ModelProduct product, int quantity) async {
    try {
      final response = await http.post(
        Uri.parse('$cartBaseUrl/carts'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': product.id,
          'name': product.name,
          'price': product.price,
          'quantity': quantity,
        }),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Exception addItemToCart: $e');
      return false;
    }
  }

  // ==================
  // 4. FUNGSI USER (PostgreSQL)
  // ==================
  Future<List<ModelUser>> getUsers() async {
    try {
      final response = await http.get(Uri.parse("$userBaseUrl/users"));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => ModelUser.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('Exception getUsers: $e');
      return [];
    }
  }

  Future<ModelUser> getUserById(int id) async {
    try {
      final response = await http.get(Uri.parse("$userBaseUrl/users/$id"));
      if (response.statusCode == 200) {
        return ModelUser.fromJson(json.decode(response.body));
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<ModelUser?> addUser(ModelUser user) async {
    try {
      final response = await http.post(
        Uri.parse("$userBaseUrl/users"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "name": user.name,
          "email": user.email,
          "role": user.role
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ModelUser.fromJson(json.decode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      print('Exception addUser: $e');
      return null;
    }
  }

  Future<ModelUser?> login(String email) async {
    try {
      List<ModelUser> users = await getUsers();
      try {
        final user = users.firstWhere(
                (u) => u.email.toLowerCase().trim() == email.toLowerCase().trim()
        );
        return user;
      } catch (e) {
        return null;
      }
    } catch (e) {
      print("Login Error: $e");
      return null;
    }
  }
}