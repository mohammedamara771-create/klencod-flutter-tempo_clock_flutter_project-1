import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnalogClock extends StatelessWidget {
  const AnalogClock({super.key, required this.time});

  final DateTime time;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ClockPainter(time),
      child: const SizedBox.expand(),
    );
  }
}

class _ClockPainter extends CustomPainter {
  _ClockPainter(this.time);
  final DateTime time;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * .43;

    final shadowPaint = Paint()
      ..color = const Color(0xFF080D19)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center.translate(0, 5), radius + 8, shadowPaint);

    final facePaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF202A49), Color(0xFF10172B)],
      ).createShader(Rect.fromCircle(center: center, radius: radius + 8));
    canvas.drawCircle(center, radius + 8, facePaint);

    final ringPaint = Paint()
      ..color = const Color(0xFF9B8AFF).withValues(alpha: .7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius + 8, ringPaint);

    final tickPaint = Paint()
      ..color = const Color(0xFFB9C3E2)
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 60; i++) {
      final angle = i * math.pi / 30 - math.pi / 2;
      final major = i % 5 == 0;
      final outer = radius - 4;
      final inner = radius - (major ? 19 : 10);
      final p1 = Offset(center.dx + math.cos(angle) * inner, center.dy + math.sin(angle) * inner);
      final p2 = Offset(center.dx + math.cos(angle) * outer, center.dy + math.sin(angle) * outer);
      tickPaint
        ..strokeWidth = major ? 2.8 : 1.1
        ..color = major ? const Color(0xFFE8EBFA) : const Color(0xFF7F8BAF).withValues(alpha: .75);
      canvas.drawLine(p1, p2, tickPaint);
    }

    const labels = ['12', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11'];
    for (int i = 0; i < 12; i++) {
      final angle = i * math.pi / 6 - math.pi / 2;
      final pos = Offset(center.dx + math.cos(angle) * (radius - 34), center.dy + math.sin(angle) * (radius - 34));
      final tp = TextPainter(
        text: TextSpan(text: labels[i], style: TextStyle(
          color: i == 0 ? const Color(0xFFB7AAFF) : const Color(0xFFE1E6F8),
          fontSize: 14, fontWeight: FontWeight.w600)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    }

    final hour = time.hour % 12 + time.minute / 60;
    final minute = time.minute + time.second / 60;
    final second = time.second + time.millisecond / 1000;
    _hand(canvas, center, radius * .48, hour * math.pi / 6, 5.5, const Color(0xFFF1F3FF));
    _hand(canvas, center, radius * .68, minute * math.pi / 30, 3.5, const Color(0xFF9B8AFF));
    _hand(canvas, center, radius * .76, second * math.pi / 30, 1.5, const Color(0xFF62E6C5));

    canvas.drawCircle(center, 7, Paint()..color = const Color(0xFF62E6C5));
    canvas.drawCircle(center, 3, Paint()..color = const Color(0xFF10172B));
  }

  void _hand(Canvas canvas, Offset center, double length, double value, double width, Color color) {
    final angle = value - math.pi / 2;
    final end = Offset(center.dx + math.cos(angle) * length, center.dy + math.sin(angle) * length);
    final paint = Paint()..color = color..strokeWidth = width..strokeCap = StrokeCap.round;
    canvas.drawLine(center, end, paint);
  }

  @override
  bool shouldRepaint(covariant _ClockPainter oldDelegate) => oldDelegate.time != time;
}
