import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter_leak_canary/vm_service_helper.dart';
import 'package:vm_service/vm_service.dart';

import 'leak_cannary_model.dart';

abstract class LeakCanaryMananger {
  factory LeakCanaryMananger() => _LeakCanaryMananger();
  void watch(WeakReference obj);
  void try2Check(WeakReference wr);
  List<LeakCanaryWeakModel> get canaryModels;
  ValueNotifier get leakCanaryModelNotifier;
}

class GCRunnable {
  String? objectId;
  final WeakReference? wkObj;

  GCRunnable({required this.wkObj});
  Future<LeakCanaryWeakModel?> run() async {
    if (wkObj?.target != null) {
      final vmsh = VmServiceHelper();
      //cant quary objectId with isolate, but quary instance
      objectId = await vmsh.getObjectId(wkObj!);
      LeakCanaryWeakModel? weakModel = await compute(_runQuery, objectId);
      return weakModel;
    }
  }
}


Future<void> runGc(data) async {
  final vmsh = VmServiceHelper();
  await Future.delayed(Duration(seconds: 1));
  await vmsh.try2GC();
}

Future<LeakCanaryWeakModel?> _runQuery(objectId) async {
  final vmsh = VmServiceHelper();
  Instance? instance = await vmsh.getInstanceByObjectId(objectId!);
  if (instance != null &&
      instance.id != 'objects/null' &&
      instance.classRef is ClassRef) {
    ClassRef? targetClassRef = instance.classRef;
    final wm = LeakCanaryWeakModel(
        className: targetClassRef!.name,
        line: targetClassRef.location?.line,
        column: targetClassRef.location?.column,
        classFileName: targetClassRef.library?.uri);
    print(wm.className);
    return wm;
  }
  return null;
}

class _LeakCanaryMananger implements LeakCanaryMananger {
  static final vmsh = VmServiceHelper();
  //objId:instance
  final _objectWeakReferenceMap = HashMap<int, WeakReference?>();
  List<GCRunnable> runnables = [];
  Timer? timer;
  bool isDetecting = false;
  loopRunnables() {
    timer ??= Timer.periodic(Duration(seconds: 3), (timer) {
      if (isDetecting) {
        return;
      }
      if (runnables.isNotEmpty) {
        isDetecting = true;
        final trunnables = List<GCRunnable>.unmodifiable(runnables);
        runnables.clear();
        //request full gc and check all
        compute(runGc, null).then((value) async {
          await Future.forEach<GCRunnable>(trunnables, (runnable) async {
            if (runnable.objectId == "objects/null") {
              return;
            }
            try {
              final LeakCanaryWeakModel? wm = await runnable.run();
              if (wm != null) {
                canaryModels.add(wm);
                leakCanaryModelNotifier.value = wm;
              }
            } catch (e, s) {
              print(s);
            } finally {
              _objectWeakReferenceMap.remove(runnable.wkObj.hashCode);
            }
          });
          isDetecting = false;
        });
      }
    });
  }

  @override
  void watch(WeakReference wr) async {
    bool isDebug = false;
    assert(() {
      isDebug = true;
      return true;
    }());
    if (!isDebug) {
      return;
    }
    _objectWeakReferenceMap[wr.hashCode] = wr;
    loopRunnables();
  }

  @override
  ValueNotifier leakCanaryModelNotifier = ValueNotifier(null);

  Completer _lock = Completer();
  List<Completer> _locks = [];

  void _check(WeakReference? wr) {
    assert(() {
      WeakReference? wkObj = _objectWeakReferenceMap[wr.hashCode];
      runnables.add(GCRunnable(wkObj: wkObj));
      return true;
    }());
  }

  @override
  void try2Check(WeakReference wr) async {
    bool isDebug = false;
    assert(() {
      isDebug = true;
      return true;
    }());
    if (!isDebug) {
      return;
    }
    if (wr.target != null) {
      _check(wr);
    }
  }

  @override
  List<LeakCanaryWeakModel> canaryModels = [];
}
