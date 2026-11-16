class UserProfileModel {
  final String userName;
  final String? firstName;
  final String? bio;
  final String? avatarUrl;
  final String? coverPhotoUrl;
  final String? location;
  final int followersCount;
  final int followingCount;

  const UserProfileModel({
    required this.userName,
    this.firstName,
    this.bio,
    this.avatarUrl,
    this.coverPhotoUrl,
    this.location,
    this.followersCount = 0,
    this.followingCount = 0,
  });

  String get displayName => firstName?.isNotEmpty == true ? firstName! : userName;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      userName: json['userName'] ?? 'user',
      firstName: json['firstName'],
      bio: json['bio'],
      avatarUrl: json['avatarUrl'],
      coverPhotoUrl: json['coverPhotoUrl'],
      location: json['location'],
      followersCount: json['followersCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'firstName': firstName,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'coverPhotoUrl': coverPhotoUrl,
      'location': location,
      'followersCount': followersCount,
      'followingCount': followingCount,
    };
  }

  UserProfileModel copyWith({
    String? userName,
    String? firstName,
    String? bio,
    String? avatarUrl,
    String? coverPhotoUrl,
    String? location,
    int? followersCount,
    int? followingCount,
  }) {
    return UserProfileModel(
      userName: userName ?? this.userName,
      firstName: firstName ?? this.firstName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverPhotoUrl: coverPhotoUrl ?? this.coverPhotoUrl,
      location: location ?? this.location,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
    );
  }
}
