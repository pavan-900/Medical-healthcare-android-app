import 'package:flutter/material.dart';
import '../services/gene_api_service.dart';

class ReferencesPage extends StatefulWidget {
  final String geneSymbol;
  final String pharmGKBId; // Add this parameter

  ReferencesPage({required this.geneSymbol, required this.pharmGKBId});

  @override
  _ReferencesPageState createState() => _ReferencesPageState();
}

class _ReferencesPageState extends State<ReferencesPage> {
  List<Map<String, String>> references = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReferences();
  }

  Future<void> _fetchReferences() async {
    final geneAPIService = GeneAPIService();
    final fetchedReferences =
    await geneAPIService.fetchCrossReferences(widget.pharmGKBId);

    setState(() {
      references = fetchedReferences;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('References for ${widget.geneSymbol}'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : references.isEmpty
          ? Center(
        child: Text(
          'No references found',
          style: TextStyle(fontSize: 18, color: Colors.red),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: references.length,
          itemBuilder: (context, index) {
            final reference = references[index];
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reference['resource'] ?? 'Unknown Resource',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      reference['url'] ?? 'No URL',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blueGrey[700],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
