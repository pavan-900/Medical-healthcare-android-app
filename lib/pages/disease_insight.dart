import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DiseaseSearchPage extends StatefulWidget {
  @override
  _DiseaseSearchPageState createState() => _DiseaseSearchPageState();
}

class _DiseaseSearchPageState extends State<DiseaseSearchPage> with SingleTickerProviderStateMixin {
  final TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  bool isSearchActive = false;

  List<Map<String, dynamic>> conditionsOverview = [];
  List<String> causingConditions = [];
  List<String> associatedConditions = [];

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    fetchConditionsOverview(); // Fetch initial data for Condition Overview
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Fetch all conditions for the overview
  Future<void> fetchConditionsOverview() async {
    setState(() {
      isLoading = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('diseases_data')
          .get();

      List<Map<String, dynamic>> data = [];
      for (var doc in snapshot.docs) {
        final condition = doc.get('condition');
        final causingDiseases = List<String>.from(doc.get('causing_diseases') ?? []);
        final associatedDiseases = List<String>.from(doc.get('associated_diseases') ?? []);

        data.add({
          'condition': condition,
          'causingDiseasesCount': causingDiseases.length,
          'associatedDiseasesCount': associatedDiseases.length,
          'causingDiseasesList': causingDiseases.take(5).toList(),
          'associatedDiseasesList': associatedDiseases.take(5).toList(),
        });
      }

      setState(() {
        conditionsOverview = data;
        isLoading = false;
      });

      // Start animation after fetching data
      _animationController.forward();
    } catch (e) {
      debugPrint('Error fetching conditions: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Fetch conditions for the given disease name
  Future<void> fetchConditions(String diseaseName) async {
    if (diseaseName.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a disease name to search.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
      isSearchActive = true;
      causingConditions = [];
      associatedConditions = [];
    });

    try {
      final causingSnapshot = await FirebaseFirestore.instance
          .collection('diseases_data')
          .where('causing_diseases', arrayContains: diseaseName.trim())
          .get();

      final associatedSnapshot = await FirebaseFirestore.instance
          .collection('diseases_data')
          .where('associated_diseases', arrayContains: diseaseName.trim())
          .get();

      for (var doc in causingSnapshot.docs) {
        causingConditions.add(doc.get('condition') ?? 'Unknown Condition');
      }

      for (var doc in associatedSnapshot.docs) {
        associatedConditions.add(doc.get('condition') ?? 'Unknown Condition');
      }

      if (causingConditions.isEmpty && associatedConditions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No conditions found for "$diseaseName".')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Disease Insights',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.blue[400],
        centerTitle: true,
        elevation: 4,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search Bar
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Enter disease name',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    filled: true,
                    fillColor: Colors.grey[200],
                    prefixIcon: Icon(Icons.search, color: Colors.indigo[900]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      fetchConditions(value.trim());
                    }
                  },
                ),
                SizedBox(height: 20),

                // Loading Indicator
                if (isLoading)
                  Center(
                    child: CircularProgressIndicator(color: Colors.indigo[900]),
                  ),

                // Condition Overview Section
                if (!isSearchActive && conditionsOverview.isNotEmpty)
                  _buildConditionOverview(),

                // Search Results Section
                if (!isLoading &&
                    isSearchActive &&
                    (causingConditions.isNotEmpty ||
                        associatedConditions.isNotEmpty)) ...[
                  Text(
                    'Search Results for "${searchController.text}":',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo[900],
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildPieChart(), // Add Pie Chart Visualization
                  if (causingConditions.isNotEmpty) _buildCausingResults(),
                  if (associatedConditions.isNotEmpty) _buildAssociatedResults(),
                ],

                // No Data Found Section
                if (!isLoading &&
                    isSearchActive &&
                    causingConditions.isEmpty &&
                    associatedConditions.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'No conditions found for "${searchController.text}".',
                        style: TextStyle(fontSize: 18, color: Colors.blueGrey[700]),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Condition Overview Widget with Slide Animation
  Widget _buildConditionOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Condition and Diseases Overview',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.indigo[900],
          ),
        ),
        SizedBox(height: 20),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: conditionsOverview.length,
          itemBuilder: (context, index) {
            final condition = conditionsOverview[index];
            final animation = Tween<Offset>(
              begin: Offset(1, 0), // Start off-screen (right)
              end: Offset.zero,   // Slide into place
            ).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(
                  index / conditionsOverview.length, // Staggered effect
                  1.0,
                  curve: Curves.easeOut,
                ),
              ),
            );

            return AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return SlideTransition(
                  position: animation,
                  child: child,
                );
              },
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[50]!, Colors.blue[200]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.description, color: Colors.indigo[900]),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              condition['condition'],
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo[900],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Divider(color: Colors.blue[300], thickness: 1),
                      SizedBox(height: 10),
                      _buildConditionDetails(
                        title: 'Causing Diseases',
                        count: condition['causingDiseasesCount'],
                        list: condition['causingDiseasesList'],
                        icon: Icons.local_hospital,
                        iconColor: Colors.blue,
                      ),
                      SizedBox(height: 10),
                      _buildConditionDetails(
                        title: 'Associated Diseases',
                        count: condition['associatedDiseasesCount'],
                        list: condition['associatedDiseasesList'],
                        icon: Icons.healing,
                        iconColor: Colors.orange,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildConditionDetails({
    required String title,
    required int count,
    required List<String> list,
    required IconData icon,
    required Color iconColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor),
            SizedBox(width: 8),
            Text(
              '$title (total - $count):',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
          ],
        ),
        ...list.map<Widget>((disease) {
          return Padding(
            padding: const EdgeInsets.only(left: 30.0, top: 4.0),
            child: Row(
              children: [
                Icon(Icons.circle, size: 8, color: iconColor),
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    disease,
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPieChart() {
    return Column(
      children: [
        Text(
          'Search Visualization',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.indigo[900],
          ),
        ),
        SizedBox(height: 20),
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: causingConditions.length.toDouble(),
                  title: 'Causing\n${causingConditions.length}',
                  color: Colors.blue,
                  radius: 80,
                  titleStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  value: associatedConditions.length.toDouble(),
                  title: 'Associated\n${associatedConditions.length}',
                  color: Colors.orange,
                  radius: 80,
                  titleStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCausingResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conditions in which the disease is Causing:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.indigo[900],
          ),
        ),
        SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: causingConditions.length,
          itemBuilder: (context, index) {
            final condition = causingConditions[index];
            return _buildConditionCard(condition, 'Causing');
          },
        ),
      ],
    );
  }

  Widget _buildAssociatedResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conditions in which the disease is Associated:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.indigo[900],
          ),
        ),
        SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: associatedConditions.length,
          itemBuilder: (context, index) {
            final condition = associatedConditions[index];
            return _buildConditionCard(condition, 'Associated');
          },
        ),
      ],
    );
  }

  Widget _buildConditionCard(String condition, String type) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 6,
      shadowColor: Colors.grey.withOpacity(0.3),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: type == 'Causing'
              ? Colors.blue.withOpacity(0.2)
              : Colors.orange.withOpacity(0.2),
          child: Icon(
            type == 'Causing' ? Icons.local_hospital : Icons.healing,
            color: type == 'Causing' ? Colors.blue : Colors.orange,
          ),
        ),
        title: Text(
          condition,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.indigo[900],
          ),
        ),
        subtitle: Text(
          type,
          style: TextStyle(
            fontSize: 14,
            color: type == 'Causing' ? Colors.blue : Colors.orange,
          ),
        ),
      ),
    );
  }
}
