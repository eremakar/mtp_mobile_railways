import 'dart:math' as math;
import 'package:flutter/material.dart';

class DotCircleLoader extends StatefulWidget {
  const DotCircleLoader({
    super.key,
    this.size = 40,
    this.dotCount = 10,
    this.duration = const Duration(milliseconds: 900),
    this.activeColor,
    this.inactiveColor,
    this.dotRadiusFactor = 0.085, 
    this.ringRadiusFactor = 0.36, 
    this.activeScale = 1.15,
    this.inactiveScale = 0.9,
  });

  final double size;
  final int dotCount;
  final Duration duration;

  final Color? activeColor;
  final Color? inactiveColor;

  final double dotRadiusFactor;

  final double ringRadiusFactor;

  final double activeScale;
  final double inactiveScale;

  @override
  State<DotCircleLoader> createState() => _DotCircleLoaderState();
}

class _DotCircleLoaderState extends State<DotCircleLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void didUpdateWidget(covariant DotCircleLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _c
        ..duration = widget.duration
        ..repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.activeColor ?? const Color(0xFF0070E0);
    final inactiveColor = widget.inactiveColor ?? activeColor;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          final t = _c.value;
          final activeIndex = (t * widget.dotCount).floor() % widget.dotCount;

          return CustomPaint(
            painter: _DotCirclePainter(
              dotCount: widget.dotCount,
              ringRadius: widget.size * widget.ringRadiusFactor,
              dotRadius: widget.size * widget.dotRadiusFactor,
              activeIndex: activeIndex,
              activeColor: activeColor,
              inactiveColor: inactiveColor,
              activeScale: widget.activeScale,
              inactiveScale: widget.inactiveScale,
            ),
          );
        },
      ),
    );
  }
}

class _DotCirclePainter extends CustomPainter {
  _DotCirclePainter({
    required this.dotCount,
    required this.ringRadius,
    required this.dotRadius,
    required this.activeIndex,
    required this.activeColor,
    required this.inactiveColor,
    required this.activeScale,
    required this.inactiveScale,
  });

  final int dotCount;
  final double ringRadius;
  final double dotRadius;
  final int activeIndex;
  final Color activeColor;
  final Color inactiveColor;
  final double activeScale;
  final double inactiveScale;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < dotCount; i++) {
      final angle = (2 * math.pi * i / dotCount) - (math.pi / 2);
      final dx = math.cos(angle) * ringRadius;
      final dy = math.sin(angle) * ringRadius;
      final p = center + Offset(dx, dy);

      final isActive = i == activeIndex;

      final dist = (i - activeIndex).abs();
      final wrappedDist = math.min(dist, dotCount - dist); 
      final tail = 1.0 - (wrappedDist / (dotCount / 2));
      final alpha = isActive
          ? 1.0
          : (0.25 + 0.45 * tail).clamp(0.25, 0.7);

      final base = isActive ? activeColor : inactiveColor;
      final color = base.withValues(alpha: isActive ? 1.0 : alpha);

      final scale = isActive ? activeScale : inactiveScale;
      final r = dotRadius * scale;

      final paint = Paint()..color = color;
      canvas.drawCircle(p, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DotCirclePainter old) {
    return old.activeIndex != activeIndex ||
        old.dotCount != dotCount ||
        old.ringRadius != ringRadius ||
        old.dotRadius != dotRadius ||
        old.activeColor != activeColor ||
        old.inactiveColor != inactiveColor ||
        old.activeScale != activeScale ||
        old.inactiveScale != inactiveScale;
  }
}