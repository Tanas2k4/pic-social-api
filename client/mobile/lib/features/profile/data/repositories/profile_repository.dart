import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../feed/data/models/post_item_model.dart';
import '../models/user_profile_model.dart';

class ProfileRepository {
  Dio get _dio => DioClient.instance.dio;

  Future<bool> updateAvatarWithPreset(String avatarUrl) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.updatePresetAvatar,
        data: {'avatarUrl': avatarUrl},
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<UserProfileModel> getMyProfile() async {
    try {
      final response = await _dio.get(ApiEndpoints.myProfile);
      if (response.statusCode == 200 && response.data != null) {
        return UserProfileModel.fromJson(response.data);
      }
    } catch (_) {
      // Fallback khi offline hoặc demo
    }

    // Default Mock Profile phản ánh đúng style PicSocial
    return const UserProfileModel(
      userName: 'quynhanh_film',
      firstName: 'Quỳnh Anh',
      bio: 'Thích chụp phim 35mm & gom nhặt khoảnh khắc 🌿✨',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
      location: 'Đà Lạt, VN',
      followersCount: 384,
      followingCount: 192,
    );
  }

  Future<List<PostItemModel>> getUserPosts(String userId) async {
    try {
      final response = await _dio.get(ApiEndpoints.postsByUser(userId));

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((json) => PostItemModel.fromJson(json))
            .toList();
      }
    } catch (_) {
      // Fallback
    }

    // Default Mock Photos với nhiều mốc thời gian để test timeline xòe tiền và không gian lơ lửng
    final now = DateTime.now();
    return [
      PostItemModel(
        postId: 'p1',
        userId: userId,
        authorUserName: 'quynhanh_film',
        authorFullName: 'Quỳnh Anh',
        authorAvatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
        title: 'Cà phê sáng sương sớm ở dốc Đa Quý',
        createdAt: now.subtract(const Duration(hours: 4)),
        photoUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=600',
        photoUrls: [
          'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=600',
          'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=600',
          'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=600',
        ],
        likeCount: 42,
        commentCount: 5,
      ),
      PostItemModel(
        postId: 'p2',
        userId: userId,
        authorUserName: 'quynhanh_film',
        authorFullName: 'Quỳnh Anh',
        title: 'Hoàng hôn bên đồi thông',
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
        photoUrl: 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=600',
        likeCount: 68,
        commentCount: 9,
      ),
      PostItemModel(
        postId: 'p3',
        userId: userId,
        authorUserName: 'quynhanh_film',
        authorFullName: 'Quỳnh Anh',
        title: 'Lá phong chớm đỏ',
        createdAt: now.subtract(const Duration(days: 3)),
        photoUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=600',
        photoUrls: [
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=600',
          'https://images.unsplash.com/photo-1519046904884-53103b34b206?w=600',
          'https://images.unsplash.com/photo-1473496169904-658ba7c44d8a?w=600',
          'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=600',
        ],
        likeCount: 115,
        commentCount: 14,
      ),
      PostItemModel(
        postId: 'p4',
        userId: userId,
        authorUserName: 'quynhanh_film',
        authorFullName: 'Quỳnh Anh',
        title: 'Góc bếp nhỏ thơm mùi bánh mì',
        createdAt: now.subtract(const Duration(days: 5)),
        photoUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600',
        likeCount: 31,
        commentCount: 3,
      ),
      PostItemModel(
        postId: 'p5',
        userId: userId,
        authorUserName: 'quynhanh_film',
        authorFullName: 'Quỳnh Anh',
        title: 'Những bông cúc dại ven đường',
        createdAt: now.subtract(const Duration(days: 7)),
        photoUrl: 'https://images.unsplash.com/photo-1465146344425-f00d5f5c8f07?w=600',
        photoUrls: [
          'https://images.unsplash.com/photo-1465146344425-f00d5f5c8f07?w=600',
          'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=600',
        ],
        likeCount: 88,
        commentCount: 7,
      ),
    ];
  }
}
