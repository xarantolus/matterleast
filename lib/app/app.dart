import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/launch_gate.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/app/theme.dart';

class MatterleastApp extends ConsumerWidget {
  const MatterleastApp({super.key});

  static final lightTheme = buildTheme(Brightness.light);
  static final darkTheme = buildTheme(Brightness.dark);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final use24 = ref.watch(use24HourClockProvider).value;
    return MaterialApp(
      title: 'Matterleast',
      theme: lightTheme,
      darkTheme: darkTheme,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          alwaysUse24HourFormat:
              use24 ?? MediaQuery.alwaysUse24HourFormatOf(context),
        ),
        child: child!,
      ),
      home: const LaunchGate(),
    );
  }
}
