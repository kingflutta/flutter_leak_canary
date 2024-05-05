import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_leak_canary_method_channel.dart';

abstract class FlutterLeakCanaryPlatform extends PlatformInterface {
  /// Constructs a FlutterLeakCanaryPlatform.
  FlutterLeakCanaryPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterLeakCanaryPlatform _instance = MethodChannelFlutterLeakCanary();

  /// The default instance of [FlutterLeakCanaryPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterLeakCanary].
  static FlutterLeakCanaryPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterLeakCanaryPlatform] when
  /// they register themselves.
  static set instance(FlutterLeakCanaryPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
