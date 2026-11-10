import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';

class FriendFilterItem {
  final String userId;
  final String name;
  final String avatarUrl;
  final bool hasNewPost;

  const FriendFilterItem({
    required this.userId,
    required this.name,
    required this.avatarUrl,
    this.hasNewPost = true,
  });
}

class FeedFilterBar extends StatelessWidget {
  final bool isExploreActive;
  final VoidCallback onExploreToggle;
  final List<FriendFilterItem> friends;
  final String? selectedFriendId;
  final Function(String? friendId) onFriendSelected;
  final bool isGridView;
  final VoidCallback onGridToggle;

  const FeedFilterBar({
    super.key,
    required this.isExploreActive,
    required this.onExploreToggle,
    required this.friends,
    required this.selectedFriendId,
    required this.onFriendSelected,
    required this.isGridView,
    required this.onGridToggle,
  });

  // HÀM BUILD NÚT CHUNG CHO CẢ "KHÁM PHÁ" VÀ "BẠN BÈ" VỚI TRANSITION MƯỢT MÀ NHƯ BƠ (400ms EASE-IN-OUT-CUBIC)
  Widget _buildModeButton({
    required bool isActive,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
        height: 40,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 14 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryYellow
              : Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primaryYellow.withValues(alpha: 0.45),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TweenAnimationBuilder<Color?>(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
              tween: ColorTween(
                begin: isActive ? Colors.white70 : Colors.black,
                end: isActive ? Colors.black : Colors.white70,
              ),
              builder: (context, color, child) {
                return Icon(
                  icon,
                  color: color,
                  size: 20,
                );
              },
            ),
            // HIỆU ỨNG MỞ/ĐÓNG CHỮ MƯỢT MÀ BẰNG CLIPRECT + ANIMATEDALIGN + ANIMATEDOPACITY
            ClipRect(
              child: AnimatedAlign(
                alignment: Alignment.centerLeft,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
                widthFactor: isActive ? 1.0 : 0.0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeInOut,
                  opacity: isActive ? 1.0 : 0.0,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Text(
                      label,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.clip,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isFriendsActive = !isExploreActive && selectedFriendId == null;

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          // 1. NÚT KHÁM PHÁ (ACTIVE THÌ HIỆN CHỮ, INACTIVE CHỈ HIỆN ICON)
          _buildModeButton(
            isActive: isExploreActive,
            icon: Icons.explore_rounded,
            label: 'Khám phá',
            onTap: onExploreToggle,
          ),

          const SizedBox(width: 8),

          // Đường phân cách mờ
          Container(
            width: 1,
            height: 22,
            color: Colors.white24,
          ),

          const SizedBox(width: 8),

          // 2. DẢI BẠN BÈ VÀ AVATAR
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                // NÚT BẠN BÈ (KÍCH THƯỚC VÀ KIỂU DÁNG TO BẰNG NÚT KHÁM PHÁ)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Center(
                    child: _buildModeButton(
                      isActive: isFriendsActive,
                      icon: Icons.people_alt_rounded,
                      label: 'Bạn bè',
                      onTap: () => onFriendSelected(null),
                    ),
                  ),
                ),

                // Danh sách từng Avatar bạn bè có viền tròn vàng
                ...friends.map((friend) {
                  final bool isSelected = !isExploreActive && selectedFriendId == friend.userId;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () {
                        if (isSelected) {
                          onFriendSelected(null); // Bấm lại thì về xem tất cả bạn bè
                        } else {
                          onFriendSelected(friend.userId); // Lọc duy nhất bạn này
                        }
                      },
                      child: Center(
                        child: Tooltip(
                          message: friend.name,
                          child: Container(
                            padding: const EdgeInsets.all(2.2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              // Vòng vàng Neon nếu có bài mới hoặc đang được chọn
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryYellow
                                    : (friend.hasNewPost
                                        ? AppColors.primaryYellow.withValues(alpha: 0.85)
                                        : Colors.white24),
                                width: isSelected ? 2.5 : 1.8,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primaryYellow.withValues(alpha: 0.5),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: CircleAvatar(
                              radius: isSelected ? 15 : 14,
                              backgroundImage: CachedNetworkImageProvider(friend.avatarUrl),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(width: 6),

          // 3. NÚT ICON CHUYỂN ĐỔI GRID / FEED
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isGridView
                  ? AppColors.primaryYellow.withValues(alpha: 0.25)
                  : Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                isGridView ? Icons.view_agenda_rounded : Icons.grid_view_rounded,
                color: isGridView ? AppColors.primaryYellow : Colors.white,
                size: 20,
              ),
              tooltip: isGridView ? 'Xem dạng Vuốt' : 'Xem dạng Lưới',
              onPressed: onGridToggle,
            ),
          ),
        ],
      ),
    );
  }
}
