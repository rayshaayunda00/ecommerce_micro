// --- FILE: lib/VIEW/add_user_page.dart ---
import 'package:flutter/material.dart';
import '../API/api_service.dart';
import '../model/model_user.dart';

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _roleController = TextEditingController(); // Default kosong agar user mengisi

  bool _isLoading = false;
  final ApiService apiService = ApiService();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      ModelUser newUser = ModelUser(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        role: _roleController.text.trim(),
      );

      try {
        ModelUser? createdUser = await apiService.addUser(newUser);
        setState(() => _isLoading = false);

        if (createdUser != null) {
          // Berhasil, kembali ke halaman list dengan membawa nilai true
          if (mounted) Navigator.pop(context, true);
        } else {
          _showErrorSnackBar('Gagal menambahkan user. Cek data input.');
        }
      } catch (e) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Terjadi kesalahan server: $e');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        title: const Text('Tambah User Baru'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.person_add_alt_1, size: 60, color: Colors.pink),
                  const SizedBox(height: 24),

                  // Input Nama
                  TextFormField(
                    controller: _nameController,
                    decoration: _inputDecoration('Nama Lengkap', Icons.person),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Nama wajib diisi' : null,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // Input Email
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

                  // Input Role
                  TextFormField(
                    controller: _roleController,
                    decoration: _inputDecoration('Role (misal: customer, admin)', Icons.admin_panel_settings),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Role wajib diisi' : null,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submitForm(),
                  ),
                  const SizedBox(height: 32),

                  // Tombol Submit
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
}