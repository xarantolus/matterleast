import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/launch_gate.dart';
import 'package:matterleast/app/theme.dart';

class MatterleastApp extends StatelessWidget {
  const MatterleastApp({super.key});

  static final lightTheme = buildTheme(Brightness.light);
  static final darkTheme = buildTheme(Brightness.dark);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Matterleast',
      theme: lightTheme,
      darkTheme: darkTheme,
      debugShowCheckedModeBanner: false,
      home: const LaunchGate(),
    );
  }
}
