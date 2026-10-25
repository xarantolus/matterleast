import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/theme.dart';
import 'package:matterleast/ui/tokens.dart';

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
      home: const _NoServersYet(),
    );
  }
}

/// Placeholder root until the server list exists: the empty state of the app.
class _NoServersYet extends StatelessWidget {
  const _NoServersYet();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Matterleast')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.xl),
          child: Text(
            'Add a server to get started.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
