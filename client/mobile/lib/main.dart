import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo ngôn ngữ tiếng Việt cho timeago
  timeago.setLocaleMessages('vi', timeago.ViMessages());

  // Trong suốt thanh trạng thái hệ thống
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const ChupChupApp());
}
