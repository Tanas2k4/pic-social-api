import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solar_icons/solar_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/friend_badge_avatar.dart';
import '../../../../core/widgets/friendship_icons.dart';
import '../../../../core/widgets/viewfinder_background.dart';
import '../../data/models/friend_user_model.dart';
import '../../data/repositories/friends_repository.dart';

class FriendsScreen extends StatefulWidget {
  final VoidCallback? onBackTap;

  const FriendsScreen({super.key, this.onBackTap});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final FriendsRepository _repository = FriendsRepository();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String _searchQuery = '';
  bool _isRequestsExpanded = false; // Mở rộng xem hơn 4 lời mời nếu có

  List<FriendUserModel> _incomingRequests = [];
  List<FriendUserModel> _following = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final requests = await _repository.getIncomingRequests();
      final following = await _repository.getFollowing('current-user');

      if (mounted) {
        setState(() {
          _incomingRequests = requests;
          _following = following;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Lọc nội bộ theo từ khóa
  List<FriendUserModel> _filter(List<FriendUserModel> list) {
    if (_searchQuery.trim().isEmpty) return list;
    final q = _searchQuery.toLowerCase().trim();
    return list.where((u) {
      return u.displayName.toLowerCase().contains(q) ||
          u.userName.toLowerCase().contains(q);
    }).toList();
  }

  // Chấp nhận lời mời
  void _acceptRequest(FriendUserModel user) {
    HapticFeedback.lightImpact();
    setState(() {
      _incomingRequests.removeWhere((u) => u.id == user.id);
      final newFriend = user.copyWith(
        isFollowing: true,
        isFollower: true,
        isFriendRequest: false,
      );
      _following.insert(0, newFriend);
    });

    AppToast.showSuccess(
      context,
      'Đã chấp nhận lời mời từ ${user.displayName}',
    );
  }

  // Gỡ lời mời
  void _declineRequest(FriendUserModel user) {
    HapticFeedback.lightImpact();
    setState(() {
      _incomingRequests.removeWhere((u) => u.id == user.id);
    });

    AppToast.showInfo(
      context,
      'Đã gỡ lời mời của ${user.displayName}',
    );
  }

  // Hủy theo dõi
  void _unfollowUser(FriendUserModel user) {
    HapticFeedback.lightImpact();
    setState(() {
      _following.removeWhere((u) => u.id == user.id);
    });
    _repository.unfollowUser(user.id);
    AppToast.showInfo(context, 'Đã hủy theo dõi ${user.displayName}');
  }

  @override
  Widget build(BuildContext context) {
    final filteredRequests = _filter(_incomingRequests);
    final filteredFollowing = _filter(_following);

    // Giới hạn hiển thị 4 lời mời nếu không bấm xem thêm
    final visibleRequests = _isRequestsExpanded
        ? filteredRequests
        : filteredRequests.take(4).toList();
    final hasMoreRequests = filteredRequests.length > 4;

    return Scaffold(
      backgroundColor: const Color(0xFF050507),
      body: ViewfinderBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
          children: [
            // 1. HEADER ĐƠN GIẢN (KHÔNG CHỨA BADGE / LABEL PHỨC TẠP)
            _buildSimpleHeader(),

            // 2. Ô TÌM KIẾM NỘI BỘ (KHÔNG DÙNG BORDER)
            _buildSearchBar(),

            const SizedBox(height: 8),

            // 3. DANH SÁCH 2 PHẦN: LỜI MỜI (TRÊN) VÀ BẠN BÈ / ĐANG THEO DÕI (DƯỚI)
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryYellow,
                        strokeWidth: 2,
                      ),
                    )
                  : RefreshIndicator(
                      color: AppColors.primaryYellow,
                      backgroundColor: AppColors.surfaceDark,
                      onRefresh: _loadData,
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        slivers: [
                          // --- PHẦN TRÊN: LỜI MỜI ĐANG NHẬN ---
                          if (filteredRequests.isNotEmpty) ...[
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(18, 12, 18, 6),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Lời mời kết bạn',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      '${filteredRequests.length}',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.4),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Danh sách tối đa 4 lời mời
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final item = visibleRequests[index];
                                  return _buildRequestTile(item);
                                },
                                childCount: visibleRequests.length,
                              ),
                            ),

                            // Nút xem thêm / thu gọn nếu có > 4 lời mời
                            if (hasMoreRequests)
                              SliverToBoxAdapter(
                                child: Center(
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.primaryYellow,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isRequestsExpanded = !_isRequestsExpanded;
                                      });
                                    },
                                    child: Text(
                                      _isRequestsExpanded
                                          ? 'Thu gọn'
                                          : 'Xem thêm (${filteredRequests.length - 4})',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                            // Dòng ngăn cách nhẹ không viền
                            SliverToBoxAdapter(
                              child: Container(
                                height: 1,
                                margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                            ),
                          ],

                          // --- TIÊU ĐỀ PHẦN DƯỚI: BẠN BÈ ---
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(18, 6, 18, 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Bạn bè',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '${filteredFollowing.length}',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.4),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // --- PHẦN DƯỚI: DANH SÁCH BẠN BÈ & ĐANG THEO DÕI (LAZY LOAD TRÍCH LƯỚT TỚI ĐÂU RENDER TỚI ĐÓ) ---
                          if (filteredFollowing.isEmpty)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                                child: Center(
                                  child: Text(
                                    _searchQuery.isNotEmpty
                                        ? 'Không tìm thấy kết quả phù hợp'
                                        : 'Chưa có bạn bè nào',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.4),
                                      fontSize: 13.5,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          else
                            SliverList.builder(
                              itemCount: filteredFollowing.length,
                              itemBuilder: (context, index) {
                                final item = filteredFollowing[index];
                                return _buildFriendTile(item);
                              },
                            ),

                          const SliverToBoxAdapter(
                            child: SizedBox(height: 95), // Chừa chỗ cho dock đáy
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  // --- HEADER ĐƠN GIẢN (ĐÃ BỎ NÚT MŨI TÊN THOÁT) ---
  Widget _buildSimpleHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(18, 12, 18, 8),
      child: Row(
        children: [
          Text(
            'Bạn bè',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  // --- Ô TÌM KIẾM NỘI BỘ (KHÔNG BORDER) ---
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF18181A),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              SolarIconsOutline.magnifier,
              color: Colors.white.withValues(alpha: 0.4),
              size: 19,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white, fontSize: 13.5),
                cursorColor: AppColors.primaryYellow,
                decoration: InputDecoration(
                  hintText: 'Tìm theo tên hoặc @username',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
                child: Icon(
                  SolarIconsOutline.closeCircle,
                  color: Colors.white.withValues(alpha: 0.4),
                  size: 17,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- TILE LỜI MỜI ĐANG NHẬN (PHẦN TRÊN) ---
  Widget _buildRequestTile(FriendUserModel item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF161618),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // Avatar chuẩn gốc Feed
            FriendBadgeAvatar(
              avatarUrl: item.avatarUrl,
              isFriend: false,
              radius: 20,
            ),
            const SizedBox(width: 12),

            // Tên và @username
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@${item.userName}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // 2 NÚT HÀNH ĐỘNG: BUTTON "ADD" (BỎ ICON, CHỮ ĐEN NỀN RETRO OLIVE) & NÚT ICON X DÀY
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Button "Add" (Tactile Bounce Primary Retro Olive)
                AppButton.primary(
                  size: AppButtonSize.small,
                  borderRadius: BorderRadius.circular(12),
                  onPressed: () => _acceptRequest(item),
                  text: 'Add',
                ),
                const SizedBox(width: 6),

                // 2. Nút icon X dày để từ chối / gỡ
                GestureDetector(
                  onTap: () => _declineRequest(item),
                  child: Container(
                    width: 34,
                    height: 34,
                    color: Colors.transparent,
                    child: Center(
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white.withValues(alpha: 0.65),
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- TILE BẠN BÈ & ĐANG THEO DÕI (PHẦN DƯỚI) ---
  Widget _buildFriendTile(FriendUserModel item) {
    final bool isMutual = item.isMutualFriend;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFF141416),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // Avatar chuẩn gốc Feed: Nếu là bạn bè (mutual) thì có dấu tích viền trắng nền Retro Olive
            FriendBadgeAvatar(
              avatarUrl: item.avatarUrl,
              isFriend: isMutual,
              radius: 20,
            ),
            const SizedBox(width: 12),

            // Tên và @username
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@${item.userName}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // ICON TRẠNG THÁI:
            // - Bạn bè: BỎ icon dấu tích đi (vì đã có dấu tích trên Avatar rồi)
            // - Người tôi đang theo dõi: icon người có mũi tên (chuẩn gốc Feed)
            if (!isMutual)
              GestureDetector(
                onTap: () {
                  // Nhấn vào icon để chọn hủy theo dõi
                  _showUnfollowDialog(item);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: FriendshipIcons.personWithArrow(
                    color: Colors.white54,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Hộp thoại hủy theo dõi nhẹ nhàng
  void _showUnfollowDialog(FriendUserModel item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Hủy theo dõi ${item.displayName}?',
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => Navigator.pop(ctx),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF2E2E36),
                        Color(0xFF1E1E24),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Hủy',
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AppButton.danger(
                size: AppButtonSize.small,
                borderRadius: BorderRadius.circular(12),
                onPressed: () {
                  Navigator.pop(ctx);
                  _unfollowUser(item);
                },
                text: 'Hủy theo dõi',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
