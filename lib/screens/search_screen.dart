import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import 'profile/profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  void _performSearch(String query) async {
    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isLoading = false;
          _hasSearched = false;
        });
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _databaseService.searchUsers(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
          _hasSearched = true;
        });
      }
    } catch (e) {
      debugPrint('Search error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Keep previous results or clear?
          // For now, let's not clear properly but maybe show error.
          // Simplest is to just stop loading.
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search users...',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
          ),
          style: TextStyle(
            color: Theme.of(context).appBarTheme.titleTextStyle?.color,
          ),
          onChanged: _performSearch, // Live search
          autofocus: true,
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _searchResults.isEmpty
              ? Center(
                child:
                    _hasSearched
                        ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No users found',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        )
                        : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Search for users',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
              )
              : ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final user = _searchResults[index];
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
                    subtitle: Text(user['bio'] ?? ''),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ProfileScreen(
                                userId: user['id'],
                                isCurrentUser: false,
                              ),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
