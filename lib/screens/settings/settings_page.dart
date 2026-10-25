import 'package:material_ui/material_ui.dart';
import 'package:matterleast/screens/status/status_page.dart';

/// Settings. Notification and display settings arrive later; the status
/// page is here already.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Settings')),
    body: ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.monitor_heart_outlined),
          title: const Text('Status'),
          subtitle: const Text('Connections, refreshes and saved data'),
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => const StatusPage())),
        ),
      ],
    ),
  );
}
