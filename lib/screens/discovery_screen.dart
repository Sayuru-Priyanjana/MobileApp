import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/database_service.dart';
import 'profile/profile_screen.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final currentUser =
        Provider.of<UserProvider>(context, listen: false).currentUser;
    if (currentUser == null) return;

    final allUsers = await _dbService.getAllUsers();
    final followingIds = await _dbService.getFollowingIds(currentUser.id);

    // Filter out self and already following
    final newUsers =
        allUsers.where((u) {
          final id = u['id'];
          return id != currentUser.id && !followingIds.contains(id);
        }).toList();

    if (mounted) {
      setState(() {
        _users = newUsers;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Discover People")),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _users.isEmpty
              ? const Center(child: Text("No new users to discover!"))
              : GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.8,
                ),
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return _buildUserCard(user);
                },
              ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProfileScreen(userId: user['id'])),
        );
      },
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage:
                  user['profileImageUrl'] != null &&
                          user['profileImageUrl'].isNotEmpty
                      ? CachedNetworkImageProvider(user['profileImageUrl'])
                      : null,
              child:
                  user['profileImageUrl'] == null ||
                          user['profileImageUrl'].isEmpty
                      ? const Text("?", style: TextStyle(fontSize: 30))
                      : null,
            ),
            const SizedBox(height: 8),
            Text(
              user['username'] ?? 'Unknown',
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // We could add a "Follow" button here, but tapping to profile is safer for now
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(userId: user['id']),
                  ),
                );
              },
              child: const Text("View Profile"),
            ),
          ],
        ),
      ),
    );
  }
}
