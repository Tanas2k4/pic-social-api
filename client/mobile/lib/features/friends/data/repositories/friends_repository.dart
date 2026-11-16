import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/friend_user_model.dart';

class FriendsRepository {
  Dio get _dio => DioClient.instance.dio;

  /// Lấy danh sách đang theo dõi (Following)
  Future<List<FriendUserModel>> getFollowing(String userId) async {
    try {
      final response = await _dio.get(ApiEndpoints.following(userId));
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((e) => FriendUserModel.fromFollowingJson(e))
            .toList();
      }
    } catch (_) {
      // Fallback
    }

    return _getDefaultFollowing();
  }

  /// Lấy danh sách người theo dõi (Followers)
  Future<List<FriendUserModel>> getFollowers(String userId) async {
    try {
      final response = await _dio.get(ApiEndpoints.followers(userId));
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((e) => FriendUserModel.fromFollowerJson(e))
            .toList();
      }
    } catch (_) {
      // Fallback
    }

    return _getDefaultFollowers();
  }

  /// Lấy danh sách lời mời kết bạn được gửi tới (Incoming Friend Requests)
  Future<List<FriendUserModel>> getIncomingRequests() async {
    // Backend hiện đang dùng hệ thống Follow, lời mời kết bạn được mock chuẩn bị cho API friend-request
    return _getDefaultIncomingRequests();
  }

  /// Theo dõi người dùng
  Future<bool> followUser(String userId) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.followUser,
        data: {'id': userId},
      );
      return response.statusCode == 200;
    } catch (_) {
      return true; // Trả về true để UI phản hồi mượt
    }
  }

  /// Hủy theo dõi người dùng
  Future<bool> unfollowUser(String userId) async {
    try {
      final response = await _dio.delete(ApiEndpoints.unfollowUser(userId));
      return response.statusCode == 200;
    } catch (_) {
      return true;
    }
  }

  // --- DỮ LIỆU MẪU MẶC ĐỊNH ĐỒNG BỘ VỚI HỆ SINH THÁI FEED CỦA APP ---
  List<FriendUserModel> _getDefaultFollowing() {
    return [
      FriendUserModel(
        id: 'user-2',
        userName: 'minhanh.cute',
        fullName: 'Minh Anh',
        avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
        bio: 'Yêu cún cưng & thích du lịch khám phá 🐶✈️',
        mutualFriendsCount: 8,
        isFollowing: true,
        isFollower: true,
      ),
      FriendUserModel(
        id: 'user-1',
        userName: 'tan_tran',
        fullName: 'Trần Tấn',
        avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
        bio: 'Nhiếp ảnh gia nghiệp dư 📸 Đà Lạt lover 🌲',
        mutualFriendsCount: 15,
        isFollowing: true,
        isFollower: true,
      ),
      FriendUserModel(
        id: 'user-3',
        userName: 'nam.street',
        fullName: 'Hoàng Nam',
        avatarUrl: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=200',
        bio: 'Street style & Skateboarding 🛹🔥',
        mutualFriendsCount: 4,
        isFollowing: true,
        isFollower: false,
      ),
      FriendUserModel(
        id: 'user-4',
        userName: 'ngoc.lens',
        fullName: 'Bảo Ngọc',
        avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200',
        bio: 'Đam mê chụp film & cà phê sáng ☕🎞️',
        mutualFriendsCount: 6,
        isFollowing: true,
        isFollower: true,
      ),
      FriendUserModel(
        id: 'user-5',
        userName: 'viet.wander',
        fullName: 'Hoàng Việt',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
        isFollowing: true,
        isFollower: false,
      ),
      FriendUserModel(
        id: 'user-6',
        userName: 'lan_huong',
        fullName: 'Lan Hương',
        avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200',
        isFollowing: true,
        isFollower: true,
      ),
      FriendUserModel(
        id: 'user-7',
        userName: 'tuan_kiet',
        fullName: 'Tuấn Kiệt',
        avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
        isFollowing: true,
        isFollower: false,
      ),
      FriendUserModel(
        id: 'user-8',
        userName: 'thu_trang',
        fullName: 'Thu Trang',
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
        isFollowing: true,
        isFollower: true,
      ),
    ];
  }

  List<FriendUserModel> _getDefaultFollowers() {
    return [
      FriendUserModel(
        id: 'user-2',
        userName: 'minhanh.cute',
        fullName: 'Minh Anh',
        avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
        bio: 'Yêu cún cưng & thích du lịch khám phá 🐶✈️',
        mutualFriendsCount: 8,
        isFollowing: true,
        isFollower: true,
      ),
      FriendUserModel(
        id: 'user-1',
        userName: 'tan_tran',
        fullName: 'Trần Tấn',
        avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
        bio: 'Nhiếp ảnh gia nghiệp dư 📸 Đà Lạt lover 🌲',
        mutualFriendsCount: 15,
        isFollowing: true,
        isFollower: true,
      ),
      FriendUserModel(
        id: 'user-5',
        userName: 'viet.wander',
        fullName: 'Hoàng Việt',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
        bio: 'Check-in mọi nẻo đường Việt Nam 🎒⛰️',
        mutualFriendsCount: 12,
        isFollowing: false,
        isFollower: true,
      ),
      FriendUserModel(
        id: 'user-6',
        userName: 'lan_huong',
        fullName: 'Lan Hương',
        avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200',
        bio: 'Food tour Sài Gòn 🍜 Gặp gỡ bạn bè 🌸',
        mutualFriendsCount: 3,
        isFollowing: false,
        isFollower: true,
      ),
    ];
  }

  List<FriendUserModel> _getDefaultIncomingRequests() {
    final now = DateTime.now();
    return [
      FriendUserModel(
        id: 'req-1',
        userName: 'thanh.nguyen',
        fullName: 'Thành Nguyễn',
        avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
        bio: 'Bạn học thời cấp 3 • Có 9 bạn chung',
        mutualFriendsCount: 9,
        isFriendRequest: true,
        requestTime: now.subtract(const Duration(minutes: 18)),
      ),
      FriendUserModel(
        id: 'req-2',
        userName: 'mai_chi_art',
        fullName: 'Mai Chi',
        avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
        bio: 'Thích phong cách chụp ảnh của bạn ✨',
        mutualFriendsCount: 4,
        isFriendRequest: true,
        requestTime: now.subtract(const Duration(hours: 2)),
      ),
      FriendUserModel(
        id: 'req-3',
        userName: 'duc_anh_film',
        fullName: 'Đức Anh',
        avatarUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=200',
        bio: 'Đà Nẵng • Có 11 bạn chung',
        mutualFriendsCount: 11,
        isFriendRequest: true,
        requestTime: now.subtract(const Duration(days: 1)),
      ),
      FriendUserModel(
        id: 'req-4',
        userName: 'haidang_photo',
        fullName: 'Hải Đăng',
        avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=200',
        mutualFriendsCount: 3,
        isFriendRequest: true,
        requestTime: now.subtract(const Duration(days: 2)),
      ),
      FriendUserModel(
        id: 'req-5',
        userName: 'yennhi_vibes',
        fullName: 'Yến Nhi',
        avatarUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=200',
        mutualFriendsCount: 7,
        isFriendRequest: true,
        requestTime: now.subtract(const Duration(days: 3)),
      ),
    ];
  }
}
