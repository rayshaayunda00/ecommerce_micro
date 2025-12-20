// --- FILE: lib/MODEL/model_user.dart ---
class ModelUser {
  int? id;
  String name;
  String email;
  String role;

  ModelUser({
    this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory ModelUser.fromJson(Map<String, dynamic> json) => ModelUser(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    role: json["role"],
  );

  Map<String, dynamic> toJson() => {
    if (id != null) "id": id,
    "name": name,
    "email": email,
    "role": role,
  };
}