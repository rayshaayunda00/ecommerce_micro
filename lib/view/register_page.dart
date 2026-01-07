import 'package:flutter/material.dart';
import '../API/api_service.dart';
import '../model/model_user.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final ApiService apiService = ApiService();
  bool _isLoading = false;

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // PERBAIKAN DISINI: Tambahkan 'id: 0' agar tidak error
      ModelUser newUser = ModelUser(
        id: 0, // <--- WAJIB ADA (Nilai sementara)
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        role: 'customer',
      );

      try {
        ModelUser? createdUser = await apiService.addUser(newUser);

        if (mounted) setState(() => _isLoading = false);

        if (createdUser != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Registrasi Berhasil! Silakan Login.'), backgroundColor: Colors.green),
            );
            Navigator.pop(context); // Balik ke Login
          }
        } else {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal daftar. Email mungkin sudah ada.'), backgroundColor: Colors.red));
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(title: const Text('Daftar Akun Baru')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center( // Tambahkan Center agar rapi
          child: SingleChildScrollView( // Tambahkan Scroll agar tidak overflow di HP kecil
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Register", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.pink)),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder()),
                        validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                        validator: (v) => !v!.contains('@') ? 'Email tidak valid' : null,
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, foregroundColor: Colors.white),
                          child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("DAFTAR SEKARANG"),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}