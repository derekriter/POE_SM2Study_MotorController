// ignore_for_file: implementation_imports

import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart' as ffi;
//horrible practice, but its the only way to do this without having to either make my own implementation of the dll or make a fork with modifications
import 'package:libserialport/src/dylib.dart';
import 'package:libserialport/src/bindings.dart';
import 'package:libserialport/src/util.dart';

typedef PortInfo = ({String name, String? description});
typedef ConnectionInfo = ({bool connected, bool ready, PortInfo? portInfo});

Set<PortInfo> getAvailablePortInfo() {
  //modified code from libserialport _SerialPortImpl::availablePorts

  final out = ffi.calloc<ffi.Pointer<ffi.Pointer<sp_port>>>();
  final rv = Util.call(() => dylib.sp_list_ports(out));
  if (rv != sp_return.SP_OK) {
    ffi.calloc.free(out);
    return {};
  }

  var i = -1;
  final ports = <PortInfo>{};
  final array = out.value;
  while (array[++i] != ffi.nullptr) {
    final name = Util.fromUtf8(dylib.sp_get_port_name(array[i]));
    final desc = Util.fromUtf8(dylib.sp_get_port_description(array[i]));

    if (name == null) continue;

    ports.add((name: name, description: desc));
  }
  dylib.sp_free_port_list(array);

  return ports;
}
