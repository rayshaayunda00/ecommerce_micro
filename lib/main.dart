import 'package:flutter/material.dart';
import 'VIEW/login_page.dart'; // <--- Import Login Page

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tugas Akhir Ecommerce',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5D4037)),
        useMaterial3: true,
      ),
      // PERUBAHAN UTAMA:
      home: const LoginPage(),
    );
  }
}