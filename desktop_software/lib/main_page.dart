import 'package:desktop_software/app_state.dart';
import 'package:desktop_software/device/device_control_request.dart';
import 'package:desktop_software/device/device_control_slot.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final Map<String, String> data = {
      "isConnected": appState.isConnected.toString(),
      "isReady": appState.isReady.toString(),
      "port": appState.port ?? "null",
      "enabled": appState.enabled.toString(),
      "sourceVoltage": appState.sourceVoltage.toString(),
      "position": appState.position.toString(),
      "velocity": appState.velocity.toString(),
      "timestamp": appState.timestamp.toString(),
      "controlModeName": appState.controlModeName.toString(),
      "dutyOut": appState.dutyOut.toString(),
      "voltageOut": appState.voltageOut.toString(),
      "closedLoopTarget": appState.closedLoopTarget.toString(),
      "closedLoopError": appState.closedLoopError.toString(),
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
              ElevatedButton(
                onPressed: () {
                  appState.sendControlRequest(DevicePIDPositionRequest(300, 0));
                },
                child: Text("PID Pos"),
              ),
            ],
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  appState.sendControlRequest(
                    DeviceSlotConfigRequest(
                      0,
                      DeviceSlotConfig(
                        kP: 0.02,
                        kI: 0,
                        kD: 0.0003,
                        kS: 0.17,
                        kSMode: KSMode.errorBased,
                        vMax: 25000,
                        aStart: 10000,
                        aEnd: 10000,
                      ),
                    ),
                  );
                },
                child: Text("Dummy Slot 0"),
              ),
              ElevatedButton(
                onPressed: () {
                  appState.sendControlRequest(DeviceGetSlotRequest(0));
                },
                child: Text("Get Slot 0"),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < (appState.slotConfigs?.length ?? 0); i++)
                Text("slot$i: ${appState.slotConfigs![i]}"),
            ],
          ),
        ],
      ),
    );
  }
}
