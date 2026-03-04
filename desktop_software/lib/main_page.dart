import 'package:desktop_software/app_state.dart';
import 'package:desktop_software/device/device_control_request.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final Map<String, String> data = {
      "isConnected": appState.isConnected.toString(),
      "port": appState.port ?? "null",
      "enabled": appState.enabled.toString(),
      "sourceVoltage": appState.sourceVoltage.toString(),
      "position": appState.position.toString(),
      "velocity": appState.velocity.toString(),
      "controlModeName": appState.controlModeName.toString(),
      "dutyOut": appState.dutyOut.toString(),
      "voltageOut": appState.voltageOut.toString(),
    };

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final point in data.entries)
            Row(
              children: [
                Text(point.key),
                SizedBox(width: 10),
                Text(point.value),
              ],
            ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  appState.sendControlRequest(DeviceEnableDisableRequest(true));
                },
                child: Text("Enable"),
              ),
              ElevatedButton(
                onPressed: () {
                  appState.sendControlRequest(
                    DeviceEnableDisableRequest(false),
                  );
                },
                child: Text("Disable"),
              ),
            ],
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  appState.sendControlRequest(DeviceStopRequest());
                },
                child: Text("Stop"),
              ),
              ElevatedButton(
                onPressed: () {
                  appState.sendControlRequest(DeviceDutyCycleRequest(1));
                },
                child: Text("Duty Cycle"),
              ),
              ElevatedButton(
                onPressed: () {
                  appState.sendControlRequest(DeviceVoltageRequest(6));
                },
                child: Text("Voltage"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
