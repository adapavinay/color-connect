import 'dart:math';
import 'package:flutter/widgets.dart';

class Squircle extends StatelessWidget {
  final Color color;
  final double n; // shape exponent ~4
  const Squircle({super.key, required this.color, this.n = 4.0});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _SquirclePainter(color: color, n: n));
  }
}

class _SquirclePainter extends CustomPainter {
  final Color color; final double n;
  _SquirclePainter({required this.color, required this.n});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    canvas.drawPath(_superellipsePath(size, n), paint);
  }

  Path _superellipsePath(Size size, double n) {
    final w = size.width / 2, h = size.height / 2;
    const steps = 96;
    final path = Path();
    for (int i = 0; i <= steps; i++) {
      final t = -pi + 2 * pi * i / steps;
      final ct = cos(t), st = sin(t);
      final x = pow(ct.abs(), 2 / n) * w * (ct >= 0 ? 1 : -1);
      final y = pow(st.abs(), 2 / n) * h * (st >= 0 ? 1 : -1);
      final px = w + x, py = h + y;
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _SquirclePainter old) => old.color != color || old.n != n;
}
