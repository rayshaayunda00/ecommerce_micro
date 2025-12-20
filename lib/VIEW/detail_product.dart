// --- FILE: lib/VIEW/detail_product.dart ---
import 'package:flutter/material.dart';
import '../MODEL/ModelProduct.dart';
import '../API/api_service.dart';
import 'review_page.dart';
import 'cart_page.dart';        // Import halaman keranjang
import 'product_form_page.dart'; // Import halaman edit form

class DetailProductPage extends StatefulWidget {
  final ModelProduct product;
  const DetailProductPage({super.key, required this.product});

  @override
  State<DetailProductPage> createState() => _DetailProductPageState();
}

class _DetailProductPageState extends State<DetailProductPage> {
  final ApiService apiService = ApiService();

  // Variabel untuk data produk (agar bisa di-refresh setelah edit)
  late ModelProduct currentProduct;

  double averageRating = 0.0;
  int reviewCount = 0;

  @override
  void initState() {
    super.initState();
    currentProduct = widget.product; // Inisialisasi data awal
    _loadReviews();
  }

  // --- LOGIC: Load Reviews ---
  void _loadReviews() async {
    final reviews = await apiService.getReviewsByProductId(currentProduct.id ?? 0);
    if (reviews.isNotEmpty) {
      double total = reviews.fold(0, (sum, r) => sum + r.rating);
      if (mounted) {
        setState(() {
          averageRating = total / reviews.length;
          reviewCount = reviews.length;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          averageRating = 0.0;
          reviewCount = 0;
        });
      }
    }
  }

  // --- LOGIC: Add to Cart ---
  void _addToCart(int quantity) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Menambahkan ke keranjang...'), duration: Duration(milliseconds: 500)),
    );

    bool success = await apiService.addItemToCart(currentProduct, quantity);

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${currentProduct.name} berhasil ditambahkan'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menambahkan ke keranjang'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showAddToCartDialog() {
    final TextEditingController qtyController = TextEditingController(text: '1');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Masukkan Keranjang'),
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
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              int qty = int.tryParse(qtyController.text) ?? 1;
              Navigator.pop(ctx);
              _addToCart(qty);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // --- LOGIC: Edit Product ---
  void _editProduct() async {
    // Navigasi ke Form Edit
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductFormPage(product: currentProduct),
      ),
    );
    // Refresh halaman ini belum bisa full reload data baru dari API kecuali di-pop,
    // tapi minimal kita bisa memberi sinyal kembali ke list.
    // Untuk update data di sini secara real-time, idealnya panggil getProductById (tapi di API service belum ada).
    // Jadi kita kembali ke list saja agar data refresh.
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  // --- UI: Bintang Rating ---
  Widget _buildRatingStars(double rating) {
    int fullStars = rating.floor();
    bool halfStar = (rating - fullStars) >= 0.5;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        if (index < fullStars) return const Icon(Icons.star, color: Colors.orange, size: 24);
        if (index == fullStars && halfStar) return const Icon(Icons.star_half, color: Colors.orange, size: 24);
        return const Icon(Icons.star_border, color: Colors.orange, size: 24);
      }),
    );
  }

  // --- NAVIGATION: Buka Review Page ---
  void _openReviewPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewPage(
            productId: currentProduct.id ?? 0,
            productName: currentProduct.name
        ),
      ),
    );
    _loadReviews(); // reload rating setelah kembali
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        title: const Text('Detail Produk'),
        actions: [
          // Tombol Edit
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Produk',
            onPressed: _editProduct,
          ),
          // Tombol Lihat Keranjang
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            tooltip: 'Lihat Keranjang',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (c) => const CartPage()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Gambar Placeholder
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.pink[100],
                  child: const Icon(Icons.shopping_bag_outlined, size: 70, color: Colors.pink),
                ),
                const SizedBox(height: 24),

                // Nama Produk
                Text(
                    currentProduct.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 8),

                // Harga
                Text(
                    "Rp ${currentProduct.price}",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.pink[700])
                ),
                const SizedBox(height: 16),

                // Rating
                _buildRatingStars(averageRating),
                const SizedBox(height: 4),
                Text(
                  reviewCount > 0
                      ? "${averageRating.toStringAsFixed(1)} / 5.0 (dari $reviewCount review)"
                      : "Belum ada review",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // Deskripsi
                const Text("Deskripsi Produk", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(
                    currentProduct.description,
                    style: const TextStyle(fontSize: 16, height: 1.5)
                ),

                const SizedBox(height: 32),

                // --- TOMBOL AKSI ---
                Row(
                  children: [
                    // Tombol Review
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.rate_review),
                        label: const Text("Review"),
                        onPressed: _openReviewPage,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Tombol Add to Cart
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text("Beli"),
                        onPressed: _showAddToCartDialog,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}