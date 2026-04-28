import 'package:flutter/material.dart';

import '../../theme/colors.dart';

/// Tab icons reproduced from the prototype SVGs (Omnom.html lines 919–940).
/// All icons render inside a 22×22 box.
class _TabIconBase extends StatelessWidget {
  const _TabIconBase({required this.painter});
  final CustomPainter painter;

  @override
  Widget build(BuildContext context) =>
      SizedBox.square(dimension: 22, child: CustomPaint(painter: painter));
}

class DiaryTabIcon extends StatelessWidget {
  const DiaryTabIcon({super.key, required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) =>
      _TabIconBase(painter: _DiaryPainter(color));
}

class RecipesTabIcon extends StatelessWidget {
  const RecipesTabIcon({super.key, required this.color, required this.active});
  final Color color;
  final bool active;

  @override
  Widget build(BuildContext context) => _TabIconBase(
        painter: _RecipesPainter(
          stroke: color,
          badgeFill: active ? color : AppColors.creamDark,
          plusColor: active ? AppColors.white : color,
        ),
      );
}

class OtherTabIcon extends StatelessWidget {
  const OtherTabIcon({super.key, required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) =>
      _TabIconBase(painter: _OtherPainter(color));
}

class _DiaryPainter extends CustomPainter {
  _DiaryPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Front cover: rect x=3 y=2 w=12 h=18 rx=2
    stroke.strokeWidth = 1.6;
    final coverRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(3, 2, 12, 18),
      const Radius.circular(2),
    );
    canvas.drawRRect(coverRect, stroke);

    // Back cover edge: M15 5h2 a2 2 0 012 2v11 a2 2 0 01-2 2H7
    final back = Path()
      ..moveTo(15, 5)
      ..lineTo(17, 5)
      ..arcToPoint(const Offset(19, 7), radius: const Radius.circular(2))
      ..lineTo(19, 18)
      ..arcToPoint(const Offset(17, 20), radius: const Radius.circular(2))
      ..lineTo(7, 20);
    canvas.drawPath(back, stroke);

    // Text lines on the cover: 7,7→12,7  7,10.5→12,10.5  7,14→10,14
    final lines = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawLine(const Offset(7, 7), const Offset(12, 7), lines)
      ..drawLine(const Offset(7, 10.5), const Offset(12, 10.5), lines)
      ..drawLine(const Offset(7, 14), const Offset(10, 14), lines);
  }

  @override
  bool shouldRepaint(covariant _DiaryPainter old) => old.color != color;
}

class _RecipesPainter extends CustomPainter {
  _RecipesPainter({
    required this.stroke,
    required this.badgeFill,
    required this.plusColor,
  });
  final Color stroke;
  final Color badgeFill;
  final Color plusColor;

  @override
  void paint(Canvas canvas, Size size) {
    final outlinePaint = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    // Card: rounded rect 4,3 → 18,18
    final card = RRect.fromRectAndRadius(
      const Rect.fromLTWH(3, 3, 16, 16),
      const Radius.circular(1),
    );
    canvas.drawRRect(card, outlinePaint);

    // Lines
    final lines = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawLine(const Offset(7, 8), const Offset(15, 8), lines)
      ..drawLine(const Offset(7, 11.5), const Offset(15, 11.5), lines)
      ..drawLine(const Offset(7, 15), const Offset(12, 15), lines);

    // Plus badge: circle r=3.5 at (16,15)
    final badgeFillPaint = Paint()..color = badgeFill;
    final badgeStroke = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas
      ..drawCircle(const Offset(16, 15), 3.5, badgeFillPaint)
      ..drawCircle(const Offset(16, 15), 3.5, badgeStroke);

    // + symbol inside badge
    final plus = Paint()
      ..color = plusColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawLine(const Offset(16, 13.5), const Offset(16, 16.5), plus)
      ..drawLine(const Offset(14.5, 15), const Offset(17.5, 15), plus);
  }

  @override
  bool shouldRepaint(covariant _RecipesPainter old) =>
      old.stroke != stroke ||
      old.badgeFill != badgeFill ||
      old.plusColor != plusColor;
}

class _OtherPainter extends CustomPainter {
  _OtherPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final outline = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawCircle(const Offset(11, 11), 8.5, outline);

    final dot = Paint()..color = color;
    canvas
      ..drawCircle(const Offset(7.5, 11), 1.2, dot)
      ..drawCircle(const Offset(11, 11), 1.2, dot)
      ..drawCircle(const Offset(14.5, 11), 1.2, dot);
  }

  @override
  bool shouldRepaint(covariant _OtherPainter old) => old.color != color;
}
