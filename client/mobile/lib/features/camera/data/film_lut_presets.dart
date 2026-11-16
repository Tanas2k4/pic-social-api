import 'package:flutter/material.dart';

/// Định nghĩa Cuộn Film LUT cổ điển cho PicSocial
/// Áp dụng Color Grading cấp độ pixel quang học (Không dùng lớp phủ giả lập)
class FilmPreset {
  final String id;
  final String name;
  final String shortName;
  final Color accentColor;
  final List<double> matrix;
  final String description;
  final String? dateStamp; // Dấu ngày cơ học Quartz Date thập niên 90 ('98 11 12)

  const FilmPreset({
    required this.id,
    required this.name,
    required this.shortName,
    required this.accentColor,
    required this.matrix,
    required this.description,
    this.dateStamp,
  });
}

/// Tone Film kinh điển mô phỏng chuẩn xác chất màu Analog 35mm (Kodak Gold 200 / Portra)
class FilmPresets {
  FilmPresets._();

  /// 1. ẢNH GỐC (LUT GỐC - ĐẶT Ở TRÊN)
  static const FilmPreset original = FilmPreset(
    id: 'original',
    name: 'Ảnh gốc',
    shortName: 'Gốc',
    accentColor: Colors.white,
    description: 'Màu sắc tự nhiên từ cảm biến máy ảnh',
    matrix: [
      1.0, 0.0, 0.0, 0.0, 0.0,
      0.0, 1.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 1.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 1.0, 0.0,
    ],
  );

  /// 2. TONE PHIM VINTAGE 90S (Kodak Portra / Gold 200)
  /// - Chuyển hóa kênh màu quang học thực thụ (Color Grading):
  ///   + Highlight: Ánh nắng ấm vàng hổ phách, da mặt hồng hào tự nhiên, trắng kem mộc mạc
  ///   + Shadow: Nâng sáng bóng đổ ngả xanh rêu mờ hoài niệm (Matte Teal-Charcoal)
  ///   + Midtone: Độ tương phản cao, tách bạch chủ thể
  /// - Dấu ngày cơ học Quartz Date màu cam 90s
  static const FilmPreset vintageFilm = FilmPreset(
    id: 'vintage_film',
    name: 'Vintage Film 90s',
    shortName: 'Film 90s',
    accentColor: Color(0xFFFFB038), // Vàng hổ phách Kodak
    description: 'Tone màu film Kodak ấm áp: Da hồng ấm, bóng mờ ngọc bích, dấu ngày cam',
    dateStamp: '\'98 11 12',
    matrix: [
      // Kênh Đỏ: Nhấn sáng ấm, da mặt hồng hào, bắt sáng vàng rạng rỡ
      1.18,  0.06, -0.06, 0.0,   6.0,
      // Kênh Lục: Mộc mạc, giữ màu sắc tự nhiên không gắt
     -0.04,  1.10, -0.02, 0.0,   3.0,
      // Kênh Lam: Nén xanh ở highlight tạo màu kem ấm, nâng shadow tạo matte hoài cổ
     -0.12, -0.04,  0.88, 0.0,  14.0,
      // Kênh Alpha: Giữ nguyên
      0.00,  0.00,  0.00, 1.0,   0.0,
    ],
  );

  /// Danh sách preset: LUT gốc ở trên, Film ở dưới
  static const List<FilmPreset> all = [
    original,
    vintageFilm,
  ];

  /// Lấy preset theo id
  static FilmPreset getById(String? id) {
    if (id == null) return original;
    return all.firstWhere((p) => p.id == id, orElse: () => vintageFilm);
  }
}
