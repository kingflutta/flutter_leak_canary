import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_leak_canary/flutter_leak_canary.dart';
import 'package:flutter_leak_canary/flutter_leak_canary_platform_interface.dart';
import 'package:flutter_leak_canary/flutter_leak_canary_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterLeakCanaryPlatform
    with MockPlatformInterfaceMixin
    implements FlutterLeakCanaryPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterLeakCanaryPlatform initialPlatform = FlutterLeakCanaryPlatform.instance;

  test('$MethodChannelFlutterLeakCanary is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterLeakCanary>());
  });

  test('getPlatformVersion', () async {
    
  });
}
