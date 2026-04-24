import 'package:desktop_software/state/app_state.dart';
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
    final appStateRead = context.read<AppState>();

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
              children: [
                appStateRead.enabledSrc.asDataEntry(),
                _divider,
                appStateRead.controlModeSrc.asDataEntry(),
                _divider,
                appStateRead.sourceVoltageSrc.asDataEntry(),
                _divider,
                appStateRead.positionSrc.asDataEntry(),
                _divider,
                appStateRead.velocitySrc.asDataEntry(),
                _divider,
                appStateRead.dutyOutSrc.asDataEntry(),
                _divider,
                appStateRead.voltageOutSrc.asDataEntry(),
                _divider,
                appStateRead.targetSrc.asDataEntry(),
                _divider,
                appStateRead.errorSrc.asDataEntry(),
                _divider,
                appStateRead.pFactorSrc.asDataEntry(),
                _divider,
                appStateRead.iFactorSrc.asDataEntry(),
                _divider,
                appStateRead.dFactorSrc.asDataEntry(),
                _divider,
                appStateRead.sFactorSrc.asDataEntry(),
                _divider,
                appStateRead.slotSrc.asDataEntry(),
                _divider,
                appStateRead.subErrorSrc.asDataEntry(),
                _divider,
                appStateRead.secsToCompletionSrc.asDataEntry(),
                _divider,
                appStateRead.phaseNameSrc.asDataEntry(),
                _divider,
              ],
            ),
      ),
    );
  }
}
