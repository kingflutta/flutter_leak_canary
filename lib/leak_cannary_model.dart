import 'leak_canary_manager.dart';

class LeakCanaryWeakModel {
  late int createTime;
  final String? className;
  final String? classFileName;
  final int? line;
  final int? column;

  LeakCanaryWeakModel({required this.className,required this.classFileName,required this.column,required this.line,}) {
    createTime = DateTime.now().millisecondsSinceEpoch;
  }
}

