import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../services/cloudinary_service.dart';
import '../../providers/user_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _bioController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _bioController.text = widget.user['bio'] ?? '';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      String? imageUrl = widget.user['profileImageUrl'];

      // Upload image if changed
      if (_imageFile != null) {
        final cloudinary = CloudinaryService();
        imageUrl = await cloudinary.uploadMedia(_imageFile!);
      }

      final updates = <String, dynamic>{
        'bio': _bioController.text.trim(),
        if (imageUrl != null) 'profileImageUrl': imageUrl,
      };

      final db = FirebaseDatabase.instance.ref();
      await db.child('users').child(widget.user['id']).update(updates);

      // Refresh local user data
      if (mounted) {
        await Provider.of<UserProvider>(context, listen: false).loadUser();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    _imageFile != null
                        ? FileImage(_imageFile!)
                        : (widget.user['profileImageUrl'] != null &&
                                    widget.user['profileImageUrl'].isNotEmpty
                                ? NetworkImage(widget.user['profileImageUrl'])
                                : null)
                            as ImageProvider?,
                child:
                    _imageFile == null &&
                            (widget.user['profileImageUrl'] == null ||
                                widget.user['profileImageUrl'].isEmpty)
                        ? const Icon(Icons.add_a_photo, size: 30)
                        : null,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Change Profile Photo'),
            const SizedBox(height: 32),
            CustomTextField(
              controller: _bioController,
              label: 'Bio',
              maxLines: 4,
            ),
            const SizedBox(height: 32),
            CustomButton(
              onPressed: _isLoading ? null : _saveProfile,
              text: 'Save Changes',
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
