import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';

/// Bộ Icon quan hệ bạn bè chuẩn Solar Icons
class FriendshipIcons {
  FriendshipIcons._();

  /// Icon người có mũi tên / đang theo dõi (Solar Icons)
  static Widget personWithArrow({Color color = Colors.white, double size = 20}) {
    return Icon(SolarIconsOutline.userPlusRounded, color: color, size: size);
  }

  /// Icon người có dấu tích (Bạn bè / Đã kết nối)
  static Widget personWithCheck({Color color = Colors.white, double size = 20}) {
    return Icon(SolarIconsOutline.userCheckRounded, color: color, size: size);
  }

  /// Icon người có dấu X (Gỡ / Hủy quan hệ)
  static Widget personWithRemove({Color color = Colors.white, double size = 20}) {
    return Icon(SolarIconsOutline.userCrossRounded, color: color, size: size);
  }
}
