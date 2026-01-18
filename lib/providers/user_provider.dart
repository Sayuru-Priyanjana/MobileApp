import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/cloudinary_service.dart';

class UserProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  Future<void> loadUser() async {
    _currentUser = await _authService.getCurrentUser();
    notifyListeners();
  }

  Future<String?> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    final user = await _authService.login(username, password);
    _currentUser = user;

    _isLoading = false;
    notifyListeners();

    if (user == null) {
      return 'Invalid credentials';
    }
    return null; // No error
  }

  Future<String?> register(
    String username,
    String email,
    String password,
    File? profileImage,
    String? bio,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      String? imageUrl;
      if (profileImage != null) {
        imageUrl = await _cloudinaryService.uploadMedia(profileImage);
        if (imageUrl == null) throw Exception('Image upload failed');
      }

      final user = await _authService.register(
        username,
        email,
        password,
        bio: bio,
        profileImageUrl: imageUrl,
      );
      _currentUser = user;

      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }
}
