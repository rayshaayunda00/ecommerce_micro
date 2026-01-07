// --- FILE: lib/view/user_list_page.dart ---
import 'package:flutter/material.dart';
import '../API/api_service.dart';
// Perbaikan: Path folder MODEL huruf besar
import '../model/model_user.dart';
import 'add_user_page.dart';
import 'user_detail_page.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final ApiService apiService = ApiService();
  late Future<List<ModelUser>> futureUsers;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    setState(() {
      futureUsers = apiService.getUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        title: const Text('Daftar Pengguna'),
        actions: [
          IconButton(onPressed: _loadUsers, icon: const Icon(Icons.refresh))
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Navigasi ke halaman tambah, tunggu hasilnya
          final bool? result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddUserPage()),
          );

          // Jika berhasil nambah user (result == true), refresh list
          if (result == true) {
            _loadUsers();
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("User berhasil ditambahkan"), backgroundColor: Colors.green,)
            );
          }
        },
        label: const Text('Tambah User'),
        icon: const Icon(Icons.person_add),
      ),
      body: FutureBuilder<List<ModelUser>>(
        future: futureUsers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data pengguna.'));
          }

          final users = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.pink[100],
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: TextStyle(color: Colors.pink[800], fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${user.email}\nRole: ${user.role}'),
                  isThreeLine: true,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.pink),
                  onTap: () {
                    // Navigasi ke detail user
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserDetailPage(userId: user.id!)));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}