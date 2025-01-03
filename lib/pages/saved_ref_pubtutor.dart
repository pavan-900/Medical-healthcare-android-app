import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class SavedPubTutorReferencesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Saved PubTutor References',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[400],
        iconTheme: IconThemeData(color: Colors.white), // Ensures the back arrow is white
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('saved_pubtutor_references')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No saved references found for PubTutor.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final savedReferences = snapshot.data!.docs;

          return ListView.builder(
            itemCount: savedReferences.length,
            itemBuilder: (context, index) {
              final reference = savedReferences[index];
              final otherConditions = List<String>.from(
                  reference['otherConditions'] ?? []);

              return Card(
                elevation: 6,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reference['title'] ?? 'No Title',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Gene: ${reference['geneName']}'),
                      Text('Condition: ${reference['currentCondition']}'),
                      SizedBox(height: 8),
                      Text('Journal: ${reference['journal'] ?? 'No Journal'}',
                          style: TextStyle(
                              fontStyle: FontStyle.italic, fontSize: 14)),
                      SizedBox(height: 8),
                      Text('Authors: ${reference['authors'] ?? 'No Authors'}',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey[700])),
                      SizedBox(height: 8),
                      Text(
                        'Publication Date: ${reference['date'] ?? 'Unknown Date'}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 8),
                      Text('PMID: ${reference['pmid'] ?? 'No PMID'}'),
                      Text('PMCID: ${reference['pmcid'] ?? 'No PMCID'}'),
                      SizedBox(height: 8),
                      if (otherConditions.isNotEmpty) ...[
                        Text(
                          'Other Conditions:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        SizedBox(height: 5),
                        ...otherConditions.map((condition) => Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            '- $condition',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blueGrey[600],
                            ),
                          ),
                        )),
                      ],
                      SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          final url = reference['link'];
                          if (url != null && url.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WebViewPage(url: url),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('No URL available')),
                            );
                          }
                        },
                        child: Text(
                          reference['link'] ?? 'No Link',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              try {
                                await reference.reference.delete();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Reference deleted.')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to delete: $e')),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class WebViewPage extends StatelessWidget {
  final String url;

  const WebViewPage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reference',
          style: TextStyle(color: Colors.white), // Ensures the header text color is white
        ),
        backgroundColor: Colors.blue[400],
        iconTheme: IconThemeData(color: Colors.white), // Ensures the back arrow color is white
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri.uri(Uri.parse(url))),
      ),
    );
  }
}
