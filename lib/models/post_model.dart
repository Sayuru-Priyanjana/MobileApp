class PostModel {
  final String id;
  final String userId;
  final String username;
  final String userProfileImage; // Snapshot at creation or link to user
  final String? caption;
  final String? mediaUrl;
  final String mediaType; // 'image' or 'video' or 'none'
  final int timestamp;
  final Map<String, bool> likes; // userId: true
  final int commentCount;

  PostModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.userProfileImage,
    this.caption,
    this.mediaUrl,
    this.mediaType = 'none',
    required this.timestamp,
    this.likes = const {},
    this.commentCount = 0,
  });

  factory PostModel.fromJson(String id, Map<dynamic, dynamic> json) {
    return PostModel(
      id: id,
      userId: json['userId'] ?? '',
      username: json['username'] ?? 'Unknown',
      userProfileImage: json['userProfileImage'] ?? '',
      caption: json['caption'],
      mediaUrl: json['mediaUrl'],
      mediaType: json['mediaType'] ?? 'none',
      timestamp: json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      likes: json['likes'] != null ? Map<String, bool>.from(json['likes']) : {},
      commentCount: json['commentCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'userProfileImage': userProfileImage,
      'caption': caption,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'timestamp': timestamp,
      'likes': likes,
      'commentCount': commentCount,
    };
  }
}
