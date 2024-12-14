import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // For bar chart visualization
import 'search_page.dart';
import '../Drawer/home.dart';
import '../Drawer/about.dart';
import '../Drawer/feedback.dart';
import '../Drawer/profile.dart';
import '../Drawer/settings.dart';
import '../Drawer/help.dart';
import '../Drawer/terms.dart';





class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedToggleIndex = 0; // Index for toggle button
  final GlobalKey<AnimatedListState> _animatedListKey = GlobalKey<AnimatedListState>();
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollTimer;

  final List<Map<String, dynamic>> drawerItems = [
    {'title': 'Home', 'icon': Icons.home, 'page': home()},
    {'title': 'Profile', 'icon': Icons.person, 'page': profile()},
    {'title': 'Settings', 'icon': Icons.settings, 'page': settings()},
    //{'title': 'Notifications', 'icon': Icons.notifications, 'page': Notifications()},
    {'title': 'Help', 'icon': Icons.help, 'page': help()},
     // {'title': 'Privacy', 'icon': Icons.lock, 'page': Privacy()},
    {'title': 'Terms', 'icon': Icons.description, 'page':  terms()},
    {'title': 'Feedback', 'icon': Icons.feedback, 'page': feedback()},
    {'title': 'About', 'icon': Icons.info, 'page': About()},
   // {'title': 'Logout', 'icon': Icons.exit_to_app, 'page': Logout()},
  ];


  final List<Map<String, dynamic>> diseaseData = [
    {'name': 'Anxiety', 'image': 'assets/images/anxietyy.png', 'genes': 100},
    {'name': 'Diabetes', 'image': 'assets/images/diabetes.jpg', 'genes': 200},
    {'name': 'CAD', 'image': 'assets/images/cardiac.png', 'genes': 150},
    {'name': 'Liver', 'image': 'assets/images/liver2.jpg', 'genes': 490},
    {'name': 'Obesity', 'image': 'assets/images/obesity.png', 'genes': 100},
    {'name': 'Cancer', 'image': 'assets/images/cancer.webp', 'genes': 50},
    {'name': 'Depression', 'image': 'assets/images/Depression.png', 'genes': 120},
    {'name': 'Cholesterol', 'image': 'assets/images/cholestral.webp', 'genes': 300},
    {'name': 'Diabetes_mellitus', 'image': 'assets/images/diabetes-milleus.png', 'genes': 250},
  ];

  final int totalGenes = 500;
  bool _isDrawerOpen = false; // Tracks if the drawer is open

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    const scrollDuration = Duration(milliseconds: 100);
    const scrollOffset = 10.0;

    _scrollTimer = Timer.periodic(scrollDuration, (timer) {
      if (_scrollController.hasClients) {
        final maxScrollExtent = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.offset;

        if (currentScroll + scrollOffset >= maxScrollExtent) {
          _scrollController.jumpTo(0); // Reset to start
        } else {
          _scrollController.animateTo(
            currentScroll + scrollOffset,
            duration: scrollDuration,
            curve: Curves.linear,
          );
        }
      }
    });
  }

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
            // Navigate to the corresponding page based on the drawer item
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
                  offset: Offset(2, 3), // Shadow position
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

  Widget _buildCircularCards() {
    return Column(
      children: diseaseData.map((disease) {
        final progress = (disease['genes'] / totalGenes).toDouble();
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
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            elevation: 10,
            shadowColor: Colors.black38,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ClipOval(
                        child: Image.asset(
                          disease['image'],
                          height: 60,
                          width: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            disease['name'],
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey[800]),
                          ),
                          SizedBox(height: 5),
                          Text(
                            '${disease['genes']} Genes',
                            style: TextStyle(fontSize: 14, color: Colors.blueGrey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 8,
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
                      Text(
                        '${(progress * 100).toStringAsFixed(1)}%',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey[800]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
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
        showingTooltipIndicators: [0],
      );
    }).toList();
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
                          child: Text('Row View', style: TextStyle(fontSize: 16)),
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
              _selectedToggleIndex == 0
                  ? Column(
                children: [
                  Padding(
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
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.white),
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 300,
                                    child: SingleChildScrollView(
                                      controller: _scrollController,
                                      scrollDirection: Axis.horizontal,
                                      child: SizedBox(
                                        width: diseaseData.length * 60,
                                        child: BarChart(
                                          BarChartData(
                                            alignment: BarChartAlignment.spaceBetween,
                                            barGroups: _generateBarGroups(),
                                            titlesData: FlTitlesData(
                                              bottomTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  getTitlesWidget: (value, meta) {
                                                    final int index = value.toInt();
                                                    if (index >= 0 &&
                                                        index < diseaseData.length) {
                                                      return Padding(
                                                        padding:
                                                        const EdgeInsets.only(
                                                            top: 8.0),
                                                        child: Text(
                                                          diseaseData[index]['name'],
                                                          style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 8),
                                                        ),
                                                      );
                                                    }
                                                    return const Text('');
                                                  },
                                                ),
                                              ),
                                              topTitles: AxisTitles(
                                                  sideTitles:
                                                  SideTitles(showTitles: false)),
                                              rightTitles: AxisTitles(
                                                  sideTitles:
                                                  SideTitles(showTitles: false)),
                                              leftTitles: AxisTitles(
                                                  sideTitles:
                                                  SideTitles(showTitles: false)),
                                            ),
                                            barTouchData: BarTouchData(
                                              enabled: true,
                                              touchTooltipData:
                                              BarTouchTooltipData(
                                                tooltipPadding:
                                                EdgeInsets.all(8),
                                                tooltipMargin: 8,

                                                tooltipRoundedRadius: 8,
                                                fitInsideHorizontally: true,
                                                fitInsideVertically: true,
                                                getTooltipItem: (group,
                                                    groupIndex, rod,
                                                    rodIndex) {
                                                  return BarTooltipItem(
                                                    rod.toY
                                                        .toStringAsFixed(0),
                                                    TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            gridData: FlGridData(
                                                show: false),
                                            borderData: FlBorderData(
                                                show: false),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _buildCircularCards(),
                ],
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
                            builder: (context) =>
                                SearchPage(diseaseName: disease['name']),
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15.0),
                              child: ClipRRect(
                                borderRadius:
                                BorderRadius.circular(5),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 10,
                                  backgroundColor: Colors.grey[300],
                                  valueColor:
                                  AlwaysStoppedAnimation<Color>(
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
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blueGrey[600]),
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
}