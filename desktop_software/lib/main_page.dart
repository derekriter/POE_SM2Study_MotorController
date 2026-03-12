import 'package:desktop_software/widgets/data_tab.dart';
import 'package:desktop_software/widgets/footer.dart';
import 'package:desktop_software/widgets/horizontal_tab.dart';
import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
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
                      TabBar(
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
                          children: [DataTab(), Text("b"), Text("c")],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              VerticalDivider(indent: 0, endIndent: 0, radius: null, width: 4),
              Expanded(flex: 2, child: Placeholder()),
            ],
          ),
        ),
        Footer(),
      ],
    );
  }
}
