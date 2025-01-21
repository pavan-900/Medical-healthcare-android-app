import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Decomposition Tree Example'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: DecompositionTree(),
        ),
      ),
    );
  }
}

class DecompositionTree extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ExpansionTile(
          title: Text('Company'),
          backgroundColor: Colors.blue.shade100,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: ExpansionTile(
                title: Text('HR Department'),
                backgroundColor: Colors.green.shade100,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: ListTile(
                      title: Text('Recruitment'),
                      tileColor: Colors.green.shade200,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: ListTile(
                      title: Text('Employee Relations'),
                      tileColor: Colors.green.shade200,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: ListTile(
                      title: Text('Training and Development'),
                      tileColor: Colors.green.shade200,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: ExpansionTile(
                title: Text('Tech Department'),
                backgroundColor: Colors.orange.shade100,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: ListTile(
                      title: Text('Software Development'),
                      tileColor: Colors.orange.shade200,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: ListTile(
                      title: Text('Infrastructure'),
                      tileColor: Colors.orange.shade200,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: ListTile(
                      title: Text('Quality Assurance'),
                      tileColor: Colors.orange.shade200,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: ExpansionTile(
                title: Text('Sales Department'),
                backgroundColor: Colors.purple.shade100,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: ListTile(
                      title: Text('Business Development'),
                      tileColor: Colors.purple.shade200,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: ListTile(
                      title: Text('Customer Support'),
                      tileColor: Colors.purple.shade200,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: ListTile(
                      title: Text('Market Research'),
                      tileColor: Colors.purple.shade200,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
