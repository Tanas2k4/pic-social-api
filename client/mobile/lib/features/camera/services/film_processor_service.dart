import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../data/film_lut_presets.dart';
import '../presentation/widgets/digital_led_date_stamp.dart';

/// Engine xử lý ảnh Film chuyên nghiệp cho PicSocial
/// Áp dụng nguyên tắc Pipeline Parity: Đảm bảo ảnh lưu ra đĩa (Full Res)
/// có cùng hiệu ứng màu sắc quang học và date stamp như kính ngắm Live Preview.
class FilmProcessorService {
  FilmProcessorService._();

  static final FilmProcessorService instance = FilmProcessorService._();

  /// Nướng (bake) toàn bộ hiệu ứng của cuộn Film vào file ảnh
  /// Trả về đường dẫn file ảnh mới đã xử lý hoàn tất
  Future<String> bakeFilmPreset({
    required String sourcePath,
    required FilmPreset preset,
    String? customDateStamp,
  }) async {
    // Nếu là ảnh gốc và không có date stamp thì giữ nguyên file
    if (preset.id == 'original' && (customDateStamp == null || customDateStamp.isEmpty)) {
      return sourcePath;
    }

    try {
      final file = File(sourcePath);
      if (!await file.exists()) {
        return sourcePath;
      }

      final Uint8List rawBytes = await file.readAsBytes();
      final ui.Codec codec = await ui.instantiateImageCodec(rawBytes);
      final ui.FrameInfo frame = await codec.getNextFrame();
      final ui.Image rawImage = frame.image;

      final double width = rawImage.width.toDouble();
      final double height = rawImage.height.toDouble();

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // 1. Áp bộ lọc Color Grading quang học trực tiếp lên pixel ảnh
      final imagePaint = Paint()
        ..colorFilter = ColorFilter.matrix(preset.matrix)
        ..filterQuality = FilterQuality.high;
      canvas.drawImage(rawImage, Offset.zero, imagePaint);

      // 2. In dấu ngày Quartz Date cơ học thập niên 90 ('98 11 12) vào góc phải dưới
      final String? dateText = customDateStamp ?? preset.dateStamp;
      if (dateText != null && dateText.isNotEmpty) {
        _renderDateStamp(canvas, width, height, dateText);
      }

      // Kết thúc ghi và xuất ra ảnh phân giải cao
      final ui.Picture picture = recorder.endRecording();
      final ui.Image bakedImage = await picture.toImage(rawImage.width, rawImage.height);
      final ByteData? byteData = await bakedImage.toByteData(format: ui.ImageByteFormat.png);

      rawImage.dispose();
      bakedImage.dispose();

      if (byteData == null) {
        return sourcePath;
      }

      // Lưu ra thư mục tạm của ứng dụng
      String tempPath;
      try {
        final tempDir = await getTemporaryDirectory();
        tempPath = tempDir.path;
      } catch (_) {
        tempPath = Directory.systemTemp.path;
      }
      final String fileName = 'film_${DateTime.now().millisecondsSinceEpoch}_${preset.id}.png';
      final String outputPath = '$tempPath/$fileName';
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(byteData.buffer.asUint8List(), flush: true);

      return outputPath;
    } catch (e) {
      debugPrint('Lỗi xử lý ảnh Film: $e');
      return sourcePath;
    }
  }

  /// In dấu ngày Quartz Date màu cam thập niên 90 vào góc dưới bên phải
  void _renderDateStamp(Canvas canvas, double width, double height, String text) {
    // Tự động scale kích thước theo độ phân giải ảnh để dấu ngày luôn sắc nét
    final double scale = (width / 390.0).clamp(1.0, 4.5);
    final double totalStampWidth = DigitalLedPainter.calculateTotalWidth(
      text: text,
      digitWidth: 7.0,
    ) * scale;
    final double stampHeight = 12.0 * scale;

    final double marginX = 18.0 * scale;
    final double marginY = 20.0 * scale;

    final Offset offset = Offset(
      width - totalStampWidth - marginX,
      height - stampHeight - marginY,
    );

    // Vẽ số LED 7 đoạn màu cam cơ học
    DigitalLedPainter.drawStamp(
      canvas,
      text: text,
      offset: offset,
      scale: scale,
      activeColor: const Color(0xFFFF921E),
      ghostColor: const Color(0x1A6A3200),
    );
  }
}
