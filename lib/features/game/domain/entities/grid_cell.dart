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
    
    // Draw colored circle for endpoint
    final paint = Paint()
      ..color = _getColorForIndex(color!)
      ..style = PaintingStyle.fill;
    
    final radius = size * 0.3;
    canvas.drawCircle(center, radius, paint);
    
    // Draw border
    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    canvas.drawCircle(center, radius, borderPaint);
  }

  Color _getColorForIndex(int colorIndex) {
    switch (colorIndex) {
      case 0:
        return AppTheme.red;
      case 1:
        return AppTheme.blue;
      case 2:
        return AppTheme.green;
      case 3:
        return AppTheme.yellow;
      case 4:
        return AppTheme.purple;
      case 5:
        return AppTheme.orange;
      default:
        return AppTheme.primaryColor;
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
