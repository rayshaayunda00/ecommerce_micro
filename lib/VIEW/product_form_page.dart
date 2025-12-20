import 'package:flutter/material.dart';
import '../MODEL/ModelProduct.dart';
import '../API/api_service.dart';

class ProductFormPage extends StatefulWidget {
  final ModelProduct? product; // Null = Tambah, Ada isi = Edit

  const ProductFormPage({Key? key, this.product}) : super(key: key);

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _priceController.text = widget.product!.price.toString();
      _descController.text = widget.product!.description;
    }
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final productData = ModelProduct(
      id: widget.product?.id, // null jika tambah baru
      name: _nameController.text,
      price: double.parse(_priceController.text),
      description: _descController.text,
    );

    bool success;
    if (widget.product == null) {
      // Create
      success = await _apiService.addProduct(productData);
    } else {
      // Update
      success = await _apiService.updateProduct(widget.product!.id!, productData);
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil menyimpan data')),
      );
      Navigator.pop(context, true); // Kembali & Refresh
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan data'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Tambah Produk' : 'Edit Produk'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Produk', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Harga', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Deskripsi', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _submitData,
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                child: Text(widget.product == null ? 'SIMPAN' : 'UPDATE'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}