class FriendUserModel {
  final String id;
  final String userName;
  final String? fullName;
  final String? avatarUrl;
  final String? bio;
  final int mutualFriendsCount;
  bool isFollowing;
  bool isFollower;
  bool isFriendRequest;
  DateTime? requestTime;

  FriendUserModel({
    required this.id,
    required this.userName,
    this.fullName,
    this.avatarUrl,
    this.bio,
    this.mutualFriendsCount = 0,
    this.isFollowing = false,
    this.isFollower = false,
    this.isFriendRequest = false,
    this.requestTime,
  });

  String get displayName =>
      (fullName != null && fullName!.trim().isNotEmpty) ? fullName! : userName;

  bool get isMutualFriend => isFollowing && isFollower;

  factory FriendUserModel.fromFollowerJson(Map<String, dynamic> json) {
    return FriendUserModel(
      id: json['followerId'] ?? json['id'] ?? '',
      userName: json['followerUserName'] ?? json['userName'] ?? 'user',
      fullName: json['followerFirstName'] ?? json['firstName'],
      avatarUrl: json['followerAvatar'] ?? json['avatarUrl'],
      isFollower: true,
      isFollowing: json['isFollowing'] ?? false,
    );
  }

  factory FriendUserModel.fromFollowingJson(Map<String, dynamic> json) {
    return FriendUserModel(
      id: json['followingId'] ?? json['id'] ?? '',
      userName: json['followingUserName'] ?? json['userName'] ?? 'user',
      fullName: json['followingFirstName'] ?? json['firstName'],
      avatarUrl: json['followingAvatar'] ?? json['avatarUrl'],
      isFollowing: true,
      isFollower: json['isFollower'] ?? false,
    );
  }

  FriendUserModel copyWith({
    String? id,
    String? userName,
    String? fullName,
    String? avatarUrl,
    String? bio,
    int? mutualFriendsCount,
    bool? isFollowing,
    bool? isFollower,
    bool? isFriendRequest,
    DateTime? requestTime,
  }) {
    return FriendUserModel(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      mutualFriendsCount: mutualFriendsCount ?? this.mutualFriendsCount,
      isFollowing: isFollowing ?? this.isFollowing,
      isFollower: isFollower ?? this.isFollower,
      isFriendRequest: isFriendRequest ?? this.isFriendRequest,
      requestTime: requestTime ?? this.requestTime,
    );
  }
}
