// --- FILE: lib/VIEW/cart_detail_page.dart ---
import 'package:flutter/material.dart';
import '../API/api_service.dart';
import '../MODEL/model_cart.dart';

class CartDetailPage extends StatelessWidget {
  final int itemId;
  const CartDetailPage({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    final ApiService apiService = ApiService();
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(title: Text('Detail Item #$itemId')),
      body: FutureBuilder<ModelCartItem>(
        future: apiService.getCartItem(itemId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Item tidak ditemukan.'));
          }
          final item = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(radius: 50, backgroundColor: Colors.pink[100], child: Icon(Icons.shopping_bag_outlined, size: 60, color: Colors.pink[700])),
                    const SizedBox(height: 20),
                    Text(item.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const Divider(height: 30),
                    _buildRow("Harga Satuan", "Rp ${item.price}"),
                    _buildRow("Jumlah", "${item.quantity} Pcs"),
                    const Divider(height: 30),
                    _buildRow("Subtotal", "Rp ${(item.price * item.quantity)}", isTotal: true),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: isTotal ? Colors.pink : Colors.black)),
        ],
      ),
    );
  }
}