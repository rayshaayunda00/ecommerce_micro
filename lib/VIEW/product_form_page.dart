// --- FILE: lib/VIEW/product_form_page.dart ---
import 'package:flutter/material.dart';
import '../MODEL/ModelProduct.dart';
import '../API/api_service.dart';

class ProductFormPage extends StatefulWidget {
  final ModelProduct? product; // Null = Tambah, Ada isi = Edit

  const ProductFormPage({super.key, this.product});

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
      // Menghapus .0 jika harga bulat agar lebih rapi di text field
      _priceController.text = widget.product!.price.toString().replaceAll(RegExp(r'\.0$'), '');
      _descController.text = widget.product!.description;
    }
  }

  Future<void> _submitData() async {
    // Hilangkan fokus keyboard sebelum submit
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final productData = ModelProduct(
      id: widget.product?.id,
      name: _nameController.text,
      price: double.tryParse(_priceController.text) ?? 0.0,
      description: _descController.text,
    );

    bool success;
    if (widget.product == null) {
      success = await _apiService.addProduct(productData);
    } else {
      success = await _apiService.updateProduct(widget.product!.id!, productData);
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil menyimpan data'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true); // Kembali & Refresh
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan data'), backgroundColor: Colors.red),
      );
    }
  }

  // Helper Custom Decoration
  InputDecoration _buildInputDecoration(String label, IconData icon, {String? prefixText}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.pink[800]),
      prefixIcon: Icon(icon, color: Colors.pink),
      prefixText: prefixText,
      prefixStyle: const TextStyle(color: Colors.pink, fontWeight: FontWeight.bold),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.pink.shade100),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.pink, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.product != null;

    return GestureDetector(
      // Menutup keyboard saat tap di luar form
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.pink[50],
        appBar: AppBar(
          title: Text(
            isEditing ? 'Edit Produk' : 'Tambah Produk',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.pink,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // --- HEADER ICON ---
              Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.pink.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))
                  ],
                ),
                child: Icon(
                  isEditing ? Icons.edit_note_rounded : Icons.add_shopping_cart_rounded,
                  size: 60,
                  color: Colors.pink,
                ),
              ),

              Text(
                isEditing ? "Ubah detail produk Anda" : "Masukkan informasi produk baru",
                style: TextStyle(color: Colors.pink[800], fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 25),

              // --- FORM ---
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // INPUT NAMA
                    TextFormField(
                      controller: _nameController,
                      decoration: _buildInputDecoration('Nama Produk', Icons.label_outline),
                      textCapitalization: TextCapitalization.words, // Huruf besar tiap kata
                      textInputAction: TextInputAction.next,
                      validator: (val) => val!.isEmpty ? 'Nama produk wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    // INPUT HARGA
                    TextFormField(
                      controller: _priceController,
                      decoration: _buildInputDecoration('Harga', Icons.attach_money, prefixText: 'Rp '),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textInputAction: TextInputAction.next,
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Harga wajib diisi';
                        if (double.tryParse(val) == null) return 'Harga harus berupa angka';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // INPUT DESKRIPSI
                    TextFormField(
                      controller: _descController,
                      decoration: _buildInputDecoration('Deskripsi', Icons.description_outlined),
                      maxLines: 4,
                      minLines: 2,
                      textCapitalization: TextCapitalization.sentences, // Huruf besar awal kalimat
                      textInputAction: TextInputAction.newline,
                      validator: (val) => val!.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 30),

                    // TOMBOL SIMPAN
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: _isLoading
                          ? ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink[100],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: const CircularProgressIndicator(color: Colors.pink),
                      )
                          : ElevatedButton.icon(
                        onPressed: _submitData,
                        icon: Icon(isEditing ? Icons.save_as : Icons.check_circle, color: Colors.white),
                        label: Text(
                          isEditing ? 'UPDATE PRODUK' : 'SIMPAN PRODUK',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 5,
                          shadowColor: Colors.pink.withOpacity(0.4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}