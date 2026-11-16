import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Hiệu ứng Sun Glitter quang học: ánh kim lấp lánh phản chiếu của mặt trời trên mặt sóng nước biển
class SunGlitterOverlay extends StatefulWidget {
  const SunGlitterOverlay({super.key});

  @override
  State<SunGlitterOverlay> createState() => _SunGlitterOverlayState();
}

class _SunGlitterOverlayState extends State<SunGlitterOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_GlitterPoint> _points;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    final random = math.Random(42);
    // Tạo 16 điểm lấp lánh trên mặt sóng (khu vực trung tâm & sóng nước biển)
    _points = List.generate(16, (index) {
      return _GlitterPoint(
        // Vị trí tập trung chủ yếu ở dải sóng nước (x từ 0.15 đến 0.85, y từ 0.38 đến 0.74)
        relX: 0.15 + random.nextDouble() * 0.70,
        relY: 0.38 + random.nextDouble() * 0.36,
        size: 5.0 + random.nextDouble() * 7.5,
        phase: random.nextDouble() * 2 * math.pi,
        frequency: 0.8 + random.nextDouble() * 1.6,
        rotation: (random.nextDouble() - 0.5) * 0.4,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            size: Size.infinite,
            painter: _SunGlitterPainter(
              progress: _controller.value,
              points: _points,
            ),
          );
        },
      ),
    );
  }
}

class _GlitterPoint {
  final double relX;
  final double relY;
  final double size;
  final double phase;
  final double frequency;
  final double rotation;

  const _GlitterPoint({
    required this.relX,
    required this.relY,
    required this.size,
    required this.phase,
    required this.frequency,
    required this.rotation,
  });
}

class _SunGlitterPainter extends CustomPainter {
  final double progress;
  final List<_GlitterPoint> points;

  _SunGlitterPainter({
    required this.progress,
    required this.points,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double time = progress * 2 * math.pi;

    for (final point in points) {
      final double wave = math.sin(time * point.frequency + point.phase);
      // Ánh sáng nhấp nháy tự nhiên (chớp sáng khi góc sóng đón nắng)
      final double intensity = math.pow((wave + 1.0) / 2.0, 3).toDouble();

      if (intensity < 0.08) continue;

      final double px = point.relX * size.width;
      final double py = point.relY * size.height;
      final double s = point.size * (0.6 + 0.4 * intensity);

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(point.rotation);

      // 1. Quầng sáng mềm (halo)
      final haloPaint = Paint()
        ..color = const Color(0xFFD4F1F9).withValues(alpha: 0.45 * intensity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5);
      canvas.drawCircle(Offset.zero, s * 0.8, haloPaint);

      // 2. Tia sáng chữ thập 4 cánh (quang học diamond glint)
      final rayPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.95 * intensity)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 1.0;

      // Tia dọc
      canvas.drawLine(Offset(0, -s), Offset(0, s), rayPaint);
      // Tia ngang
      canvas.drawLine(Offset(-s, 0), Offset(s, 0), rayPaint);

      // 3. Tia chéo phụ (nhỏ hơn)
      final subRayPaint = Paint()
        ..color = const Color(0xFFE8F8FF).withValues(alpha: 0.65 * intensity)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 0.8;
      final double subS = s * 0.45;
      canvas.drawLine(Offset(-subS, -subS), Offset(subS, subS), subRayPaint);
      canvas.drawLine(Offset(-subS, subS), Offset(subS, -subS), subRayPaint);

      // 4. Tâm lõi trắng lóa (Specular Core)
      final corePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.98 * intensity);
      canvas.drawCircle(Offset.zero, 1.2, corePaint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _SunGlitterPainter oldDelegate) => true;
}
