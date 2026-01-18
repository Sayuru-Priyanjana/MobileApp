import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/feed_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/post_card.dart';
import '../../widgets/stories_bar.dart';
import '../../services/database_service.dart';

// Import local to fix type inference if needed
import '../../models/post_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> _followingIds = [];

  @override
  void initState() {
    super.initState();
    _loadFollowing();
  }

  void _loadFollowing() async {
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    if (user != null) {
      final ids = await DatabaseService().getFollowingIds(user.id);
      if (mounted) setState(() => _followingIds = ids);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lumo',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit', // Ensure consistent font
            fontStyle: FontStyle.italic,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<FeedProvider>(
        builder: (context, feed, child) {
          if (feed.isLoading && feed.posts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Feed Logic: Prioritize following
          List<PostModel> followingPosts = [];
          List<PostModel> otherPosts = [];

          for (var post in feed.posts) {
            if (_followingIds.contains(post.userId)) {
              followingPosts.add(post);
            } else {
              otherPosts.add(post);
            }
          }

          final sortedPosts = [...followingPosts, ...otherPosts];

          if (sortedPosts.isEmpty) {
            return Column(
              children: const [
                StoriesBar(),
                Expanded(
                  child: Center(
                    child: Text('No posts yet! Be the first to post.'),
                  ),
                ),
              ],
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _loadFollowing(); // Refresh following list
              await Future.delayed(const Duration(seconds: 1));
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: sortedPosts.length + 1, // +1 for Stories
              itemBuilder: (context, index) {
                if (index == 0) return const StoriesBar();
                final post = sortedPosts[index - 1];
                return PostCard(
                  post: post,
                  enableDelete: false,
                ); // Disable delete on feed
              },
            ),
          );
        },
      ),
    );
  }
}
