import 'dart:math';
import 'package:flutter/material.dart';

class ExactDotsLoader extends StatefulWidget {
  final double size;
  final Color color;

  const ExactDotsLoader({
    Key? key,
    this.size = 60.0,
    this.color = Colors.blue,
  }) : super(key: key);

  @override
  ExactDotsLoaderState createState() => ExactDotsLoaderState();
}

class ExactDotsLoaderState extends State<ExactDotsLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          final progress = _controller.value;
          final angle = progress * 2 * pi;
          final radius = widget.size * 0.3 * (0.5 + 0.5 * sin(angle));

          return Stack(
            alignment: Alignment.center,
            children: List.generate(4, (index) {
              final currentAngle = pi / 2 * index + angle;
              return Transform.translate(
                offset: Offset(
                  radius * cos(currentAngle),
                  radius * sin(currentAngle),
                ),
                child: Container(
                  width: widget.size * 0.15,
                  height: widget.size * 0.15,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
