import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/album_cup_model.dart';
import '../../data/models/single_photo_item.dart';

class GlassCupWidget extends StatelessWidget {
  final AlbumCupModel album;
  final bool isHovered;
  final VoidCallback onTap;

  const GlassCupWidget({
    super.key,
    required this.album,
    required this.isHovered,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final photos = album.photos;
    final int displayCount = min(photos.length, 6);
    final List<Map<String, double>> fanConfigs = _getOrganicCardConfigs(displayCount);

    return AnimatedScale(
      scale: isHovered ? 1.12 : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 130,
          height: 195,
          child: Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
              // 1. TÊN ALBUM: DÙNG FONT DANCING SCRIPT, VÒM XUỐNG PHÍA TRÊN NGOÀI LY
              Positioned(
                top: 8,
                left: 0,
                right: 0,
                height: 38,
                child: CustomPaint(
                  painter: _DancingScriptArchPainter(
                    text: album.name,
                    color: isHovered
                        ? const Color(0xFFE6E6EC)
                        : Colors.white.withValues(alpha: 0.95),
                  ),
                ),
              ),

              // 2. TẦNG NỀN SAU CỦA LY (Back Glass Wall)
              Positioned(
                top: 50,
                child: Container(
                  width: 104,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                      bottom: Radius.circular(42),
                    ),
                    border: Border.all(
                      color: isHovered
                          ? const Color(0xFFE6E6EC)
                          : Colors.white.withValues(alpha: 0.22),
                      width: isHovered ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isHovered
                            ? Colors.white.withValues(alpha: 0.35)
                            : Colors.black.withValues(alpha: 0.45),
                        blurRadius: isHovered ? 20 : 12,
                        spreadRadius: isHovered ? 3 : 0,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. TẦNG CÁC THẺ ẢNH (BỐ TRÍ TỰ NHIÊN: NHÔ MIỆNG LY VÀ CHEN CHÚC DƯỚI LÒNG LY)
              if (photos.isNotEmpty)
                ...List.generate(displayCount, (index) {
                  final photo = photos[index];
                  final config = fanConfigs[index];
                  final angle = config['angle']!;
                  final dx = config['dx']!;
                  final dy = config['dy']!;

                  return Positioned(
                    top: 50 + dy,
                    child: Transform.translate(
                      offset: Offset(dx, 0),
                      child: Transform.rotate(
                        angle: angle,
                        alignment: Alignment.center,
                        child: _buildPhotocard(photo),
                      ),
                    ),
                  );
                }),

              // 4. TẦNG MẶT KÍNH TRONG SUỐT PHÍA TRƯỚC (Front Glass & Specular Glare)
              // Phủ lên phần dưới của ảnh để thấy ảnh chìm trong lòng kính trong suốt
              Positioned(
                top: 50,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                    bottom: Radius.circular(42),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 0.4, sigmaY: 0.4),
                    child: Container(
                      width: 104,
                      height: 110,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.12),
                            Colors.white.withValues(alpha: 0.02),
                            Colors.white.withValues(alpha: 0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: isHovered
                              ? const Color(0xFFE6E6EC)
                              : Colors.white.withValues(alpha: 0.38),
                          width: isHovered ? 2.0 : 1.2,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Vệt sáng phản chiếu (Glass Glare)
                          Positioned(
                            top: 8,
                            left: 10,
                            width: 12,
                            height: 70,
                            child: Transform.rotate(
                              angle: -0.15,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withValues(alpha: 0.35),
                                      Colors.white.withValues(alpha: 0.04),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Đáy ly thủy tinh dày đặc trưng
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: 14,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(42),
                                ),
                                border: Border(
                                  top: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.28),
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Viền miệng ly
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: 2.5,
                            child: Container(
                              color: isHovered
                                  ? const Color(0xFFE6E6EC)
                                  : Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotocard(SinglePhotoItem photo) {
    return Container(
      width: 46,
      height: 68,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.88),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.65),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: CachedNetworkImage(
          imageUrl: photo.photoUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(color: Colors.black54),
        ),
      ),
    );
  }

  // BỐ TRÍ THẺ ẢNH TỰ NHIÊN:
  // - 1 đến 3 ảnh: nhô lên miệng ly với góc xoay vừa vặn (không tràn miệng)
  // - Trên 3 ảnh: các ảnh tiếp theo chen chúc chìm sâu hơn ở đáy/lòng ly giống hệt ảnh thực tế
  List<Map<String, double>> _getOrganicCardConfigs(int count) {
    if (count <= 1) {
      return [{'angle': 0.0, 'dx': 0.0, 'dy': -24.0}];
    }
    if (count == 2) {
      return [
        {'angle': -0.12, 'dx': -12.0, 'dy': -22.0},
        {'angle': 0.12, 'dx': 12.0, 'dy': -22.0},
      ];
    }
    if (count == 3) {
      return [
        {'angle': -0.16, 'dx': -16.0, 'dy': -20.0},
        {'angle': 0.02, 'dx': 0.0, 'dy': -26.0}, // Ảnh giữa nhô cao nhất
        {'angle': 0.16, 'dx': 16.0, 'dy': -20.0},
      ];
    }
    if (count == 4) {
      return [
        // 2 ảnh nhô miệng ly
        {'angle': -0.14, 'dx': -14.0, 'dy': -24.0},
        {'angle': 0.12, 'dx': 12.0, 'dy': -22.0},
        // 2 ảnh chen chúc phía dưới lòng ly
        {'angle': 0.04, 'dx': -4.0, 'dy': 6.0},
        {'angle': -0.10, 'dx': 10.0, 'dy': 24.0},
      ];
    }
    if (count == 5) {
      return [
        // 3 ảnh nhô miệng ly
        {'angle': -0.15, 'dx': -16.0, 'dy': -22.0},
        {'angle': 0.0, 'dx': 2.0, 'dy': -26.0},
        {'angle': 0.14, 'dx': 16.0, 'dy': -22.0},
        // 2 ảnh chen chúc tầng dưới
        {'angle': -0.06, 'dx': -12.0, 'dy': 12.0},
        {'angle': 0.10, 'dx': 8.0, 'dy': 26.0},
      ];
    }
    // 6 ảnh trở lên
    return [
      // 3 ảnh tầng trên miệng ly
      {'angle': -0.16, 'dx': -16.0, 'dy': -22.0},
      {'angle': 0.02, 'dx': 0.0, 'dy': -26.0},
      {'angle': 0.15, 'dx': 16.0, 'dy': -22.0},
      // 3 ảnh chen chúc tầng giữa và đáy ly
      {'angle': -0.08, 'dx': -14.0, 'dy': 8.0},
      {'angle': 0.08, 'dx': 12.0, 'dy': 14.0},
      {'angle': -0.02, 'dx': -2.0, 'dy': 30.0}, // Nằm sát đáy ly
    ];
  }
}

// CustomPainter vẽ tên Album theo font Dancing Script, vòm xuống phía trên miệng ly
class _DancingScriptArchPainter extends CustomPainter {
  final String text;
  final Color color;

  _DancingScriptArchPainter({required this.text, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (text.isEmpty) return;

    // Giới hạn độ dài chữ tối đa 12 ký tự để vừa vòm
    final displayText = text.length > 12 ? '${text.substring(0, 11)}…' : text;

    final centerX = size.width / 2;
    // Tâm của vòng tròn vòm xuống nằm phía dưới
    const centerY = 50.0;
    const radius = 42.0;
    const charSpacingAngle = 0.14;

    final totalAngle = (displayText.length - 1) * charSpacingAngle;
    final startAngle = -totalAngle / 2;

    for (int i = 0; i < displayText.length; i++) {
      final char = displayText[i];
      final theta = startAngle + i * charSpacingAngle;

      // X nằm hai bên tâm, Y đạt đỉnh cao nhất ở giữa và cong chúc xuống hai bên (vòm cung)
      final x = centerX + radius * sin(theta);
      final y = centerY - radius * cos(theta);

      final textPainter = TextPainter(
        text: TextSpan(
          text: char,
          style: GoogleFonts.dancingScript(
            color: color,
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.9),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(theta); // Nghiêng tự nhiên theo đường vòm
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _DancingScriptArchPainter oldDelegate) {
    return oldDelegate.text != text || oldDelegate.color != color;
  }
}
