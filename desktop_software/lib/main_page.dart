import 'package:desktop_software/widgets/footer.dart';
import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: Placeholder()),
        Footer(),
      ],
    );
  }
}
