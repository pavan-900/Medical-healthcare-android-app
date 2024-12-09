import 'package:flutter/material.dart';
import 'search_page.dart';

class HomePage extends StatelessWidget {
  final List<String> diseaseNames = [
    'Anxiety', 'Diabetes', 'Cardiac', 'Liver', 'Obesity', 'Cancer', // Continue the list
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Disease Conditions'),
        centerTitle: true,
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: diseaseNames.length,
        itemBuilder: (context, index) {
          String disease = diseaseNames[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchPage(diseaseName: disease),
                ),
              );
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: Colors.blueAccent,
              elevation: 5,
              child: Center(
                child: Text(
                  disease,
                  style: TextStyle(fontSize: 20, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
