// --- FILE: lib/view/cart_page.dart ---
import 'package:flutter/material.dart';
import '../API/api_service.dart';
import '../model/model_cart.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Future<ModelCart> futureCart;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadCartData();
  }

  void _loadCartData() {
    setState(() {
      futureCart = apiService.getCart();
    });
  }

  void _deleteItem(int id) async {
    try {
      bool success = await apiService.deleteCartItem(id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item dihapus'), backgroundColor: Colors.green));
        _loadCartData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menghapus item'), backgroundColor: Colors.red));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        title: const Text('Keranjang Saya'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadCartData),
        ],
      ),
      body: FutureBuilder<ModelCart>(
        future: futureCart,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          }
          if (!snapshot.hasData || snapshot.data!.items.isEmpty) {
            return const Center(child: Text('Keranjang kosong.', style: TextStyle(fontSize: 18, color: Colors.grey)));
          }
          final cart = snapshot.data!;
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.pink[100],
                          child: Text('x${item.quantity}', style: TextStyle(color: Colors.pink[800], fontWeight: FontWeight.bold)),
                        ),
                        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Rp ${item.price}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _deleteItem(item.id),
                        ),
                        // HAPUS navigasi ke CartDetailPage agar tidak error
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))]),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('Rp ${cart.total}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.pink[700])),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}