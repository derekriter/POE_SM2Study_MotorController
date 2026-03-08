import 'dart:async';
import 'dart:typed_data';

import 'package:desktop_software/device/device_control_request.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:logger/logger.dart';

final _logger = Logger();

SerialPort? _port;
SerialPortConfig? _portConfig;
DateTime? _lastSendTime;
DateTime? _connectTime;

//NOTE: calling any functions in this file from any isolates other than the device loop will probably break things

bool connect() {
  if (isConnected()) {
    _logger.w("Device already connected");
    return false;
  }

  /*
  all config parameters must be manually set
  https://pub.dev/documentation/flutter_libserialport/latest/flutter_libserialport/SerialPortConfig-class.html
  
  Arduino doesnt support flow control, ie. no DTR, RTS, DSR, CTS, or XON/XOFF
  https://arduino.stackexchange.com/a/98737
  
  Arduino defaults to 8 bits with no parity and 1 stop bit (8N1 serial)
  https://docs.arduino.cc/language-reference/en/functions/communication/serial/begin/
  */
  _portConfig = SerialPortConfig()
    ..baudRate = 115200
    ..bits = 8
    ..parity = SerialPortParity.none
    ..stopBits = 1
    ..dtr = SerialPortDtr.off
    ..rts = SerialPortRts.off
    ..dsr = SerialPortDsr.ignore
    ..cts = SerialPortCts.ignore
    ..xonXoff = SerialPortXonXoff.disabled;

  _port = SerialPort("COM6"); //TODO: port scanning

  if (!_port!.openReadWrite()) {
    _logger.e("Failed to open device connection\n${SerialPort.lastError}");
    _port = null;
    return false;
  }

  /*
  config must be set after opening port
  https://github.com/jpnurmi/flutter_libserialport/issues/29#issuecomment-1706355179
  */
  _port!.config = _portConfig!;

  _connectTime = DateTime.now();

  _logger.i("Connected to device on port ${getConnectedPort()}");
  return true;
}

void disconnect() {
  if (!isConnected()) {
    _logger.w("Device already disconnected");
    return;
  }

  _port?.drain(); //wait for send buffer to clear
  _port?.close();
  _port?.dispose();
  _port = null;

  // _portConfig?.dispose(); // causes assertion failure even though the docs say to dispose. I think SerialPort.dispose() might auto dispose the config
  _portConfig = null;

  _connectTime = null;

  _logger.i("Disconnected from device");
}

bool isConnected() {
  return _port != null && _port!.isOpen;
}

bool isReady() {
  return isConnected() &&
      _connectTime != null &&
      DateTime.now().difference(_connectTime!).inMilliseconds >=
          200; //allow time for connection to configure and stabilize
}

String? getConnectedPort() {
  return isConnected() ? _port?.name : null;
}

Future<String?> readLine() async {
  if (!isReady()) return null;

  StringBuffer line = StringBuffer();
  await Future.doWhile(() {
    late String data;
    try {
      data = String.fromCharCode(_port!.read(1, timeout: 0)[0]);
    } catch (err) {
      _logger.e("Exception while reading line: $err");
      return false;
    }

    if (data == "\n") {
      return false;
    }

    line.write(data);
    return true;
  });

  return line.toString();
}

Future<bool> _sendMessage(Uint8List msg) async {
  if (!isReady()) return false;

  await Future.doWhile(() {
    return _lastSendTime != null &&
        DateTime.now().difference(_lastSendTime!).inMilliseconds < 40;
  });

  try {
    await Future.microtask(() {
      _port!.write(msg, timeout: 0);
    });
    _lastSendTime = DateTime.now();
  } catch (err) {
    _logger.e("Exception while sending message: $err");
    _lastSendTime = null;
    return false;
  }

  return true;
}

Future<bool> sendControlRequest(DeviceControlRequest req) async {
  final commands = req.toSerialCommands();

  bool anyFailed = false;
  for (final c in commands) {
    if (!await _sendMessage(Uint8List.fromList(c.codeUnits))) {
      anyFailed = true;
    }
  }

  return !anyFailed;
}

void flushBuffers() {
  if (!isConnected()) return;

  _port!.flush(SerialPortBuffer.both);
}
