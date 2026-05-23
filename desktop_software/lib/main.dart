import 'package:desktop_software/state/app_state.dart';
import 'package:desktop_software/pages/main_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  windowManager.setTitle("Remote Motor Control (v2.1)");
  windowManager.setMinimumSize(Size(1086, 621));

  runApp(const AppRoot());
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Remote Motor Control (v2.1)",
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Color.fromARGB(255, 34, 118, 115),
            brightness: Brightness.dark,
          ),
        ),
        home: const Scaffold(body: MainPage()),
      ),
    );
  }
}
