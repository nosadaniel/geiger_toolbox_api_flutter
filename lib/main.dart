import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geiger_localstorage/geiger_localstorage.dart' as ToolboxAPI;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final String testingNumber = '0.1';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter - Toolbox APIs',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      home: MyHomePage(title: 'Flutter - Toolbox APIs test ' + testingNumber),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // ToolboxAPI.StorageController geigerToolboxStorageController =
  //     ToolboxAPI.GenericController('MI-Cyberrange',
  //         ToolboxAPI.SqliteMapper('jdbc:sqlite:./dbFileName.sqlite'));
  ToolboxAPI.StorageController geigerToolboxStorageController =
      ToolboxAPI.GenericController('MI-Cyberrange', ToolboxAPI.DummyMapper());

  // Get battery level.
  String scoreAndLevel = 'Unknown';

  void sendToGeiger(int level, String random) {
    try {
      print('Trying to get a node');
      ToolboxAPI.Node node = geigerToolboxStorageController.get(':score-node');
      node.addValue(ToolboxAPI.NodeValueImpl('score', '$random'));
      node.addValue(ToolboxAPI.NodeValueImpl('level', '$level'));
      geigerToolboxStorageController.update(node);
      _testAPI();
    } catch (e) {
      print('Creating a new node');
      // print(e.toString());
      ToolboxAPI.Node node = ToolboxAPI.NodeImpl('score-node');
      geigerToolboxStorageController.addOrUpdate(node);
      node.addValue(ToolboxAPI.NodeValueImpl('score', '$random'));
      node.addValue(ToolboxAPI.NodeValueImpl('level', '$level'));
      geigerToolboxStorageController.update(node);
      _testAPI();
    }
  }

  void _testAPI() {
    try {
      ToolboxAPI.Node node = geigerToolboxStorageController.get(':score-node');
      if (node != null) {
        print('getOwner: ${node.getOwner()}');
        print('getName: ${node.getName()}');
        print('getPath: ${node.getPath()}');
        print('getScore: ${node.getValue('score')}');
        print('getLevel: ${node.getValue('level')}');
        setState(() {
          scoreAndLevel =
              'Score: ${node.getValue('score')}/ Level: ${node.getValue('level')}';
        });
      } else {
        print('Failed to retrieve the node');
      }
    } catch (e) {
      print('Failed to retrieve the node');
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              child: Text('Test API'),
              onPressed: () {
                sendToGeiger(1, DateTime.now().toString());
              },
            ),
            Text(scoreAndLevel),
          ],
        ),
      ),
    );
  }
}
