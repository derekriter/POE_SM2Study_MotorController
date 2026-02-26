import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:logger/logger.dart';

final _logger = Logger();

SerialPort? _port;

//NOTE: calling any functions in this file from any isolates other than the device loop will probably break things

enum ControlMode {
  none,
  dutyCycle,
  voltage,
  pidPosition,
  pidVelocity,
  trapPosition;

  static ControlMode? fromID(int id) {
    switch (id) {
      case 0:
        return none;
      case 1:
        return dutyCycle;
      case 2:
        return voltage;
      case 3:
        return pidPosition;
      case 4:
        return pidVelocity;
      case 5:
        return trapPosition;
    }

    return null;
  }
}

bool connect() {
  if (isConnected()) {
    _logger.w("Device already connected");
    return false;
  }

  _port = SerialPort("COM6"); //TODO: port scanning

  if (!_port!.openReadWrite()) {
    _logger.e("Failed to open device connection\n${SerialPort.lastError}");
    _port = null;
    return false;
  }

  /*
  config must be set after opening port
  https://github.com/jpnurmi/flutter_libserialport/issues/29#issuecomment-1706355179
  
  all config parameters must be manually set
  https://pub.dev/documentation/flutter_libserialport/latest/flutter_libserialport/SerialPortConfig-class.html
  
  used https://github.com/jpnurmi/flutter_libserialport/issues/140 as reference for configs
  
  Arduino doesnt support flow control, ie. no DTR, RTS, DSR, CTS, or XON/XOFF
  https://arduino.stackexchange.com/a/98737
  
  Arduino defaults to 8 bits with no parity and 1 stop bit
  https://docs.arduino.cc/language-reference/en/functions/communication/serial/begin/#:~:text=SERIAL_7N1-,serial_8n1
  */
  _port!.config = SerialPortConfig()
    ..baudRate = 115200
    ..bits = 8
    ..parity = SerialPortParity.none
    ..stopBits = 1
    ..dtr = SerialPortDtr.off
    ..rts = SerialPortRts.off
    ..dsr = SerialPortDsr.ignore
    ..cts = SerialPortCts.ignore
    ..xonXoff = SerialPortXonXoff.disabled;

  _logger.i("Connected to device on port ${_port!.name}");
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

  _logger.i("Disconnected from device");
}

bool isConnected() {
  return _port != null && _port!.isOpen;
}

String? getConnectedPort() {
  return isConnected() ? _port?.name : null;
}

Future<String?> readLine() async {
  if (!isConnected()) return null;

  StringBuffer line = StringBuffer();
  await Future.doWhile(() {
    late String data;
    try {
      data = String.fromCharCode(_port!.read(1, timeout: 0)[0]);
    } catch (err) {
      _logger.e("Exception while reading line: '$err'");
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
