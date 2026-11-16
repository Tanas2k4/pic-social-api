import 'app_config.dart';

class ApiEndpoints {
  ApiEndpoints._();

  /// Base API URL lấy động từ AppConfig
  static String get baseUrl => AppConfig.baseUrl;

  // --- Auth ---
  static String get login => '$baseUrl/Auth/login';
  static String get register => '$baseUrl/Auth/register';
  static String get sendOtp => '$baseUrl/Auth/send-otp';
  static String get verifyOtp => '$baseUrl/Auth/verify-otp';

  // --- Post & Feed ---
  static String get feed => '$baseUrl/Post/feed';
  static String get uploadPost => '$baseUrl/Post';
  static String postById(String id) => '$baseUrl/Post/view/$id';
  static String postsByUser(String userId) => '$baseUrl/Post/$userId';
  static String deletePost(String postId) => '$baseUrl/Post/$postId';
  static String updatePost(String postId) => '$baseUrl/Post/$postId';

  // --- Interactions (Reactions & Comments) ---
  static String toggleReaction(String postId) => '$baseUrl/Reaction/$postId';
  static String comments(String postId) => '$baseUrl/Comment/$postId';
  static String deleteComment(String commentId) => '$baseUrl/Comment/$commentId';
  static String updateComment(String commentId) => '$baseUrl/Comment/$commentId';

  // --- Profile ---
  static String get myProfile => '$baseUrl/Profile/me';
  static String get updateProfile => '$baseUrl/Profile';
  static String userProfile(String userId) => '$baseUrl/Profile/$userId';
  static String get updateAvatar => '$baseUrl/Avatar';
  static String get updatePresetAvatar => '$baseUrl/Avatar/preset';
  static String get avatarPresets => '$baseUrl/Avatar/presets';
  static String get updateCoverPhoto => '$baseUrl/CoverPhoto';

  // --- Follow / Friends ---
  static String isFollowing(String userId) => '$baseUrl/Follow/isFollowing/$userId';
  static String get followUser => '$baseUrl/Follow';
  static String unfollowUser(String userId) => '$baseUrl/Follow/$userId';
  static String followers(String userId) => '$baseUrl/Follow/followers/$userId';
  static String following(String userId) => '$baseUrl/Follow/following/$userId';
}
