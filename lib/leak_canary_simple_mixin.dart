import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_leak_canary/flutter_leak_canary.dart';
import 'package:flutter_leak_canary/leak_canary_manager.dart';

mixin LeakCanarySimpleMixin {
  late WeakReference _wr;
  String? objId;
  void watch()  {
    _wr = WeakReference(this);
   FlutterLeakCanary.get().watch(_wr);
  }

  void try2Check() {
    FlutterLeakCanary.get().try2Check(_wr);
  }
}
