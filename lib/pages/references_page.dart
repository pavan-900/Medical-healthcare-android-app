import 'package:flutter/material.dart';
import '../services/gene_api_service.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ReferencesPage extends StatefulWidget {
  final String geneSymbol;
  final String pharmGKBId;

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
                    GestureDetector(
                      onTap: () {
                        if (reference['url'] != null) {
                          _openWebView(reference['url']!);
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

class WebViewPage extends StatelessWidget {
  final String url;

  const WebViewPage({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reference'),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(url)),
        onLoadStart: (controller, url) {
          // Optional: Show loading indicator
        },
        onLoadStop: (controller, url) {
          // Optional: Hide loading indicator
        },
      ),
    );
  }
}