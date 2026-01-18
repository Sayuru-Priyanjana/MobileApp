import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/post_model.dart';
import '../services/database_service.dart';
import '../services/cloudinary_service.dart';

class FeedProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  List<PostModel> _posts = [];
  bool _isLoading = false;

  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;

  FeedProvider() {
    _listenToPosts();
  }

  void _listenToPosts() {
    _dbService.postsQuery.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        final List<PostModel> loaded = [];
        data.forEach((key, value) {
          loaded.add(PostModel.fromJson(key, value as Map));
        });

        // Random order as requested, or maybe chronological?
        // User asked for "Random order".
        loaded.shuffle();

        _posts = loaded;
      } else {
        _posts = [];
      }
      notifyListeners();
    });
  }

  Future<void> createPost({
    required String userId,
    required String username,
    required String userProfileImage,
    String? caption,
    File? mediaFile,
    bool isVideo = false,
  }) async {
    if (caption == null && mediaFile == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      String? mediaUrl;
      if (mediaFile != null) {
        mediaUrl = await _cloudinaryService.uploadMedia(
          mediaFile,
          resourceType: isVideo ? 'video' : 'image',
        );
      }

      final newPost = PostModel(
        id: const Uuid().v4(),
        userId: userId,
        username: username,
        userProfileImage: userProfileImage,
        caption: caption,
        mediaUrl: mediaUrl,
        mediaType: mediaUrl == null ? 'none' : (isVideo ? 'video' : 'image'),
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      await _dbService.createPost(newPost);
    } catch (e) {
      print('Create Post Error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> likePost(String postId, String userId) async {
    await _dbService.likePost(postId, userId);
  }

  Future<void> deletePost(String postId) async {
    await _dbService.deletePost(postId);
  }
}
