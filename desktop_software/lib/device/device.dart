import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:logger/logger.dart';

final logger = Logger();

SerialPort? _port;

bool connect() {
  if (isConnected()) {
    logger.w("Device already connected");
    return false;
  }

  _port = SerialPort("COM6");
  if (!_port!.openReadWrite()) {
    logger.e("Failed to open device connection\n${SerialPort.lastError}");
    _port = null;
    return false;
  }

  logger.i("Connected to device on port ${_port!.name}");
  return true;
}

void disconnect() {
  if (!isConnected()) {
    logger.w("Device already disconnected");
    return;
  }

  _port!.close();
  _port!.dispose();
  _port = null;

  logger.i("Disconnected from device");
}

bool isConnected() {
  return _port != null && _port!.isOpen;
}
