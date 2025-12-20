// --- FILE: lib/VIEW/user_detail_page.dart ---
import 'package:flutter/material.dart';
import '../API/api_service.dart';
import '../model/model_user.dart';

class UserDetailPage extends StatefulWidget {
  final int userId;
  const UserDetailPage({super.key, required this.userId});

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  final ApiService apiService = ApiService();
  late Future<ModelUser> futureUser;

  @override
  void initState() {
    super.initState();
    futureUser = apiService.getUserById(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        title: Text('Detail User #${widget.userId}'),
      ),
      body: FutureBuilder<ModelUser>(
        future: futureUser,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('User tidak ditemukan.'));
          }

          final user = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.pink[200],
                  child: Icon(Icons.person, size: 80, color: Colors.pink[800]),
                ),
                const SizedBox(height: 30),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _buildDetailItem(Icons.badge_outlined, 'ID Pengguna', user.id.toString()),
                        const Divider(),
                        _buildDetailItem(Icons.person_outline, 'Nama Lengkap', user.name),
                        const Divider(),
                        _buildDetailItem(Icons.email_outlined, 'Email', user.email),
                        const Divider(),
                        _buildDetailItem(Icons.admin_panel_settings_outlined, 'Role', user.role),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.pink, size: 28),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}