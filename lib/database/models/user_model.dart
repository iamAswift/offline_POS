
//lib/database/models/user_model.dart

class UserModel {
  final int id;
  final String name;
  final String? loginId;
  final String email;
  final String password;
  final bool isActive;
  final String role;

  UserModel({
    required this.id,
    required this.name,
    this.loginId,
    required this.email,
    required this.password,
    required this.isActive,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "loginId": loginId,
        "email": email,
        "password": password,
        "isActive": isActive,
        "role": role,
      };

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'] as int,
      name: data['name'] as String,
      loginId: data['loginId'] as String?,
      email: data['email'] as String,
      password: data['password'] as String,
      isActive: data['isActive'] == 1,
      role: data['role'] as String,
    );
  }

}
