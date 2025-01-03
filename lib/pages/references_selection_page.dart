import 'package:flutter/material.dart';
import 'references_page.dart'; // Your existing PharmGKB references page
import 'pubtutor_references_page.dart'; // A new page for PubTutor references

class ReferencesSelectionPage extends StatelessWidget {
  final String geneSymbol;
  final String pharmGKBId;
  final String currentCondition;
  final List<Map<String, dynamic>> otherConditions; // Added other conditions

  ReferencesSelectionPage({
    required this.geneSymbol,
    required this.pharmGKBId,
    required this.currentCondition,
    required this.otherConditions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Reference Source',
          style: TextStyle(color: Colors.white), // Set the text color to white
        ),
        backgroundColor: Colors.blue[400], // Set the background color to blue
        iconTheme: IconThemeData(color: Colors.white), // Set the back button color to white
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReferencesPage(
                      geneSymbol: geneSymbol,
                      pharmGKBId: pharmGKBId,
                      currentCondition: currentCondition, // Pass current condition
                      otherConditions: otherConditions,   // Pass other conditions
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey[900],
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              ),
              child: Text(
                'View References from PharmGKB',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PubTutorReferencesPage(
                      geneSymbol: geneSymbol,
                      currentCondition: currentCondition, // Pass current condition
                      otherConditions: otherConditions,   // Pass other conditions
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              ),
              child: Text(
                'View References from PubTutor',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
