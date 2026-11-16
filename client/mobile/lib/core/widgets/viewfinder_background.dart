import 'package:flutter/material.dart';

/// Background thấu kính quang học & khung ngắm máy ảnh phim cổ điển (Phương án 2):
/// - Optical Lens Vignette Radial Gradient (Tâm sáng dịu, rìa & 4 góc tối sâu thẳm)
/// - Viewfinder Frame Marks (4 góc thước ngắm ┌ ┐ └ ┘ + crosshair trung tâm)
class ViewfinderBackground extends StatelessWidget {
  final Widget child;
  final bool showViewfinderMarks;
  final Alignment centerAlignment;

  const ViewfinderBackground({
    super.key,
    required this.child,
    this.showViewfinderMarks = true,
    this.centerAlignment = const Alignment(0, -0.28),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Lớp 1: Optical Lens Vignette Gradient (Nền thấu kính có chiều sâu)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: centerAlignment,
                radius: 1.18,
                colors: const [
                  Color(0xFF202028), // Ánh sáng dịu vùng trung tâm quang học
                  Color(0xFF131317), // Chuyển tiếp mịn
                  Color(0xFF08080A), // Rìa tối
                  Color(0xFF030304), // 4 góc tối thẳm mô phỏng Vignette thấu kính
                ],
                stops: const [0.0, 0.42, 0.8, 1.0],
              ),
            ),
          ),
        ),

        // Lớp 2: Khung viền ngắm máy cơ cổ điển (Viewfinder Frame Marks)
        if (showViewfinderMarks)
          const Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: ViewfinderFramePainter(),
              ),
            ),
          ),

        // Lớp 3: Nội dung chính của màn hình
        child,
      ],
    );
  }
}

/// Khung ngắm máy ảnh phim (Viewfinder Frame Markers)
class ViewfinderFramePainter extends CustomPainter {
  const ViewfinderFramePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const double inset = 18.0;
    const double len = 14.0;

    // Góc trên - trái ┌
    canvas.drawLine(const Offset(inset, inset), const Offset(inset + len, inset), paint);
    canvas.drawLine(const Offset(inset, inset), const Offset(inset, inset + len), paint);

    // Góc trên - phải ┐
    canvas.drawLine(Offset(size.width - inset, inset), Offset(size.width - inset - len, inset), paint);
    canvas.drawLine(Offset(size.width - inset, inset), Offset(size.width - inset, inset + len), paint);

    // Góc dưới - trái └
    canvas.drawLine(Offset(inset, size.height - inset), Offset(inset + len, size.height - inset), paint);
    canvas.drawLine(Offset(inset, size.height - inset), Offset(inset, size.height - inset - len), paint);

    // Góc dưới - phải ┘
    canvas.drawLine(Offset(size.width - inset, size.height - inset), Offset(size.width - inset - len, size.height - inset), paint);
    canvas.drawLine(Offset(size.width - inset, size.height - inset), Offset(size.width - inset, size.height - inset - len), paint);

    // Điểm ngắm chữ thập trung tâm (Crosshair) mờ nhẹ
    final crossPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1.0;
    final center = Offset(size.width / 2, size.height * 0.22);
    canvas.drawLine(Offset(center.dx - 6, center.dy), Offset(center.dx + 6, center.dy), crossPaint);
    canvas.drawLine(Offset(center.dx, center.dy - 6), Offset(center.dx, center.dy + 6), crossPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
