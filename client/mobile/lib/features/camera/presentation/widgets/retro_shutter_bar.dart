import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solar_icons/solar_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_button.dart';

/// Cụm phím điều khiển Shutter cơ học chuẩn xác phong cách Analog
class RetroShutterBar extends StatelessWidget {
  final bool isPreviewMode;
  final int capturedCount;
  final bool isShutterPressed;
  final bool isTakingPhoto;
  final VoidCallback onPickGallery;
  final VoidCallback onShutterTap;
  final ValueChanged<bool> onShutterPressChanged;
  final VoidCallback onFlipCamera;
  final VoidCallback onBackToCamera;
  final VoidCallback onSubmitPost;

  const RetroShutterBar({
    super.key,
    required this.isPreviewMode,
    required this.capturedCount,
    required this.isShutterPressed,
    required this.isTakingPhoto,
    required this.onPickGallery,
    required this.onShutterTap,
    required this.onShutterPressChanged,
    required this.onFlipCamera,
    required this.onBackToCamera,
    required this.onSubmitPost,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 6, 24, 16),
      child: !isPreviewMode
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // NÚT CHỌN TỪ THƯ VIỆN
                AppIconButton(
                  size: 50,
                  tooltip: 'Chọn ảnh từ thư viện',
                  onPressed: onPickGallery,
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(SolarIconsOutline.gallery, color: Colors.white, size: 24),
                      if (capturedCount > 0)
                        Positioned(
                          top: -3,
                          right: -5,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryYellow,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '+${3 - capturedCount}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // NÚT SHUTTER CƠ HỌC VÀNG OLIVE RETRO
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (_) {
                    HapticFeedback.heavyImpact();
                    onShutterPressChanged(true);
                  },
                  onTapUp: (_) => onShutterPressChanged(false),
                  onTapCancel: () => onShutterPressChanged(false),
                  onTap: isTakingPhoto ? null : onShutterTap,
                  child: AnimatedScale(
                    scale: isShutterPressed ? 0.88 : 1.0,
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.easeOutCubic,
                    child: Container(
                      width: 80,
                      height: 80,
                      padding: const EdgeInsets.all(4.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.85),
                          width: 3.5,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF5F821C),
                              Color(0xFF45610F),
                            ],
                          ),
                          border: Border.all(
                            color: const Color(0xFF7FA32E).withValues(alpha: 0.5),
                            width: 1.0,
                          ),
                        ),
                        child: Center(
                          child: capturedCount == 0
                              ? const Icon(
                                  SolarIconsBold.camera,
                                  color: Colors.black,
                                  size: 30,
                                )
                              : Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      SolarIconsBold.camera,
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                    Text(
                                      '$capturedCount/3',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ),

                // NÚT ĐỔI CAMERA TRƯỚC / SAU
                AppIconButton(
                  size: 50,
                  tooltip: 'Đổi camera',
                  onPressed: onFlipCamera,
                  icon: const Icon(SolarIconsOutline.cameraRotate, color: Colors.white, size: 24),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: AppButton.outline(
                    onPressed: onBackToCamera,
                    text: 'Chụp thêm',
                    height: 52,
                    fontSize: 14.0,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: AppButton.primary(
                    onPressed: onSubmitPost,
                    text: 'Gửi khoảnh khắc ($capturedCount)',
                    icon: const Icon(SolarIconsBold.plain, size: 18, color: Colors.black),
                    height: 52,
                    fontSize: 14.0,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
              ],
            ),
    );
  }
}
