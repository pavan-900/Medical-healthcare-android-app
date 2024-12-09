class Gene {
  final String geneName;
  final int geneScore;
  final String condition;

  Gene({required this.geneName, required this.geneScore, required this.condition});

  // Factory constructor to create a Gene object from Firestore document data
  factory Gene.fromFirestore(Map<String, dynamic> firestoreData) {
    return Gene(
      geneName: firestoreData['gene_name'] ?? 'Unknown',  // Gene name should be a string
      geneScore: firestoreData['GEMS_corrected_Score'] ?? 0,  // GEMS_corrected_Score should be an integer
      condition: firestoreData['condition'] ?? 'No condition',  // Default value for condition
    );
  }
}
