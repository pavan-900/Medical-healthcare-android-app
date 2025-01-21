import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CausingDiseasesPage extends StatefulWidget {
  final String conditionName;

  CausingDiseasesPage({required this.conditionName});

  @override
  _CausingDiseasesPageState createState() => _CausingDiseasesPageState();
}

class _CausingDiseasesPageState extends State<CausingDiseasesPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController searchController = TextEditingController();
  List<String> allCausingDiseases = [];
  List<String> filteredCausingDiseases = [];
  bool isLoading = true;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _fetchCausingDiseases();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500), // Animation duration
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchCausingDiseases() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('diseases_data')
          .where('condition', isEqualTo: widget.conditionName)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          allCausingDiseases = List<String>.from(snapshot.docs.first['causing_diseases']);
          filteredCausingDiseases = allCausingDiseases;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
        _animationController.forward(); // Trigger animation
      });
    }
  }

  void _filterDiseases(String query) {
    final filtered = allCausingDiseases
        .where((disease) => disease.toLowerCase().contains(query.toLowerCase()))
        .toList();

    setState(() {
      filteredCausingDiseases = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Causing Diseases: ${widget.conditionName}',
          style: TextStyle(color: Colors.white), // Header text color
        ),
        backgroundColor: Colors.blue[400],
        iconTheme: IconThemeData(color: Colors.white), // Back arrow color
        centerTitle: true,
        elevation: 5,
      ),
      body: Column(
        children: [
          // Search Bar with Scale Transition Animation
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: _animationController,
                curve: Curves.easeOut,
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search for a disease...',
                  prefixIcon: Icon(Icons.search, color: Colors.blueGrey[900]),
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
          ),

          // Loading Indicator
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),

          // List of Causing Diseases with Fade-In Animation
          if (!isLoading && filteredCausingDiseases.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: filteredCausingDiseases.length,
                itemBuilder: (context, index) {
                  final disease = filteredCausingDiseases[index];
                  return FadeTransition(
                    opacity: _animationController,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(0, 0.3),
                        end: Offset(0, 0),
                      ).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: Curves.easeOut,
                        ),
                      ),
                      child: _buildDiseaseCard(disease, "Causing"),
                    ),
                  );
                },
              ),
            ),

          // No Data Found Message
          if (!isLoading && filteredCausingDiseases.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'No diseases found matching your search.',
                  style: TextStyle(fontSize: 18, color: Colors.blueGrey[700]),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Build a disease card styled as per the example
  Widget _buildDiseaseCard(String disease, String status) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 6,
      shadowColor: Colors.grey.withOpacity(0.3),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100], // Soft background color
          child: Icon(Icons.add, color: Colors.blue), // Icon with the "+" sign
        ),
        title: Text(
          disease,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey[900],
          ),
        ),
        subtitle: Text(
          status,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.blue, // Blue color for "Causing"
          ),
        ),
      ),
    );
  }
}
