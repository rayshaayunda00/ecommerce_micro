// --- FILE: lib/API/api_service.dart ---
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/model_user.dart'; // Pastikan path ini benar (kadang huruf kecil/besar berpengaruh)
import '../MODEL/ModelProduct.dart';
import '../MODEL/model_cart.dart';
import '../MODEL/model_review.dart';

class ApiService {
  // =========================
  // Base URL untuk semua service
  // =========================
  // ⚠️ GANTI IP INI DENGAN IP KOMPUTER ANDA / docker host
  final String _ipAddress = '10.192.194.149';

  // Produk service (Node.js)
  late final String productBaseUrl = 'http://$_ipAddress:3000';
  // Review service (Flask)
  late final String reviewBaseUrl = 'http://$_ipAddress:5002';
  // Cart service (Lumen)
  late final String cartBaseUrl = 'http://$_ipAddress:8001'; // <-- Pastikan Port 8001 (sesuai docker-compose)
  // User service (Node.js)
  late final String userBaseUrl = 'http://$_ipAddress:4000';

  // ==================
  // FUNGSI PRODUK
  // ==================
  Future<List<ModelProduct>> getProducts() async {
    try {
      final response = await http.get(Uri.parse('$productBaseUrl/products'));
      if (response.statusCode == 200) {
        return modelProductFromJson(response.body);
      } else {
        print('Error getProducts: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception getProducts: $e');
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
      print('Exception addProduct: $e');
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
      print('Exception updateProduct: $e');
      return false;
    }
  }

  Future<bool> deleteProduct(int id) async {
    try {
      final response = await http.delete(Uri.parse('$productBaseUrl/products/$id'));
      return response.statusCode == 200;
    } catch (e) {
      print('Exception deleteProduct: $e');
      return false;
    }
  }

  // ==================
  // FUNGSI REVIEW
  // ==================
  Future<List<ModelReview>> getAllReviews() async {
    try {
      final response = await http.get(Uri.parse('$reviewBaseUrl/reviews'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => ModelReview.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Exception getAllReviews: $e');
      return [];
    }
  }

  Future<List<ModelReview>> getReviewsByProductId(int productId) async {
    try {
      final response = await http.get(Uri.parse('$reviewBaseUrl/reviews/product/$productId'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => ModelReview.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Exception getReviewsByProductId: $e');
      return [];
    }
  }

  Future<bool> addReview(ModelReview review) async {
    try {
      final response = await http.post(
        Uri.parse('$reviewBaseUrl/reviews'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(review.toJson()),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Exception addReview: $e');
      return false;
    }
  }

  // ==================
  // FUNGSI CART (BAGIAN YANG DIPERBAIKI)
  // ==================
  Future<ModelCart> getCart() async {
    try {
      final response = await http.get(Uri.parse('$cartBaseUrl/carts'));
      if (response.statusCode == 200) {
        // FIX: Panggil ModelCart.fromJson langsung
        return ModelCart.fromJson(json.decode(response.body));
      } else {
        throw Exception('Gagal memuat keranjang');
      }
    } catch (e) {
      print('Exception getCart: $e');
      rethrow;
    }
  }

  Future<ModelCartItem> getCartItem(int id) async {
    try {
      final response = await http.get(Uri.parse('$cartBaseUrl/carts/$id'));
      if (response.statusCode == 200) {
        // FIX: Panggil ModelCartItem.fromJson langsung agar tidak error
        return ModelCartItem.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Item tidak ditemukan');
      } else {
        throw Exception('Gagal memuat detail item keranjang');
      }
    } catch (e) {
      print('Exception getCartItem: $e');
      rethrow;
    }
  }

  Future<bool> deleteCartItem(int id) async {
    try {
      final response = await http.delete(Uri.parse('$cartBaseUrl/carts/$id'));
      return response.statusCode == 200;
    } catch (e) {
      print('Exception deleteCartItem: $e');
      return false;
    }
  }

  Future<bool> addItemToCart(ModelProduct product, int quantity) async {
    try {
      final url = Uri.parse('$cartBaseUrl/carts');
      final body = json.encode({
        'id': product.id,
        'name': product.name,
        'price': product.price,
        'quantity': quantity,
      });
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: body,
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Exception addItemToCart: $e');
      return false;
    }
  }

  // ==================
  // FUNGSI USER
  // ==================
  Future<List<ModelUser>> getUsers() async {
    try {
      final response = await http.get(Uri.parse("$userBaseUrl/users"));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => ModelUser.fromJson(e)).toList();
      } else {
        return [];
      }
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
        body: json.encode(user.toJson()),
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
}