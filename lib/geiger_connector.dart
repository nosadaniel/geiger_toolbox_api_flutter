import 'dart:developer';

import 'package:geiger_api/geiger_api.dart';
import 'package:geiger_localstorage/geiger_localstorage.dart';
import 'package:geiger_localstorage/src/visibility.dart' as GGVisibility;
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';

const String geigerOwner = 'GEIGER_API_TEST';
const String nodeDataName = 'dataNode';

class GeigerConnector {
  late StorageController storageController;
  Future<void> initGeigerStorage() async {
    // String dbPath = join(await getDatabasesPath(), 'geiger.db');
    String dbPath = 'geigerDB.sqlite';
    log('Database path: $dbPath');
    try {
      GeigerApi? geigerApi =
          await getGeigerApi("", GeigerApi.masterId, Declaration.doShareData);
      //await StorageMapper.initDatabaseExpander();
      // storageController =
      //     GenericController(geigerOwner, DummyMapper(geigerOwner));
      storageController = (geigerApi!.getStorage())!;
    } catch (e) {
      log(e.toString());
      log('Failed to create storageController');
      log('Try one more time here');
      try {
        await StorageMapper.initDatabaseExpander();
        storageController =
            GenericController(geigerOwner, SqliteMapper(dbPath));
      } catch (e2) {
        log(e2.toString());
        log('--> Out of luck');
      }
    }
  }

  Future<void> writeToGeigerStorage(String data) async {
    log('Trying to get the data node');
    try {
      log('Found the data node - Going to write the data');
      Node node = await storageController.get(':$nodeDataName');
      if (node == null) {
        log('---> Should never happen');
      }
      NodeValueImpl nvi = NodeValueImpl('data', '$data');
      await node.updateValue(nvi);
      await storageController.update(node);
    } catch (e) {
      log(e.toString());
      log('Cannot find the data node - Going to create a new one');
      try {
        Node node = NodeImpl(
            nodeDataName, geigerOwner, '', GGVisibility.Visibility.green);
        await node.addValue(NodeValueImpl('data', '$data'));
        await storageController.add(node);
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
      Node node = await storageController.get(':$nodeDataName');
      if (node == null) {
        log('---> Should never happen');
      }
      NodeValue? nValue = await node.getValue('data');
      if (nValue != null) {
        log('Found value: ${nValue.value}');
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
