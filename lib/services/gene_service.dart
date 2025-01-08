import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gene.dart';

class GeneService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch a gene by condition and check across other conditions.
  Future<Map<String, dynamic>> fetchGeneAndCheckOtherConditions(String condition, String geneName) async {
    print('Checking gene in condition: $condition and then across all conditions if found.');

    try {
      // Query for the specified condition
      QuerySnapshot conditionQuery = await _firestore.collection('combined_genes')
          .where('condition', isEqualTo: condition)
          .where('gene_name', isEqualTo: geneName)
          .get();

      List<Gene> conditionGenes = conditionQuery.docs.map((doc) =>
          Gene.fromFirestore(doc.data() as Map<String, dynamic>)).toList();

      // If not found in the specified condition, return immediately
      if (conditionGenes.isEmpty) {
        print('Gene not found in the specified condition.');
        return {
          'currentCondition': [],
          'otherConditions': [],
        };
      }

      // Query for the same gene across all conditions
      QuerySnapshot allConditionsQuery = await _firestore.collection('combined_genes')
          .where('gene_name', isEqualTo: geneName)
          .get();

      List<Gene> allConditionGenes = allConditionsQuery.docs.map((doc) =>
          Gene.fromFirestore(doc.data() as Map<String, dynamic>)).toList();

      print('Gene found in selected condition. Checking across all conditions.');
      return {
        'currentCondition': conditionGenes,
        'otherConditions': allConditionGenes.where((gene) => gene.condition != condition).toList(),
      };
    } catch (e) {
      print('Error fetching genes: $e');
      return {
        'currentCondition': [],
        'otherConditions': [],
      };
    }
  }

  /// Fetch genes by their name.
  Future<List<Gene>> fetchGenesByName(String geneName) async {
    try {
      // Query the Firestore collection to find genes by name
      QuerySnapshot querySnapshot = await _firestore
          .collection('combined_genes')
          .where('gene_name', isEqualTo: geneName)
          .get();

      // Map Firestore documents to Gene objects
      return querySnapshot.docs
          .map((doc) => Gene.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching genes by name: $e');
      return [];
    }
  }
}