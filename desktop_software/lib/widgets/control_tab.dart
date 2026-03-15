import 'package:desktop_software/app_state.dart';
import 'package:desktop_software/widgets/overflow_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ControlTab extends StatelessWidget {
  const ControlTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    if (!appState.isReady) {
      return Center(child: OverflowText("Please connect a device to control"));
    }

    return Placeholder(child: Center(child: OverflowText("control")));
  }
}
