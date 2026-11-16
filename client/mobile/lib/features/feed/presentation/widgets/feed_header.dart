import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';
import '../../../../core/widgets/app_button.dart';

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
        // 1. Nút Cài đặt (Settings) - Xúc giác nảy lò xo & viền bắt sáng
        AppIconButton(
          onPressed: onSettingsTap,
          icon: const Icon(SolarIconsOutline.settings, color: Colors.white, size: 21),
          tooltip: 'Cài đặt',
          size: 42,
        ),

        // 2. Nút Camera "Đăng bài" ở giữa - Tactile Button
        AppButton.secondary(
          onPressed: onNewPostTap,
          text: 'Đăng bài',
          icon: const Icon(SolarIconsBold.camera, color: Colors.white, size: 19),
          height: 40,
          size: AppButtonSize.medium,
          borderRadius: BorderRadius.circular(20),
        ),

        // 3. Nút Profile (Cá nhân) - Xúc giác nảy lò xo & viền bắt sáng
        AppIconButton(
          onPressed: onProfileTap,
          icon: const Icon(SolarIconsOutline.user, color: Colors.white, size: 21),
          tooltip: 'Trang cá nhân',
          size: 42,
        ),
      ],
    );
  }
}
