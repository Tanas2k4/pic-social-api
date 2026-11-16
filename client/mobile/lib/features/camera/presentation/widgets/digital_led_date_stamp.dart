import 'package:flutter/material.dart';

/// Hiển thị dấu ngày tháng dạng LED 7 đoạn (7-Segment Digital LED)
/// Chuẩn xác theo đồng hồ Quartz Date của các dòng máy film compact thập niên 90 (Olympus Mju, Contax T2)
class DigitalLedDateStamp extends StatelessWidget {
  final String text;
  final Color activeColor;
  final Color ghostColor;
  final double digitWidth;
  final double digitHeight;

  const DigitalLedDateStamp({
    super.key,
    required this.text,
    this.activeColor = const Color(0xFFFF981A),
    this.ghostColor = const Color(0x1A6A3200),
    this.digitWidth = 7.5,
    this.digitHeight = 13.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(_calculateTotalWidth(), digitHeight),
      painter: DigitalLedPainter(
        text: text,
        activeColor: activeColor,
        ghostColor: ghostColor,
        digitWidth: digitWidth,
        digitHeight: digitHeight,
      ),
    );
  }

  double _calculateTotalWidth() {
    double total = 0;
    const double digitSpacing = 2.2;
    const double spaceWidth = 4.5;
    const double apostropheWidth = 3.5;

    for (int i = 0; i < text.length; i++) {
      final ch = text[i];
      if (ch == ' ') {
        total += spaceWidth;
      } else if (ch == '\'' || ch == '’') {
        total += apostropheWidth + digitSpacing;
      } else {
        total += digitWidth + digitSpacing;
      }
    }
    return total;
  }
}

class DigitalLedPainter extends CustomPainter {
  final String text;
  final Color activeColor;
  final Color ghostColor;
  final double digitWidth;
  final double digitHeight;

  DigitalLedPainter({
    required this.text,
    required this.activeColor,
    required this.ghostColor,
    required this.digitWidth,
    required this.digitHeight,
  });

  static double calculateTotalWidth({
    required String text,
    required double digitWidth,
    double digitSpacing = 2.2,
    double spaceWidth = 4.5,
    double apostropheWidth = 3.5,
  }) {
    double total = 0;
    for (int i = 0; i < text.length; i++) {
      final ch = text[i];
      if (ch == ' ') {
        total += spaceWidth;
      } else if (ch == '\'' || ch == '’') {
        total += apostropheWidth + digitSpacing;
      } else {
        total += digitWidth + digitSpacing;
      }
    }
    return total;
  }

  static void drawStamp(
    Canvas canvas, {
    required String text,
    required Offset offset,
    double scale = 1.0,
    Color activeColor = const Color(0xFFFF961C),
    Color ghostColor = const Color(0x1F6B3400),
  }) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.scale(scale);

    final painter = DigitalLedPainter(
      text: text,
      activeColor: activeColor,
      ghostColor: ghostColor,
      digitWidth: 7.5,
      digitHeight: 13.0,
    );
    painter.paint(canvas, Size(calculateTotalWidth(text: text, digitWidth: 7.5), 13.0));
    canvas.restore();
  }

  static const Map<String, List<int>> _digitSegments = {
    '0': [0, 1, 2, 3, 4, 5],
    '1': [1, 2],
    '2': [0, 1, 6, 4, 3],
    '3': [0, 1, 6, 2, 3],
    '4': [5, 6, 1, 2],
    '5': [0, 5, 6, 2, 3],
    '6': [0, 5, 6, 4, 2, 3],
    '7': [0, 1, 2],
    '8': [0, 1, 2, 3, 4, 5, 6],
    '9': [0, 1, 2, 3, 5, 6],
  };

  @override
  void paint(Canvas canvas, Size size) {
    double cursorX = 0;
    const double digitSpacing = 2.2;
    const double spaceWidth = 4.5;
    const double apostropheWidth = 3.5;

    for (int i = 0; i < text.length; i++) {
      final ch = text[i];
      if (ch == ' ') {
        cursorX += spaceWidth;
        continue;
      }

      if (ch == '\'' || ch == '’') {
        _drawApostrophe(canvas, cursorX);
        cursorX += apostropheWidth + digitSpacing;
        continue;
      }

      if (_digitSegments.containsKey(ch)) {
        _drawDigit(canvas, cursorX, _digitSegments[ch]!);
        cursorX += digitWidth + digitSpacing;
      }
    }
  }

  void _drawApostrophe(Canvas canvas, double startX) {
    final paint = Paint()
      ..color = activeColor
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 0.8);

    canvas.drawLine(
      Offset(startX + 1.0, 0.5),
      Offset(startX + 2.0, 3.8),
      paint,
    );
  }

  void _drawDigit(Canvas canvas, double startX, List<int> activeSegments) {
    const double segThickness = 1.3;
    final double w = digitWidth;
    final double h = digitHeight;
    final double halfH = h / 2.0;

    final activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 0.8);

    final ghostPaint = Paint()
      ..color = ghostColor
      ..style = PaintingStyle.fill;

    // 7 đoạn LED: 0=Top, 1=TopRight, 2=BottomRight, 3=Bottom, 4=BottomLeft, 5=TopLeft, 6=Middle
    for (int seg = 0; seg < 7; seg++) {
      final isLit = activeSegments.contains(seg);
      final paint = isLit ? activePaint : ghostPaint;
      final path = Path();

      switch (seg) {
        case 0: // Top
          path.moveTo(startX + segThickness, 0);
          path.lineTo(startX + w - segThickness, 0);
          path.lineTo(startX + w - 2 * segThickness, segThickness);
          path.lineTo(startX + 2 * segThickness, segThickness);
          path.close();
          break;
        case 1: // Top Right
          path.moveTo(startX + w, segThickness);
          path.lineTo(startX + w, halfH - segThickness * 0.5);
          path.lineTo(startX + w - segThickness, halfH - segThickness * 0.8);
          path.lineTo(startX + w - segThickness, 2 * segThickness);
          path.close();
          break;
        case 2: // Bottom Right
          path.moveTo(startX + w, halfH + segThickness * 0.5);
          path.lineTo(startX + w, h - segThickness);
          path.lineTo(startX + w - segThickness, h - 2 * segThickness);
          path.lineTo(startX + w - segThickness, halfH + segThickness * 0.8);
          path.close();
          break;
        case 3: // Bottom
          path.moveTo(startX + 2 * segThickness, h - segThickness);
          path.lineTo(startX + w - 2 * segThickness, h - segThickness);
          path.lineTo(startX + w - segThickness, h);
          path.lineTo(startX + segThickness, h);
          path.close();
          break;
        case 4: // Bottom Left
          path.moveTo(startX, halfH + segThickness * 0.5);
          path.lineTo(startX + segThickness, halfH + segThickness * 0.8);
          path.lineTo(startX + segThickness, h - 2 * segThickness);
          path.lineTo(startX, h - segThickness);
          path.close();
          break;
        case 5: // Top Left
          path.moveTo(startX, segThickness);
          path.lineTo(startX + segThickness, 2 * segThickness);
          path.lineTo(startX + segThickness, halfH - segThickness * 0.8);
          path.lineTo(startX, halfH - segThickness * 0.5);
          path.close();
          break;
        case 6: // Middle
          path.moveTo(startX + 1.5 * segThickness, halfH - segThickness * 0.4);
          path.lineTo(startX + w - 1.5 * segThickness, halfH - segThickness * 0.4);
          path.lineTo(startX + w - segThickness, halfH);
          path.lineTo(startX + w - 1.5 * segThickness, halfH + segThickness * 0.4);
          path.lineTo(startX + 1.5 * segThickness, halfH + segThickness * 0.4);
          path.lineTo(startX + segThickness, halfH);
          path.close();
          break;
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant DigitalLedPainter oldDelegate) {
    return oldDelegate.text != text ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.ghostColor != ghostColor;
  }
}
