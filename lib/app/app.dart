import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/keyboard_shortcuts.dart';
import 'package:matterleast/app/launch_gate.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/app/theme.dart';
import 'package:matterleast/app/theme_providers.dart';
import 'package:matterleast/domain/message_text_size.dart';
import 'package:matterleast/screens/root/open_panes.dart';
import 'package:matterleast/ui/message_display.dart';
import 'package:matterleast/ui/window_bar.dart';

class MatterleastApp extends ConsumerWidget {
  const MatterleastApp({super.key});

  static final lightTheme = buildTheme(Brightness.light);
  static final darkTheme = buildTheme(Brightness.dark);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final use24 = ref.watch(use24HourClockProvider).value;
    final textSize = ref.watch(messageTextSizeProvider).value;
    final wrapCode = ref.watch(wrapCodeProvider).value ?? false;
    final themes = ref.watch(appThemesProvider).value;
    return MaterialApp(
      title: 'Matterleast',
      theme: themes?.light ?? lightTheme,
      darkTheme: themes?.dark ?? darkTheme,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => WindowEdges(
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat:
                use24 ?? MediaQuery.alwaysUse24HourFormatOf(context),
          ),
          child: MessageDisplay(
            textScale: (textSize ?? MessageTextSize.normal).scale,
            wrapCode: wrapCode,
            child: AppShortcuts(child: child!),
          ),
        ),
      ),
      navigatorObservers: [ref.watch(conversationRoutesProvider)],
      home: const LaunchGate(),
    );
  }
}
