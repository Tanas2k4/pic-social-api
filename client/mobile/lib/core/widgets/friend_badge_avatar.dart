import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:solar_icons/solar_icons.dart';
import '../constants/app_colors.dart';

/// Widget Avatar hiển thị dấu tích bạn bè chuẩn gốc của Feed ChupChup
class FriendBadgeAvatar extends StatelessWidget {
  final String? avatarUrl;
  final bool isFriend;
  final double radius;

  const FriendBadgeAvatar({
    super.key,
    required this.avatarUrl,
    this.isFriend = false,
    this.radius = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: Colors.white.withValues(alpha: 0.12),
          backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty && avatarUrl!.startsWith('http')
              ? CachedNetworkImageProvider(avatarUrl!)
              : null,
          child: avatarUrl == null || avatarUrl!.isEmpty || !avatarUrl!.startsWith('http')
              ? Icon(SolarIconsBold.user, color: Colors.white, size: radius * 1.1)
              : null,
        ),
        // DẤU TÍCH XÁC NHẬN BẠN BÈ CHUẨN GỐC TỪ FEED (VIỀN TRẮNG 1.5, NỀN RETRO OLIVE, CHECK SIZE 10)
        if (isFriend)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                color: AppColors.primaryOlive, // Tông màu Retro Olive #6B8E23
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 10,
              ),
            ),
          ),
      ],
    );
  }
}
