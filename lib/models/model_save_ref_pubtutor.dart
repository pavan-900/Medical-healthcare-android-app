import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> savePubTutorReference({
  required String geneName,
  required String currentCondition,
  required String title,
  required String authors,
  required String journal,
  required String date,
  required String pmid,
  required String pmcid,
  required String link,
  required List<Map<String, dynamic>> otherConditions,
}) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;

  if (userId == null) {
    print("User not logged in.");
    return;
  }

  try {
    await FirebaseFirestore.instance.collection('saved_pubtutor_references').add({
      'geneName': geneName,
      'currentCondition': currentCondition,
      'title': title,
      'authors': authors,
      'journal': journal,
      'date': date,
      'pmid': pmid,
      'pmcid': pmcid,
      'link': link,
      'otherConditions': otherConditions,
      'userId': userId,
    });

    print("PubTutor reference saved successfully.");
  } catch (e) {
    print("Failed to save PubTutor reference: $e");
  }
}
