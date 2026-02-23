import 'dart:isolate';
import 'dart:ui';

import 'package:desktop_software/device/device_loop.dart';
import 'package:desktop_software/device/device_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

class AppState extends ChangeNotifier {
  AppState() {
    logger.i("Spawning device isolate...");
    _deviceReceive = ReceivePort();
    _deviceReceive.listen(_onReceiveFromDevice);
    Isolate.spawn(
          deviceLoop,
          _deviceReceive.sendPort,
          onExit: _deviceReceive.sendPort,
        )
        .then((val) async {
          _deviceIsolate = val;
          logger.i("Successfully created device isolate");
        })
        .onError((err, _) {
          logger.f("Failed to create device isolate, exiting");
          ServicesBinding.instance.exitApplication(AppExitType.cancelable, 1);
        });

    AppLifecycleListener(
      onExitRequested: () async {
        _deviceIsolate?.kill();
        logger.d("closing");
        return AppExitResponse.exit;
      },
    );
  }

  DeviceState? get deviceState => _deviceState;

  final logger = Logger();

  late final ReceivePort _deviceReceive;
  Isolate? _deviceIsolate;
  DeviceState? _deviceState;

  void _onReceiveFromDevice(dynamic msg) {
    if (msg is DeviceState) {
      _deviceState = msg;
      notifyListeners();
    }
  }
}
