import 'package:desktop_software/components/control_tab.dart';
import 'package:desktop_software/components/data_tab.dart';
import 'package:desktop_software/components/footer.dart';
import 'package:desktop_software/components/graph_region.dart';
import 'package:desktop_software/state/app_state.dart';
import 'package:desktop_software/state/control_tab_state.dart';
import 'package:desktop_software/state/slots_tab_state.dart';
import 'package:desktop_software/widgets/horizontal_tab.dart';
import 'package:desktop_software/components/slots_tab.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appStateRead = context.read<AppState>();

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 1,
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
                              child: ControlTab(),
                            ),
                            ChangeNotifierProvider(
                              create: (_) => SlotsTabState(
                                workingConfigs: appStateRead.slotConfigs,
                              ),
                              child: SlotsTab(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const VerticalDivider(
                indent: 0,
                endIndent: 0,
                radius: null,
                width: 4,
              ),
              const Expanded(flex: 2, child: GraphRegion()),
            ],
          ),
        ),
        const Footer(),
      ],
    );
  }
}
