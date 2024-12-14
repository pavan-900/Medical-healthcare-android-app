import 'dart:convert';
import 'package:http/http.dart' as http;

class GeneAPIService {
  final String baseUrl = "https://api.pharmgkb.org/v1";

  /// Fetch PharmGKB ID for a gene using the "Query Gene Object" endpoint.
  Future<String?> fetchPharmGKBId(String geneSymbol) async {
    final url = Uri.parse("$baseUrl/data/gene?symbol=$geneSymbol");

    try {
      final response = await http.get(url, headers: {
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null && data['data'].isNotEmpty) {
          return data['data'][0]['id']; // Extract PharmGKB ID
        } else {
          print("No data found for gene symbol: $geneSymbol");
        }
      } else {
        print("Error: ${response.statusCode}, ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Error fetching PharmGKB ID: $e");
    }
    return null; // Return null if no ID found
  }

  /// Fetch resources and URLs using the "Cross References" endpoint.
  Future<List<Map<String, String>>> fetchCrossReferences(String pharmGKBId) async {
    final url = Uri.parse("$baseUrl/data/gene/$pharmGKBId/crossReferences");

    try {
      final response = await http.get(url, headers: {
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null) {
          // Ensure proper type conversion for null safety
          return (data['data'] as List).map<Map<String, String>>((resource) {
            return {
              "resource": resource['resource'] ?? "Unknown Resource",
              "url": resource['_url'] ?? "No URL",
            };
          }).toList();
        } else {
          print("No cross-references found for PharmGKB ID: $pharmGKBId");
        }
      } else {
        print("Error: ${response.statusCode}, ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Error fetching cross-references: $e");
    }
    return []; // Return an empty list if no data found
  }
}
