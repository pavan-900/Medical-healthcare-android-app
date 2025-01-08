import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:intl/intl.dart';

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
        iconTheme: IconThemeData(color: Colors.white),
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
              final otherConditions = List<String>.from(reference['otherConditions'] ?? []);
              final String? rawDate = reference['date'];
              String formattedDate = 'Unknown Date';

              // Format the date if available
              if (rawDate != null && rawDate.isNotEmpty) {
                try {
                  final DateTime date = DateTime.parse(rawDate);
                  formattedDate = DateFormat('d MMMM, yyyy').format(date); // Example: 13 June, 2024
                } catch (e) {
                  formattedDate = 'Invalid Date';
                }
              }

              return Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // PMID, PMCID, and Date
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'PMID: ${reference['pmid'] ?? 'N/A'} . ${reference['pmcid'] ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                            ),
                          ),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      // Title
                      Text(
                        reference['title'] ?? 'No Title',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 6),
                      // Journal
                      Text(
                        'Journal: ${reference['journal'] ?? 'No Journal'}',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 14,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                      SizedBox(height: 6),
                      // Authors
                      Text(
                        'Authors: ${reference['authors'] ?? 'No Authors'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 6),
                      // Link
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
                      SizedBox(height: 8),
                      Divider(color: Colors.grey[300]),
                      SizedBox(height: 8),
                      // Additional Info (Gene Name, Condition, and Other Conditions)
                      Text(
                        'Gene: ${reference['geneName'] ?? 'N/A'}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Condition: ${reference['currentCondition'] ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[800],
                        ),
                      ),
                      if (otherConditions.isNotEmpty) ...[
                        SizedBox(height: 6),
                        Text(
                          'Other Conditions:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        ...otherConditions.map((condition) => Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            '- $condition',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blueGrey[800],
                            ),
                          ),
                        )),
                      ],
                      SizedBox(height: 12),
                      // Delete Button
                      Align(
                        alignment: Alignment.centerRight,
                        child: Transform.translate(
                          offset: Offset(0, -6), // Move the delete icon upwards
                          child: IconButton(
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
                        ),
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
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[400],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri.uri(Uri.parse(url))),
      ),
    );
  }
}
