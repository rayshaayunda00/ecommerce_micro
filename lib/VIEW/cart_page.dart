// --- FILE: lib/VIEW/cart_page.dart ---
import 'package:flutter/material.dart';
import '../API/api_service.dart';
import '../MODEL/model_cart.dart';

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
    // Tampilkan loading snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Menghapus item...'), duration: Duration(seconds: 1)),
    );

    try {
      bool success = await apiService.deleteCartItem(id);
      if (mounted) ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item berhasil dihapus'), backgroundColor: Colors.green),
          );
        }
        _loadCartData(); // Refresh list keranjang
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menghapus item'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
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
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.remove_shopping_cart, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Keranjang kosong.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          final cart = snapshot.data!;
          return Column(
            children: [
              // --- LIST ITEMS ---
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: Colors.pink[100], borderRadius: BorderRadius.circular(8)),
                          child: Text('${item.quantity}x', style: TextStyle(color: Colors.pink[800], fontWeight: FontWeight.bold)),
                        ),
                        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Rp ${item.price}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _deleteItem(item.id),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // --- TOTAL & CHECKOUT ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20))
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Rp ${cart.total}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.pink[700])),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14)
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Fitur Checkout belum tersedia')),
                          );
                        },
                        child: const Text('CHECKOUT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    )
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