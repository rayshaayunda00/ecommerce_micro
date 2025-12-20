// --- FILE: lib/VIEW/product_list_screen.dart ---
import 'package:flutter/material.dart';
import '../API/api_service.dart';
import '../MODEL/ModelProduct.dart';
import 'cart_page.dart';
import 'detail_product.dart';
import 'user_list_page.dart';
import 'product_form_page.dart'; // IMPORT PENTING: Untuk form tambah/edit

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Future<List<ModelProduct>> futureProducts;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Fungsi untuk memuat ulang data (dipanggil saat init, refresh, atau setelah edit/delete)
  Future<void> _loadData() async {
    setState(() {
      futureProducts = apiService.getProducts();
    });
  }

  // Fungsi Hapus Data
  void _deleteData(int id) async {
    bool confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Produk?'),
        content: const Text('Data akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ??
        false;

    if (confirm) {
      bool success = await apiService.deleteProduct(id);
      if (success) {
        _loadData(); // Refresh list setelah hapus
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produk berhasil dihapus')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menghapus produk'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void addToCart(ModelProduct product, int quantity) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Menambahkan ke keranjang...'),
        backgroundColor: Colors.blue,
        duration: Duration(milliseconds: 500),
      ),
    );
    try {
      bool success = await apiService.addItemToCart(product, quantity);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} (x$quantity) berhasil ditambahkan'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menambahkan item.'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void showAddToCartDialog(ModelProduct product) {
    final TextEditingController qtyController = TextEditingController(text: '1');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Beli ${product.name}'),
        content: TextField(
          controller: qtyController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Jumlah',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              int qty = int.tryParse(qtyController.text) ?? 1;
              Navigator.pop(context);
              addToCart(product, qty);
            },
            child: const Text('Tambahkan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        title: const Text('Daftar Produk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_alt_outlined),
            tooltip: 'Manajemen User',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserListPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            tooltip: 'Keranjang',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartPage()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      // --- TOMBOL TAMBAH DATA (FAB) ---
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          // Navigasi ke Form Tambah
          bool? refresh = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProductFormPage()),
          );
          // Jika kembali dengan nilai true, refresh data
          if (refresh == true) _loadData();
        },
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: FutureBuilder<List<ModelProduct>>(
          future: futureProducts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                  child: Text('Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red)));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Tidak ada produk tersedia.'));
            }
            final products = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final p = products[index];
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  color: Colors.white,
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon Gambar Produk
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.pink[100],
                          child: Icon(Icons.shopping_bag_outlined,
                              size: 40, color: Colors.pink[700]),
                        ),
                        const SizedBox(width: 16),
                        // Konten Teks & Tombol
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Baris Judul & Tombol Admin (Edit/Delete)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      p.name,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  // Tombol Edit
                                  InkWell(
                                    onTap: () async {
                                      bool? refresh = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ProductFormPage(product: p),
                                        ),
                                      );
                                      if (refresh == true) _loadData();
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: Icon(Icons.edit,
                                          color: Colors.blue, size: 20),
                                    ),
                                  ),
                                  // Tombol Delete
                                  InkWell(
                                    onTap: () => _deleteData(p.id ?? 0),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: Icon(Icons.delete,
                                          color: Colors.red, size: 20),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(p.description,
                                  maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 8),
                              Text('Rp ${p.price}',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.pink[700])),
                              const SizedBox(height: 12),
                              // Baris Tombol User (Detail & Beli)
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                DetailProductPage(product: p),
                                          ),
                                        );
                                        // Refresh saat kembali jaga-jaga ada perubahan
                                        _loadData();
                                      },
                                      icon: const Icon(Icons.info_outline,
                                          size: 18),
                                      label: const Text('Detail'),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 0, horizontal: 8),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => showAddToCartDialog(p),
                                      icon: const Icon(Icons.add_shopping_cart,
                                          size: 18),
                                      label: const Text('Beli'),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 0, horizontal: 8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}