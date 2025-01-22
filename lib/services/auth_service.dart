import '../models/user.dart';
import 'database_service.dart';

class AuthService {
  static final AuthService instance = AuthService._init();
  AuthService._init();

  Future<User?> login(String username, String password) async {
    final db = await DatabaseService.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (maps.isEmpty) {
      return null;
    }

    return User.fromMap(maps.first);
  }

  Future<User> register({
    required String username,
    required String password,
    required bool isAdmin,
  }) async {
    return DatabaseService.instance.createUser(
      username: username,
      password: password,
      isAdmin: isAdmin,
    );
  }

  Future<List<User>> getNonAdminUsers() async {
    final db = await DatabaseService.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'is_admin = ?',
      whereArgs: [0],
    );
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }
} 