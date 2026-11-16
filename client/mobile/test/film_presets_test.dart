import 'package:flutter_test/flutter_test.dart';
import 'package:chupchup/features/camera/data/film_lut_presets.dart';

void main() {
  group('FilmPresets Signature Retro Tests', () {
    test('Contains signature vintageFilm preset', () {
      final presets = FilmPresets.all;
      expect(presets.length, equals(2));

      final ids = presets.map((p) => p.id).toList();
      expect(ids, contains('vintage_film'));
      expect(ids, contains('original'));
    });

    test('vintageFilm has authentic analog specs enabled', () {
      final vintage = FilmPresets.vintageFilm;
      expect(vintage.dateStamp, equals('\'98 11 12'));
      expect(vintage.matrix.length, equals(20));
    });
  });
}
