import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mx_core/mx_core_method_channel.dart';

void main() {
  MethodChannelMxCore platform = MethodChannelMxCore();
  const MethodChannel channel = MethodChannel('mx_core');

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
