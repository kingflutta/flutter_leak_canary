import 'dart:isolate';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_leak_canary/flutter_leak_canary.dart';
import 'package:flutter_leak_canary/leak_canary_state_mixin.dart';
import 'package:flutter_leak_canary/leak_cannary_model.dart';
import 'package:flutter_leak_canary_example/weak_page.dart';
import 'package:intl/intl.dart';

import 'package:vm_service/vm_service.dart' as vm;

void main() {
  runApp(_MyApp());
}

class _MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
    FlutterLeakCanary.get().addListener(_onChange);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return WeakPage();
      }));
    });
  }

  List<LeakCanaryWeakModel> canaryModels = [];

  _onChange() {
    if (mounted) {
      setState(() {
        canaryModels = FlutterLeakCanary.get().canaryModels;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    FlutterLeakCanary.get().removeListener(_onChange);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: ListView.builder(
        itemCount: canaryModels.length,
        itemBuilder: (BuildContext context, int index) {
          final canaryModel = canaryModels[index];
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '${DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.fromMillisecondsSinceEpoch(canaryModel.createTime))}'),
                Text('file:${canaryModel.classFileName}',style: TextStyle(color: Colors.lightBlue),),
                Text('class name:${canaryModel.className}',style: TextStyle(color: Colors.red),),
                Text('location>column:${canaryModel.column},line:${canaryModel.line}', style: TextStyle(color: Colors.redAccent),),
                SizedBox(
                  height: 5,
                ),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: Color(0xFFf5f5f5),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
