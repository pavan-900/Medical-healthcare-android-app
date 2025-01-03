import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SavedGenesPage extends StatelessWidget {
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<List<Map<String, dynamic>>> fetchSavedGenes() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('saved_genes')
        .where('userId', isEqualTo: userId)
        .get();

    final allGenes = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Add document ID for deletion
      return data;
    }).toList();

    final seen = <String>{};
    final uniqueGenes = allGenes.where((gene) {
      final uniqueKey = '${gene['geneName']}-${gene['currentCondition']}';
      if (seen.contains(uniqueKey)) {
        return false;
      } else {
        seen.add(uniqueKey);
        return true;
      }
    }).toList();

    return uniqueGenes;
  }

  Future<void> deleteGene(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('saved_genes').doc(docId).delete();
    } catch (e) {
      print("Error deleting gene: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Saved Genes",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blueGrey[900],
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white), // Left arrow color set to white
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchSavedGenes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "No saved genes found.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final savedGenes = snapshot.data!;

          return ListView.builder(
            itemCount: savedGenes.length,
            itemBuilder: (context, index) {
              final gene = savedGenes[index];
              final otherConditions = List<Map<String, dynamic>>.from(
                gene['otherConditions'] ?? [],
              );

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 8,
                shadowColor: Colors.blueGrey.withOpacity(0.5),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.blueGrey[900],
                                child: Text(
                                  gene['geneName']?.substring(0, 1) ?? '?',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                gene['geneName'] ?? 'Unknown Gene',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey[900],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Text(
                            "Gene Score: ${gene['geneScore'] ?? 'N/A'}",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blueGrey[800],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Current Condition: ${gene['currentCondition'] ?? 'N/A'}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                          if (otherConditions.isNotEmpty) ...[
                            SizedBox(height: 12),
                            Text(
                              "Also  in Other Conditions:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.blueGrey[900],
                              ),
                            ),
                            ...otherConditions.map((cond) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                                child: Text(
                                  "- ${cond['condition']} (Score: ${cond['score']})",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blueGrey[700],
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        ],
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("Delete Gene"),
                                  content: Text(
                                    "Are you sure you want to delete this saved gene?",
                                    style: TextStyle(color: Colors.blueGrey[700]),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: Text("Delete"),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirm == true) {
                              await deleteGene(gene['id']);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Gene deleted successfully."),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              // Refresh the page after deletion
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => SavedGenesPage()),
                              );
                            }
                          },
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
