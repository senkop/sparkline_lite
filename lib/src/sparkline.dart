import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Maps [data] to points inside [size], leaving [padding] on every side.
/// A flat series is drawn along the middle.
List<Offset> sparklinePoints(List<double> data, Size size,
    {double padding = 0}) {
  if (data.isEmpty) return const [];
  final minV = data.reduce(math.min);
  final maxV = data.reduce(math.max);
  final w = size.width - padding * 2;
  final h = size.height - padding * 2;
  final span = maxV - minV;
  return [
    for (var i = 0; i < data.length; i++)
      Offset(
        padding + (data.length == 1 ? w / 2 : w * i / (data.length - 1)),
        padding + (span == 0 ? h / 2 : h - (data[i] - minV) / span * h),
      ),
  ];
}

/// A small line chart.
///
/// ```dart
/// Sparkline(data: [3, 5, 4, 8, 6, 9], color: Colors.green)
/// ```
class Sparkline extends StatelessWidget {
  /// Creates a sparkline.
  const Sparkline({
    super.key,
    required this.data,
    this.width = 120,
    this.height = 36,
    this.color,
    this.strokeWidth = 2,
    this.smooth = true,
    this.fill = true,
    this.showLastPoint = true,
    this.showMinMax = false,
    this.minColor = Colors.red,
    this.maxColor = Colors.green,
  });

  /// The values, oldest first.
  final List<double> data;

  /// Width. Use `double.infinity` to fill the parent.
  final double width;

  /// Height.
  final double height;

  /// Line color. Defaults to the theme's primary color.
  final Color? color;

  /// Line width.
  final double strokeWidth;

  /// Whether to draw a smooth curve instead of straight segments.
  final bool smooth;

  /// Whether to fill the area under the line with a fading gradient.
  final bool fill;

  /// Whether to draw a dot on the last value.
  final bool showLastPoint;

  /// Whether to mark the lowest and highest values.
  final bool showMinMax;

  /// Color of the lowest-value marker.
  final Color minColor;

  /// Color of the highest-value marker.
  final Color maxColor;

  @override
  Widget build(BuildContext context) {
    final lineColor = color ?? Theme.of(context).colorScheme.primary;
    return Semantics(
      label: data.isEmpty
          ? 'Empty chart'
          : 'Trend from ${data.first} to ${data.last}',
      child: SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          painter: _SparklinePainter(
            data: data,
            color: lineColor,
            strokeWidth: strokeWidth,
            smooth: smooth,
            fill: fill,
            showLastPoint: showLastPoint,
            showMinMax: showMinMax,
            minColor: minColor,
            maxColor: maxColor,
          ),
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.data,
    required this.color,
    required this.strokeWidth,
    required this.smooth,
    required this.fill,
    required this.showLastPoint,
    required this.showMinMax,
    required this.minColor,
    required this.maxColor,
  });

  final List<double> data;
  final Color color;
  final double strokeWidth;
  final bool smooth;
  final bool fill;
  final bool showLastPoint;
  final bool showMinMax;
  final Color minColor;
  final Color maxColor;

  @override
  void paint(Canvas canvas, Size size) {
    final points = sparklinePoints(data, size, padding: strokeWidth + 2);
    if (points.isEmpty) return;
    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final p0 = points[i - 1];
      final p1 = points[i];
      if (smooth) {
        final mid = (p0.dx + p1.dx) / 2;
        line.cubicTo(mid, p0.dy, mid, p1.dy, p1.dx, p1.dy);
      } else {
        line.lineTo(p1.dx, p1.dy);
      }
    }
    if (fill && points.length > 1) {
      final area = Path.from(line)
        ..lineTo(points.last.dx, size.height)
        ..lineTo(points.first.dx, size.height)
        ..close();
      canvas.drawPath(
        area,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withAlpha(70), color.withAlpha(0)],
          ).createShader(Offset.zero & size),
      );
    }
    canvas.drawPath(
      line,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );
    if (showMinMax && data.length > 1) {
      final minI = data.indexOf(data.reduce(math.min));
      final maxI = data.indexOf(data.reduce(math.max));
      canvas.drawCircle(
          points[minI], strokeWidth + 1.5, Paint()..color = minColor);
      canvas.drawCircle(
          points[maxI], strokeWidth + 1.5, Paint()..color = maxColor);
    }
    if (showLastPoint) {
      canvas.drawCircle(points.last, strokeWidth + 2, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.data != data || old.color != color || old.smooth != smooth;
}
