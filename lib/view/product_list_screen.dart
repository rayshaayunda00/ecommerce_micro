// --- FILE: lib/view/product_list_screen.dart ---
import 'package:flutter/material.dart';
// Pastikan import folder menggunakan huruf kecil sesuai perbaikan sebelumnya
import '../api/api_service.dart';
import '../model/model_product.dart';// Sesuaikan nama file kamu (model_product.dart atau model_product.dart)
import 'cart_page.dart';
import 'detail_product.dart';
import 'user_list_page.dart';
import 'product_form_page.dart';

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

  Future<void> _loadData() async {
    setState(() {
      futureProducts = apiService.getProducts();
    });
  }

  void _deleteData(int id) async {
    bool confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.pink[50], // Background Dialog Pink Pastel
        title: const Text('Hapus Produk?', style: TextStyle(color: Colors.pink)),
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
    ) ?? false;

    if (confirm) {
      bool success = await apiService.deleteProduct(id);
      if (success) {
        _loadData();
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
        backgroundColor: Colors.pink, // Loading warna Pink
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
        backgroundColor: Colors.pink[50], // Dialog Background
        title: Text('Beli ${product.name}', style: const TextStyle(color: Colors.pink)),
        content: TextField(
          controller: qtyController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Jumlah',
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.pink)),
            floatingLabelStyle: TextStyle(color: Colors.pink),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink, // Tombol Pink
              foregroundColor: Colors.white,
            ),
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
      backgroundColor: Colors.pink[50], // BACKGROUND PINK PASTEL
      appBar: AppBar(
        title: const Text('Daftar Produk'),
        backgroundColor: Colors.pink, // APPBAR PINK
        foregroundColor: Colors.white, // TEXT PUTIH
        elevation: 0,
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
        backgroundColor: Colors.pink, // FAB PINK
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          bool? refresh = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProductFormPage()),
          );
          if (refresh == true) _loadData();
        },
      ),
      body: RefreshIndicator(
        color: Colors.pink, // Loading Spinner Pink
        onRefresh: _loadData,
        child: FutureBuilder<List<ModelProduct>>(
          future: futureProducts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.pink));
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
                  // Membuat card rounded
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  color: Colors.white,
                  surfaceTintColor: Colors.white,
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon Gambar Produk (Styling Pink Muda)
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.pink[50], // Background icon Pink Muda
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.shopping_bag_outlined,
                              size: 40, color: Colors.pink), // Icon Pink
                        ),
                        const SizedBox(width: 16),
                        // Konten Teks & Tombol
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Baris Judul & Tombol Admin
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      p.name,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.pink[900]), // Judul agak gelap
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
                                          color: Colors.orange, size: 20),
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
                                  style: TextStyle(color: Colors.grey[700]),
                                  maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 8),
                              Text('Rp ${p.price}',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.pink)), // Harga Pink
                              const SizedBox(height: 12),
                              // Baris Tombol User
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
                                        _loadData();
                                      },
                                      icon: const Icon(Icons.info_outline,
                                          size: 18),
                                      label: const Text('Detail'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.pink, // Text Pink
                                        side: const BorderSide(color: Colors.pink),
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
                                        backgroundColor: Colors.pink, // Background Pink
                                        foregroundColor: Colors.white,
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