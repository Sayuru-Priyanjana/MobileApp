class StoryModel {
  final String id;
  final String userId;
  final String username;
  final String userImage;
  final String mediaUrl;
  final String mediaType;
  final int timestamp;

  StoryModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.userImage,
    required this.mediaUrl,
    required this.mediaType,
    required this.timestamp,
  });

  factory StoryModel.fromMap(Map<dynamic, dynamic> map) {
    return StoryModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      userImage: map['userImage'] ?? '',
      mediaUrl: map['mediaUrl'] ?? '',
      mediaType: map['mediaType'] ?? 'image',
      timestamp: map['timestamp'] ?? 0,
    );
  }
}
