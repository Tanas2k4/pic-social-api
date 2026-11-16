class DefaultAvatarItem {
  final String id;
  final String name;
  final String category;
  final String style;
  final String seed;
  final String url;

  const DefaultAvatarItem({
    required this.id,
    required this.name,
    required this.category,
    required this.style,
    required this.seed,
    required this.url,
  });
}

class DefaultAvatars {
  DefaultAvatars._();

  /// 16 mẫu avatar DiceBear được tuyển chọn kỹ lưỡng, đẹp mắt và KHÔNG dùng style "funemoji".
  /// Sử dụng trực tiếp định dạng PNG chất lượng cao, tải cực nhanh và tương thích hoàn toàn.
  static const List<DefaultAvatarItem> items = [
    // --- 1. Anime & Manga Art (Lorelei) ---
    DefaultAvatarItem(
      id: 'lorelei_willow',
      name: 'Mây Chiều',
      category: 'Anime / Manga',
      style: 'lorelei',
      seed: 'Willow',
      url: 'https://api.dicebear.com/9.x/lorelei/png?seed=Willow',
    ),
    DefaultAvatarItem(
      id: 'lorelei_oliver',
      name: 'Lãng Tử',
      category: 'Anime / Manga',
      style: 'lorelei',
      seed: 'Oliver',
      url: 'https://api.dicebear.com/9.x/lorelei/png?seed=Oliver',
    ),

    // --- 2. Hoạt hình Hiện đại (Avataaars) ---
    DefaultAvatarItem(
      id: 'avataaars_felix',
      name: 'Năng Động',
      category: 'Hoạt hình',
      style: 'avataaars',
      seed: 'Felix',
      url: 'https://api.dicebear.com/9.x/avataaars/png?seed=Felix',
    ),
    DefaultAvatarItem(
      id: 'avataaars_aneka',
      name: 'Phong Cách',
      category: 'Hoạt hình',
      style: 'avataaars',
      seed: 'Aneka',
      url: 'https://api.dicebear.com/9.x/avataaars/png?seed=Aneka',
    ),

    // --- 3. Phiêu lưu & Fantasy (Adventurer) ---
    DefaultAvatarItem(
      id: 'adventurer_luna',
      name: 'Thám Hiểm Nữ',
      category: 'Phiêu lưu',
      style: 'adventurer',
      seed: 'Luna',
      url: 'https://api.dicebear.com/9.x/adventurer/png?seed=Luna',
    ),
    DefaultAvatarItem(
      id: 'adventurer_jack',
      name: 'Hiệp Sĩ',
      category: 'Phiêu lưu',
      style: 'adventurer',
      seed: 'Jack',
      url: 'https://api.dicebear.com/9.x/adventurer/png?seed=Jack',
    ),

    // --- 4. Retro Robots (Bottts) ---
    DefaultAvatarItem(
      id: 'bottts_sparky',
      name: 'Robot Sparky',
      category: 'Retro Robot',
      style: 'bottts',
      seed: 'Sparky',
      url: 'https://api.dicebear.com/9.x/bottts/png?seed=Sparky',
    ),
    DefaultAvatarItem(
      id: 'bottts_buster',
      name: 'Robot Buster',
      category: 'Retro Robot',
      style: 'bottts',
      seed: 'Buster',
      url: 'https://api.dicebear.com/9.x/bottts/png?seed=Buster',
    ),

    // --- 5. Tối giản Monochrome (Notionists) ---
    DefaultAvatarItem(
      id: 'notionists_milo',
      name: 'Minimal Milo',
      category: 'Tối giản',
      style: 'notionists',
      seed: 'Milo',
      url: 'https://api.dicebear.com/9.x/notionists/png?seed=Milo',
    ),
    DefaultAvatarItem(
      id: 'notionists_sophie',
      name: 'Thanh Lịch Sophie',
      category: 'Tối giản',
      style: 'notionists',
      seed: 'Sophie',
      url: 'https://api.dicebear.com/9.x/notionists/png?seed=Sophie',
    ),

    // --- 6. Vector Chân dung Hiện đại (Micah) ---
    DefaultAvatarItem(
      id: 'micah_leo',
      name: 'Hiện Đại Leo',
      category: 'Chân dung',
      style: 'micah',
      seed: 'Leo',
      url: 'https://api.dicebear.com/9.x/micah/png?seed=Leo',
    ),
    DefaultAvatarItem(
      id: 'micah_maya',
      name: 'Nghệ Sĩ Maya',
      category: 'Chân dung',
      style: 'micah',
      seed: 'Maya',
      url: 'https://api.dicebear.com/9.x/micah/png?seed=Maya',
    ),

    // --- 7. Game thủ 8-Bit (Pixel Art) ---
    DefaultAvatarItem(
      id: 'pixel_hero',
      name: 'Hiệp Sĩ 8-Bit',
      category: 'Retro Pixel',
      style: 'pixel-art',
      seed: 'PixelHero',
      url: 'https://api.dicebear.com/9.x/pixel-art/png?seed=PixelHero',
    ),
    DefaultAvatarItem(
      id: 'pixel_retro_gamer',
      name: 'Game Thủ Retro',
      category: 'Retro Pixel',
      style: 'pixel-art',
      seed: 'RetroGamer',
      url: 'https://api.dicebear.com/9.x/pixel-art/png?seed=RetroGamer',
    ),

    // --- 8. Linh vật Ngộ nghĩnh (Thumbs) ---
    DefaultAvatarItem(
      id: 'thumbs_happy',
      name: 'Vui Vẻ Happy',
      category: 'Ngộ nghĩnh',
      style: 'thumbs',
      seed: 'HappyThumb',
      url: 'https://api.dicebear.com/9.x/thumbs/png?seed=HappyThumb',
    ),
    DefaultAvatarItem(
      id: 'thumbs_cool',
      name: 'Cool Ngầu',
      category: 'Ngộ nghĩnh',
      style: 'thumbs',
      seed: 'CoolVibe',
      url: 'https://api.dicebear.com/9.x/thumbs/png?seed=CoolVibe',
    ),
  ];

  /// Lấy avatar mặc định dựa theo username (deterministic)
  static String getByUsername(String? username) {
    if (username == null || username.trim().isEmpty) {
      return items.first.url;
    }
    final index = username.trim().hashCode.abs() % items.length;
    return items[index].url;
  }
}
