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
      "closedLoopP": appState.closedLoopP.toString(),
      "closedLoopI": appState.closedLoopI.toString(),
      "closedLoopD": appState.closedLoopD.toString(),
      "closedLoopS": appState.closedLoopS.toString(),
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
              ElevatedButton(
                onPressed: () {
                  appState.sendControlRequest(
                    DevicePIDVelocityRequest(3000, 1),
                  );
                },
                child: Text("PID Vel"),
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
                        kP: 0.03,
                        kI: 0,
                        kD: 0.01,
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
                  appState.sendControlRequest(
                    DeviceSlotConfigRequest(
                      1,
                      DeviceSlotConfig(
                        kP: 0.002,
                        kI: 0.00001,
                        kD: 0,
                        kS: 0.17,
                        kSMode: KSMode.velocityBased,
                        vMax: 0,
                        aStart: 0,
                        aEnd: 0,
                      ),
                    ),
                  );
                },
                child: Text("Dummy Slot 1"),
              ),
              ElevatedButton(
                onPressed: () {
                  for (int i = 0; i < 6; i++) {
                    appState.sendControlRequest(DeviceGetSlotRequest(i));
                  }
                },
                child: Text("Refresh slots"),
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
