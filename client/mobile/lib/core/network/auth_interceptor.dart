import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';

/// Interceptor tự động đính kèm JWT Bearer Token vào header
/// và xử lý khi gặp lỗi 401 Unauthorized (hết hạn token)
class AuthInterceptor extends Interceptor {
  final VoidCallback? onUnauthorized;

  AuthInterceptor({this.onUnauthorized});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Nếu chưa có Authorization header, lấy token từ StorageService
    if (!options.headers.containsKey('Authorization')) {
      final token = await StorageService.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      if (kDebugMode) {
        debugPrint('[AuthInterceptor] 401 Unauthorized phát hiện: Token hết hạn hoặc không hợp lệ.');
      }
      // Xóa token đã hết hạn
      await StorageService.clearToken();

      // Gọi callback để App Router hoặc UI điều hướng người dùng về màn hình đăng nhập
      onUnauthorized?.call();
    }
    handler.next(err);
  }
}
