import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:color_connect/core/theme/app_theme.dart';

class GridCell extends Component {
  final Vector2 position;
  final double size;
  final int? color;
  final bool isEndpoint;

  GridCell({
    required this.position,
    required this.size,
    required this.color,
    required this.isEndpoint,
  });

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    if (isEndpoint && color != null) {
      _drawEndpoint(canvas);
    }
  }

  void _drawEndpoint(Canvas canvas) {
    final center = Offset(
      position.x + size / 2,
      position.y + size / 2,
    );
    
    // Draw colored squircle for endpoint using superellipse
    final paint = Paint()
      ..color = _getColorForIndex(color!)
      ..style = PaintingStyle.fill;
    
    final radius = size * 0.25;
    final path = _createSuperellipsePath(center, radius, 4.0);
    canvas.drawPath(path, paint);
    
    // Draw white border
    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    canvas.drawPath(path, borderPaint);
  }

  Path _createSuperellipsePath(Offset center, double radius, double n) {
    const steps = 64;
    final path = Path();
    
    for (int i = 0; i <= steps; i++) {
      final t = -math.pi + 2 * math.pi * i / steps;
      final ct = math.cos(t), st = math.sin(t);
      final x = math.pow(ct.abs(), 2 / n) * radius * (ct >= 0 ? 1 : -1);
      final y = math.pow(st.abs(), 2 / n) * radius * (st >= 0 ? 1 : -1);
      final px = center.dx + x, py = center.dy + y;
      
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    return path;
  }

  Color _getColorForIndex(int colorIndex) {
    switch (colorIndex) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.purple;
      case 5:
        return Colors.orange;
      default:
        return CCColors.primary;
    }
  }

  @override
  bool containsPoint(Vector2 point) {
    return point.x >= position.x &&
           point.x < position.x + size &&
           point.y >= position.y &&
           point.y < position.y + size;
  }
}
