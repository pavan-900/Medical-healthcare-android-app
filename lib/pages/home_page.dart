import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // For bar chart visualization
import 'search_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedToggleIndex = 0; // Index for toggle button
  final GlobalKey<AnimatedListState> _animatedListKey = GlobalKey<AnimatedListState>();

  final List<Map<String, dynamic>> drawerItems = [
    {'title': 'Home', 'icon': Icons.home},
    {'title': 'Profile', 'icon': Icons.person},
    {'title': 'Settings', 'icon': Icons.settings},
    {'title': 'Notifications', 'icon': Icons.notifications},
    {'title': 'Help', 'icon': Icons.help},
    {'title': 'Privacy', 'icon': Icons.lock},
    {'title': 'Terms', 'icon': Icons.description},
    {'title': 'Feedback', 'icon': Icons.feedback},
    {'title': 'About', 'icon': Icons.info},
    {'title': 'Logout', 'icon': Icons.exit_to_app},
  ];

  final List<Map<String, dynamic>> diseaseData = [
    {'name': 'Anxiety', 'image': 'assets/images/anxietyy.png', 'genes': 100},
    {'name': 'Diabetes', 'image': 'assets/images/diabetes.jpg', 'genes': 200},
    {'name': 'CAD', 'image': 'assets/images/cardiac.png', 'genes': 150},
    {'name': 'Liver', 'image': 'assets/images/liver2.jpg', 'genes': 490},
    {'name': 'Obesity', 'image': 'assets/images/obesity.png', 'genes': 100},
    {'name': 'Cancer', 'image': 'assets/images/cancer.webp', 'genes': 50},
  ];

  final int totalGenes = 500;
  bool _isDrawerOpen = false;

  void _onToggleButtonPressed(int index) {
    setState(() {
      _selectedToggleIndex = index;
    });
  }

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
            print('Tapped on: ${item['title']}');
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
                ? Icon(Icons.close, color: Colors.white, size: 30, key: ValueKey('close'))
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Toggle Button for Views
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ToggleButtons(
                      isSelected: [_selectedToggleIndex == 0, _selectedToggleIndex == 1],
                      onPressed: _onToggleButtonPressed,
                      borderRadius: BorderRadius.circular(25),
                      fillColor: Colors.blueGrey[900],
                      selectedColor: Colors.white,
                      color: Colors.blueGrey[800],
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text('Bar Chart', style: TextStyle(fontSize: 16)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text('Grid View', style: TextStyle(fontSize: 16)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // View based on Toggle Button
              _selectedToggleIndex == 0
                  ? Padding(
                padding: const EdgeInsets.all(20.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  color: Colors.black,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Overall Disease Statistics',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
                        ),
                        SizedBox(height: 20),
                        AspectRatio(
                          aspectRatio: 1.5,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              barGroups: _generateBarGroups(),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final int index = value.toInt();
                                      if (index >= 0 && index < diseaseData.length) {
                                        return Text(
                                          diseaseData[index]['name'],
                                          style: TextStyle(color: Colors.white, fontSize: 12),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        '${value.toInt()}',
                                        style: TextStyle(color: Colors.white, fontSize: 12),
                                      );
                                    },
                                  ),
                                ),
                                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              gridData: FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
                  : Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
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
                                    progress < 0.5 ? Colors.red : progress < 0.8 ? Colors.orange : Colors.green,
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
            ],
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _generateBarGroups() {
    return diseaseData.asMap().entries.map((entry) {
      final int index = entry.key;
      final Map<String, dynamic> disease = entry.value;
      final double barValue = disease['genes'].toDouble();
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: barValue,
            color: barValue < 100
                ? Colors.red
                : barValue < 200
                ? Colors.yellow
                : Colors.green,
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }
}
