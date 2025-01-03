import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:intl/intl.dart';
import '../services/pubtutor_api_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PubTutorReferencesPage extends StatefulWidget {
  final String geneSymbol;
  final String currentCondition;
  final List<Map<String, dynamic>> otherConditions;

  PubTutorReferencesPage({
    required this.geneSymbol,
    required this.currentCondition,
    required this.otherConditions,
  });

  @override
  _PubTutorReferencesPageState createState() => _PubTutorReferencesPageState();
}

class _PubTutorReferencesPageState extends State<PubTutorReferencesPage> {
  final PubTutorAPIService _apiService = PubTutorAPIService();
  List<Map<String, String>> references = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchReferences();
  }

  Future<void> _fetchReferences() async {
    try {
      final results = await _apiService.fetchReferences(widget.geneSymbol);
      setState(() {
        references = results;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<String?> _getSavedReferenceId(String title) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return null;
    }

    final query = await FirebaseFirestore.instance
        .collection('saved_pubtutor_references')
        .where('userId', isEqualTo: userId)
        .where('title', isEqualTo: title)
        .where('currentCondition', isEqualTo: widget.currentCondition)
        .get();

    return query.docs.isNotEmpty ? query.docs.first.id : null;
  }

  Future<void> _saveReference(Map<String, String> ref) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You must be logged in to save a reference.')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('saved_pubtutor_references').add({
        'geneName': widget.geneSymbol,
        'currentCondition': widget.currentCondition,
        'title': ref['title'] ?? 'No Title',
        'authors': ref['authors'] ?? 'No Authors',
        'journal': ref['journal'] ?? 'No Journal',
        'date': ref['date'] ?? 'Unknown Date',
        'pmid': ref['pmid'] ?? 'Unknown',
        'pmcid': ref['pmcid'] ?? 'Unknown',
        'link': ref['link'] ?? 'No Link',
        'otherConditions': widget.otherConditions.map((cond) => cond['condition']).toList(),
        'userId': userId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reference saved successfully!')),
      );
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save reference: $e')),
      );
    }
  }

  Future<void> _unsaveReference(String referenceId) async {
    try {
      await FirebaseFirestore.instance
          .collection('saved_pubtutor_references')
          .doc(referenceId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reference unsaved successfully!')),
      );
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to unsave reference: $e')),
      );
    }
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return "Unknown Date";
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat.yMMMd().format(parsedDate);
    } catch (e) {
      return "Invalid Date";
    }
  }

  void _openInAppWebView(String url) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InAppWebViewPage(url: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PubTutor References for ${widget.geneSymbol}',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[400],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
        child: Text(
          errorMessage,
          style: TextStyle(fontSize: 16, color: Colors.red),
        ),
      )
          : references.isEmpty
          ? Center(
        child: Text(
          "No references found for ${widget.geneSymbol} in PubTutor.",
          style: TextStyle(fontSize: 16, color: Colors.red),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: references.length,
          itemBuilder: (context, index) {
            final ref = references[index];
            final pmid = ref['pmid'] ?? 'Unknown';
            final pmcid = ref['pmcid']?.isNotEmpty == true ? ref['pmcid']! : "";
            return Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "PMID: $pmid ${pmcid.isNotEmpty ? '• $pmcid' : ''}",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue),
                        ),
                        Text(
                          _formatDate(ref['date']),
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      ref['title'] ?? 'No Title',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Journal: ${ref['journal'] ?? 'No Journal'}",
                      style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Authors: ${ref['authors'] ?? 'No Authors'}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        final url = ref['link'];
                        if (url != null && url.isNotEmpty) {
                          _openInAppWebView(url);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("No link available"),
                          ));
                        }
                      },
                      child: Text(
                        ref['link'] ?? 'No Link',
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                            decoration: TextDecoration.underline),
                      ),
                    ),
                    SizedBox(height: 8),
                    FutureBuilder<String?>(
                      future: _getSavedReferenceId(ref['title'] ?? ''),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        final referenceId = snapshot.data;
                        final isSaved = referenceId != null;
                        return ElevatedButton(
                          onPressed: () => isSaved
                              ? _unsaveReference(referenceId!)
                              : _saveReference(ref),
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
    );
  }
}

class InAppWebViewPage extends StatelessWidget {
  final String url;

  const InAppWebViewPage({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reference'),
        backgroundColor: Colors.blue[400],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(url)),
      ),
    );
  }
}
