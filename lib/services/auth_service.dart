import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../config/constants.dart';

class AuthService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();



  Future<UserModel?> login(String username, String password) async {
  

    try {
      String safeUsername = username.toLowerCase();
      final usernameSnapshot =
          await _db.child('usernames').child(safeUsername).get();
      if (usernameSnapshot.exists && usernameSnapshot.value != null) {
        String userId = usernameSnapshot.value.toString();

      
        final userSnapshot = await _db.child('users').child(userId).get();
        if (userSnapshot.exists) {
          final data = userSnapshot.value as Map;
          if (data['password'] == password) {
            // Success
            final user = UserModel.fromJson(data);
            await _saveUserLocally(user);
            return user;
          }
        }
      }
    } catch (e) {
      print('Login Error: $e');
    }
    return null;
  }

  Future<UserModel?> register(
    String username,
    String email,
    String password, {
    String? bio,
    String? profileImageUrl,
  }) async {
    try {
      String safeUsername = username.toLowerCase();
      // Check if username exists
      final usernameSnapshot =
          await _db.child('usernames').child(safeUsername).get();
      if (usernameSnapshot.exists) {
        throw Exception('Username already taken');
      }

      String userId = const Uuid().v4();

      final newUser = UserModel(
        id: userId,
        username: username, // Keep display name as original
        email: email,
        bio: bio,
        profileImageUrl: profileImageUrl,
      );

      
      Map<String, dynamic> userData = newUser.toJson();
      userData['password'] =
          password; 
      userData['username_key'] = safeUsername;

      await _db.child('users').child(userId).set(userData);
      await _db.child('usernames').child(safeUsername).set(userId);

      await _saveUserLocally(newUser);

      return newUser;
    } catch (e) {
      print('Registration Error: $e');
      rethrow;
    }
  }

  Future<void> _saveUserLocally(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefUserKey, jsonEncode(user.toJson()));
  }

  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString(AppConstants.prefUserKey);
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.prefUserKey);
  }
}
