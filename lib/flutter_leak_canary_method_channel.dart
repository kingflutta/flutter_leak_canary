import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_leak_canary_platform_interface.dart';

/// An implementation of [FlutterLeakCanaryPlatform] that uses method channels.
class MethodChannelFlutterLeakCanary extends FlutterLeakCanaryPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_leak_canary');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
