import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gene.dart';

class GeneService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Gene>> fetchGenesByCondition(String condition, String geneName) async {
    print('Fetching genes for condition: $condition and gene name: $geneName');

    try {
      QuerySnapshot querySnapshot = await _firestore.collection('combined_genes')
          .where('condition', isEqualTo: condition)
          .where('gene_name', isEqualTo: geneName)
          .get();

      // Check if documents are returned
      if (querySnapshot.docs.isEmpty) {
        print('No genes found for the given condition and gene name.');
      } else {
        print('Found ${querySnapshot.docs.length} genes.');
      }

      // Return the list of Gene objects from the query result
      return querySnapshot.docs.map((doc) => Gene.fromFirestore(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error fetching genes: $e');
      return [];
    }
  }

}