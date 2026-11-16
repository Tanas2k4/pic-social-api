import 'package:flutter_test/flutter_test.dart';
import 'package:chupchup/core/constants/app_config.dart';
import 'package:chupchup/core/constants/api_endpoints.dart';

void main() {
  group('AppConfig & ApiEndpoints Tests', () {
    test('Default baseUrl is not empty', () {
      expect(AppConfig.baseUrl, isNotEmpty);
      expect(ApiEndpoints.baseUrl, isNotEmpty);
    });

    test('Custom baseUrl setter works correctly', () {
      AppConfig.setCustomHost('192.168.1.100');
      expect(AppConfig.baseUrl, equals('http://192.168.1.100:5187/api'));
      expect(ApiEndpoints.login, equals('http://192.168.1.100:5187/api/Auth/login'));

      AppConfig.resetToDefault();
    });
  });
}
