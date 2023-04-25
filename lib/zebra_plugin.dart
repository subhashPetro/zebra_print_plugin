import 'package:zebra_plugin/permission_manager.dart';

import 'zebra_plugin_platform_interface.dart';

class ZebraPlugin {
  Future<String?> getPlatformVersion() {
    return ZebraPluginPlatform.instance.getPlatformVersion();
  }

  Future<bool?> sendTestLabel() => ZebraPluginPlatform.instance.sendTestLabel();
  Future<dynamic> getConfigLabel() =>
      ZebraPluginPlatform.instance.getConfigLabel();
  Future<bool?> disconnectPrinter() =>
      ZebraPluginPlatform.instance.disconnectPrinter();
  Future<bool?> connectPrinter(String macID) =>
      ZebraPluginPlatform.instance.connectPrinter(macID);

  Future<bool> hasAllBluetoothPermission() =>
      BluetoothPermissionManager.checkAndRequestPermissions();

  Future<bool> isBluetoothOn() => ZebraPluginPlatform.instance.isBluetoothOn();
  Future<String?> getConnectedDevice() =>
      ZebraPluginPlatform.instance.getConnectedDevice();
  Future<List<dynamic>?> getAllPairedZQDevices() async {
    final devices = await ZebraPluginPlatform.instance.getAllPairedZQDevices();
    return devices?.map((e) {
          if (e != null) {
            final objectMap = e as Map<Object?, Object?>;
            return Map.from(objectMap);
          } else {
            return null;
          }
        }).toList() ??
        [];
  }
}
