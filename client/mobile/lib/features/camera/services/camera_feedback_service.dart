import 'package:flutter/services.dart';

/// Dịch vụ phản hồi xúc giác (Haptic) và âm thanh cơ học cho máy ảnh Film
class CameraFeedbackService {
  CameraFeedbackService._();

  /// Tiếng bấm màn trập (Shutter Click) & độ rung nặng giả lập gương lật cơ học
  static Future<void> shutterClick() async {
    // Rung phản hồi cơ học
    await HapticFeedback.heavyImpact();
    // Tiếng click hệ thống
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

  /// Tiếng xoay vòng chuyển cuộn film (Film dial / roll switch)
  static Future<void> dialTick() async {
    await HapticFeedback.selectionClick();
  }

  /// Chuyển đổi công tắc gạt (Flash, Zoom, Flip camera)
  static Future<void> toggleSwitch() async {
    await HapticFeedback.mediumImpact();
  }

  /// Giả lập tiếng mô tơ lên phim (Film Winding / Advance) sau khi chụp
  static Future<void> filmWinding() async {
    for (int i = 0; i < 3; i++) {
      await Future.delayed(const Duration(milliseconds: 60));
      await HapticFeedback.lightImpact();
    }
  }
}
