import 'package:flutter/material.dart';
import '../services/gene_service.dart';
import '../models/gene.dart';

class AllGenesSearchPage extends StatefulWidget {
  @override
  _AllGenesSearchPageState createState() => _AllGenesSearchPageState();
}

class _AllGenesSearchPageState extends State<AllGenesSearchPage> {
  final TextEditingController _geneController = TextEditingController();
  final GeneService _geneService = GeneService();
  bool _isLoading = false;
  List<Gene> _geneResults = [];

  @override
  void initState() {
    super.initState();
    _geneController.addListener(() {
      // Automatically convert the text to uppercase
      final text = _geneController.text;
      if (text != text.toUpperCase()) {
        _geneController.value = _geneController.value.copyWith(
          text: text.toUpperCase(),
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    });
  }

  Future<void> _searchGene() async {
    setState(() {
      _isLoading = true;
      _geneResults = [];
    });

    String geneName = _geneController.text.trim();
    if (geneName.isNotEmpty) {
      List<Gene> genes = await _geneService.fetchGenesByName(geneName);

      // Filter out duplicates by using a Set and combining geneName, condition, and geneScore
      final seen = <String>{};
      final uniqueGenes = genes.where((gene) {
        final key = '${gene.geneName}-${gene.condition}-${gene.geneScore}';
        if (seen.contains(key)) {
          return false;
        } else {
          seen.add(key);
          return true;
        }
      }).toList();

      setState(() {
        _geneResults = uniqueGenes;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search All Genes',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[400],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            TextField(
              controller: _geneController,
              decoration: InputDecoration(
                labelText: 'Enter Gene Name',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search, color: Colors.lightBlue),
                  onPressed: _searchGene,
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _searchGene,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 8,
                ),
                child: Text(
                  'Search',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else if (_geneResults.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  child: Table(
                    border: TableBorder.all(
                      color: Colors.blueGrey,
                      width: 1,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    columnWidths: {
                      0: FlexColumnWidth(1),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(2),
                      3: FlexColumnWidth(1),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(
                          color: Colors.blueGrey[50],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'S.No.',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey[900],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Gene Name',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey[900],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Condition',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey[900],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Gene Score',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey[900],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      ..._geneResults.asMap().entries.map((entry) {
                        final index = entry.key + 1;
                        final gene = entry.value;
                        return TableRow(
                          decoration: BoxDecoration(
                            color: index % 2 == 0
                                ? Colors.blueGrey[100]
                                : Colors.white,
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '$index',
                                style: TextStyle(
                                  color: Colors.blueGrey[800],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                gene.geneName,
                                style: TextStyle(
                                  color: Colors.blueGrey[800],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                gene.condition,
                                style: TextStyle(
                                  color: Colors.blueGrey[800],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                gene.geneScore.toString(),
                                style: TextStyle(
                                  color: Colors.blueGrey[800],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              )
            else
              Center(
                child: Text(
                  'No results found. Please try searching for another gene.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
