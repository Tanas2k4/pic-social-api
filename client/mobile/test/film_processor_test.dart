import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chupchup/features/camera/data/film_lut_presets.dart';
import 'package:chupchup/features/camera/services/film_processor_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late File sampleImageFile;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('film_test_');

    // Tạo một ảnh mẫu 200x200 pixel để test
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 200, 200),
      Paint()..color = const Color(0xFF336699),
    );
    final picture = recorder.endRecording();
    final img = await picture.toImage(200, 200);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    sampleImageFile = File('${tempDir.path}/sample.png');
    await sampleImageFile.writeAsBytes(byteData!.buffer.asUint8List());
  });

  tearDownAll(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('FilmProcessorService Tests', () {
    test('Original preset with no date stamp returns original path', () async {
      final result = await FilmProcessorService.instance.bakeFilmPreset(
        sourcePath: sampleImageFile.path,
        preset: FilmPresets.original,
      );
      expect(result, equals(sampleImageFile.path));
    });

    test('Baking Vintage Film preset produces a valid new image file', () async {
      final result = await FilmProcessorService.instance.bakeFilmPreset(
        sourcePath: sampleImageFile.path,
        preset: FilmPresets.vintageFilm,
      );

      expect(result, isNot(equals(sampleImageFile.path)));
      final outputFile = File(result);
      expect(await outputFile.exists(), isTrue);

      final bytes = await outputFile.readAsBytes();
      expect(bytes.length, greaterThan(100)); // Kiểm tra ảnh hợp lệ

      // Xóa file test sau khi xong
      await outputFile.delete();
    });
  });
}
