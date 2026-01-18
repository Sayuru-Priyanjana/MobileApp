import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../services/cloudinary_service.dart'; // Add this
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import '../models/story_model.dart';
import '../services/database_service.dart';
import '../providers/user_provider.dart';

class StoriesBar extends StatefulWidget {
  const StoriesBar({super.key});

  @override
  State<StoriesBar> createState() => _StoriesBarState();
}

class _StoriesBarState extends State<StoriesBar> {
  final DatabaseService _dbService = DatabaseService();
  bool _isUploading = false;
  List<String> _followingIds = [];
  bool _isLoading = true;
  final Set<String> _seenUserIds = {};

  @override
  void initState() {
    super.initState();
    _loadFollowing();
  }

  Future<void> _loadFollowing() async {
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    if (user != null) {
      final following = await _dbService.getFollowingIds(user.id);
      if (mounted) {
        setState(() {
          _followingIds = [user.id, ...following];
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAddStory() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && mounted) {
      setState(() => _isUploading = true);

      try {
        final cloudinary = CloudinaryService();
        final url = await cloudinary.uploadMedia(File(pickedFile.path));
        final user =
            Provider.of<UserProvider>(context, listen: false).currentUser;

        if (url != null && user != null) {
          await _dbService.createStory(
            user.id,
            user.username,
            user.profileImageUrl,
            url,
            'image',
          );
        }
      } catch (e) {
        debugPrint('Error uploading story: $e');
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isUploading || _isLoading) {
      return const SizedBox(
        height: 110,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _followingIds.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return _buildAddStoryButton(context);

          final userId = _followingIds[index - 1];
          return StreamBuilder<DatabaseEvent>(
            stream: _dbService.getUserStories(userId),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                return const SizedBox.shrink();
              }

              final data =
                  snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
              final List<StoryModel> stories = [];
              final now = DateTime.now().millisecondsSinceEpoch;

              data.forEach((k, v) {
                final s = StoryModel.fromMap(v);
                if (now - s.timestamp < 24 * 60 * 60 * 1000) {
                  stories.add(s);
                }
              });

              if (stories.isEmpty) return const SizedBox.shrink();

              stories.sort((a, b) => a.timestamp.compareTo(b.timestamp));

              return _buildUserStoryCircle(context, stories);
            },
          );
        },
      ),
    );
  }

  Widget _buildAddStoryButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: _handleAddStory,
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: CachedNetworkImageProvider(
                    Provider.of<UserProvider>(
                          context,
                        ).currentUser?.profileImageUrl ??
                        '',
                  ),
                  child:
                      Provider.of<UserProvider>(
                                context,
                              ).currentUser?.profileImageUrl ==
                              null
                          ? const Icon(Icons.person)
                          : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Color(0xFF00B4D8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text("Add Story", style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildUserStoryCircle(BuildContext context, List<StoryModel> stories) {
    final story = stories.last;
    final isSeen = _seenUserIds.contains(story.userId);

    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: () => _viewStory(context, stories),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border:
                    isSeen ? Border.all(color: Colors.grey, width: 1.5) : null,
                gradient:
                    isSeen
                        ? null
                        : const LinearGradient(
                          colors: [
                            Color(0xFF833AB4),
                            Color(0xFFFD1D1D),
                            Color(0xFFF56040),
                            Color(0xFFFFDC80),
                          ],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
              ),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: CachedNetworkImageProvider(story.userImage),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(story.username, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _viewStory(BuildContext context, List<StoryModel> stories) {
    if (stories.isEmpty) return;
    setState(() {
      _seenUserIds.add(stories.first.userId);
    });
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => _StoryViewer(stories: stories)));
  }
}

class _StoryViewer extends StatefulWidget {
  final List<StoryModel> stories;
  const _StoryViewer({required this.stories});

  @override
  State<_StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<_StoryViewer> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.stories.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) {
                return Center(
                  child: CachedNetworkImage(
                    imageUrl: widget.stories[index].mediaUrl,
                    fit: BoxFit.contain,
                    placeholder:
                        (context, url) => const CircularProgressIndicator(),
                  ),
                );
              },
            ),
            // Progress Bar?
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Row(
                children: List.generate(widget.stories.length, (index) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 4,
                      color:
                          index <= _currentIndex
                              ? Colors.white
                              : Colors.white24,
                    ),
                  );
                }),
              ),
            ),
            // Close Button
            Positioned(
              top: 20,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            // Delete if Owner
            if (widget.stories[_currentIndex].userId ==
                Provider.of<UserProvider>(
                  context,
                  listen: false,
                ).currentUser?.id)
              Positioned(
                bottom: 30,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final story = widget.stories[_currentIndex];
                    await DatabaseService().deleteStory(story.userId, story.id);
                    // Close if last story deleted? Or refresh?
                    // Since it's realtime, parent will update circle.
                    // But Viewer needs to handle list change.
                    // For simplicity, pop.
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
