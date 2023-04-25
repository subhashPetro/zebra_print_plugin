package com.example.zebra_print_plugin;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.NonNull;

import com.zebra.sdk.comm.BluetoothConnection;
import com.zebra.sdk.comm.Connection;
import com.zebra.sdk.comm.ConnectionException;
import com.zebra.sdk.printer.PrinterLanguage;
import com.zebra.sdk.printer.PrinterStatus;
import com.zebra.sdk.printer.SGD;
import com.zebra.sdk.printer.ZebraPrinter;
import com.zebra.sdk.printer.ZebraPrinterFactory;
import com.zebra.sdk.printer.ZebraPrinterLanguageUnknownException;
import com.zebra.sdk.printer.ZebraPrinterLinkOs;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** ZebraPrintPlugin */
public class ZebraPrintPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private static final String connectChannel = "connect_channel";
  private static final String disConnectChannel = "disconnect_channel";
  private static final String getConfigLabelChannel = "get_config_label";
  private static final String sendTestLabelChannel = "send_test_label";
  private static final String IsBluetoothOn = "is_bluetooth_on";

  private static final String ConnectedDevice = "connected_device";

  private static final String GetAllPairedZQDevices = "get_all_paired_zq_devices";

  private ZebraPrinter zebraPrinter;
  private ZebraRepo zebraRepo;

  BluetoothAdapter bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();


  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "zebra_plugin");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case connectChannel:
        connectPrinter(call, result);
      case disConnectChannel:
        disconnectPrinter(call, result);
      case getConfigLabelChannel:
        getConfigLabel(call, result);
      case sendTestLabelChannel:
        sendTestLabel(call, result);
      case IsBluetoothOn:
        isBluetoothOn(call,result);
        break;
      case ConnectedDevice:
        getConnectedDevice(call,result);
        break;
      case GetAllPairedZQDevices:
        getAllPairedZQDevices(call,result);
        break;
      case "getPlatformVersion":
        result.success("Android " + android.os.Build.VERSION.RELEASE);
      default:
        result.notImplemented();
    }
  }

  private void getAllPairedZQDevices(MethodCall call, Result result) {
    Set<BluetoothDevice> pairedDevices = bluetoothAdapter.getBondedDevices();
    List<BluetoothDevice> devices = new ArrayList<>();
    for (BluetoothDevice device : pairedDevices) {
      String deviceName = device.getName();
      if (deviceName != null && deviceName.startsWith("ZQ")) {
        devices.add(device);
      }
    }
    result.success(devices);
  }

  private void getConnectedDevice(MethodCall call, Result result) {
    Set<BluetoothDevice> pairedDevices = bluetoothAdapter.getBondedDevices();
    String deviceId = null;
    for (BluetoothDevice device : pairedDevices) {
      // Get the device ID
      deviceId = device.getAddress();
      Log.d("Bluetooth", "Connected device ID: " + deviceId);
      break;
    }
    result.success(deviceId);
  }

  private void isBluetoothOn(MethodCall call, Result result) {
    Map<String, Object> responseData = new HashMap<>();
    if (bluetoothAdapter == null) {
      responseData.put("isSupported",false);
      responseData.put("isBluetoothOn",false);
    } else {
      if (bluetoothAdapter.isEnabled()) {
        responseData.put("isSupported",true);
        responseData.put("isBluetoothOn",true);
      } else {
        responseData.put("isSupported",true);
        responseData.put("isBluetoothOn",false);
      }
    }
    result.success(responseData);
  }

  private void sendTestLabel(MethodCall call, Result result) {
    try {
      zebraRepo.sendTestLabel();
      result.success("true");
    } catch (Exception e) {
      result.success(null);
    }
  }

  private void getConfigLabel(MethodCall call, Result result) {
    try {
      byte[] value = zebraRepo.getConfigLabel();
      result.success(value);
    } catch (Exception e) {
      result.success(null);
    }
  }

  private void disconnectPrinter(MethodCall call, Result result) {
    try {
      zebraRepo.disconnect();
      result.success("true");
    } catch (Exception e) {
      result.success("false");
    }
  }

  private void connectPrinter(MethodCall call, Result result) {
    try {
      Map<String, Object> arguments = call.arguments();
      String macId = (String) arguments.get("macID");
      zebraRepo = new ZebraRepo();
      new Thread(new Runnable() {
        public void run() {
          Looper.prepare();
          doConnectionTest(macId);
          Looper.loop();
          Looper.myLooper().quit();
        }
      }).start();
      result.success("true");
    } catch (Exception e) {
      Log.e("connect exception", "connectPrinter: " + e);
      result.success("false");
    }
  }

  void doConnectionTest(String macId) {
    zebraPrinter = zebraRepo.connect(macId);
    if (zebraPrinter != null) {
      zebraRepo.sendTestLabel();
    } else {
      zebraRepo.disconnect();
    }
  }


  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}


class ZebraRepo {

  private ZebraPrinter zebraPrinter;
  private Connection connection;


  public ZebraPrinter connect(String macAddress) {
//        setStatus("Connecting...", Color.YELLOW);
    connection = new BluetoothConnection(macAddress);

    try {
      connection.open();
    } catch (ConnectionException e) {
      Log.d("MY_LOG", "Emptyyyyyyyyyyyyyy - " + e);
      sleep(1000);
      disconnect();
    }

    ZebraPrinter printer = null;
    if (connection.isConnected()) {
      try {
        printer = ZebraPrinterFactory.getInstance(connection);
        Log.d("MY_LOG", "Determining Printer Languag");
        String pl = SGD.GET("device.languages", connection);
        Log.d("MY_LOG", "Printer Language" + pl);
      } catch (ConnectionException | ZebraPrinterLanguageUnknownException e) {
        Log.d("MY_LOG", "UnknownPrinter Language");
        printer = null;
        sleep(1000);
        disconnect();
      }
    }
    zebraPrinter = printer;
    return printer;
  }

  public void disconnect() {
    String friendlyName;
    try {

      if (connection != null) {
        connection.close();
      }

    } catch (ConnectionException e) {

    }
  }

  void sendTestLabel() {
    try {
      ZebraPrinterLinkOs linkOsPrinter = ZebraPrinterFactory.createLinkOsPrinter(zebraPrinter);
      Log.d("MY_LOG", "Emptyyyyyyyyyyyyyy" + linkOsPrinter);

      PrinterStatus printerStatus = (linkOsPrinter != null) ? linkOsPrinter.getCurrentStatus() : zebraPrinter.getCurrentStatus();
      Log.d("MY_LOG", "Emptyyyyyyyyyyyyyy" + printerStatus);

      if (printerStatus.isReadyToPrint) {
        byte[] configLabel = getConfigLabel();
        connection.write(configLabel);
      } else if (printerStatus.isHeadOpen) {
      } else if (printerStatus.isPaused) {
      } else if (printerStatus.isPaperOut) {
      }
      sleep(1500);
      if (connection instanceof BluetoothConnection) {
        String friendlyName = ((BluetoothConnection) connection).getFriendlyName();
        sleep(500);
      }
    } catch (ConnectionException e) {
    } finally {
      disconnect();
    }
  }

  byte[] getConfigLabel() {
    byte[] configLabel = null;
    try {
      PrinterLanguage printerLanguage = zebraPrinter.getPrinterControlLanguage();
      SGD.SET("device.languages", "zpl", connection);


      if (printerLanguage == PrinterLanguage.ZPL) {

        //para configurar un formato de impresion diseñarlo en la siguiente pagina http://labelary.com/viewer.html

        String bytes = "^XA^FX Top section with company logo, name and address.^CF0,60^FO50,50^GB100,100,100^FS^FO75,75^FR^GB100,100,100^FS^FO88,88^GB50,50,50^FS^FO220,50^FDIntershipping, Inc.^FS^CF0,30^FO220,115^FD1000 Shipping Lane^FS^FO220,155^FDShelbyville TN 38102^FS^FO220,195^FDUnited States (USA)^FS^FO50,250^GB700,1,3^FS^FX Second section with recipient address and permit information.^CFA,30^FO50,300^FDJohn Doe^FS^FO50,340^FD100 Main Street^FS^FO50,380^FDSpringfield TN 39021^FS^FO50,420^FDUnited States (USA)^FS^CFA,15^FO600,300^GB150,150,3^FS^FO638,340^FDPermit^FS^FO638,390^FD123456^FS^FO50,500^GB700,1,3^FS^FX Third section with barcode.^BY5,2,270^FO100,550^BC^FD12345678^FS^FX Fourth section (the two boxes on the bottom).^FO50,900^GB700,250,3^FS^FO400,900^GB1,250,3^FS^CF0,40^FO100,960^FDCtr. X34B-1^FS^FO100,1010^FDREF1 F00B47^FS^FO100,1060^FDREF2 BL4H8^FS^CF0,190^FO470,955^FDCA^FS^XZ";

        configLabel = bytes.getBytes();

      } else if (printerLanguage == PrinterLanguage.CPCL) {
        String cpclConfigLabel = "! 0 200 200 406 1\r\n" + "ON-FEED IGNORE\r\n" + "BOX 20 20 380 380 8\r\n" + "T 0 6 137 177 TEST\r\n" + "PRINT\r\n";
        configLabel = cpclConfigLabel.getBytes();
      }
    } catch (ConnectionException e) {
      Log.e("ConectionExeption", e.getMessage() + " " + e.getCause());
    }
    return configLabel;
  }

  public static void sleep(int ms) {
    try {
      Thread.sleep(ms);
    } catch (InterruptedException e) {
      e.printStackTrace();
    }
  }

}
