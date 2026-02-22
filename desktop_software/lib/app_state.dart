import 'dart:io';
import 'dart:isolate';

import 'package:desktop_software/device/device.dart' as device;
import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  AppState() {
    Isolate.run(_deviceLoop);
  }

  bool get isConnected => _isConnected;

  bool _isConnected = false;

  void _deviceLoop() async {
    while (true) {
      if (!_isConnected) {
        _isConnected = device.connect();
        notifyListeners();

        if (!_isConnected) {
          sleep(Duration(seconds: 3));
          continue;
        }
      }
    }
  }
}
