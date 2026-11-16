import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  AppConfig._();

  /// Đọc cấu hình từ cờ `--dart-define=API_BASE_URL=...` khi build/run
  /// Ví dụ: flutter run --dart-define=API_BASE_URL=http://192.168.1.15:5187/api
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// Biến runtime cho phép override URL trực tiếp (tiện cho màn hình Cài đặt mạng)
  static String? _customBaseUrl;

  /// Cổng mặc định của backend ASP.NET Core
  static const int defaultPort = 5187;

  /// Đặt URL tùy biến trong runtime (ví dụ sau khi nhập IP máy tính trong Settings)
  static void setCustomBaseUrl(String url) {
    _customBaseUrl = url.trim().endsWith('/api') ? url.trim() : '${url.trim()}/api';
  }

  /// Cập nhật Base URL nhanh bằng IP LAN máy tính (ví dụ: "192.168.1.15")
  static void setCustomHost(String host, {int port = defaultPort}) {
    _customBaseUrl = 'http://$host:$port/api';
  }

  /// Reset về URL mặc định
  static void resetToDefault() {
    _customBaseUrl = null;
  }

  /// Lấy BaseUrl hiện tại có xét thứ tự ưu tiên:
  /// 1. URL tùy biến trong runtime (nếu có)
  /// 2. Cờ `--dart-define=API_BASE_URL=...`
  /// 3. Mặc định theo nền tảng:
  ///    - Android Emulator: 10.0.2.2:5187
  ///    - iOS Simulator / Web / Desktop: localhost:5187
  static String get baseUrl {
    if (_customBaseUrl != null && _customBaseUrl!.isNotEmpty) {
      return _customBaseUrl!;
    }

    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl;
    }

    if (kIsWeb) {
      return 'http://localhost:$defaultPort/api';
    }

    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:$defaultPort/api';
      }
    } catch (_) {
      // Bắt lỗi khi không chạy trên nền tảng hỗ trợ Platform
    }

    return 'http://localhost:$defaultPort/api';
  }
}
