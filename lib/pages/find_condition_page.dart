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
            color: Colors.blueGrey[900],
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.blueGrey[900]),
        elevation: 4,
        shadowColor: Colors.grey.withOpacity(0.5),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _geneController,
                decoration: InputDecoration(
                  labelText: 'Enter Gene Name',
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[700],
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.blueGrey[700]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.blueGrey[900]!, width: 2),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search, color: Colors.blueGrey[900]),
                    onPressed: _searchGene,
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _searchGene,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[900],
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
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
              SizedBox(height: 20),
              if (_isLoading)
                Center(child: CircularProgressIndicator())
              else if (_geneResults.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Table(
                    border: TableBorder.all(
                      color: Colors.blueGrey[200]!,
                      width: 1,
                    ),
                    columnWidths: {
                      0: FlexColumnWidth(1),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(2),
                      3: FlexColumnWidth(1),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: Colors.blueGrey[50]),
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
                                ? Colors.blueGrey[50]
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
                )
              else
                Center(
                  child: Text(
                    'No results found. Please try searching for another gene.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blueGrey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
