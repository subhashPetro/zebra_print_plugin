import 'package:flutter_test/flutter_test.dart';
import 'package:zebra_print_plugin/zebra_print_plugin.dart';
import 'package:zebra_print_plugin/zebra_print_plugin_platform_interface.dart';
import 'package:zebra_print_plugin/zebra_print_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockZebraPrintPluginPlatform
    with MockPlatformInterfaceMixin
    implements ZebraPrintPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final ZebraPrintPluginPlatform initialPlatform = ZebraPrintPluginPlatform.instance;

  test('$MethodChannelZebraPrintPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelZebraPrintPlugin>());
  });

  test('getPlatformVersion', () async {
    ZebraPrintPlugin zebraPrintPlugin = ZebraPrintPlugin();
    MockZebraPrintPluginPlatform fakePlatform = MockZebraPrintPluginPlatform();
    ZebraPrintPluginPlatform.instance = fakePlatform;

    expect(await zebraPrintPlugin.getPlatformVersion(), '42');
  });
}
