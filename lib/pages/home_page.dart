import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'find_disease_page.dart';
import 'saved_genes_page.dart';
import 'search_page.dart';
import '../Drawer/home.dart';
import '../Drawer/about.dart';
import '../Drawer/feedback.dart';
import '../Drawer/profile.dart';
import '../Drawer/settings.dart';
import '../Drawer/help.dart';
import '../Drawer/terms.dart';
import 'saved_ref_pharm.dart';
import 'saved_ref_pubtutor.dart';
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<AnimatedListState> _animatedListKey = GlobalKey<AnimatedListState>();

  final List<Map<String, dynamic>> drawerItems = [
    {'title': 'Find the gene', 'icon': Icons.search, 'page': AllGenesSearchPage()},
    {'title': 'Profile', 'icon': Icons.person, 'page': ProfilePage()},
    {'title': 'Saved Genes', 'icon': Icons.save, 'page': SavedGenesPage()},
    {'title': 'Saved  pharmGKB', 'icon': Icons.save, 'page': SavedPharmGKBReferencesPage()},
    {'title': 'Saved pubtutor', 'icon': Icons.save, 'page': SavedPubTutorReferencesPage()},
    {'title': 'Terms', 'icon': Icons.description, 'page':  terms()},
    {'title': 'Feedback', 'icon': Icons.feedback, 'page': feedback()},
    {'title': 'Help', 'icon': Icons.help, 'page': help()},
    {'title': 'Settings', 'icon': Icons.settings, 'page': settings()},

    {'title': 'About', 'icon': Icons.info, 'page': About()},
  ];




  final List<Map<String, dynamic>> diseaseData = [
    //{'name': 'Search Gene', 'image': 'assets/images/anxietyy.png','genes':500},
    {'name': 'Anxiety', 'image': 'assets/images/anxietyy.png', 'genes': 100},
    {'name': 'Diabetes', 'image': 'assets/images/diabetes.jpg', 'genes': 200},
    {'name': 'CAD', 'image': 'assets/images/cardiac.png', 'genes': 150},
    {'name': 'Liver', 'image': 'assets/images/liver2.jpg', 'genes': 490},
    {'name': 'Obesity', 'image': 'assets/images/obesity.png', 'genes': 100},
    {'name': 'Cancer', 'image': 'assets/images/cancer.webp', 'genes': 50},
    {'name': 'Depression', 'image': 'assets/images/Depression.png', 'genes': 120},
    {'name': 'Cholestral', 'image': 'assets/images/cholestral.webp', 'genes': 300},
    {'name': 'Diabetes_mellitus', 'image': 'assets/images/diabetes-milleus.png', 'genes': 250},
  ];

  final int totalGenes = 500;
  bool _isDrawerOpen = false;

  void _startDrawerAnimation() {
    Future.delayed(Duration(milliseconds: 300), () {
      for (int i = 0; i < drawerItems.length; i++) {
        Future.delayed(Duration(milliseconds: i * 150), () {
          _animatedListKey.currentState?.insertItem(i);
        });
      }
    });
  }

  void _resetDrawerAnimation() {
    for (int i = drawerItems.length - 1; i >= 0; i--) {
      _animatedListKey.currentState?.removeItem(
        i,
            (context, animation) => _buildAnimatedItem(drawerItems[i], animation),
      );
    }
  }

  Widget _buildAnimatedItem(Map<String, dynamic> item, Animation<double> animation) {
    return SlideTransition(
      position: animation.drive(
        Tween<Offset>(begin: Offset(-1, 0), end: Offset(0, 0)).chain(CurveTween(curve: Curves.easeOut)),
      ),
      child: FadeTransition(
        opacity: animation,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => item['page']),
            );
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 6,
                  spreadRadius: 2,
                  offset: Offset(2, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(item['icon'], color: Colors.blueGrey[700], size: 25),
                    SizedBox(width: 15),
                    Text(
                      item['title'],
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey[800]),
                    ),
                  ],
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.blueGrey[600], size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Disease Conditions',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.blueGrey[900],
        leading: IconButton(
          icon: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: _isDrawerOpen
                ? Icon(Icons.menu, color: Colors.white, size: 30, key: ValueKey('close'))
                : Icon(Icons.menu, color: Colors.white, size: 30, key: ValueKey('menu')),
          ),
          onPressed: () {
            if (_isDrawerOpen) {
              Navigator.of(context).pop();
            } else {
              _scaffoldKey.currentState!.openDrawer();
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              showSearch(context: context, delegate: DiseaseSearchDelegate(diseaseData));
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  height: 100,
                  width: double.infinity,
                  color: Colors.blueGrey[900],
                  child: Image.asset(
                    'assets/images/drawerlogo.png',
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  child: AnimatedList(
                    key: _animatedListKey,
                    initialItemCount: 0,
                    itemBuilder: (context, index, animation) {
                      return _buildAnimatedItem(drawerItems[index], animation);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      onDrawerChanged: (isOpen) {
        setState(() {
          _isDrawerOpen = isOpen;
          if (isOpen) {
            _startDrawerAnimation();
          } else {
            _resetDrawerAnimation();
          }
        });
      },
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              Color(0xFFF7E4EC),
              Color(0xFFDEE7F1),
            ],
          ),
        ),
        child: GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 0.8,
          ),
          itemCount: diseaseData.length,
          itemBuilder: (context, index) {
            final disease = diseaseData[index];
            final progress = disease['genes'] / totalGenes;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchPage(diseaseName: disease['name']),
                  ),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 25,
                shadowColor: Colors.black45,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: Image.asset(
                        disease['image'],
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      disease['name'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[800],
                      ),
                    ),
                    SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress < 0.5
                                ? Colors.red
                                : progress < 0.8
                                ? Colors.orange
                                : Colors.green,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '${disease['genes']} of $totalGenes Genes',
                      style: TextStyle(fontSize: 14, color: Colors.blueGrey[600]),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class DiseaseSearchDelegate extends SearchDelegate<String> {
  final List<Map<String, dynamic>> diseaseData;

  DiseaseSearchDelegate(this.diseaseData);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final List<Map<String, dynamic>> results = diseaseData
        .where((disease) => disease['name'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final disease = results[index];
        return ListTile(
          title: Text(disease['name']),
          leading: Image.asset(disease['image'], height: 50, width: 50),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchPage(diseaseName: disease['name']),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<Map<String, dynamic>> suggestions = diseaseData
        .where((disease) => disease['name'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final disease = suggestions[index];
        return ListTile(
          title: Text(disease['name']),
          leading: Image.asset(disease['image'], height: 50, width: 50),
          onTap: () {
            query = disease['name'];
            showResults(context);
          },
        );
      },
    );
  }
}
