import 'package:flutter/foundation.dart';

class Logger {
 static void log(var data) {
    if (kDebugMode) {
      print(data);
    }
  }
}
