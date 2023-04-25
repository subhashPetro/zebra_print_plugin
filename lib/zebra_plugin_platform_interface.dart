import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'zebra_plugin_method_channel.dart';

abstract class ZebraPluginPlatform extends PlatformInterface {
  /// Constructs a ZebraPluginPlatform.
  ZebraPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static ZebraPluginPlatform _instance = MethodChannelZebraPlugin();

  /// The default instance of [ZebraPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelZebraPlugin].
  static ZebraPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ZebraPluginPlatform] when
  /// they register themselves.
  static set instance(ZebraPluginPlatform instance) {
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
  Future<List<dynamic>?> getAllPairedZQDevices();
}
