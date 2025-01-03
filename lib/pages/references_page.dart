import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/gene_api_service.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ReferencesPage extends StatefulWidget {
  final String geneSymbol;
  final String pharmGKBId;
  final String currentCondition;
  final List<Map<String, dynamic>> otherConditions;

  ReferencesPage({
    required this.geneSymbol,
    required this.pharmGKBId,
    required this.currentCondition,
    required this.otherConditions,
  });

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
    try {
      final geneAPIService = GeneAPIService();
      final fetchedReferences =
      await geneAPIService.fetchCrossReferences(widget.pharmGKBId);

      setState(() {
        references = fetchedReferences;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching references: $e");
      setState(() {
        references = [];
        isLoading = false;
      });
    }
  }

  Future<String?> _getSavedReferenceId(String referenceName) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return null;
    }

    final query = await FirebaseFirestore.instance
        .collection('saved_pharmgkb_references')
        .where('userId', isEqualTo: userId)
        .where('referenceName', isEqualTo: referenceName)
        .where('currentCondition', isEqualTo: widget.currentCondition)
        .get();

    return query.docs.isNotEmpty ? query.docs.first.id : null;
  }

  Future<void> _saveReference(Map<String, String> reference) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You must be logged in to save a reference.")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('saved_pharmgkb_references').add({
        'geneName': widget.geneSymbol,
        'currentCondition': widget.currentCondition,
        'referenceName': reference['resource'] ?? 'Unknown Resource',
        'referenceURL': reference['url'] ?? '',
        'userId': userId,
        'otherConditions': widget.otherConditions
            .map((condition) => condition['condition'] as String)
            .toList(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Reference saved successfully!")),
      );
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save reference: $e")),
      );
    }
  }

  Future<void> _unsaveReference(String referenceId) async {
    try {
      await FirebaseFirestore.instance
          .collection('saved_pharmgkb_references')
          .doc(referenceId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Reference unsaved successfully!")),
      );
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to unsave reference: $e")),
      );
    }
  }

  void _openWebView(String url) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WebViewPage(url: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'References for ${widget.geneSymbol}',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Condition: ${widget.currentCondition}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.blueGrey[800],
              ),
            ),
            SizedBox(height: 10),
            if (widget.otherConditions.isNotEmpty) ...[
              Text(
                'Other Conditions:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blueGrey[700],
                ),
              ),
              SizedBox(height: 5),
              ...widget.otherConditions.map((condition) {
                return Padding(
                  padding: const EdgeInsets.only(left: 10.0, bottom: 5.0),
                  child: Text(
                    '- ${condition['condition']} (Score: ${condition['score']})',
                    style: TextStyle(fontSize: 14, color: Colors.blueGrey[600]),
                  ),
                );
              }).toList(),
            ],
            SizedBox(height: 20),
            Expanded(
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
                          GestureDetector(
                            onTap: () {
                              final url = reference['url'];
                              if (url != null && url.isNotEmpty) {
                                _openWebView(url);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('No URL available'),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              reference['url'] ?? 'No URL',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          FutureBuilder<String?>(
                            future: _getSavedReferenceId(reference['resource'] ?? ''),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              }
                              final referenceId = snapshot.data;
                              final isSaved = referenceId != null;
                              return ElevatedButton(
                                onPressed: () => isSaved
                                    ? _unsaveReference(referenceId!)
                                    : _saveReference(reference),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                  isSaved ? Colors.grey : Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  isSaved ? 'Unsave Reference' : 'Save Reference',
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WebViewPage extends StatelessWidget {
  final String url;

  const WebViewPage({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reference',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(url)),
        onLoadStart: (controller, url) {},
        onLoadStop: (controller, url) {},
      ),
    );
  }
}
