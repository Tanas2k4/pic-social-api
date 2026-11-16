import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:solar_icons/solar_icons.dart';
import '../../../../core/widgets/app_button.dart';

/// Thanh điều hướng & tác vụ đáy của màn hình Feed (Persistent Bottom Dock):
/// - Góc trái ngoài cùng: Nút Cài đặt (Settings)
/// - Cụm Dock 3 nút nổi ở giữa:
///     + Nút Thêm bạn bè (Add Friends) - không nền, sáng đèn khi ở tab Add Friends
///     + Nút ở giữa: Nút Chụp (Camera) khi ở Feed; Animate phóng to thành Icon Ngôi nhà (Home) khi ở Add Friends / Noti
///     + Nút Chuông thông báo (Bell) - không nền, sáng đèn khi ở tab Thông báo
/// - Góc phải ngoài cùng: Nút Profile dạng Avatar tròn của người dùng
class FeedBottomBar extends StatelessWidget {
  final int currentScreenIndex; // 0: Add Friends, 1: Feed, 2: Notifications
  final String? profileAvatarUrl;
  final VoidCallback onSettingsTap;
  final VoidCallback onAddFriendsTap;
  final VoidCallback onNewPostTap;
  final VoidCallback onHomeTap;
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;

  const FeedBottomBar({
    super.key,
    required this.currentScreenIndex,
    this.profileAvatarUrl,
    required this.onSettingsTap,
    required this.onAddFriendsTap,
    required this.onNewPostTap,
    required this.onHomeTap,
    required this.onNotificationTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. NÚT CÀI ĐẶT (Góc trái - Độc lập, Graphite không viền)
          AppIconButton(
            size: 44,
            icon: const Icon(SolarIconsOutline.settings, color: Colors.white, size: 21),
            tooltip: 'Cài đặt',
            onPressed: onSettingsTap,
          ),

          // 2. CỤM 3 NÚT Ở GIỮA ĐƯỢC BỌC CHUNG DẠNG FLOATING DOCK
          _CenterFloatingDock(
            currentScreenIndex: currentScreenIndex,
            onAddFriendsTap: onAddFriendsTap,
            onNewPostTap: onNewPostTap,
            onHomeTap: onHomeTap,
            onNotificationTap: onNotificationTap,
          ),

          // 3. NÚT TRANG CÁ NHÂN: DẠNG AVATAR TRÒN THAY VÌ ICON
          _ProfileAvatarButton(
            avatarUrl: profileAvatarUrl,
            onTap: onProfileTap,
          ),
        ],
      ),
    );
  }
}

/// Cụm Dock 3 nút nổi ở giữa: Thêm bạn - Nút trung tâm (Camera / Home) - Thông báo
class _CenterFloatingDock extends StatelessWidget {
  final int currentScreenIndex;
  final VoidCallback onAddFriendsTap;
  final VoidCallback onNewPostTap;
  final VoidCallback onHomeTap;
  final VoidCallback onNotificationTap;

  const _CenterFloatingDock({
    required this.currentScreenIndex,
    required this.onAddFriendsTap,
    required this.onNewPostTap,
    required this.onHomeTap,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAddFriendsActive = currentScreenIndex == 0;
    final bool isHome = currentScreenIndex != 1;
    final bool isNotificationActive = currentScreenIndex == 2;

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF222228).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.55),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // NÚT THÊM BẠN BÈ: ICON GIỮ NGUYÊN OUTLINE, SÁNG HƠN KHI ACTIVE
          _DockIconButton(
            icon: SolarIconsOutline.userPlus,
            isActive: isAddFriendsActive,
            tooltip: 'Tìm & thêm bạn bè',
            onTap: onAddFriendsTap,
          ),

          const SizedBox(width: 4),

          // NÚT TRUNG TÂM NỔI BẬT: Ở Feed thì là nút Chụp ảnh; ở Add Friends/Noti thì biến hình thành Icon Home
          _MorphingCenterButton(
            isHome: isHome,
            onTap: isHome ? onHomeTap : onNewPostTap,
          ),

          const SizedBox(width: 4),

          // NÚT THÔNG BÁO: ICON GIỮ NGUYÊN OUTLINE, SÁNG HƠN KHI ACTIVE
          _DockIconButton(
            icon: SolarIconsOutline.bell,
            isActive: isNotificationActive,
            tooltip: 'Thông báo',
            onTap: onNotificationTap,
          ),
        ],
      ),
    );
  }
}

/// Nút Icon bên trong Dock: nền trong suốt khi inactive, khi active nền graphite tối như cũ (không xài oliu), icon sáng rõ
class _DockIconButton extends StatefulWidget {
  final IconData icon;
  final bool isActive;
  final String tooltip;
  final VoidCallback onTap;

  const _DockIconButton({
    required this.icon,
    required this.isActive,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_DockIconButton> createState() => _DockIconButtonState();
}

class _DockIconButtonState extends State<_DockIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isActive = widget.isActive;

    return AnimatedScale(
      scale: _isPressed ? 0.90 : 1.0,
      duration: const Duration(milliseconds: 100),
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
        child: Tooltip(
          message: widget.tooltip,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // Lúc active: nền graphite tối bo tròn như ban đầu (tuyệt đối không xài oliu)
              gradient: isActive
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF2E2E36),
                        Color(0xFF1E1E24),
                      ],
                    )
                  : null,
              color: isActive ? null : Colors.transparent,
            ),
            child: Center(
              child: Icon(
                widget.icon,
                size: 21,
                // Icon giữ nguyên, khi active sáng rõ (100% trắng), khi inactive mờ dịu
                color: isActive
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.45),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Nút bấm trung tâm biến hình (Morphing Center Button):
/// - Khi ở Feed: Icon Camera (chụp bài mới)
/// - Khi ở Add Friends / Notification: Animate xuất hiện từ nhỏ tới lớn (scale-in) thành Icon Ngôi nhà (Home)
class _MorphingCenterButton extends StatefulWidget {
  final bool isHome;
  final VoidCallback onTap;

  const _MorphingCenterButton({
    required this.isHome,
    required this.onTap,
  });

  @override
  State<_MorphingCenterButton> createState() => _MorphingCenterButtonState();
}

class _MorphingCenterButtonState extends State<_MorphingCenterButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -6), // Nhô cao nhẹ lên trên mặt dock
      child: AnimatedScale(
        scale: _isPressed ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) {
            HapticFeedback.heavyImpact();
            setState(() => _isPressed = true);
          },
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          child: Tooltip(
            message: widget.isHome ? 'Về trang chủ Feed' : 'Đăng khoảnh khắc mới',
            child: Container(
              width: 58,
              height: 58,
              padding: const EdgeInsets.all(3.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.92),
                  width: 2.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF45610F).withValues(alpha: 0.55),
                    blurRadius: 14,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF5F821C), // Deep Retro Olive
                      Color(0xFF45610F),
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0xFF7FA32E).withValues(alpha: 0.5),
                    width: 1.0,
                  ),
                ),
                child: Center(
                  // HIỆU ỨNG BIẾN HÌNH TỪ NHỎ TỚI LỚN (SCALE POP-IN) KHI ĐỔI CAMERA <-> HOME
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutBack, // Hiệu ứng bung nở nảy đàn hồi
                        ),
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: widget.isHome
                        ? const Icon(
                            SolarIconsBold.home2,
                            key: ValueKey('btn_home'),
                            color: Colors.black, // Đen tương phản cao trên nền Oliu
                            size: 26,
                          )
                        : const Icon(
                            SolarIconsBold.camera,
                            key: ValueKey('btn_camera'),
                            color: Colors.black,
                            size: 25,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Nút Profile dạng Avatar tròn của người dùng thay vì icon đơn điệu
class _ProfileAvatarButton extends StatefulWidget {
  final String? avatarUrl;
  final VoidCallback onTap;

  const _ProfileAvatarButton({
    this.avatarUrl,
    required this.onTap,
  });

  @override
  State<_ProfileAvatarButton> createState() => _ProfileAvatarButtonState();
}

class _ProfileAvatarButtonState extends State<_ProfileAvatarButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const String defaultAvatar = 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200';
    final String url = (widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty)
        ? widget.avatarUrl!
        : defaultAvatar;

    return AnimatedScale(
      scale: _isPressed ? 0.90 : 1.0,
      duration: const Duration(milliseconds: 100),
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
        child: Tooltip(
          message: 'Trang cá nhân',
          child: Container(
            width: 44,
            height: 44,
            padding: const EdgeInsets.all(2.2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: const Color(0xFF28282E),
                  child: const Icon(SolarIconsBold.user, color: Colors.white54, size: 20),
                ),
                errorWidget: (context, url, error) => Container(
                  color: const Color(0xFF28282E),
                  child: const Icon(SolarIconsBold.user, color: Colors.white54, size: 20),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
