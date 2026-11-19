import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sparkline_lite/sparkline_lite.dart';

void main() {
  test('points span the box, low values at the bottom', () {
    final p = sparklinePoints([0, 10, 5], const Size(100, 50));
    expect(p.first, const Offset(0, 50));
    expect(p[1], const Offset(50, 0));
    expect(p.last, const Offset(100, 25));
  });

  test('flat and single-value series stay centered', () {
    expect(sparklinePoints([3, 3], const Size(100, 40)).first.dy, 20);
    expect(
        sparklinePoints([7], const Size(100, 40)).single, const Offset(50, 20));
    expect(sparklinePoints([], const Size(100, 40)), isEmpty);
  });

  test('padding insets the points', () {
    final p = sparklinePoints([0, 1], const Size(100, 50), padding: 5);
    expect(p.first, const Offset(5, 45));
    expect(p.last, const Offset(95, 5));
  });

  testWidgets('renders with the given size', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home:
          Center(child: Sparkline(data: [1, 3, 2, 5], width: 150, height: 40)),
    ));
    expect(tester.getSize(find.byType(Sparkline)), const Size(150, 40));
  });
}
