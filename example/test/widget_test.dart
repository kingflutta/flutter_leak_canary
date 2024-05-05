// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_leak_canary_example/main.dart';
import 'dart:developer';

Expando<Data> expando = Expando<Data>('ancc');

class Key {}

Key key = Key();

class Data {
  String? value;
}  

var data = Data()..value = '1';
WeakReference<Data>? _cache;
Expando<String> ed = Expando<String>();
void test() {
  var data2 =  Data()..value = '2';
  ed[data2] = 'Expando start';

  _cache = WeakReference<Data>(data);
  print(_cache?.target?.value ?? '');
  print(ed[data2]);
}

void main() async {

}
