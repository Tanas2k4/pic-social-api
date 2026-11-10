enum FriendshipStatus {
  none,        // Chưa kết bạn (hiện icon thêm bạn)
  requested,   // Đã gửi lời mời kết bạn (hiện icon đồng hồ/đang chờ)
  friends,     // Đã là bạn bè (hiện icon 2 người/đã kết bạn)
}

/// Model đại diện cho 1 bài viết trong Feed, khớp với PostResponseDto của Backend C#
class PostItemModel {
  final String postId;
  final String userId;
  final String authorUserName;
  final String? authorFullName;
  final String? authorAvatarUrl;
  final String? title;
  final DateTime createdAt;
  final String photoUrl;
  final List<String> photoUrls;
  int likeCount;
  int commentCount;
  int shareCount;
  bool isLikedByMe;
  FriendshipStatus friendshipStatus;

  PostItemModel({
    required this.postId,
    required this.userId,
    required this.authorUserName,
    this.authorFullName,
    this.authorAvatarUrl,
    this.title,
    required this.createdAt,
    required this.photoUrl,
    List<String>? photoUrls,
    required this.likeCount,
    required this.commentCount,
    this.shareCount = 0,
    this.isLikedByMe = false,
    this.friendshipStatus = FriendshipStatus.none,
  }) : photoUrls = photoUrls ?? [photoUrl];

  factory PostItemModel.fromJson(Map<String, dynamic> json) {
    String firstPhotoUrl = '';
    List<String> photos = [];
    if (json['photos'] != null && (json['photos'] as List).isNotEmpty) {
      firstPhotoUrl = json['photos'][0]['originalFileUrl'] ?? '';
      photos = (json['photos'] as List)
          .map((p) => p['originalFileUrl']?.toString() ?? '')
          .where((url) => url.isNotEmpty)
          .take(3)
          .toList();
    }
    if (photos.isEmpty && firstPhotoUrl.isNotEmpty) {
      photos = [firstPhotoUrl];
    }

    return PostItemModel(
      postId: json['postId'] ?? '',
      userId: json['userId'] ?? '',
      authorUserName: json['authorUserName'] ?? 'unknown',
      authorFullName: json['authorFullName'],
      authorAvatarUrl: json['authorAvatarUrl'],
      title: json['title'],
      createdAt: DateTime.parse(json['createdDate']),
      photoUrl: firstPhotoUrl,
      photoUrls: photos,
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      shareCount: json['shareCount'] ?? 0,
      isLikedByMe: json['isLikedByMe'] ?? false,
      friendshipStatus: json['isFriend'] == true 
          ? FriendshipStatus.friends 
          : (json['isPending'] == true ? FriendshipStatus.requested : FriendshipStatus.none),
    );
  }
}
