import 'package:flutter_test/flutter_test.dart';
import 'package:chupchup/core/constants/default_avatars.dart';

void main() {
  group('DiceBear Default Avatars Tests', () {
    test('Contains more than 10 curated avatars (16 presets)', () {
      expect(DefaultAvatars.items.length, greaterThanOrEqualTo(12));
      expect(DefaultAvatars.items.length, equals(16));
    });

    test('Strict constraint: No funemoji style anywhere in curated list', () {
      for (final item in DefaultAvatars.items) {
        expect(
          item.style.toLowerCase(),
          isNot(contains('funemoji')),
          reason: 'Avatar ${item.name} must not use funemoji',
        );
        expect(
          item.url.toLowerCase(),
          isNot(contains('funemoji')),
          reason: 'Avatar URL ${item.url} must not contain funemoji',
        );
      }
    });

    test('All avatars use high quality PNG DiceBear endpoints', () {
      for (final item in DefaultAvatars.items) {
        expect(item.url, startsWith('https://api.dicebear.com/9.x/'));
        expect(item.url, contains('/png?seed='));
        expect(item.id, isNotEmpty);
        expect(item.name, isNotEmpty);
        expect(item.category, isNotEmpty);
      }
    });

    test('getByUsername returns deterministic avatar URLs', () {
      final url1 = DefaultAvatars.getByUsername('user_alice');
      final url2 = DefaultAvatars.getByUsername('user_alice');
      final url3 = DefaultAvatars.getByUsername('user_bob');

      expect(url1, equals(url2));
      expect(url1, startsWith('https://api.dicebear.com/9.x/'));
      expect(url1, isNot(contains('funemoji')));
      expect(url3, isNot(contains('funemoji')));
    });

    test('All items have unique IDs', () {
      final ids = DefaultAvatars.items.map((i) => i.id).toSet();
      expect(ids.length, equals(DefaultAvatars.items.length));
    });
  });
}
