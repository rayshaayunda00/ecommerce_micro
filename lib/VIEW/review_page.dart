// --- FILE: lib/VIEW/review_page.dart ---
import 'package:flutter/material.dart';
import '../API/api_service.dart';
import '../MODEL/model_review.dart';

class ReviewPage extends StatefulWidget {
  final int productId;
  final String productName;

  const ReviewPage({super.key, required this.productId, required this.productName});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final ApiService apiService = ApiService();
  late Future<List<ModelReview>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  void _loadReviews() {
    setState(() {
      _reviewsFuture = apiService.getReviewsByProductId(widget.productId);
    });
  }

  // --- LOGIC: Tambah Review ke API ---
  void _submitReview(String reviewText, int rating) async {
    // Tampilkan loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    // Buat objek model
    final newReview = ModelReview(
      id: 0, // ID biasanya diabaikan oleh backend saat create
      productId: widget.productId,
      review: reviewText,
      rating: rating,
    );

    // Kirim ke API
    bool success = await apiService.addReview(newReview);

    // Tutup Loading
    if (mounted) Navigator.pop(context);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review berhasil ditambahkan'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Tutup dialog input
        _loadReviews(); // Refresh list review
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menambahkan review'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showAddReviewDialog() {
    final reviewController = TextEditingController();
    double currentRating = 5.0;

    showDialog(
      context: context,
      builder: (context) {
        // StatefulBuilder digunakan agar Dropdown bisa update state di dalam Dialog
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Review ${widget.productName}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: reviewController,
                    decoration: const InputDecoration(
                      labelText: 'Tulis komentar...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Rating: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      DropdownButton<double>(
                        value: currentRating,
                        items: [1, 2, 3, 4, 5].map((e) => DropdownMenuItem(
                          value: e.toDouble(),
                          child: Row(
                            children: [
                              Text("$e"),
                              const SizedBox(width: 4),
                              const Icon(Icons.star, color: Colors.orange, size: 16),
                            ],
                          ),
                        )).toList(),
                        onChanged: (v) {
                          if (v != null) {
                            // Update state LOKAL DIALOG
                            setStateDialog(() {
                              currentRating = v;
                            });
                          }
                        },
                      ),
                    ],
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (reviewController.text.isNotEmpty) {
                      _submitReview(reviewController.text, currentRating.toInt());
                    }
                  },
                  child: const Text('Kirim'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildReviewItem(ModelReview review) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.pink[100],
          child: Text(
            "${review.rating}",
            style: TextStyle(color: Colors.pink[800], fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(review.review),
        subtitle: Row(
          children: List.generate(5, (index) {
            return Icon(
              index < review.rating ? Icons.star : Icons.star_border,
              color: Colors.orange,
              size: 16,
            );
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(title: Text('Review Produk')),
      body: FutureBuilder<List<ModelReview>>(
        future: _reviewsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada review. Jadilah yang pertama!'));
          }

          final reviews = snapshot.data!;
          return ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              return _buildReviewItem(reviews[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddReviewDialog,
        label: const Text('Tulis Review'),
        icon: const Icon(Icons.rate_review),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
    );
  }
}