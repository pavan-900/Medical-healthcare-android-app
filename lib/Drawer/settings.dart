import 'package:flutter/material.dart';

class settings extends StatelessWidget {
  final List<Map<String, dynamic>> data = [
    {"label": "Gene score 1", "value": 128311, "color": Colors.blue},
    {"label": "Gene score 2", "value": 76102, "color": Colors.orange},
    {"label": "Gene score 3", "value": 75578, "color": Colors.green},
    {"label": "Gene score 7", "value": 95926, "color": Colors.greenAccent},
    {"label": "Gene score 9", "value": 35710, "color": Colors.lightGreen},
    {"label": "Gene score 4", "value": 73151, "color": Colors.red},
    {"label": "Gene score 6", "value": 66772, "color": Colors.redAccent},
    {"label": "Gene score 5 ", "value": 84904, "color": Colors.deepOrange},
    {"label": "Gene score 8", "value": 62248, "color": Colors.blueAccent},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Center(
        child: SingleChildScrollView(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 16.0,
            runSpacing: 16.0,
            children: data.map((item) {
              final double size = item['value'] / 1000; // Scale for circle size
              return Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item['color'],
                ),
                child: Center(
                  child: Text(
                    '${item['label']}\n\$${item['value']}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}