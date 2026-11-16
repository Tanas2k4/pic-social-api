import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_icons/solar_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../data/models/user_profile_model.dart';

enum ProfileActiveTab {
  floatingCanvas,
  wavyTimeline,
}

class CompactProfileHeader extends StatelessWidget {
  final UserProfileModel profile;
  final int postCount;
  final ProfileActiveTab currentTab;
  final ValueChanged<ProfileActiveTab> onTabChanged;
  final VoidCallback? onBackTap;

  const CompactProfileHeader({
    super.key,
    required this.profile,
    required this.postCount,
    required this.currentTab,
    required this.onTabChanged,
    this.onBackTap,
  });

  Widget _buildModeTabButton({
    required bool isActive,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return _TactileProfileTabButton(
      isActive: isActive,
      icon: icon,
      label: label,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dải gradient track chuẩn 1:1 như Header của bảng Feed
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0.92),
            Colors.black.withValues(alpha: 0.65),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HÀNG ĐẦU: Nút Back tròn giống FeedHeader + Avatar + Tên & Username & Location
            Row(
              children: [
                if (onBackTap != null) ...[
                  AppIconButton(
                    size: 38,
                    onPressed: onBackTap,
                    tooltip: 'Quay lại',
                    icon: const Icon(
                      SolarIconsOutline.arrowLeft,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: profile.avatarUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => _defaultAvatar(),
                          )
                        : _defaultAvatar(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.displayName,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Text(
                            '@${profile.userName}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.65),
                              fontSize: 12,
                              shadows: const [
                                Shadow(color: Colors.black, blurRadius: 4),
                              ],
                            ),
                          ),
                          if (profile.location != null && profile.location!.isNotEmpty) ...[
                            Text(
                              ' • ',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 12,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                '📍 ${profile.location}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  fontSize: 11,
                                  shadows: const [
                                    Shadow(color: Colors.black, blurRadius: 4),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // 2. TIỂU SỬ (BIO) XUYÊN THẤU NHÌN RÕ SAO PHÍA SAU
            if (profile.bio != null && profile.bio!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  profile.bio!,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                    height: 1.35,
                    shadows: const [
                      Shadow(color: Colors.black, blurRadius: 6),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],

            const SizedBox(height: 10),

            // 3. HÀNG DƯỚI BIO: THỐNG KÊ + 2 TABS
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      _buildStatItem('Bài viết', postCount),
                      _buildStatDivider(),
                      _buildStatItem(
                        'Followers',
                        profile.followersCount,
                        onTap: () => context.push('/friends'),
                      ),
                      _buildStatDivider(),
                      _buildStatItem(
                        'Following',
                        profile.followingCount,
                        onTap: () => context.push('/friends'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // 2 TAB PHONG CÁCH KHÁM PHÁ / BẠN BÈ
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildModeTabButton(
                      isActive: currentTab == ProfileActiveTab.floatingCanvas,
                      icon: currentTab == ProfileActiveTab.floatingCanvas
                          ? SolarIconsBold.planet
                          : SolarIconsOutline.planet,
                      label: 'Vũ trụ',
                      onTap: () => onTabChanged(ProfileActiveTab.floatingCanvas),
                    ),
                    const SizedBox(width: 6),
                    _buildModeTabButton(
                      isActive: currentTab == ProfileActiveTab.wavyTimeline,
                      icon: currentTab == ProfileActiveTab.wavyTimeline
                          ? SolarIconsBold.routing
                          : SolarIconsOutline.routing,
                      label: 'Roadmap',
                      onTap: () => onTabChanged(ProfileActiveTab.wavyTimeline),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count, {VoidCallback? onTap}) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black, blurRadius: 4)],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 10,
            shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
          ),
        ),
      ],
    );

    if (onTap != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 18,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.white.withValues(alpha: 0.15),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      color: AppColors.surfaceDark,
      child: const Icon(
        SolarIconsBold.user,
        size: 22,
        color: AppColors.primaryOlive,
      ),
    );
  }
}

class _TactileProfileTabButton extends StatefulWidget {
  final bool isActive;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _TactileProfileTabButton({
    required this.isActive,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_TactileProfileTabButton> createState() => _TactileProfileTabButtonState();
}

class _TactileProfileTabButtonState extends State<_TactileProfileTabButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isActive = widget.isActive;

    final gradient = isActive
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF5F821C), // Deep Retro Olive
              Color(0xFF45610F),
            ],
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF28282E),
              Color(0xFF18181C),
            ],
          );

    // Không có màu oliu thì BỎ BORDER theo yêu cầu người dùng
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
          height: 36,
          padding: EdgeInsets.symmetric(
            horizontal: isActive ? 14 : 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(18),
            border: border,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFF45610F).withValues(alpha: 0.4),
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
              Icon(
                widget.icon,
                size: 18,
                color: isActive ? Colors.black : Colors.white70,
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
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
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
      ),
    );
  }
}
