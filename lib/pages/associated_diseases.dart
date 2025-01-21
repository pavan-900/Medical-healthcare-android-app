import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AssociatedDiseasesPage extends StatefulWidget {
  final String conditionName;

  AssociatedDiseasesPage({required this.conditionName});

  @override
  _AssociatedDiseasesPageState createState() => _AssociatedDiseasesPageState();
}

class _AssociatedDiseasesPageState extends State<AssociatedDiseasesPage> {
  final TextEditingController searchController = TextEditingController();
  List<String> allAssociatedDiseases = [];
  List<String> filteredAssociatedDiseases = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAssociatedDiseases();
  }

  Future<void> _fetchAssociatedDiseases() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('diseases_data')
          .where('condition', isEqualTo: widget.conditionName)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          allAssociatedDiseases = List<String>.from(snapshot.docs.first['associated_diseases']);
          filteredAssociatedDiseases = allAssociatedDiseases;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterDiseases(String query) {
    final filtered = allAssociatedDiseases
        .where((disease) => disease.toLowerCase().contains(query.toLowerCase()))
        .toList();

    setState(() {
      filteredAssociatedDiseases = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Associated Diseases: ${widget.conditionName}',
          style: TextStyle(color: Colors.white), // Header text color
        ),
        backgroundColor: Colors.blue[400],
        iconTheme: IconThemeData(color: Colors.white), // Back arrow color
        centerTitle: true,
        elevation: 5,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search for a disease...',
                prefixIcon: Icon(Icons.search, color: Colors.orange), // Orange icon for search
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _filterDiseases,
            ),
          ),

          // Loading Indicator
          if (isLoading)
            Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),

          // Grid of Associated Diseases
          if (!isLoading && filteredAssociatedDiseases.isNotEmpty)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: filteredAssociatedDiseases.length,
                  itemBuilder: (context, index) {
                    final disease = filteredAssociatedDiseases[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 6,
                      shadowColor: Colors.orange.withOpacity(0.5),
                      child: Container(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.healing,
                              color: Colors.orange, // Orange icon color
                              size: 40,
                            ),
                            SizedBox(height: 10),
                            Text(
                              disease,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black, // Text color
                              ),
                              maxLines: 2, // Limit to two lines
                              overflow: TextOverflow.ellipsis, // Handle long text
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          // No Data Found Message
          if (!isLoading && filteredAssociatedDiseases.isEmpty)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'No diseases found matching your search.',
                    style: TextStyle(fontSize: 18, color: Colors.orange),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
