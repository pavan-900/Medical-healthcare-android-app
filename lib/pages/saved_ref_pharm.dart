import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class SavedPharmGKBReferencesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Saved PharmGKB References',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[800],
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('saved_pharmgkb_references')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No saved references found for PharmGKB.',
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

              return Card(
                elevation: 6,
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              reference['referenceName'] ?? 'Unknown Reference',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.blueGrey[800],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('saved_pharmgkb_references')
                                  .doc(reference.id)
                                  .delete();

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Reference deleted successfully!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Gene: ${reference['geneName']}',
                        style: TextStyle(fontSize: 16, color: Colors.blueGrey[700]),
                      ),
                      Text(
                        'Condition: ${reference['currentCondition']}',
                        style: TextStyle(fontSize: 16, color: Colors.blueGrey[700]),
                      ),
                      SizedBox(height: 8),
                      if (otherConditions.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Other Conditions:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey[800],
                              ),
                            ),
                            ...otherConditions.map((condition) => Padding(
                              padding: const EdgeInsets.only(left: 10.0, top: 5.0),
                              child: Text(
                                '- $condition',
                                style: TextStyle(fontSize: 14, color: Colors.blueGrey[600]),
                              ),
                            )),
                          ],
                        ),
                      SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          final url = reference['referenceURL'];
                          if (url != null && url.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WebViewPage(url: url),
                              ),
                            );
                          }
                        },
                        child: Text(
                          reference['referenceURL'] ?? 'No URL',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
