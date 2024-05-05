import 'dart:collection';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:vm_service/utils.dart';
import 'package:vm_service/vm_service.dart';
import 'package:vm_service/vm_service_io.dart';

const String vmServiceHelperLiraryPath =
    'package:flutter_leak_canary/vm_service_helper.dart';

final _snapWeakReferenceMap = HashMap<String, WeakReference>();

//dont remove this method, it's invoked by getObjectId
String getLiraryResponse() {
  return "Hello LeakCanary";
}
//dont remove this method, it's invoked by getObjectId
dynamic popSnapObject(String objectKey) {
  final object = _snapWeakReferenceMap[objectKey];
  return object?.target;
}

class VmServiceHelper {
  bool debug = false;
  VmServiceHelper() {
    assert(() {
      debug = true;
      return true;
    }());
  }
  VmService? _vmService;
  VM? _vm;
  Uri? _observatoryUri;

  Future<LibraryRef?> getLiraryByPath(String libraryPath) async {
    if (!debug) {
      return null;
    }
    Isolate? mainIsolate = await getMainIsolate();
    if (mainIsolate != null) {
      final libraries = mainIsolate.libraries;
      if (libraries != null) {
        final index =
            libraries.indexWhere((element) => element.uri == libraryPath);
        if (index != -1) {
          return libraries[index];
        }
      }
    }
    return null;
  }

  Future<String?> getObjectId(WeakReference obj) async {
    if (!debug) {
      return null;
    }
    final library = await getLiraryByPath(vmServiceHelperLiraryPath);
    if (library == null || library.id == null) return null;
    final vms = await getVmService();
    if (vms == null) return null;
    final mainIsolate = await getMainIsolate();
    if (mainIsolate == null || mainIsolate.id == null) return null;
    Response libRsp =
        await vms.invoke(mainIsolate.id!, library.id!, 'getLiraryResponse', []);
    final libRspRef = InstanceRef.parse(libRsp.json);
    String? libRspRefVs = libRspRef?.valueAsString;
    if (libRspRefVs == null) return null;
    _snapWeakReferenceMap[libRspRefVs] = obj;
    try {
      Response popSnapObjectRsp = await vms.invoke(
          mainIsolate.id!, library.id!, "popSnapObject", [libRspRef!.id!]);
      final instanceRef = InstanceRef.parse(popSnapObjectRsp.json);
      return instanceRef?.id;
    } catch (e, stack) {
      print('getObjectId $stack');
    } finally {
      _snapWeakReferenceMap.remove(libRspRefVs);
    }
    return null;
  }

  Future<Obj?> getObjById(String objectId) async {
    if (!debug) {
      return null;
    }
    final vms = await getVmService();
    if (vms == null) return null;
    final mainIsolate = await getMainIsolate();
    if (mainIsolate?.id != null) {
      try {
        Obj obj = await vms.getObject(mainIsolate!.id!, objectId);
        return obj;
      } catch (e, stack) {
        print('getObjById>>$stack');
      }
    }
    return null;
  }

  Future<Instance?> getInstanceByObjectId(String objectId) async {
    if (!debug) {
      return null;
    }
    Obj? obj = await getObjById(objectId);
    if (obj != null) {
      var instance = Instance.parse(obj.json);
      return instance;
    }
    return null;
  }

  Future<ObjRef?> getObjRefByObjectId(String objectId) async {
    Instance? instance = await getInstanceByObjectId(objectId);
    return instance?.propertyKey;
  }

  Future<RetainingPath?> getRetainingPath(String objectId, int limit) async {
    if (!debug) {
      return null;
    }
    final vms = await getVmService();
    if (vms == null) return null;
    final mainIsolate = await getMainIsolate();
    if (mainIsolate != null && mainIsolate.id != null) {
      return vms.getRetainingPath(mainIsolate.id!, objectId, limit);
    }
    return null;
  }

  Future<VmService?> getVmService() async {
    if (_vmService == null && debug) {
      ServiceProtocolInfo serviceProtocolInfo = await Service.getInfo();
      _observatoryUri = serviceProtocolInfo.serverUri;
      if (_observatoryUri != null) {
        Uri url = convertToWebSocketUrl(serviceProtocolUrl: _observatoryUri!);
        try {
          _vmService = await vmServiceConnectUri(url.toString());
        } catch (error, stack) {
          print(stack);
        }
      }
    }
    return _vmService;
  }

  Future try2GC() async {
    if (!debug) {
      return;
    }
    final vms = await getVmService();
    if (vms == null) return null;
    final isolate = await getMainIsolate();
    if (isolate?.id != null) {
      await vms.getAllocationProfile(isolate!.id!, gc: true);
    }
  }

  Future<Isolate?> getMainIsolate() async {
    if (!debug) {
      return null;
    }
    IsolateRef? ref;
    final vm = await getVM();
    if (vm == null) return null;
    var index = vm.isolates?.indexWhere((element) => element.name == 'main');
    if (index != -1) {
      ref = vm.isolates![index!];
    }
    final vms = await getVmService();
    if (ref?.id != null) {
      return vms?.getIsolate(ref!.id!);
    }
    return null;
  }

  Future<VM?> getVM() async {
    if (!debug) {
      return null;
    }
    return _vm ??= await (await getVmService())?.getVM();
  }
}
