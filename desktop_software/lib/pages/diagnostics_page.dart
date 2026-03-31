import 'package:desktop_software/state/app_state.dart';
import 'package:desktop_software/device/device_control_request.dart';
import 'package:desktop_software/device/device_control_slot.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DiagnosticsPage extends StatelessWidget {
  const DiagnosticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final Map<String, String> data = {
      "isConnected": appState.isConnected.toString(),
      "isReady": appState.isReady.toString(),
      "port": appState.port.toString(),
      "enabled": appState.enabled.toString(),
      "sourceVoltage": appState.sourceVoltage.toString(),
      "position": appState.position.toString(),
      "velocity": appState.velocity.toString(),
      "timestamp": appState.timestamp.toString(),
      "controlModeID": appState.controlModeID.toString(),
      "controlModeName": appState.controlModeName.toString(),
      "dutyOut": appState.dutyOut.toString(),
      "voltageOut": appState.voltageOut.toString(),
      "closedLoopTarget": appState.target.toString(),
      "closedLoopError": appState.error.toString(),
      "closedLoopP": appState.pFactor.toString(),
      "closedLoopI": appState.iFactor.toString(),
      "closedLoopD": appState.dFactor.toString(),
      "closedLoopS": appState.sFactor.toString(),
      "closedLoopSubError": appState.subError.toString(),
      "secsToCompletion": appState.secsToCompletion.toString(),
      "closedLoopPhase": appState.phase.toString(),
      "closedLoopPhaseName": appState.phaseName.toString(),
      "updatesPerSec": appState.updatesPerSec.toString(),
      "deviceName": appState.deviceName.toString(),
      "firmwareVersion": appState.firmwareVersion.toString(),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final point in data.entries)
          Row(
            children: [Text(point.key), SizedBox(width: 10), Text(point.value)],
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
                appState.sendControlRequest(DeviceEnableDisableRequest(false));
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
                appState.sendControlRequest(DevicePIDVelocityRequest(3000, 1));
              },
              child: Text("PID Vel"),
            ),
            ElevatedButton(
              onPressed: () {
                appState.sendControlRequest(
                  DeviceTrapezoidalMotionPositionRequest(100000 / 400, 0),
                );
              },
              child: Text("Trap Pos 1"),
            ),
            ElevatedButton(
              onPressed: () {
                appState.sendControlRequest(
                  DeviceTrapezoidalMotionPositionRequest(0, 0),
                );
              },
              child: Text("Trap Pos 0"),
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
                      vMax: 25000 / 400 * 60,
                      aStart: 10000 / 400 * 60 * 60,
                      aEnd: 10000 / 400 * 60 * 60,
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
                      kP: 0.0005,
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
    );
  }
}
