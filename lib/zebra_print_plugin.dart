import 'package:zebra_print_plugin/permission_manager.dart';

import 'zebra_print_plugin_platform_interface.dart';

class ZebraPrintPlugin {
  Future<String?> getPlatformVersion() {
    return ZebraPrintPluginPlatform.instance.getPlatformVersion();
  }

  Future<bool?> sendTestLabel() =>
      ZebraPrintPluginPlatform.instance.sendTestLabel();
  Future<dynamic> getConfigLabel() =>
      ZebraPrintPluginPlatform.instance.getConfigLabel();
  Future<bool?> disconnectPrinter() =>
      ZebraPrintPluginPlatform.instance.disconnectPrinter();
  Future<bool?> connectPrinter(String macID) =>
      ZebraPrintPluginPlatform.instance.connectPrinter(macID);

  Future<bool> hasAllBluetoothPermission() =>
      BluetoothPermissionManager.checkAndRequestPermissions();

  Future<bool> isBluetoothOn() =>
      ZebraPrintPluginPlatform.instance.isBluetoothOn();
  Future<String?> getConnectedDevice() =>
      ZebraPrintPluginPlatform.instance.getConnectedDevice();
  Future<dynamic> getAllPairedZQDevices() =>
      ZebraPrintPluginPlatform.instance.getAllPairedZQDevices();
}
