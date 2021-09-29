import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  var _testing_number = '0.1';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter - Toolbox APIs',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      home: MyHomePage(title: 'Flutter - Toolbox APIs test ' + _testing_number),
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
  static const platform = const MethodChannel('com.geiger.dev/toolboxAPI');

  // Get battery level.
  String _getStorageStatus = 'Unknown getStorage status.';

  Future<void> _getStorage() async {
    String status;
    try {
      print('Going to get the storage status...');
      final String result =
          await platform.invokeMethod('setupStorageController');
      status = 'Storage status: $result .';
    } on PlatformException catch (e) {
      status = "Failed to get storage status: '${e.message}'.";
    }

    setState(() {
      _getStorageStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              child: Text('Get Storage'),
              onPressed: _getStorage,
            ),
            Text(_getStorageStatus),
          ],
        ),
      ),
    );
  }
}
