import 'dart:math';

import 'package:flutter/material.dart';

/// Same color stops as login / sign-up CTA [LinearGradient] (pink → magenta → mauve → green).
const _kCtaSweepColors = <Color>[
  Color(0xFFFD215C),
  Color(0xFFFD22C4),
  Color(0xFF9C8095),
  Color(0xFF29F04A),
  Color(0xFFFD215C),
];

/// Gradient arc + glowing dot spinner for inline loading states.
class FlashyLoader extends StatefulWidget {
  const FlashyLoader({super.key, this.size = 50});

  final double size;

  @override
  State<FlashyLoader> createState() => _FlashyLoaderState();
}

class _FlashyLoaderState extends State<FlashyLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: FlashyLoaderPainter(_controller),
      child: SizedBox(width: widget.size, height: widget.size),
    );
  }
}

class FlashyLoaderPainter extends CustomPainter {
  FlashyLoaderPainter(this.animation) : super(repaint: animation);

  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(radius, radius);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(2 * pi * animation.value);
    canvas.translate(-center.dx, -center.dy);

    final gradientPaint = Paint()
      ..shader = SweepGradient(
        colors: _kCtaSweepColors,
        startAngle: 0,
        endAngle: 2 * pi,
        tileMode: TileMode.mirror,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 10),
      0,
      pi * 1.5,
      false,
      gradientPaint,
    );

    canvas.restore();

    final dotRadius = 6 + sin(animation.value * 2 * pi) * 2;
    final angle = 2 * pi * animation.value + pi * 1.5;
    final dotOffset = Offset(
      center.dx + (radius - 10) * cos(angle),
      center.dy + (radius - 10) * sin(angle),
    );

    final dotPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFD22C4).withOpacity(0.95),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: dotOffset, radius: dotRadius * 2))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(dotOffset, dotRadius, dotPaint);
  }

  @override
  bool shouldRepaint(covariant FlashyLoaderPainter oldDelegate) => true;
}
