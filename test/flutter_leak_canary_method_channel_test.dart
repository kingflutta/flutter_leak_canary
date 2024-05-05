import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_leak_canary/flutter_leak_canary_method_channel.dart';

void main() {
  MethodChannelFlutterLeakCanary platform = MethodChannelFlutterLeakCanary();
  const MethodChannel channel = MethodChannel('flutter_leak_canary');

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
