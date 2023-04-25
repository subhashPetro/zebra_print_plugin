import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'zebra_print_plugin_method_channel.dart';

abstract class ZebraPrintPluginPlatform extends PlatformInterface {
  /// Constructs a ZebraPrintPluginPlatform.
  ZebraPrintPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static ZebraPrintPluginPlatform _instance = MethodChannelZebraPrintPlugin();

  /// The default instance of [ZebraPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelZebraPlugin].
  static ZebraPrintPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ZebraPluginPlatform] when
  /// they register themselves.
  static set instance(ZebraPrintPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<bool?> sendTestLabel();
  Future<dynamic> getConfigLabel();
  Future<bool?> disconnectPrinter();
  Future<bool?> connectPrinter(String macID);
  Future<bool> isBluetoothOn();
  Future<String?> getConnectedDevice();
  Future<dynamic> getAllPairedZQDevices();
}
