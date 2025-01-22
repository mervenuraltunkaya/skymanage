import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/database_service.dart';

class SelectUsersScreen extends StatefulWidget {
  final int surveyId;

  const SelectUsersScreen({Key? key, required this.surveyId}) : super(key: key);

  @override
  State<SelectUsersScreen> createState() => _SelectUsersScreenState();
}

class _SelectUsersScreenState extends State<SelectUsersScreen> {
  List<User> _users = [];
  final Set<int> _selectedUserIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await DatabaseService.instance.getAllUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kullanıcılar yüklenirken hata oluştu: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _assignSurvey() async {
    if (_selectedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen en az bir kullanıcı seçin')),
      );
      return;
    }

    try {
      for (final userId in _selectedUserIds) {
        await DatabaseService.instance.assignSurveyToUser(
          surveyId: widget.surveyId,
          userId: userId,
        );
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Anket atanırken hata oluştu: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kullanıcı Seç'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      return CheckboxListTile(
                        title: Text(user.username),
                        subtitle: Text(user.role == UserRole.admin
                            ? 'Yönetici'
                            : 'Kullanıcı'),
                        value: _selectedUserIds.contains(user.id),
                        onChanged: (selected) {
                          setState(() {
                            if (selected!) {
                              _selectedUserIds.add(user.id);
                            } else {
                              _selectedUserIds.remove(user.id);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: _assignSurvey,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: const Text(
                      'Seçili Kullanıcılara Ata',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
} 