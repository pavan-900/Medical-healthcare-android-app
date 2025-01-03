import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> saveGene(String geneName, int geneScore, String currentCondition, List<Map<String, dynamic>> otherConditions) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;

  if (userId == null) {
    print("User not logged in.");
    return;
  }

  await FirebaseFirestore.instance.collection('saved_genes').add({
    'geneName': geneName,
    'geneScore': geneScore,
    'currentCondition': currentCondition,
    'otherConditions': otherConditions,
    'userId': userId,
  });
}
