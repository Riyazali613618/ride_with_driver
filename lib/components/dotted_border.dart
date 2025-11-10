import 'dart:ui';

import 'package:flutter/material.dart';

import '../constants/color_constants.dart';

class DottedBorderPainter extends CustomPainter {
  final double borderRadius;

  DottedBorderPainter({this.borderRadius = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = ColorConstants.greyLight
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final double dashWidth = 5.0;
    final double dashSpace = 3.0;

    // Create a rounded rectangle
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    // Create a path for the rounded rectangle
    final Path path = Path()..addRRect(rrect);

    // Create a dashed path
    final Path dashedPath = _createDashedPath(path, dashWidth, dashSpace);

    // Draw the dashed path
    canvas.drawPath(dashedPath, paint);
  }

  Path _createDashedPath(Path path, double dashWidth, double dashSpace) {
    final Path dashedPath = Path();
    final PathMetrics pathMetrics = path.computeMetrics();

    for (final PathMetric pathMetric in pathMetrics) {
      double distance = 0.0;

      while (distance < pathMetric.length) {
        final Tangent? tangent = pathMetric.getTangentForOffset(distance);

        if (tangent != null) {
          final Offset start = tangent.position;
          distance += dashWidth;

          if (distance > pathMetric.length) {
            distance = pathMetric.length;
          }

          final Tangent? endTangent = pathMetric.getTangentForOffset(distance);
          if (endTangent != null) {
            dashedPath.moveTo(start.dx, start.dy);
            dashedPath.lineTo(endTangent.position.dx, endTangent.position.dy);
          }
          distance += dashSpace;
        }
      }
    }
    return dashedPath;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
