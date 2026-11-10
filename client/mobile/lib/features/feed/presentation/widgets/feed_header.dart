import 'package:flutter/material.dart';

class FeedHeader extends StatelessWidget {
  final VoidCallback onSettingsTap;
  final VoidCallback onNewPostTap;
  final VoidCallback onProfileTap;

  const FeedHeader({
    super.key,
    required this.onSettingsTap,
    required this.onNewPostTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 1. Nút Cài đặt (Settings) - Đổi từ Nút Bạn bè
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 22),
            onPressed: onSettingsTap,
          ),
        ),

        // 2. Nút Camera "New Post"
        GestureDetector(
          onTap: onNewPostTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.88),
                width: 2.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.10),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                SizedBox(width: 6),
                Text(
                  'Đăng bài',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 3. Nút Profile (Cá nhân)
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 22),
            onPressed: onProfileTap,
          ),
        ),
      ],
    );
  }
}
