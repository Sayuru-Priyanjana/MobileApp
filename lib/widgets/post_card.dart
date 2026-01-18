import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/post_model.dart';
import '../providers/user_provider.dart';
import '../providers/feed_provider.dart';
import '../services/database_service.dart';
import '../utils/time_ago.dart';
import '../screens/profile/profile_screen.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final bool enableDelete;

  const PostCard({super.key, required this.post, this.enableDelete = true});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final TextEditingController _commentController = TextEditingController();
  final DatabaseService _dbService = DatabaseService();

  void _handleLike() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.isLoggedIn) {
      Provider.of<FeedProvider>(
        context,
        listen: false,
      ).likePost(widget.post.id, userProvider.currentUser!.id);
    }
  }

  void _handleDelete() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Post'),
            content: const Text('Are you sure you want to delete this post?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Provider.of<FeedProvider>(
                    context,
                    listen: false,
                  ).deletePost(widget.post.id);
                  Navigator.pop(context);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _handleShare() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text("Share via..."),
                onTap: () {
                  Navigator.pop(context);
                  Share.share(
                    'Check out this post by ${widget.post.username}: ${widget.post.caption ?? ""}',
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.repeat),
                title: const Text("Repost"),
                onTap: () async {
                  Navigator.pop(context);
                  final currentUser =
                      Provider.of<UserProvider>(
                        context,
                        listen: false,
                      ).currentUser;
                  if (currentUser != null) {
                    await _dbService.repost(
                      widget.post,
                      currentUser.id,
                      currentUser.username,
                      currentUser.profileImageUrl,
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reposted!')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToProfile(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return ProfileScreen(userId: userId);
        },
      ),
    );
  }

  void _showComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Comments",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const Divider(),
                Expanded(
                  child: StreamBuilder<DatabaseEvent>(
                    stream: _dbService.getComments(widget.post.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData ||
                          snapshot.data!.snapshot.value == null) {
                        return const Center(child: Text("No comments yet"));
                      }

                      Map<dynamic, dynamic> commentsMap =
                          snapshot.data!.snapshot.value as Map;
                      List<Map> comments = [];
                      commentsMap.forEach((k, v) => comments.add(v));
                      comments.sort(
                        (a, b) => (b['timestamp'] ?? 0).compareTo(
                          a['timestamp'] ?? 0,
                        ),
                      );

                      return ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          final username = comment['username'] ?? 'User';
                          final userImage = comment['userImage'] ?? '';

                          return ListTile(
                            onTap: () {
                              if (comment['userId'] != null) {
                                _navigateToProfile(comment['userId']);
                              }
                            },
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey[200],
                              backgroundImage:
                                  userImage.isNotEmpty
                                      ? CachedNetworkImageProvider(userImage)
                                      : null,
                              child:
                                  userImage.isEmpty
                                      ? Text(
                                        username.isNotEmpty
                                            ? username[0].toUpperCase()
                                            : '?',
                                      )
                                      : null,
                            ),
                            title: Text(
                              username,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(comment['text'] ?? ''),
                          );
                        },
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          hintText: 'Add a comment...',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        final userProvider = Provider.of<UserProvider>(
                          context,
                          listen: false,
                        );
                        if (userProvider.isLoggedIn &&
                            _commentController.text.isNotEmpty) {
                          _dbService.addComment(
                            widget.post.id,
                            userProvider.currentUser!.id,
                            userProvider.currentUser!.username,
                            userProvider
                                .currentUser!
                                .profileImageUrl, // Pass image
                            _commentController.text,
                          );
                          _commentController.clear();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).currentUser;
    final isLiked = user != null && widget.post.likes.containsKey(user.id);
    final likesCount = widget.post.likes.length;
    final isOwner = user != null && widget.post.userId == user.id;

    final formattedTime = formatTimeAgo(widget.post.timestamp);

    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 0,
      ), // Full width look
      elevation: 0, // Flat
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _navigateToProfile(widget.post.userId),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage:
                        widget.post.userProfileImage.isNotEmpty
                            ? CachedNetworkImageProvider(
                              widget.post.userProfileImage,
                            )
                            : null,
                    backgroundColor: Colors.grey[200],
                    child:
                        widget.post.userProfileImage.isEmpty
                            ? const Icon(
                              Icons.person,
                              color: Colors.grey,
                              size: 16,
                            )
                            : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _navigateToProfile(widget.post.userId),
                    child: Text(
                      widget.post.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                if (isOwner && widget.enableDelete)
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: _handleDelete, // Or show menu
                  ),
              ],
            ),
          ),

          // Media (Full Width)
          if (widget.post.mediaType == 'image' && widget.post.mediaUrl != null)
            CachedNetworkImage(
              imageUrl: widget.post.mediaUrl!,
              placeholder:
                  (context, url) =>
                      Container(height: 300, color: Colors.grey[100]),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          if (widget.post.mediaType == 'video' && widget.post.mediaUrl != null)
            _VideoPlayerWidget(videoUrl: widget.post.mediaUrl!),

          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _handleLike,
                  child: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color:
                        isLiked
                            ? Colors.red
                            : Theme.of(context).iconTheme.color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: _showComments,
                  child: Icon(
                    Icons.mode_comment_outlined,
                    size: 26,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: _handleShare,
                  child: Icon(
                    Icons.send_outlined,
                    size: 26,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.bookmark_border,
                  size: 28,
                  color: Theme.of(context).iconTheme.color,
                ), // Placeholder
              ],
            ),
          ),

          // Likes Count
          if (likesCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '$likesCount likes',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

          // Caption
          if (widget.post.caption != null && widget.post.caption!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    TextSpan(
                      text: '${widget.post.username} ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: widget.post.caption),
                  ],
                ),
              ),
            ),

          // View Comments
          if (widget.post.commentCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              child: GestureDetector(
                onTap: _showComments,
                child: Text(
                  'View all ${widget.post.commentCount} comments',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ),
            ),

          // Timestamp
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: Text(
              formattedTime.toUpperCase(),
              style: TextStyle(color: Colors.grey[500], fontSize: 10),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  const _VideoPlayerWidget({required this.videoUrl});

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );
    await _videoPlayerController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      aspectRatio: _videoPlayerController.value.aspectRatio,
      autoPlay: false,
      looping: false,
      showControls: true,
      placeholder: Container(color: Colors.black),
      autoInitialize: true,
    );
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_chewieController != null &&
        _videoPlayerController.value.isInitialized) {
      return AspectRatio(
        aspectRatio: _videoPlayerController.value.aspectRatio,
        child: Chewie(controller: _chewieController!),
      );
    }
    return Container(
      height: 200,
      color: Colors.black12,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
