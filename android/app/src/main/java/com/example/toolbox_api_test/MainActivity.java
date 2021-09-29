package com.example.toolbox_api_test;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Bundle;
import androidx.annotation.NonNull;

//Geiger packages - communication API
import ch.fhnw.geiger.localstorage.StorageException;
import eu.cybergeiger.communication.Declaration;
import eu.cybergeiger.communication.DeclarationMismatchException;
import ch.fhnw.geiger.localstorage.db.GenericController;
import eu.cybergeiger.communication.LocalApi;
import eu.cybergeiger.communication.LocalApiFactory;
import ch.fhnw.geiger.localstorage.db.data.Node;
import ch.fhnw.geiger.localstorage.db.data.NodeImpl;

// Geiger - LocalStorage
import static ch.fhnw.geiger.localstorage.Visibility.RED;
import static ch.fhnw.geiger.localstorage.Visibility.GREEN;
import ch.fhnw.geiger.localstorage.db.GenericController;
import ch.fhnw.geiger.localstorage.db.data.Node;
import ch.fhnw.geiger.localstorage.db.data.NodeImpl;
import ch.fhnw.geiger.localstorage.db.data.NodeValue;
import ch.fhnw.geiger.localstorage.db.data.NodeValueImpl;
import ch.fhnw.geiger.localstorage.db.mapper.DummyMapper;

public class MainActivity extends FlutterActivity {
  private static final String CHANNEL = "com.geiger.dev/toolboxAPI";

  private LocalApi localApi;
  private GenericController controller;
  // private GenericController genericController;

    private final static String miPluginUUID = "a2fdb2e9-b070-4e14-b28a-52066a9e3e99";
    private final static String userUUID = "328161f6-89bd-49f6-user-5a375ff56ana";
    private final static String deviceUUID = "328161f6-89bd-49f6-dev1-5a375ff56ana";
    private final static String basicCyberrangeRecommendationUUID = "83e5a8d2-6d4d-4c43-ac5b-e1c9b2ecdb0a";
    private final static String basicCyberrangeSensorUUID = "964d7bae-3d96-4fc7-b9ee-c19134366b59";

    // TBD: declare the url of the MI APK file here
    private final static String miBasicCyberrangeAPK = "https://...";
    private final static String miBasicCyberrangeAppIdentifier = "com.android....";
    private final static String miBasicCyberrangeParameters = "";
  // StorageController controller;

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
  super.configureFlutterEngine(flutterEngine);
    new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
        .setMethodCallHandler(
          (call, result) -> {
            if (call.method.equals("setupStorageController")) {
              String message = setupStorageController();
              if (!message.isEmpty()) {
                result.success(message);
              } else {
                result.error("UNAVAILABLE", "Message is empty.", null);
              }
            } else {
              result.notImplemented();
            }
          }

        );
  }

  private String setupStorageController(){
    String retMsg = "BAD";
    try {
      // Setup Storage Controller
      this.controller = new GenericController("testOwner", new DummyMapper());
      this.controller.zap();

      this.controller.add(new NodeImpl("parent1", ""));
    // updated Node with different visibility children
      NodeImpl node = new NodeImpl("testNode1", ":parent1", GREEN);
      this.controller.add(node);
      retMsg = "testOwner" + node.getOwner();
      retMsg += "\'n"+String.valueOf(GREEN) + String.valueOf(node.getVisibility());
      System.out.println("testOwner: "+ node.getOwner());
      NodeImpl sn = new NodeImpl("testChild1", ":parent1:testNode1");
      this.controller.add(sn);
      node.setVisibility(RED);
      node.addChild(sn);

      // update with node from above
      this.controller.update(node);

      // get the record
      Node storedNode = this.controller.get(":parent1:testNode1");

      // check results
      System.out.println("testOwner:" + storedNode.getOwner());
      retMsg += "\ntestOwner" + storedNode.getOwner();
      System.out.println("testNode1:" + storedNode.getName());
      retMsg += "\ntestNode1" + storedNode.getName();
      System.out.println(":parent1:testNode1" + storedNode.getPath());
      retMsg += "\n:parent1:testNode1" + storedNode.getPath();
      System.out.println("testChild1" + storedNode.getChildNodesCsv());
      retMsg += "\ntestChild1" + storedNode.getChildNodesCsv();
      System.out.println(String.valueOf(RED) + String.valueOf(storedNode.getVisibility()));
      retMsg += "\'n"+String.valueOf(RED) + String.valueOf(storedNode.getVisibility());
      return retMsg;
    }
    catch (StorageException se){
        se.printStackTrace();
        return  "BAD!";
    }
  }

//   // write recommendation to GEIGER data store
//   private void addBasicCyberrangeRecommendation() {

//     // create recommendation node
//     // TBD: check whether correct branch structure
//     Node recommendation = new NodeImpl(basicCyberrangeRecommendationUUID, ":Users:" + userUUID + ":" + miPluginUUID + ":data:recommendations");

//     // specify recommendation
//     // TBD: Catch MissingResourceException
//     recommendation.addValue(new NodeValueImpl("short", "Phishing Cyberrange"));
//     recommendation.addValue(new NodeValueImpl("long", "Learn how to detect and handle phishing attempts."));
//     recommendation.addValue(new NodeValueImpl("Action", "geiger://toolbox/experience_mi_basiccyberrange"));
//     // recommendation.addValue(new NodeValueImpl("relatedThreatsWeights", geigerThreatsMapRev.get("Phishing")+",high"));
//     recommendation.addValue(new NodeValueImpl("costs", "False"));
//     recommendation.addValue(new NodeValueImpl("RecommendationType", "User"));
//     recommendation.addValue(new NodeValueImpl("implemented", "0"));

//     // push recommendation into backend
//     // TBD: Catch StorageException
//     this.controller.add(recommendation);
// }

  private int getBatteryLevel() {
    int batteryLevel = -1;
    if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
      BatteryManager batteryManager = (BatteryManager) getSystemService(BATTERY_SERVICE);
      batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY);
    } else {
      Intent intent = new ContextWrapper(getApplicationContext()).
          registerReceiver(null, new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
      batteryLevel = (intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100) /
          intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1);
    }

    return batteryLevel;
  }

}
