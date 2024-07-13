import 'package:flutter/material.dart';
import 'dart:math' as math;

class CurrentDirectionPaintWidget extends CustomPainter {
  final double angle;
  final double length;
  final double percentageStart;

  late Paint _paint;
  CurrentDirectionPaintWidget({
    required this.angle,
    required this.length,
    required this.percentageStart,
  }) {
    _paint = Paint()
      ..color = Colors.blue.withOpacity(.25)
      ..strokeCap = StrokeCap.square
      ..strokeWidth = 5;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final halfAngle = 90 - (angle / 2);
    final halfAngleRadians = (halfAngle * (math.pi / 180));
    final percentageOfAngle = 1 - (angle / 180);
    final useLength = length * percentageOfAngle;
    final percentageLength = (useLength * (percentageStart / 100));
    final topDistance = useLength / math.tan(halfAngleRadians);

    final startDistance = percentageLength / math.tan(halfAngleRadians);
    final midWidth = size.width / 2;

    Path path = Path();
    path.moveTo(midWidth - topDistance, length - useLength);
    path.lineTo(midWidth - startDistance, useLength - percentageLength);
    path.lineTo(midWidth + startDistance, useLength - percentageLength);
    path.lineTo(midWidth + topDistance, length - useLength);
    path.quadraticBezierTo(
        midWidth, 0, midWidth - topDistance, length - useLength);
    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
