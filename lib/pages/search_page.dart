import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart' as pc;
import '../services/gene_service.dart';
import '../services/gene_api_service.dart'; // Import for API service
import '../models/gene.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'references_page.dart'; // Import the ReferencesPage

class SearchPage extends StatefulWidget {
  final String diseaseName;

  SearchPage({required this.diseaseName});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController geneController = TextEditingController();
  final GeneService geneService = GeneService();
  final GeneAPIService geneAPIService = GeneAPIService(); // API service instance
  String? geneName;
  int? geneScore;
  bool showResult = false;

  // Static gene score data for diseases
  final Map<String, Map<String, double>> diseaseGeneScores = {
    "Anxiety": {
      "Gene Score 1": 12,
      "Gene Score 2": 8,
      "Gene Score 3": 15,
      "Gene Score 4": 10,
      "Gene Score 5": 5,
      "Gene Score 6": 7,
      "Gene Score 7": 9,
      "Gene Score 8": 10,
      "Gene Score 9": 20,
    },
    "Diabetes": {
      "Gene Score 1": 14,
      "Gene Score 2": 9,
      "Gene Score 3": 18,
      "Gene Score 4": 20,
      "Gene Score 5": 6,
      "Gene Score 6": 15,
      "Gene Score 7": 12,
      "Gene Score 8": 8,
      "Gene Score 9": 25,
    },
    "Middle": {
      "Gene Score 1": 10,
      "Gene Score 2": 15,
      "Gene Score 3": 18,
      "Gene Score 4": 20,
      "Gene Score 5": 5,
      "Gene Score 6": 12,
      "Gene Score 7": 8,
      "Gene Score 8": 22,
      "Gene Score 9": 30,
    },
    "CAD": {
      "Gene Score 1": 5,
      "Gene Score 2": 10,
      "Gene Score 3": 12,
      "Gene Score 4": 15,
      "Gene Score 5": 20,
      "Gene Score 6": 25,
      "Gene Score 7": 10,
      "Gene Score 8": 18,
      "Gene Score 9": 30,
    },
    "Liver": {
      "Gene Score 1": 8,
      "Gene Score 2": 12,
      "Gene Score 3": 15,
      "Gene Score 4": 25,
      "Gene Score 5": 10,
      "Gene Score 6": 15,
      "Gene Score 7": 20,
      "Gene Score 8": 18,
      "Gene Score 9": 12,
    },
    "Obesity": {
      "Gene Score 1": 20,
      "Gene Score 2": 15,
      "Gene Score 3": 10,
      "Gene Score 4": 8,
      "Gene Score 5": 12,
      "Gene Score 6": 15,
      "Gene Score 7": 18,
      "Gene Score 8": 10,
      "Gene Score 9": 5,
    },
    "Cancer": {
      "Gene Score 1": 15,
      "Gene Score 2": 20,
      "Gene Score 3": 10,
      "Gene Score 4": 12,
      "Gene Score 5": 8,
      "Gene Score 6": 18,
      "Gene Score 7": 10,
      "Gene Score 8": 25,
      "Gene Score 9": 30,
    },
  };

  Future<void> _searchGene() async {
    String enteredGene = geneController.text.trim();
    if (enteredGene.isNotEmpty) {
      List<Gene> geneData =
      await geneService.fetchGenesByCondition(widget.diseaseName, enteredGene);

      if (geneData.isNotEmpty) {
        final geneName = geneData.first.geneName;
        final pharmGKBId = await geneAPIService.fetchPharmGKBId(geneName);

        if (pharmGKBId != null) {
          // Navigate to ReferencesPage with PharmGKB ID
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ReferencesPage(
                    geneSymbol: geneName,
                    pharmGKBId: pharmGKBId,
                  ),
            ),
          );
        } else {
          setState(() {
            this.geneName = "No PharmGKB ID found for $geneName";
            this.geneScore = null;
            showResult = true;
          });
        }
      } else {
        setState(() {
          geneName = "No results found";
          geneScore = null;
          showResult = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, double> pieChartData =
        diseaseGeneScores[widget.diseaseName] ?? {};

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Search Gene in ${widget.diseaseName}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        elevation: 8,
        shadowColor: Colors.grey.withOpacity(0.5),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF7E4EC),
                Color(0xFFDEE7F1),
              ],
            ),
          ),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Find Gene Information',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[900],
                ),
              ),
              SizedBox(height: 30),
              TextField(
                controller: geneController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Enter Gene Name',
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[700],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.blueGrey[700]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                        color: Colors.blueGrey[700]!, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                        color: Colors.blueGrey[900]!, width: 3),
                  ),
                ),
                style: TextStyle(fontSize: 18, color: Colors.blueGrey[900]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _searchGene,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[900],
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 10,
                ),
                child: Text(
                  'Search',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 30),
              if (showResult) ...[
                AnimatedContainer(
                  duration: Duration(seconds: 1),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 6,
                        spreadRadius: 2,
                        offset: Offset(2, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Search Result',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[900],
                        ),
                      ),
                      Divider(
                        color: Colors.blueGrey[200],
                        thickness: 1,
                        height: 20,
                      ),
                      if (geneScore != null) ...[
                        Text(
                          'Gene Name: $geneName',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.blueGrey[800],
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Gene Score: $geneScore',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.blueGrey[800],
                          ),
                        ),
                      ] else
                        Text(
                          geneName!,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 30),
              Text(
                'Gene Scores for ${widget.diseaseName}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[900],
                ),
              ),
              SizedBox(height: 20),
              if (pieChartData.isNotEmpty)
                pc.PieChart(
                  dataMap: pieChartData,
                  animationDuration: Duration(milliseconds: 800),
                  chartLegendSpacing: 32,
                  chartRadius: MediaQuery
                      .of(context)
                      .size
                      .width / 2.5,
                  colorList: [
                    Colors.red,
                    Colors.orange,
                    Colors.yellow,
                    Colors.green,
                    Colors.blue,
                    Colors.purple,
                    Colors.pink,
                    Colors.cyan,
                    Colors.lime,
                  ],
                  initialAngleInDegree: 0,
                  chartType: pc.ChartType.ring,
                  ringStrokeWidth: 32,
                  centerText: widget.diseaseName,
                  legendOptions: pc.LegendOptions(
                    showLegendsInRow: true,
                    legendPosition: pc.LegendPosition.bottom,
                    legendShape: BoxShape.circle,
                    legendTextStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  chartValuesOptions: pc.ChartValuesOptions(
                    showChartValueBackground: true,
                    showChartValues: true,
                    showChartValuesInPercentage: false,
                    showChartValuesOutside: false,
                    decimalPlaces: 1,
                  ),
                )
              else
                Text(
                  'No data available for ${widget.diseaseName}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
            ],
          ),
        ),
      ),
    );
  }
}