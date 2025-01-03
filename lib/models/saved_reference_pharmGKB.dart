import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> savePharmGKBReference({
  required String geneName,
  required String currentCondition,
  required String referenceName,
  required String referenceURL,
  required List<Map<String, dynamic>> otherConditions,
}) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;

  if (userId == null) {
    print("User not logged in.");
    return;
  }

  try {
    await FirebaseFirestore.instance.collection('saved_pharmgkb_references').add({
      'geneName': geneName,
      'currentCondition': currentCondition,
      'referenceName': referenceName,
      'referenceURL': referenceURL,
      'otherConditions': otherConditions,
      'userId': userId,
    });

    print("PharmGKB reference saved successfully.");
  } catch (e) {
    print("Failed to save PharmGKB reference: $e");
  }
}
