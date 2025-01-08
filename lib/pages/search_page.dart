import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/gene_service.dart';
import '../services/gene_api_service.dart';
import '../models/gene.dart';
import 'references_selection_page.dart';

class SearchPage extends StatefulWidget {
  final String conditionName;

  SearchPage({required this.conditionName});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController geneController = TextEditingController();
  final GeneService geneService = GeneService();
  final GeneAPIService geneAPIService = GeneAPIService();
  String? geneName;
  int? geneScore;
  bool showResult = false;
  String? pharmGKBId;
  List<Gene> otherConditionGenes = [];
  bool isSaved = false; // Track saved status

  @override
  void initState() {
    super.initState();
    geneController.addListener(() {
      setState(() {}); // Update UI whenever input changes
    });
  }

  Future<void> _checkIfGeneIsSaved() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null || geneName == null) return;

    final query = await FirebaseFirestore.instance
        .collection('saved_genes')
        .where('userId', isEqualTo: userId)
        .where('geneName', isEqualTo: geneName)
        .where('currentCondition', isEqualTo: widget.conditionName)
        .get();

    setState(() {
      isSaved = query.docs.isNotEmpty;
    });
  }

  Future<void> _searchGene() async {
    String enteredGene = geneController.text.trim();
    if (enteredGene.isNotEmpty) {
      final geneData = await geneService.fetchGeneAndCheckOtherConditions(widget.conditionName, enteredGene);

      final currentConditionGenes = geneData['currentCondition'];
      final fetchedOtherConditionGenes = geneData['otherConditions'];

      if (currentConditionGenes.isNotEmpty) {
        setState(() {
          geneName = currentConditionGenes.first.geneName;
          geneScore = currentConditionGenes.first.geneScore;
          showResult = true;
          otherConditionGenes = fetchedOtherConditionGenes;
        });

        // Fetch PharmGKB ID
        final fetchedPharmGKBId = await geneAPIService.fetchPharmGKBId(geneName!);

        setState(() {
          pharmGKBId = fetchedPharmGKBId;
        });

        // Check if the gene is already saved
        _checkIfGeneIsSaved();
      } else {
        setState(() {
          geneName = "No results found in ${widget.conditionName}.";
          geneScore = null;
          showResult = true;
          otherConditionGenes = [];
        });
      }
    }
  }

  Future<void> _saveGene() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You must be logged in to save a gene.")),
      );
      return;
    }

    if (geneName != null && geneScore != null) {
      try {
        await FirebaseFirestore.instance.collection('saved_genes').add({
          'geneName': geneName,
          'geneScore': geneScore,
          'currentCondition': widget.conditionName,
          'otherConditions': otherConditionGenes
              .map((gene) => {
            'condition': gene.condition,
            'score': gene.geneScore,
          })
              .toList(),
          'userId': userId,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gene saved successfully!")),
        );

        // Update saved status
        _checkIfGeneIsSaved();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save gene: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No gene to save.")),
      );
    }
  }

  Future<void> _unsaveGene() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null || geneName == null) return;

    final query = await FirebaseFirestore.instance
        .collection('saved_genes')
        .where('userId', isEqualTo: userId)
        .where('geneName', isEqualTo: geneName)
        .where('currentCondition', isEqualTo: widget.conditionName)
        .get();

    for (var doc in query.docs) {
      await doc.reference.delete();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Gene unsaved successfully!")),
    );

    // Update saved status
    _checkIfGeneIsSaved();
  }

  Widget _buildSaveUnsaveButton() {
    return ElevatedButton(
      onPressed: isSaved ? _unsaveGene : _saveGene,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSaved ? Colors.grey : Colors.blueGrey[900],
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
      child: Text(
        isSaved ? 'Unsave Gene' : 'Save Gene',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  List<BarChartGroupData> _generateBarGroups() {
    return otherConditionGenes.asMap().entries.map((entry) {
      final int index = entry.key;
      final Gene gene = entry.value;

      final double geneScore = gene.geneScore.toDouble().isFinite ? gene.geneScore.toDouble() : 0;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: geneScore,
            color: Colors.orange,
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
        showingTooltipIndicators: [0],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Search Gene in ${widget.conditionName}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.black,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        elevation: 4,
        shadowColor: Colors.grey.withOpacity(0.5),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
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
              SizedBox(height: 20),
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
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.blueGrey[700]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.blueGrey[900]!, width: 2),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search, color: Colors.blueGrey[900]),
                    onPressed: _searchGene,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              if (showResult) ...[
                Container(
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
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Search Result',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[900],
                        ),
                      ),
                      Divider(color: Colors.blueGrey[300], thickness: 1),
                      Text(
                        'Gene Name: $geneName',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Gene Score: $geneScore',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildSaveUnsaveButton(), // Save/Unsave Button
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReferencesSelectionPage(
                                geneSymbol: geneName!,
                                pharmGKBId: pharmGKBId ?? '',
                                currentCondition: widget.conditionName,
                                otherConditions: otherConditionGenes.map((gene) => {
                                  'condition': gene.condition,
                                  'score': gene.geneScore,
                                }).toList(),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          'View References',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (otherConditionGenes.isNotEmpty) ...[
                  SizedBox(height: 30),
                  Text(
                    'Also Found in Other Conditions:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[900],
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orangeAccent.withOpacity(0.3),
                          blurRadius: 6,
                          spreadRadius: 2,
                          offset: Offset(2, 3),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(10),
                    child: SizedBox(
                      height: 400,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 9,
                          barGroups: _generateBarGroups(),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                getTitlesWidget: (value, meta) {
                                  int index = value.toInt();
                                  if (index < otherConditionGenes.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        otherConditionGenes[index].condition,
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    );
                                  }
                                  return Text('');
                                },
                              ),
                              axisNameWidget: Text(
                                'Conditions',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() >= 1 && value.toInt() <= 9) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: TextStyle(fontSize: 12),
                                    );
                                  }
                                  return Text('');
                                },
                              ),
                              axisNameWidget: Text(
                                'Gene Score',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
