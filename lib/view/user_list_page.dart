import 'package:flutter/material.dart';
import '../API/api_service.dart';
// Pastikan baris ini sesuai dengan nama folder kamu (model vs MODEL)
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

  // Fungsi Hapus User
  void _deleteUser(int id, String name) async {
    // Kalau ID-nya 0 (user error), jangan jalankan apa-apa
    if (id == 0) return;

    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Pengguna"),
        content: Text("Yakin ingin menghapus $name?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    bool success = await apiService.deleteUser(id);

    if (success) {
      _loadUsers();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil dihapus"), backgroundColor: Colors.green));
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal menghapus"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(title: const Text('Daftar Pengguna'), actions: [IconButton(onPressed: _loadUsers, icon: const Icon(Icons.refresh))]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final bool? result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddUserPage()));
          if (result == true) {
            _loadUsers();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User ditambahkan"), backgroundColor: Colors.green));
          }
        },
        label: const Text('Tambah User'),
        icon: const Icon(Icons.person_add),
      ),
      body: FutureBuilder<List<ModelUser>>(
        future: futureUsers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('Tidak ada data.'));

          final users = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];

              // --- PERBAIKAN: AMBIL ID DENGAN AMAN ---
              // Jika user.id error/merah, kode "?? 0" ini solusinya.
              // Artinya: Ambil ID, kalau null ganti jadi 0.
              final int userId = user.id ?? 0;

              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?')),
                  title: Text(user.name),
                  subtitle: Text(user.role),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        // Gunakan userId yang sudah aman di atas
                        onPressed: () => _deleteUser(userId, user.name),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.pink),
                    ],
                  ),
                  onTap: () {
                    // Gunakan userId yang sudah aman di atas
                    Navigator.push(context, MaterialPageRoute(builder: (context) => UserDetailPage(userId: userId)));
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