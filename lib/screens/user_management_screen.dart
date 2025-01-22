import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/user.dart';

class UserManagementScreen extends StatefulWidget {
  final int adminId;

  const UserManagementScreen({Key? key, required this.adminId}) : super(key: key);

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<User> _users = [];
  bool _isLoading = true;

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    if (!mounted) return;
    
    try {
      final users = await _databaseService.getAllUsers();
      if (!mounted) return;
      
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kullanıcılar yüklenirken hata oluştu: $e')),
      );
    }
  }

  Future<void> _addUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = await _databaseService.createUser(
          username: _usernameController.text,
          password: _passwordController.text,
          isAdmin: _isAdmin,
        );
        
        if (!mounted) return;
        
        setState(() {
          _users.add(user);
          _usernameController.clear();
          _passwordController.clear();
          _isAdmin = false;
        });
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kullanıcı eklenirken hata oluştu: $e')),
        );
      }
    }
  }

  Future<void> _deleteUser(int userId) async {
    try {
      await DatabaseService.instance.deleteUser(userId);
      if (mounted) {
        setState(() {
          _users.removeWhere((user) => user.id == userId);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kullanıcı silinirken hata oluştu: $e')),
        );
      }
    }
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Kullanıcı Ekle'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Kullanıcı Adı'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen kullanıcı adı girin';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Şifre'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen şifre girin';
                  }
                  return null;
                },
              ),
              CheckboxListTile(
                title: const Text('Admin Yetkisi'),
                value: _isAdmin,
                onChanged: (value) {
                  setState(() {
                    _isAdmin = value ?? false;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: _addUser,
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kullanıcı Yönetimi'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddUserDialog,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Icon(
                      user.isAdmin ? Icons.admin_panel_settings : Icons.person,
                    ),
                    title: Text(user.username),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteUser(user.id),
                    ),
                  ),
                );
              },
            ),
    );
  }
} 