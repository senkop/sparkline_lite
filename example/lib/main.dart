import 'package:flutter/material.dart';
import 'package:sparkline_lite/sparkline_lite.dart';

void main() => runApp(const MaterialApp(home: DemoPage()));

class DemoPage extends StatelessWidget {
  const DemoPage({super.key});

  static const List<(String, List<double>, Color)> rows = [
    ('Revenue', [12.0, 14, 13, 17, 16, 21, 24], Colors.green),
    ('Orders', [40.0, 38, 42, 35, 33, 30, 31], Colors.red),
    ('Visitors', [5.0, 9, 7, 12, 10, 14, 13], Colors.indigo),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('sparkline_lite')),
      body: ListView(
        children: [
          for (final (name, data, color) in rows)
            ListTile(
              title: Text(name),
              subtitle: Text('${data.last}'),
              trailing: Sparkline(data: data, color: color, showMinMax: true),
            ),
        ],
      ),
    );
  }
}
