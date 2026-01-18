import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/database_service.dart';
import 'profile_screen.dart';

class UserListScreen extends StatefulWidget {
  final List<String> userIds;
  final String title;

  const UserListScreen({super.key, required this.userIds, required this.title});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final List<Map<String, dynamic>> users = [];
    for (String userId in widget.userIds) {
      final user = await _dbService.getUser(userId);
      if (user != null) {
        users.add(user);
      }
    }
    if (mounted) {
      setState(() {
        _users = users;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _users.isEmpty
              ? const Center(child: Text('No users found'))
              : ListView.builder(
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          user['profileImageUrl'] != null &&
                                  user['profileImageUrl'].isNotEmpty
                              ? CachedNetworkImageProvider(
                                user['profileImageUrl'],
                              )
                              : null,
                      child:
                          user['profileImageUrl'] == null ||
                                  user['profileImageUrl'].isEmpty
                              ? const Icon(Icons.person)
                              : null,
                    ),
                    title: Text(user['username'] ?? 'Unknown'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProfileScreen(userId: user['id']),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
