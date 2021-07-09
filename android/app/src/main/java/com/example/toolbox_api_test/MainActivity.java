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

//Geiger packages
import ch.fhnw.geiger.localstorage.StorageException;
import eu.cybergeiger.communication.Declaration;
import eu.cybergeiger.communication.DeclarationMismatchException;
import ch.fhnw.geiger.localstorage.db.GenericController;
import eu.cybergeiger.communication.LocalApi;
import eu.cybergeiger.communication.LocalApiFactory;
import ch.fhnw.geiger.localstorage.db.data.Node;
import ch.fhnw.geiger.localstorage.db.data.NodeImpl;


public class MainActivity extends FlutterActivity {
  private static final String CHANNEL = "com.geiger.dev/toolboxAPI";

  private LocalApi localApi;
  private GenericController genericController;

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
  super.configureFlutterEngine(flutterEngine);
    new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
        .setMethodCallHandler(
          (call, result) -> {
            // Note: this method is invoked on the main thread.
            if (call.method.equals("getStorage")) {
              String storageMsg = getStorage();
              if (!storageMsg.isEmpty()) {
                result.success(storageMsg);
              } else {
                result.error("UNAVAILABLE", "Storage not created.", null);
              }
            } else {
              result.notImplemented();
            }
          }

        );
  }

  private String getStorage(){
    // try{
        System.out.println("LocalAPI variable: " + LocalApi.MASTER);
        // this.localApi = LocalApiFactory.getLocalApi("mi-cyberrange", LocalApi.MASTER, Declaration.DO_NOT_SHARE_DATA);
        // this.genericController = (GenericController) localApi.getStorage();

        // //create node
        Node userUUIdNode = new NodeImpl("328161f6-89bd-49f6-user-5a375ff56ana", ":Users");
        // //add node to database
        // this.genericController.add(userUUIdNode);
        // this.genericController.update(userUUIdNode);

        return LocalApi.MASTER;
    // }
    // catch (StorageException | DeclarationMismatchException se){
    //     se.printStackTrace();
    //     return  "Sorry!";
    // }
}

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
