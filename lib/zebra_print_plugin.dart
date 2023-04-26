import 'package:zebra_print_plugin/permission_manager.dart';
import 'package:zebra_print_plugin/zebra_print_plugin_platform_interface.dart';

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
  Future<bool?> connectPrinter(String macID, String printBytes) =>
      ZebraPrintPluginPlatform.instance.connectPrinter(macID, printBytes);

  Future<bool> hasAllBluetoothPermission() =>
      BluetoothPermissionManager.checkAndRequestPermissions();

  Future<bool> isBluetoothOn() =>
      ZebraPrintPluginPlatform.instance.isBluetoothOn();
  Future<String?> getConnectedDevice() =>
      ZebraPrintPluginPlatform.instance.getConnectedDevice();
  Future<List<dynamic>?> getAllPairedZQDevices() async {
    final devices =
        await ZebraPrintPluginPlatform.instance.getAllPairedZQDevices();
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
