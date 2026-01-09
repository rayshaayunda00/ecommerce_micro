class ModelUser {
  int id; // HAPUS tanda tanya (?) agar Wajib Angka
  String name;
  String email;
  String role;

  ModelUser({
    this.id = 0, // Default 0 (Penting agar Register tidak error)
    required this.name,
    required this.email,
    required this.role,
  });

  factory ModelUser.fromJson(Map<String, dynamic> json) {
    return ModelUser(
      // Logika: Jika id null/error, paksa jadi 0
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'customer',
    );
  }

  Map<String, dynamic> toJson() => {
    // ID 0 tidak perlu dikirim ke backend saat register
    if (id != 0) "id": id,
    "name": name,
    "email": email,
    "role": role,
  };
}