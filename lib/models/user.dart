enum UserRole {
  admin,
  user,
}

class User {
  final int id;
  final String username;
  final bool isAdmin;

  UserRole get role => isAdmin ? UserRole.admin : UserRole.user;

  User({
    required this.id,
    required this.username,
    required this.isAdmin,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int,
      username: map['username'] as String,
      isAdmin: map['is_admin'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'is_admin': isAdmin ? 1 : 0,
    };
  }
}