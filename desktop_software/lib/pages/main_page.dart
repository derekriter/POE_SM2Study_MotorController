import 'package:desktop_software/components/control_tab.dart';
import 'package:desktop_software/components/data_tab.dart';
import 'package:desktop_software/components/footer.dart';
import 'package:desktop_software/components/graph_region.dart';
import 'package:desktop_software/state/app_state.dart';
import 'package:desktop_software/state/control_tab_state.dart';
import 'package:desktop_software/state/graph_state.dart';
import 'package:desktop_software/state/slots_tab_state.dart';
import 'package:desktop_software/widgets/horizontal_tab.dart';
import 'package:desktop_software/components/slots_tab.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resizable_splitter/resizable_splitter.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appStateRead = context.read<AppState>();

    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          child: ResizableSplitter(
            axis: Axis.horizontal,
            initialRatio: 0.3,
            dividerColor: theme.colorScheme.surfaceContainerHigh,
            dividerHoverColor: theme.colorScheme.surfaceContainerHighest,
            dividerActiveColor: theme.colorScheme.surfaceBright,
            startPanel: Container(
              color: theme.colorScheme.surfaceContainer,
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        HorizontalTab(
                          text: "Data",
                          icon: Icon(Icons.data_array),
                        ),
                        HorizontalTab(
                          text: "Control",
                          icon: Icon(Icons.gamepad),
                        ),
                        HorizontalTab(
                          text: "Slots",
                          icon: Icon(Icons.settings),
                        ),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          const DataTab(),
                          ChangeNotifierProvider(
                            create: (_) => ControlTabState(),
                            child: const ControlTab(),
                          ),
                          ChangeNotifierProvider(
                            create: (_) => SlotsTabState(
                              workingConfigs: appStateRead.slotConfigs,
                            ),
                            child: const SlotsTab(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            endPanel: ChangeNotifierProvider(
              create: (_) => GraphState(),
              child: const GraphRegion(),
            ),
          ),
        ),
        const Footer(),
      ],
    );
  }
}
