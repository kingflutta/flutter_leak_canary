import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_leak_canary/flutter_leak_canary.dart';
import 'package:flutter_leak_canary/leak_canary_manager.dart';

mixin LeakCanaryStateMixin<T extends StatefulWidget> on State<T> {
  late WeakReference _wr;
  String? objId;
  @mustCallSuper
  @override
  void initState() {
    super.initState();
    _wr = WeakReference(this);
    FlutterLeakCanary.get().watch(_wr);
  }

  @mustCallSuper
  @override
  void dispose() {
    super.dispose();
    FlutterLeakCanary.get().try2Check(_wr);
  }
}
