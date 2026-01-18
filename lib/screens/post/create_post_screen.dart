import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/feed_provider.dart';
import '../../providers/user_provider.dart';

class CreatePostScreen extends StatefulWidget {
  final VoidCallback? onPostSuccess;
  const CreatePostScreen({super.key, this.onPostSuccess});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _captionController = TextEditingController();
  File? _mediaFile;
  bool _isVideo = false;

  Future<void> _pickMedia(bool isVideo) async {
    final picker = ImagePicker();
    final XFile? picked;
    if (isVideo) {
      picked = await picker.pickVideo(source: ImageSource.gallery);
    } else {
      picked = await picker.pickImage(source: ImageSource.gallery);
    }

    setState(() {
      _mediaFile = File(picked!.path);
      _isVideo = isVideo;
    });
  }

  void _createPost() async {
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    if (user == null) return;

    if (_captionController.text.isEmpty && _mediaFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Add caption or media')));
      return;
    }

    final provider = Provider.of<FeedProvider>(context, listen: false);

    try {
      await provider.createPost(
        userId: user.id,
        username: user.username,
        userProfileImage: user.profileImageUrl ?? '',
        caption: _captionController.text,
        mediaFile: _mediaFile,
        isVideo: _isVideo,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Posted successfully!')));
        _captionController.clear();
        setState(() {
          _mediaFile = null;
        });
        if (widget.onPostSuccess != null) {
          widget.onPostSuccess!();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<FeedProvider>(context).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: isLoading ? null : _createPost,
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child:
                  isLoading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : const Text('Post'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _captionController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "What's on your mind?",
                border: InputBorder.none,
                filled: false,
              ),
            ),
            const SizedBox(height: 16),
            if (_mediaFile != null)
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child:
                        _isVideo
                            ? Container(
                              height: 200,
                              color: Colors.black,
                              child: const Center(
                                child: Icon(
                                  Icons.play_circle,
                                  color: Colors.white,
                                  size: 50,
                                ),
                              ),
                            )
                            : Image.file(
                              _mediaFile!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _mediaFile = null),
                    icon: const Icon(Icons.close, color: Colors.red),
                    style: IconButton.styleFrom(backgroundColor: Colors.white),
                  ),
                ],
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => _pickMedia(false),
                  icon: const Icon(Icons.image),
                  label: const Text('Photo'),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () => _pickMedia(true),
                  icon: const Icon(Icons.videocam),
                  label: const Text('Video'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
