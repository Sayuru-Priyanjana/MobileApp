class UserModel {
  final String id;
  final String username;
  final String email;
  final String? bio;
  final String? profileImageUrl;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.bio,
    this.profileImageUrl,
  });

  factory UserModel.fromJson(Map<dynamic, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      bio: json['bio'],
      profileImageUrl: json['profileImageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
    };
  }
}
