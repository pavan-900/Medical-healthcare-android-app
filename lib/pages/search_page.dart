import 'package:flutter/material.dart';
import '../services/gene_service.dart';
import '../models/gene.dart';

class SearchPage extends StatelessWidget {
  final String diseaseName;
  final TextEditingController geneController = TextEditingController();
  final GeneService geneService = GeneService();

  SearchPage({required this.diseaseName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Gene in $diseaseName'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: geneController,
              decoration: InputDecoration(
                labelText: 'Enter Gene Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String geneName = geneController.text.trim();
                if (geneName.isNotEmpty) {
                  List<Gene> geneData = await geneService.fetchGenesByCondition(diseaseName, geneName);

                  if (geneData.isNotEmpty) {
                    var geneScore = geneData.first.geneScore;
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text('Gene Found'),
                        content: Text('Gene Name: $geneName\nGene Score: $geneScore'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text('No Results'),
                        content: Text('Gene not found in $diseaseName.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                }
              },
              child: Text('Search'),
            ),
          ],
        ),
      ),
    );
  }
}
