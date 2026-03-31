import 'package:desktop_software/state/app_state.dart';
import 'package:desktop_software/device/device_control_mode.dart';
import 'package:desktop_software/util/data_source.dart';
import 'package:desktop_software/widgets/data_widgets.dart';
import 'package:desktop_software/widgets/overflow_text.dart';
import 'package:desktop_software/widgets/smooth_scroll.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DataTab extends StatelessWidget {
  const DataTab({super.key});

  static const Widget _divider = Divider(
    indent: 0,
    endIndent: 0,
    radius: null,
    height: 8,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: SmoothScroll(
        builder:
            (
              BuildContext _,
              ScrollController controller,
              ScrollPhysics physics,
            ) => ListView(
              controller: controller,
              physics: physics,
              children: const [
                _EnabledWidget(),
                _divider,
                _SourceVoltageWidget(),
                _divider,
                _PositionWidget(),
                _divider,
                _VelocityWidget(),
                _divider,
                _ControlModeWidget(),
                _divider,
                _DutyOutWidget(),
                _divider,
                _VoltageOutWidget(),
                _divider,
                _TargetWidget(),
                _divider,
                _ErrorWidget(),
                _divider,
                _PFactorWidget(),
                _divider,
                _IFactorWidget(),
                _divider,
                _DFactorWidget(),
                _divider,
                _SFactorWidget(),
                _divider,
                _SlotWidget(),
                _divider,
                _SubErrorWidget(),
                _divider,
                _SecsToCompletionWidget(),
                _divider,
                _PhaseNameWidget(),
                _divider,
              ],
            ),
      ),
    );
  }
}

class _EnabledWidget extends StatelessWidget {
  // ignore: unused_element_parameter
  const _EnabledWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final appStateRead = context.read<AppState>();
    final enabled = context.select((AppState appState) => appState.enabled);

    final theme = Theme.of(context);

    final validStyle = TextStyle(color: theme.colorScheme.onSurface);
    final invalidStyle = TextStyle(
      color: theme.colorScheme.onSurface.withAlpha(127),
      fontStyle: FontStyle.italic,
    );

    return Draggable<DiscreteDataSource>(
      data: DiscreteDataSource(
        name: "enabled",
        watchCurrentValue: (context) =>
            context.select((AppState state) => state.enabled)?.toString(),
        getValueAtTimestamp: (timestamp) =>
            appStateRead.enabledTimeMap?.getValueAtTime(timestamp)?.toString(),
        getAllValueChanges: () => appStateRead.enabledTimeMap
            ?.getAllValueChanges()
            .map((entry) => MapEntry(entry.key, entry.value?.toString())),
      ),
      feedback: OverflowText("enabled", style: theme.textTheme.bodyMedium),
      dragAnchorStrategy: (draggable, context, position) =>
          pointerDragAnchorStrategy(draggable, context, position),
      hitTestBehavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: OverflowText(
                  "enabled",
                  style: enabled == null ? invalidStyle : validStyle,
                ),
              ),
            ),
            if (enabled != null) Expanded(child: BooleanDataWidget(enabled)),
          ],
        ),
      ),
    );
  }
}

class _SourceVoltageWidget extends StatelessWidget {
  // ignore: unused_element_parameter
  const _SourceVoltageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final appStateRead = context.read<AppState>();
    final sv = context.select((AppState appState) => appState.sourceVoltage);

    final theme = Theme.of(context);

    final validStyle = TextStyle(color: theme.colorScheme.onSurface);
    final invalidStyle = TextStyle(
      color: theme.colorScheme.onSurface.withAlpha(127),
      fontStyle: FontStyle.italic,
    );

    return Draggable<ContinousDataSource>(
      data: ContinousDataSource(
        name: "sourceVoltage",
        watchCurrentValue: (context) =>
            context.select((AppState state) => state.sourceVoltage),
        getValueAtTimestamp: (timestamp) =>
            appStateRead.sourceVoltageTimeMap?.getValueAtTime(timestamp),
        getAllValueChanges: () =>
            appStateRead.sourceVoltageTimeMap?.getAllValueChanges(),
        stringRepresentation: (volts) => "${volts.toStringAsFixed(2)} V",
      ),
      feedback: OverflowText(
        "sourceVoltage",
        style: theme.textTheme.bodyMedium,
      ),
      dragAnchorStrategy: (draggable, context, position) =>
          pointerDragAnchorStrategy(draggable, context, position),
      hitTestBehavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: OverflowText(
                  "sourceVoltage",
                  style: sv == null ? invalidStyle : validStyle,
                ),
              ),
            ),
            if (sv != null)
              Expanded(child: NumberDataWidget(sv, precision: 2, suffix: " V")),
          ],
        ),
      ),
    );
  }
}

class _PositionWidget extends StatelessWidget {
  // ignore: unused_element_parameter
  const _PositionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final appStateRead = context.read<AppState>();
    final pos = context.select((AppState appState) => appState.position);

    final theme = Theme.of(context);

    final validStyle = TextStyle(color: theme.colorScheme.onSurface);
    final invalidStyle = TextStyle(
      color: theme.colorScheme.onSurface.withAlpha(127),
      fontStyle: FontStyle.italic,
    );

    return Draggable<ContinousDataSource>(
      data: ContinousDataSource(
        name: "position",
        watchCurrentValue: (context) =>
            context.select((AppState state) => state.position),
        getValueAtTimestamp: (timestamp) =>
            appStateRead.positionTimeMap?.getValueAtTime(timestamp),
        getAllValueChanges: () =>
            appStateRead.positionTimeMap?.getAllValueChanges(),
        stringRepresentation: (rots) => "${rots.toStringAsFixed(4)} rots",
      ),
      feedback: OverflowText("position", style: theme.textTheme.bodyMedium),
      dragAnchorStrategy: (draggable, context, position) =>
          pointerDragAnchorStrategy(draggable, context, position),
      hitTestBehavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: OverflowText(
                  "position",
                  style: pos == null ? invalidStyle : validStyle,
                ),
              ),
            ),
            if (pos != null)
              Expanded(
                child: NumberDataWidget(pos, precision: 4, suffix: " rots"),
              ),
          ],
        ),
      ),
    );
  }
}

class _VelocityWidget extends StatelessWidget {
  // ignore: unused_element_parameter
  const _VelocityWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final appStateRead = context.read<AppState>();
    final vel = context.select((AppState appState) => appState.velocity);

    final theme = Theme.of(context);

    final validStyle = TextStyle(color: theme.colorScheme.onSurface);
    final invalidStyle = TextStyle(
      color: theme.colorScheme.onSurface.withAlpha(127),
      fontStyle: FontStyle.italic,
    );

    return Draggable<ContinousDataSource>(
      data: ContinousDataSource(
        name: "velocity",
        watchCurrentValue: (context) =>
            context.select((AppState state) => state.velocity),
        getValueAtTimestamp: (timestamp) =>
            appStateRead.velocityTimeMap?.getValueAtTime(timestamp),
        getAllValueChanges: () =>
            appStateRead.velocityTimeMap?.getAllValueChanges(),
        stringRepresentation: (rpm) => "${rpm.toStringAsFixed(4)} rpm",
      ),
      feedback: OverflowText("velocity", style: theme.textTheme.bodyMedium),
      dragAnchorStrategy: (draggable, context, position) =>
          pointerDragAnchorStrategy(draggable, context, position),
      hitTestBehavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: OverflowText(
                  "velocity",
                  style: vel == null ? invalidStyle : validStyle,
                ),
              ),
            ),
            if (vel != null)
              Expanded(
                child: NumberDataWidget(vel, precision: 4, suffix: " rpm"),
              ),
          ],
        ),
      ),
    );
  }
}

class _ControlModeWidget extends StatelessWidget {
  // ignore: unused_element_parameter
  const _ControlModeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final appStateRead = context.read<AppState>();
    final cm = context.select((AppState appState) => appState.controlMode);

    final theme = Theme.of(context);

    final validStyle = TextStyle(color: theme.colorScheme.onSurface);
    final invalidStyle = TextStyle(
      color: theme.colorScheme.onSurface.withAlpha(127),
      fontStyle: FontStyle.italic,
    );

    return Draggable<DiscreteDataSource>(
      data: DiscreteDataSource(
        name: "controlMode",
        watchCurrentValue: (context) =>
            context.select((AppState state) => appStateRead.controlModeName),
        getValueAtTimestamp: (timestamp) =>
            appStateRead.controlModeTimeMap?.getValueAtTime(timestamp)?.name,
        getAllValueChanges: () => appStateRead.controlModeTimeMap
            ?.getAllValueChanges()
            .map((entry) => MapEntry(entry.key, entry.value?.toString())),
      ),
      feedback: OverflowText("controlMode", style: theme.textTheme.bodyMedium),
      dragAnchorStrategy: (draggable, context, position) =>
          pointerDragAnchorStrategy(draggable, context, position),
      hitTestBehavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: OverflowText(
                  "controlMode",
                  style: cm == null ? invalidStyle : validStyle,
                ),
              ),
            ),
            if (cm != null) Expanded(child: ControlModeDataWidget(cm)),
          ],
        ),
      ),
    );
  }
}

class _DutyOutWidget extends StatelessWidget {
  // ignore: unused_element_parameter
  const _DutyOutWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final appStateRead = context.read<AppState>();
    final dutyOut = context.select((AppState appState) => appState.dutyOut);

    final theme = Theme.of(context);

    final validStyle = TextStyle(color: theme.colorScheme.onSurface);
    final invalidStyle = TextStyle(
      color: theme.colorScheme.onSurface.withAlpha(127),
      fontStyle: FontStyle.italic,
    );

    return Draggable<ContinousDataSource>(
      data: ContinousDataSource(
        name: "dutyOut",
        watchCurrentValue: (context) =>
            context.select((AppState state) => state.dutyOut),
        getValueAtTimestamp: (timestamp) =>
            appStateRead.dutyOutTimeMap?.getValueAtTime(timestamp),
        getAllValueChanges: () =>
            appStateRead.dutyOutTimeMap?.getAllValueChanges(),
        stringRepresentation: (duty) => duty.toStringAsFixed(3),
      ),
      feedback: OverflowText("dutyOut", style: theme.textTheme.bodyMedium),
      dragAnchorStrategy: (draggable, context, position) =>
          pointerDragAnchorStrategy(draggable, context, position),
      hitTestBehavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: OverflowText(
                  "dutyOut",
                  style: dutyOut == null ? invalidStyle : validStyle,
                ),
              ),
            ),
            if (dutyOut != null)
              Expanded(child: PercentOutDataWidget(dutyOut, 3, dutyOut)),
          ],
        ),
      ),
    );
  }
}

class _VoltageOutWidget extends StatelessWidget {
  // ignore: unused_element_parameter
  const _VoltageOutWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final appStateRead = context.read<AppState>();
    final voltageOut = context.select(
      (AppState appState) => appState.voltageOut,
    );
    final source = context.select(
      (AppState appState) => appState.sourceVoltage,
    );

    final theme = Theme.of(context);

    final validStyle = TextStyle(color: theme.colorScheme.onSurface);
    final invalidStyle = TextStyle(
      color: theme.colorScheme.onSurface.withAlpha(127),
      fontStyle: FontStyle.italic,
    );

    return Draggable<ContinousDataSource>(
      data: ContinousDataSource(
        name: "voltageOut",
        watchCurrentValue: (context) =>
            context.select((AppState state) => state.voltageOut),
        getValueAtTimestamp: (timestamp) =>
            appStateRead.voltageOutTimeMap?.getValueAtTime(timestamp),
        getAllValueChanges: () =>
            appStateRead.voltageOutTimeMap?.getAllValueChanges(),
        stringRepresentation: (volts) => "${volts.toStringAsFixed(3)} V",
      ),
      feedback: OverflowText("voltageOut", style: theme.textTheme.bodyMedium),
      dragAnchorStrategy: (draggable, context, position) =>
          pointerDragAnchorStrategy(draggable, context, position),
      hitTestBehavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: OverflowText(
                  "voltageOut",
                  style: voltageOut == null ? invalidStyle : validStyle,
                ),
              ),
            ),
            if (voltageOut != null && source != null)
              Expanded(
                child: PercentOutDataWidget(
                  voltageOut,
                  3,
                  source == 0
                      ? 0
                      : voltageOut / source, //prevent divide by zero
                  suffix: " V",
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TargetWidget extends StatelessWidget {
  // ignore: unused_element_parameter
  const _TargetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final appStateRead = context.read<AppState>();
    final target = context.select((AppState appState) => appState.target);
    final controlMode = context.select(
      (AppState appState) => appState.controlMode,
    );

    final theme = Theme.of(context);

    late final String closedLoopUnit;
    switch (controlMode) {
      case DeviceControlMode.pidPos:
      case DeviceControlMode.trapPos:
        {
          closedLoopUnit = " rots";
        }
      case DeviceControlMode.pidVel:
        {
          closedLoopUnit = " rpm";
        }
      default:
        {
          closedLoopUnit = "";
        }
    }

    final validStyle = TextStyle(color: theme.colorScheme.onSurface);
    final invalidStyle = TextStyle(
      color: theme.colorScheme.onSurface.withAlpha(127),
      fontStyle: FontStyle.italic,
    );

    return Draggable<ContinousDataSource>(
      data: ContinousDataSource(
        name: "target",
        watchCurrentValue: (context) =>
            context.select((AppState state) => state.target),
        getValueAtTimestamp: (timestamp) =>
            appStateRead.targetTimeMap?.getValueAtTime(timestamp),
        getAllValueChanges: () =>
            appStateRead.targetTimeMap?.getAllValueChanges(),
        stringRepresentation: (val) =>
            "${val.toStringAsFixed(4)}$closedLoopUnit",
      ),
      feedback: OverflowText("target", style: theme.textTheme.bodyMedium),
      dragAnchorStrategy: (draggable, context, position) =>
          pointerDragAnchorStrategy(draggable, context, position),
      hitTestBehavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: OverflowText(
                  "target",
                  style: target == null ? invalidStyle : validStyle,
                ),
              ),
            ),
            if (target != null)
              Expanded(
                child: NumberDataWidget(
                  target,
                  precision: 4,
                  suffix: closedLoopUnit,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  // ignore: unused_element_parameter
  const _ErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final appStateRead = context.read<AppState>();
    final error = context.select((AppState appState) => appState.error);
    final controlMode = context.select(
      (AppState appState) => appState.controlMode,
    );

    final theme = Theme.of(context);

    late final String closedLoopUnit;
    switch (controlMode) {
      case DeviceControlMode.pidPos:
      case DeviceControlMode.trapPos:
        {
          closedLoopUnit = " rots";
        }
      case DeviceControlMode.pidVel:
        {
          closedLoopUnit = " rpm";
        }
      default:
        {
          closedLoopUnit = "";
        }
    }

    final validStyle = TextStyle(color: theme.colorScheme.onSurface);
    final invalidStyle = TextStyle(
      color: theme.colorScheme.onSurface.withAlpha(127),
      fontStyle: FontStyle.italic,
    );

    return Draggable<ContinousDataSource>(
      data: ContinousDataSource(
        name: "error",
        watchCurrentValue: (context) =>
            context.select((AppState state) => state.error),
        getValueAtTimestamp: (timestamp) =>
            appStateRead.errorTimeMap?.getValueAtTime(timestamp),
        getAllValueChanges: () =>
            appStateRead.errorTimeMap?.getAllValueChanges(),
        stringRepresentation: (val) =>
            "${val.toStringAsFixed(4)}$closedLoopUnit",
      ),
      feedback: OverflowText("error", style: theme.textTheme.bodyMedium),
      dragAnchorStrategy: (draggable, context, position) =>
          pointerDragAnchorStrategy(draggable, context, position),
      hitTestBehavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: OverflowText(
                  "error",
                  style: error == null ? invalidStyle : validStyle,
                ),
              ),
            ),
            if (error != null)
              Expanded(
                child: NumberDataWidget(
                  error,
                  precision: 4,
                  suffix: closedLoopUnit,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PFactorWidget extends StatelessWidget {
  // ignore: unused_element_parameter
  const _PFactorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final appStateRead = context.read<AppState>();
    final pFactor = context.select((AppState appState) => appState.pFactor);

    final theme = Theme.of(context);

    final validStyle = TextStyle(color: theme.colorScheme.onSurface);
    final invalidStyle = TextStyle(
      color: theme.colorScheme.onSurface.withAlpha(127),
      fontStyle: FontStyle.italic,
    );

    return Draggable<ContinousDataSource>(
      data: ContinousDataSource(
        name: "pFactor",
        watchCurrentValue: (context) =>
            context.select((AppState state) => state.pFactor),
        getValueAtTimestamp: (timestamp) =>
            appStateRead.pFactorTimeMap?.getValueAtTime(timestamp),
        getAllValueChanges: () =>
            appStateRead.pFactorTimeMap?.getAllValueChanges(),
        stringRepresentation: (val) => val.toStringAsFixed(3),
      ),
      feedback: OverflowText("pFactor", style: theme.textTheme.bodyMedium),
      dragAnchorStrategy: (draggable, context, position) =>
          pointerDragAnchorStrategy(draggable, context, position),
      hitTestBehavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: OverflowText(
                  "pFactor",
                  style: pFactor == null ? invalidStyle : validStyle,
                ),
              ),
            ),
            if (pFactor != null)
              Expanded(child: PercentOutDataWidget(pFactor, 3, pFactor)),
          ],
        ),
      ),
    );
  }
}

class _IFactorWidget extends StatelessWidget {
  // ignore: unused_element_parameter
  const _IFactorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final appStateRead = context.read<AppState>();
    final iFactor = context.select((AppState appState) => appState.iFactor);

    final theme = Theme.of(context);

    final validStyle = TextStyle(color: theme.colorScheme.onSurface);
    final invalidStyle = TextStyle(
      color: theme.colorScheme.onSurface.withAlpha(127),
      fontStyle: FontStyle.italic,
    );

    return Draggable<ContinousDataSource>(
      data: ContinousDataSource(
        name: "iFactor",
        watchCurrentValue: (context) =>
            context.select((AppState state) => state.iFactor),
        getValueAtTimestamp: (timestamp) =>
            appStateRead.iFactorTimeMap?.getValueAtTime(timestamp),
        getAllValueChanges: () =>
            appStateRead.iFactorTimeMap?.getAllValueChanges(),
        stringRepresentation: (val) => val.toStringAsFixed(3),
      ),
      feedback: OverflowText("iFactor", style: theme.textTheme.bodyMedium),
      dragAnchorStrategy: (draggable, context, position) =>
          pointerDragAnchorStrategy(draggable, context, position),
      hitTestBehavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: OverflowText(
                  "iFactor",
                  style: iFactor == null ? invalidStyle : validStyle,
                ),
              ),
            ),
            if (iFactor != null)
              Expanded(child: PercentOutDataWidget(iFactor, 3, iFactor)),
          ],
        ),
      ),
    );
  }
}

class _DFactorWidget extends StatelessWidget {
  // ignore: unused_element_parameter
  const _DFactorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final appStateRead = context.read<AppState>();
    final dFactor = context.select((AppState appState) => appState.dFactor);

    final theme = Theme.of(context);

    final validStyle = TextStyle(color: theme.colorScheme.onSurface);
    final invalidStyle = TextStyle(
      color: theme.colorScheme.onSurface.withAlpha(127),
      fontStyle: FontStyle.italic,
    );

    return Draggable<ContinousDataSource>(
      data: ContinousDataSource(
        name: "dFactor",
        watchCurrentValue: (context) =>
            context.select((AppState state) => state.dFactor),
        getValueAtTimestamp: (timestamp) =>
            appStateRead.dFactorTimeMap?.getValueAtTime(timestamp),
        getAllValueChanges: () =>
            appStateRead.dFactorTimeMap?.getAllValueChanges(),
        stringRepresentation: (val) => val.toStringAsFixed(3),
      ),
      feedback: OverflowText("dFactor", style: theme.textTheme.bodyMedium),
      dragAnchorStrategy: (draggable, context, position) =>
          pointerDragAnchorStrategy(draggable, context, position),
      hitTestBehavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: OverflowText(
                  "dFactor",
                  style: dFactor == null ? invalidStyle : validStyle,
                ),
              ),
            ),
            if (dFactor != null)
              Expanded(
                child: PercentOutDataWidget(dFactor, 3, dFactor.clamp(-1, 1)),
              ),
          ],
        ),
      ),
    );
  }
}

class _SFactorWidget extends StatelessWidget {
  // ignore: unused_element_parameter
  const _SFactorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final appStateRead = context.read<AppState>();
    final sFactor = context.select((AppState appState) => appState.sFactor);

    final theme = Theme.of(context);

    final validStyle = TextStyle(color: theme.colorScheme.onSurface);
    final invalidStyle = TextStyle(
      color: theme.colorScheme.onSurface.withAlpha(127),
      fontStyle: FontStyle.italic,
    );

    return Draggable<ContinousDataSource>(
      data: ContinousDataSource(
        name: "sFactor",
        watchCurrentValue: (context) =>
            context.select((AppState state) => state.sFactor),
        getValueAtTimestamp: (timestamp) =>
            appStateRead.sFactorTimeMap?.getValueAtTime(timestamp),
        getAllValueChanges: () =>
            appStateRead.sFactorTimeMap?.getAllValueChanges(),
        stringRepresentation: (val) => val.toStringAsFixed(3),
      ),
      feedback: OverflowText("sFactor", style: theme.textTheme.bodyMedium),
      dragAnchorStrategy: (draggable, context, position) =>
          pointerDragAnchorStrategy(draggable, context, position),
      hitTestBehavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: OverflowText(
                  "sFactor",
                  style: sFactor == null ? invalidStyle : validStyle,
                ),
              ),
            ),
            if (sFactor != null)
              Expanded(
                child: PercentOutDataWidget(sFactor, 3, sFactor.clamp(-1, 1)),
              ),
          ],
        ),
      ),
    );
  }
}

class _SlotWidget extends StatelessWidget {
  // ignore: unused_element_parameter
  const _SlotWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final appStateRead = context.read<AppState>();
    final slot = context.select((AppState appState) => appState.slot);

    final theme = Theme.of(context);

    final validStyle = TextStyle(color: theme.colorScheme.onSurface);
    final invalidStyle = TextStyle(
      color: theme.colorScheme.onSurface.withAlpha(127),
      fontStyle: FontStyle.italic,
    );

    return Draggable<DiscreteDataSource>(
      data: DiscreteDataSource(
        name: "slot",
        watchCurrentValue: (context) =>
            context.select((AppState state) => state.slot)?.toString(),
        getValueAtTimestamp: (timestamp) =>
            appStateRead.slotTimeMap?.getValueAtTime(timestamp)?.toString(),
        getAllValueChanges: () => appStateRead.slotTimeMap
            ?.getAllValueChanges()
            .map((entry) => MapEntry(entry.key, entry.value?.toString())),
      ),
      feedback: OverflowText("slot", style: theme.textTheme.bodyMedium),
      dragAnchorStrategy: (draggable, context, position) =>
          pointerDragAnchorStrategy(draggable, context, position),
      hitTestBehavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: OverflowText(
                  "slot",
                  style: slot == null ? invalidStyle : validStyle,
                ),
              ),
            ),
            if (slot != null) Expanded(child: NumberDataWidget(slot)),
          ],
        ),
      ),
    );
  }
}

class _SubErrorWidget extends StatelessWidget {
  // ignore: unused_element_parameter
  const _SubErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final appStateRead = context.read<AppState>();
    final subError = context.select((AppState appState) => appState.subError);
    final controlMode = context.select(
      (AppState appState) => appState.controlMode,
    );

    final theme = Theme.of(context);

    late final String closedLoopUnit;
    switch (controlMode) {
      case DeviceControlMode.pidPos:
      case DeviceControlMode.trapPos:
        {
          closedLoopUnit = " rots";
        }
      case DeviceControlMode.pidVel:
        {
          closedLoopUnit = " rpm";
        }
      default:
        {
          closedLoopUnit = "";
        }
    }

    final validStyle = TextStyle(color: theme.colorScheme.onSurface);
    final invalidStyle = TextStyle(
      color: theme.colorScheme.onSurface.withAlpha(127),
      fontStyle: FontStyle.italic,
    );

    return Draggable<ContinousDataSource>(
      data: ContinousDataSource(
        name: "subError",
        watchCurrentValue: (context) =>
            context.select((AppState state) => state.subError),
        getValueAtTimestamp: (timestamp) =>
            appStateRead.subErrorTimeMap?.getValueAtTime(timestamp),
        getAllValueChanges: () =>
            appStateRead.subErrorTimeMap?.getAllValueChanges(),
        stringRepresentation: (val) =>
            "${val.toStringAsFixed(4)}$closedLoopUnit",
      ),
      feedback: OverflowText("subError", style: theme.textTheme.bodyMedium),
      dragAnchorStrategy: (draggable, context, position) =>
          pointerDragAnchorStrategy(draggable, context, position),
      hitTestBehavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: OverflowText(
                  "subError",
                  style: subError == null ? invalidStyle : validStyle,
                ),
              ),
            ),
            if (subError != null)
              Expanded(
                child: NumberDataWidget(
                  subError,
                  precision: 4,
                  suffix: closedLoopUnit,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SecsToCompletionWidget extends StatelessWidget {
  // ignore: unused_element_parameter
  const _SecsToCompletionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final appStateRead = context.read<AppState>();
    final secs = context.select(
      (AppState appState) => appState.secsToCompletion,
    );

    final theme = Theme.of(context);

    final validStyle = TextStyle(color: theme.colorScheme.onSurface);
    final invalidStyle = TextStyle(
      color: theme.colorScheme.onSurface.withAlpha(127),
      fontStyle: FontStyle.italic,
    );

    return Draggable<ContinousDataSource>(
      data: ContinousDataSource(
        name: "secsToCompletion",
        watchCurrentValue: (context) =>
            context.select((AppState state) => state.secsToCompletion),
        getValueAtTimestamp: (timestamp) =>
            appStateRead.secsToCompletionTimeMap?.getValueAtTime(timestamp),
        getAllValueChanges: () =>
            appStateRead.secsToCompletionTimeMap?.getAllValueChanges(),
        stringRepresentation: (val) => "${val.toStringAsFixed(3)} s",
      ),
      feedback: OverflowText(
        "secsToCompletion",
        style: theme.textTheme.bodyMedium,
      ),
      dragAnchorStrategy: (draggable, context, position) =>
          pointerDragAnchorStrategy(draggable, context, position),
      hitTestBehavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: OverflowText(
                  "secsToCompletion",
                  style: secs == null ? invalidStyle : validStyle,
                ),
              ),
            ),
            if (secs != null)
              Expanded(
                child: NumberDataWidget(secs, precision: 3, suffix: " s"),
              ),
          ],
        ),
      ),
    );
  }
}

class _PhaseNameWidget extends StatelessWidget {
  // ignore: unused_element_parameter
  const _PhaseNameWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final appStateRead = context.read<AppState>();
    final phase = context.select((AppState appState) => appState.phaseName);

    final theme = Theme.of(context);

    final validStyle = TextStyle(color: theme.colorScheme.onSurface);
    final invalidStyle = TextStyle(
      color: theme.colorScheme.onSurface.withAlpha(127),
      fontStyle: FontStyle.italic,
    );

    return Draggable<DiscreteDataSource>(
      data: DiscreteDataSource(
        name: "phaseName",
        watchCurrentValue: (context) =>
            context.select((AppState state) => state.phaseName),
        getValueAtTimestamp: (timestamp) =>
            appStateRead.phaseNameTimeMap?.getValueAtTime(timestamp),
        getAllValueChanges: () =>
            appStateRead.phaseNameTimeMap?.getAllValueChanges(),
      ),
      feedback: OverflowText("phaseName", style: theme.textTheme.bodyMedium),
      dragAnchorStrategy: (draggable, context, position) =>
          pointerDragAnchorStrategy(draggable, context, position),
      hitTestBehavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: OverflowText(
                  "phaseName",
                  style: phase == null ? invalidStyle : validStyle,
                ),
              ),
            ),
            if (phase != null) Expanded(child: TextDataWidget(phase)),
          ],
        ),
      ),
    );
  }
}
