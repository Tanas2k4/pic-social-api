class ApiEndpoints {
  ApiEndpoints._();

  // Android Emulator dùng 10.0.2.2, thiết bị thật dùng IP LAN máy tính
  static const String baseUrl = 'http://10.0.2.2:5187/api';

  // Auth
  static const String login = '$baseUrl/Auth/login';
  static const String register = '$baseUrl/Auth/register';

  // Post & Feed
  static const String feed = '$baseUrl/Post/feed';
  static const String uploadPost = '$baseUrl/Post';
  static String postById(String id) => '$baseUrl/Post/view/$id';
  static String postsByUser(String userId) => '$baseUrl/Post/$userId';

  // Interactions
  static String toggleReaction(String postId) => '$baseUrl/Reaction/$postId';
  static String comments(String postId) => '$baseUrl/Comment/$postId';

  // Profile
  static const String myProfile = '$baseUrl/Profile/me';
  static String userProfile(String userId) => '$baseUrl/Profile/$userId';
}
