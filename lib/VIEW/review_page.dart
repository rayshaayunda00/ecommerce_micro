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

  // Fungsi Kirim ke API
  void _submitReview(String content, int rating) async {
    // Tampilkan loading
    showDialog(context: context, barrierDismissible: false, builder: (c) => const Center(child: CircularProgressIndicator()));

    final newReview = ModelReview(
      id: 0,
      productId: widget.productId,
      review: content,
      rating: rating,
    );

    bool success = await apiService.addReview(newReview);

    if (mounted) Navigator.pop(context); // Tutup loading

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review berhasil ditambahkan'), backgroundColor: Colors.green));
        Navigator.pop(context); // Tutup dialog form
        _loadReviews(); // Refresh list
      }
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal mengirim review'), backgroundColor: Colors.red));
    }
  }

  void _addReviewDialog() {
    final reviewController = TextEditingController();
    double rating = 5;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Review - ${widget.productName}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: reviewController,
                    decoration: const InputDecoration(labelText: 'Review', border: OutlineInputBorder()),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Rating:'),
                      const SizedBox(width: 12),
                      DropdownButton<double>(
                        value: rating,
                        items: [1,2,3,4,5].map((e) => DropdownMenuItem(value: e.toDouble(), child: Text(e.toString()))).toList(),
                        onChanged: (v) {
                          if (v != null) setStateDialog(() => rating = v);
                        },
                      ),
                    ],
                  )
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                ElevatedButton(
                  onPressed: () {
                    if (reviewController.text.isNotEmpty) {
                      _submitReview(reviewController.text, rating.toInt());
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
          child: Text(review.rating.toString(), style: TextStyle(color: Colors.pink[800], fontWeight: FontWeight.bold)),
        ),
        title: Text(review.review),
        subtitle: Row(
          children: List.generate(5, (index) => Icon(
              index < review.rating ? Icons.star : Icons.star_border,
              color: Colors.orange, size: 16
          )),
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
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('Belum ada review.'));

          final reviews = snapshot.data!;
          return ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (context, index) => _buildReviewItem(reviews[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addReviewDialog,
        label: const Text('Tulis Review'),
        icon: const Icon(Icons.rate_review),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
    );
  }
}