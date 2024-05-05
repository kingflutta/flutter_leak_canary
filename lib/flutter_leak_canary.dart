// You have generated a new plugin project without specifying the `--platforms`
// flag. A plugin project with no platform support was generated. To add a
// platform, run `flutter create -t plugin --platforms <platforms> .` under the
// same directory. You can also find a detailed instruction on how to add
// platforms in the `pubspec.yaml` at
// https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'package:flutter/src/foundation/change_notifier.dart';
import 'package:flutter_leak_canary/leak_canary_manager.dart';
import 'package:flutter_leak_canary/leak_canary_state_mixin.dart';
import 'package:flutter_leak_canary/leak_canary_simple_mixin.dart';

import 'leak_cannary_model.dart';

class FlutterLeakCanary implements LeakCanaryMananger {
  final _helper = LeakCanaryMananger();
  static final _instance = FlutterLeakCanary._();
  FlutterLeakCanary._();
  factory() => _instance;

  static FlutterLeakCanary get() {
    return _instance;
  }

  @override
  void watch(obj) {
     _helper.watch(obj);
  }

  @override
  void try2Check(WeakReference wr) {
    _helper.try2Check(wr);
  }

  void addListener(VoidCallback listener) {
    _helper.leakCanaryModelNotifier.addListener(listener);
  }

  void removeListener(VoidCallback listener) {
    _helper.leakCanaryModelNotifier.removeListener(listener);
  }
  
  
  @override
  List<LeakCanaryWeakModel> get canaryModels => List.unmodifiable(_helper.canaryModels);
  
  @override
  ValueNotifier get leakCanaryModelNotifier => _helper.leakCanaryModelNotifier;
}
