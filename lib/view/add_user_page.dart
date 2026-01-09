import 'package:flutter/material.dart';
import '../API/api_service.dart';
import '../model/model_user.dart'; // Pastikan path import ini benar

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();

  // Controller Input
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // GANTI Controller Role menjadi Variabel Pilihan
  String? _selectedRole = 'customer'; // Default value

  // Daftar Pilihan Role
  final List<String> _roleOptions = ['customer', 'admin', 'seller'];

  bool _isLoading = false;
  final ApiService apiService = ApiService();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    // _roleController tidak perlu didispose karena sudah dihapus
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Buat User Baru
      ModelUser newUser = ModelUser(
        id: 0, // PENTING: Default 0 agar tidak error di Model
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        role: _selectedRole!, // Ambil dari Dropdown
      );

      try {
        ModelUser? createdUser = await apiService.addUser(newUser);

        if (mounted) {
          setState(() => _isLoading = false);
        }

        if (createdUser != null) {
          if (mounted) Navigator.pop(context, true); // Kembali & Refresh List
        } else {
          if (mounted) _showErrorSnackBar('Gagal menambahkan user. Email mungkin duplikat.');
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showErrorSnackBar('Terjadi kesalahan server: $e');
        }
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // Helper untuk Desain Input
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.pink),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.pink, width: 2),
      ),
      filled: true,
      fillColor: Colors.pink.shade50.withOpacity(0.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        title: const Text('Tambah User Baru'),
      ),
      body: SingleChildScrollView( // Agar bisa discroll di HP kecil
        padding: const EdgeInsets.all(20.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.person_add_alt_1, size: 60, color: Colors.pink),
                  const SizedBox(height: 24),

                  // 1. INPUT NAMA
                  TextFormField(
                    controller: _nameController,
                    decoration: _inputDecoration('Nama Lengkap', Icons.person),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Nama wajib diisi' : null,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // 2. INPUT EMAIL
                  TextFormField(
                    controller: _emailController,
                    decoration: _inputDecoration('Email', Icons.email),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Email wajib diisi';
                      if (!value.contains('@')) return 'Email tidak valid';
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // 3. INPUT ROLE (DROPDOWN)
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: _inputDecoration('Pilih Role', Icons.admin_panel_settings),
                    items: _roleOptions.map((String role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Text(
                          role.toUpperCase(), // Biar tampilannya kapital (CUSTOMER)
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedRole = newValue;
                      });
                    },
                    validator: (value) => value == null ? 'Pilih salah satu role' : null,
                  ),

                  const SizedBox(height: 32),

                  // TOMBOL SIMPAN
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                        : const Text('SIMPAN USER'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}