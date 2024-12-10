import 'package:flutter/material.dart';
import '../services/gene_service.dart';
import '../models/gene.dart';

class SearchPage extends StatefulWidget {
  final String diseaseName;

  SearchPage({required this.diseaseName});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController geneController = TextEditingController();
  final GeneService geneService = GeneService();
  String? geneName;
  int? geneScore;
  bool showResult = false;

  Future<void> _searchGene() async {
    String enteredGene = geneController.text.trim();
    if (enteredGene.isNotEmpty) {
      List<Gene> geneData = await geneService.fetchGenesByCondition(widget.diseaseName, enteredGene);

      if (geneData.isNotEmpty) {
        setState(() {
          geneName = geneData.first.geneName;
          geneScore = geneData.first.geneScore;
          showResult = true;
        });
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF7E4EC), // Soft Pink
              Color(0xFFDEE7F1), // Light Blue
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                    borderSide: BorderSide(color: Colors.blueGrey[700]!, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.blueGrey[900]!, width: 3),
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
            ],
          ),
        ),
      ),
    );
  }
}
