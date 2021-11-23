import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geiger_localstorage/geiger_localstorage.dart';
import 'package:geiger_localstorage/src/visibility.dart' as GGVisibility;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const String geigerOwner = 'GEIGER_API_TEST';
const String nodeDataName = 'dataNode';

class GeigerConnector {
  late StorageController geigerToolboxStorageController;
  Future<void> initGeigerStorage() async {
    String dbPath = join(await getDatabasesPath(), 'geiger.db');
    log('Database path: $dbPath');
    geigerToolboxStorageController =
        GenericController(geigerOwner, SqliteMapper(dbPath));
  }

  Future<void> writeToGeigerStorage(String data) async {
    log('Trying to get the data node');
    try {
      log('Found the data node - Going to write the data');
      Node node = await geigerToolboxStorageController.get(':$nodeDataName');
      await node.addOrUpdateValue(NodeValueImpl('data', '$data'));
      await geigerToolboxStorageController.update(node);
    } catch (e) {
      log(e.toString());
      log('Cannot find the data node - Going to create a new one');
      try {
        Node node = NodeImpl(
            nodeDataName, geigerOwner, '', GGVisibility.Visibility.green);
        await geigerToolboxStorageController.addOrUpdate(node);
        await node.addOrUpdateValue(NodeValueImpl('data', '$data'));
        await geigerToolboxStorageController.update(node);
      } catch (e2) {
        log(e2.toString());
        log('---> Out of luck');
      }
    }
  }

  Future<String?> readDataFromGeigerStorage() async {
    log('Trying to get the data node');
    try {
      log('Found the data node - Going to get the data');
      Node node = await geigerToolboxStorageController.get(':$nodeDataName');
      NodeValue? nValue = await node.getValue('data');
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
