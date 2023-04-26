import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:zebra_print_plugin/zebra_core.dart';
import 'package:zebra_print_plugin/zebra_print_plugin_platform_interface.dart';

/// An implementation of [ZebraPluginPlatform] that uses method channels.
class MethodChannelZebraPrintPlugin extends ZebraPrintPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('zebra_print_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<bool?> connectPrinter(String macID, String printBytes) async {
    final value = await methodChannel
        .invokeMethod<String?>(connectChannel, <String, dynamic>{
      'macID': macID,
      'printBytes': printBytes,
    });
    return value == "true";
  }

  @override
  Future<bool?> disconnectPrinter() async {
    final value = await methodChannel.invokeMethod<String?>(disConnectChannel);
    return value == "true";
  }

  @override
  Future<dynamic> getConfigLabel() async {
    return await methodChannel.invokeMethod<bool>(getConfigLabelChannel);
  }

  @override
  Future<bool?> sendTestLabel() async {
    final value =
        await methodChannel.invokeMethod<String?>(sendTestLabelChannel);
    return value == "true";
  }

  @override
  Future<String?> getConnectedDevice() async {
    return await methodChannel.invokeMethod<String?>(connectedDeviceChannel);
  }

  @override
  Future<bool> isBluetoothOn() async {
    final res = await methodChannel.invokeMethod<Map<Object?, Object?>>(
      isBluetoothOnChannel,
    );
    if (res != null && res['isBluetoothOn'] != null) {
      return res['isBluetoothOn'] as bool;
    } else {
      return false;
    }
  }

  @override
  Future<List<dynamic>?> getAllPairedZQDevices() async {
    final devices =
        await methodChannel.invokeMethod<dynamic>(getAllPairedZQDevicesChannel);
    return devices;
  }
}
