enum UserRole { doctor, patient }

class UserModel {
  final String id;
  final String name;
  final String username;
  final UserRole role;

  const UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.role,
  });
}
