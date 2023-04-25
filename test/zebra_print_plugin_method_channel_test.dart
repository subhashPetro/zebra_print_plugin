import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zebra_print_plugin/zebra_print_plugin_method_channel.dart';

void main() {
  MethodChannelZebraPrintPlugin platform = MethodChannelZebraPrintPlugin();
  const MethodChannel channel = MethodChannel('zebra_print_plugin');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
