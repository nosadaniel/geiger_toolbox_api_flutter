import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geiger_localstorage/geiger_localstorage.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class GeigerConnector {
  late StorageController geigerToolboxStorageController;
  Future<void> initGeigerStorage() async {
    WidgetsFlutterBinding.ensureInitialized();
    String dbPath = join(await getDatabasesPath(), 'geiger_database.db');
    log('Database path: $dbPath');
    geigerToolboxStorageController =
        GenericController('MI-Cyberrange', SqliteMapper(dbPath));
  }

  void writeToGeigerStorage(String data) {
    log('Trying to get the data node');
    try {
      log('Found the data node - Going to write the data');
      Node node = geigerToolboxStorageController.get(':data-node');
      node.addOrUpdateValue(NodeValueImpl('data', '$data'));
      geigerToolboxStorageController.update(node);
    } catch (e) {
      log(e.toString());
      log('Cannot find the data node - Going to create a new one');
      Node node = NodeImpl('data-node');
      geigerToolboxStorageController.addOrUpdate(node);
      node.addOrUpdateValue(NodeValueImpl('data', '$data'));
      geigerToolboxStorageController.update(node);
    }
  }

  String? readDataFromGeigerStorage() {
    log('Trying to get the data node');
    try {
      log('Found the data node - Going to get the data');
      Node node = geigerToolboxStorageController.get(':data-node');
      NodeValue? nValue = node.getValue('data');
      if (nValue != null) {
        return nValue.value;
      } else {
        log('Failed to retrieve the node value');
      }
    } catch (e) {
      log('Failed to retrieve the data node');
      log(e.toString());
    }
    return null;
  }
}
