import 'package:flame/components.dart';

class PathSegment {
  final Vector2 start;
  final Vector2 end;
  final int color;

  const PathSegment({
    required this.start,
    required this.end,
    required this.color,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PathSegment &&
        start == other.start &&
        end == other.end &&
        color == other.color;
  }

  @override
  int get hashCode {
    return start.hashCode ^ end.hashCode ^ color.hashCode;
  }

  @override
  String toString() {
    return 'PathSegment(start: $start, end: $end, color: $color)';
  }

  PathSegment copyWith({
    Vector2? start,
    Vector2? end,
    int? color,
  }) {
    return PathSegment(
      start: start ?? this.start,
      end: end ?? this.end,
      color: color ?? this.color,
    );
  }
}
