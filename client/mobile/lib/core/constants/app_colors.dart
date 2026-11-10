import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Màu chủ đạo PicSocial (Retro Olive #6B8E23)
  static const Color primaryOlive = Color(0xFF6B8E23);
  static const Color primaryYellow = primaryOlive; // Alias để tương thích toàn diện
  static const Color backgroundBlack = Colors.black;
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color cardOverlay = Color(0x59000000); // 35% opacity black

  // Màu chữ & icon
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xB3FFFFFF); // 70% opacity white
  static const Color textMuted = Color(0x66FFFFFF); // 40% opacity white

  // Màu tương tác
  static const Color heartRed = Color(0xFFFF2D55);
}
