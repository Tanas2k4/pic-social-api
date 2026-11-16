import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class _StarData {
  final double xRatio;
  final double yRatio;
  final double radius;
  final double baseAlpha;
  final int twinkleCycles; // Số chu kỳ nguyên vẹn trong 1 vòng lặp để lặp lại mượt 100% không giật
  final double twinklePhase;
  final bool isSparkle;
  final Color tintColor;

  const _StarData({
    required this.xRatio,
    required this.yRatio,
    required this.radius,
    required this.baseAlpha,
    required this.twinkleCycles,
    required this.twinklePhase,
    required this.isSparkle,
    required this.tintColor,
  });
}

class StarryCosmosBackground extends StatefulWidget {
  const StarryCosmosBackground({super.key});

  @override
  State<StarryCosmosBackground> createState() => _StarryCosmosBackgroundState();
}

class _StarryCosmosBackgroundState extends State<StarryCosmosBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late final List<_StarData> _stars;

  @override
  void initState() {
    super.initState();
    // Vòng lặp 6 giây với chu kỳ toán học nguyên vẹn (Không bao giờ giật khi repeat)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _stars = _generateSeamlessStars(120);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<_StarData> _generateSeamlessStars(int count) {
    final random = Random(42);
    final List<_StarData> list = [];

    for (int i = 0; i < count; i++) {
      final isSparkle = i < 14;
      final isTintedOlive = i % 8 == 0;
      final isTintedBlue = i % 10 == 0;

      Color tint = Colors.white;
      if (isTintedOlive) {
        tint = const Color(0xFFE8F2B8); // Ánh vàng olive nhẹ
      } else if (isTintedBlue) {
        tint = const Color(0xFFD6E8FF); // Ánh xanh băng
      }

      list.add(
        _StarData(
          xRatio: random.nextDouble(),
          yRatio: random.nextDouble(),
          radius: isSparkle
              ? 1.6 + random.nextDouble() * 0.8
              : 0.7 + random.nextDouble() * 1.1,
          baseAlpha: 0.35 + random.nextDouble() * 0.55,
          // Số chu kỳ nguyên vẹn (1, 2, 3...) giúp sin(2 * pi * cycles * time) liên tục hoàn hảo tại t=0 và t=1
          twinkleCycles: 1 + random.nextInt(4),
          twinklePhase: random.nextDouble() * 2 * pi,
          isSparkle: isSparkle,
          tintColor: tint,
        ),
      );
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _CosmosPainter(
            time: _controller.value,
            stars: _stars,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _CosmosPainter extends CustomPainter {
  final double time;
  final List<_StarData> stars;

  _CosmosPainter({required this.time, required this.stars});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width == 0 || size.height == 0) return;

    // 1. Nền không gian đen tuyền
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.black,
    );

    // 2. Mây tinh vân mờ tĩnh (Vẽ nhanh, không tốn GPU)
    final nebulaPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.primaryOlive.withValues(alpha: 0.05),
          Colors.transparent,
        ],
        radius: 0.65,
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.7, size.height * 0.25),
        radius: size.width * 0.5,
      ));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), nebulaPaint);

    // 3. Vẽ 120 đốm sao lấp lánh (Vị trí tọa độ CỐ ĐỊNH, nhấp nháy tuần hoàn 100% mượt, KHÔNG BAO GIỜ GIẬT)
    for (final star in stars) {
      final x = star.xRatio * size.width;
      final y = star.yRatio * size.height;

      // Chu kỳ nguyên vẹn: sin(2 * pi * cycles * time + phase) tại time=0 và time=1 có giá trị bằng nhau tuyệt đối
      final twinkle = sin(time * 2 * pi * star.twinkleCycles + star.twinklePhase);
      final alpha = (star.baseAlpha * (0.65 + 0.35 * twinkle)).clamp(0.12, 1.0);

      final starPaint = Paint()
        ..color = star.tintColor.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      // Sao lớn có tia sáng chữ thập 4 cánh (+) vẽ siêu nhẹ không dùng blur
      if (star.isSparkle) {
        final flarePaint = Paint()
          ..color = star.tintColor.withValues(alpha: alpha * 0.7)
          ..strokeWidth = 0.8;
        final flareLen = star.radius * 2.8;

        canvas.drawLine(Offset(x - flareLen, y), Offset(x + flareLen, y), flarePaint);
        canvas.drawLine(Offset(x, y - flareLen), Offset(x, y + flareLen), flarePaint);

        // Vòng quầng mờ xung quanh
        final glowPaint = Paint()
          ..color = star.tintColor.withValues(alpha: alpha * 0.25)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, y), star.radius * 2.0, glowPaint);
      }

      // Đốm sao tròn
      canvas.drawCircle(Offset(x, y), star.radius, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CosmosPainter oldDelegate) => true;
}
