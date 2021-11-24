import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:toolbox_api_test/geiger_connector.dart';
import 'package:toolbox_api_test/utils.dart';

GeigerConnector geigerConnector = GeigerConnector();
String? firstData;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  log('ensure initialized');
  await readPackageInfo();
  log('initialized packaged info');
  await geigerConnector.initGeigerStorage();
  log('initialized geiger storage');
  firstData = await geigerConnector.readDataFromGeigerStorage();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    log('Start building the application');
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Get battery level.
  String geigerData = firstData ?? 'Failed';
  TextEditingController inputDataController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Geiger APIs - Version ${getVersion()}"),
      ),
      body: Container(
        margin: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextField(
              controller: inputDataController,
            ),
            ElevatedButton(
              onPressed: () async {
                log('Enter data: ${inputDataController.text}');
                String inputData = inputDataController.text.trim();
                if (inputData != '') {
                  await geigerConnector.writeToGeigerStorage(inputData);
                  log('Data has been written, going to read it');
                  String? newData =
                      await geigerConnector.readDataFromGeigerStorage();
                  log('Going to update the state');
                  setState(() {
                    geigerData = newData ?? 'Failed!';
                  });
                  inputDataController.clear();
                }
              },
              child: const Text('Save to Geiger Storage'),
            ),
            SizedBox(height: 20),
            Text('Geiger Data: $geigerData'),
          ],
        ),
      ),
    );
  }
}
