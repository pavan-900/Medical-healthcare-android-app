import 'dart:convert';
import 'package:http/http.dart' as http;

class PubTutorAPIService {
  final String baseUrl = "https://www.ncbi.nlm.nih.gov/research/pubtator3-api";

  /// Fetch references for a gene from PubTutor API
  Future<List<Map<String, String>>> fetchReferences(String geneSymbol) async {
    final query = "@GENE_$geneSymbol";
    final url = Uri.parse("$baseUrl/search/?text=$query");

    try {
      final response = await http.get(url);
      print("API Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['results'] == null || (data['results'] as List).isEmpty) {
          throw Exception("No publications found for $geneSymbol.");
        }

        // Extract relevant details and include PMCID-based links
        return (data['results'] as List)
            .map((result) => {
          "title": result['title']?.toString() ?? "No Title",
          "journal": result['journal']?.toString() ?? "No Journal",
          "pmid": result['pmid']?.toString() ?? "No PMID",
          "pmcid": result['pmcid']?.toString() ?? "", // Include PMCID
          "authors": (result['authors'] as List?)
              ?.join(", ") ??
              "No Authors",
          "date": result['date']?.toString() ?? "No Date",
          "link": result['pmid'] != null
              ? "https://pubmed.ncbi.nlm.nih.gov/${result['pmid']}/"
              : "No Link",
        })
            .toList();
      } else {
        print("Error: ${response.statusCode} - ${response.body}");
        throw Exception("Failed to fetch data from PubTutor API.");
      }
    } catch (e) {
      print("Error fetching PubTutor references: $e");
      throw e;
    }
  }
}
