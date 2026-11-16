import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:solar_icons/solar_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_button.dart';

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

  @override
  Widget build(BuildContext context) {
    final bool isFriendsActive = !isExploreActive && selectedFriendId == null;

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          // 1. NÚT KHÁM PHÁ (ACTIVE THÌ HIỆN CHỮ, INACTIVE CHỈ HIỆN ICON) - XÚC GIÁC NẢY LÒ XO
          _TactileModeButton(
            isActive: isExploreActive,
            icon: isExploreActive ? SolarIconsBold.compass : SolarIconsOutline.compass,
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
                // NÚT BẠN BÈ (KÍCH THƯỚC VÀ KIỂU DÁNG TO BẰNG NÚT KHÁM PHÁ) - XÚC GIÁC NẢY LÒ XO
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Center(
                    child: _TactileModeButton(
                      isActive: isFriendsActive,
                      icon: isFriendsActive
                          ? SolarIconsBold.usersGroupTwoRounded
                          : SolarIconsOutline.usersGroupTwoRounded,
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

          // 3. NÚT ICON CHUYỂN ĐỔI GRID / FEED - Xúc giác nảy lò xo & viền bắt sáng
          AppIconButton(
            size: 40,
            isSelected: isGridView,
            activeColor: AppColors.primaryOlive,
            tooltip: isGridView ? 'Xem dạng Vuốt' : 'Xem dạng Lưới',
            onPressed: onGridToggle,
            icon: Icon(
              isGridView ? SolarIconsOutline.gallery : SolarIconsOutline.widget_4,
              color: isGridView ? Colors.black : Colors.white70,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

/// Nút chuyển đổi chế độ lọc (Khám phá / Bạn bè) với độ sâu xúc giác & đàn hồi lò xo
class _TactileModeButton extends StatefulWidget {
  final bool isActive;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _TactileModeButton({
    required this.isActive,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_TactileModeButton> createState() => _TactileModeButtonState();
}

class _TactileModeButtonState extends State<_TactileModeButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isActive = widget.isActive;

    final gradient = isActive
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5F821C), Color(0xFF45610F)],
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2C2C32), Color(0xFF1C1C20)],
          );

    final border = isActive
        ? Border.all(
            color: const Color(0xFF7FA32E).withValues(alpha: 0.5),
            width: 0.9,
          )
        : null;

    return AnimatedScale(
      scale: _isPressed ? 0.92 : 1.0,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOutCubic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) {
          HapticFeedback.lightImpact();
          setState(() => _isPressed = true);
        },
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeInOutCubic,
          height: 40,
          padding: EdgeInsets.symmetric(
            horizontal: isActive ? 14 : 10,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
            border: border,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                color: isActive ? Colors.black : Colors.white70,
                size: 20,
              ),
              ClipRect(
                child: AnimatedAlign(
                  alignment: Alignment.centerLeft,
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeInOutCubic,
                  widthFactor: isActive ? 1.0 : 0.0,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeInOut,
                    opacity: isActive ? 1.0 : 0.0,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(
                        widget.label,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          color: isActive ? Colors.black : Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
