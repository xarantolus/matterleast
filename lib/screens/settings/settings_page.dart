import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/screens/settings/advanced_settings_page.dart';
import 'package:matterleast/screens/settings/display_settings_page.dart';
import 'package:matterleast/screens/settings/notification_settings_page.dart';
import 'package:matterleast/screens/settings/settings_providers.dart';
import 'package:matterleast/screens/settings/settings_widgets.dart';
import 'package:matterleast/screens/status/status_page.dart';
import 'package:url_launcher/url_launcher.dart';

final _sourceCode = Uri.parse('https://github.com/xarantolus/matterleast');

/// Settings: the account's notifications and display on the current
/// server, the app's storage and status, and about.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final server = ref.watch(settingsServerProvider);
    final version = ref.watch(appVersionProvider).value;
    void push(Widget page) =>
        Navigator.of(context)
            .push(MaterialPageRoute<void>(builder: (_) => page));
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
        children: [
          if (server != null)
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Notifications'),
              subtitle: Text('When and how ${server.displayName} tells you'),
              onTap: () => push(NotificationSettingsPage(server: server)),
            ),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Display'),
            subtitle: const Text('Clock, colours, threads and names'),
            onTap: () => push(DisplaySettingsPage(server: server)),
          ),
          ListTile(
            leading: const Icon(Icons.storage_outlined),
            title: const Text('Storage'),
            subtitle: const Text('Downloaded images and files'),
            onTap: () => push(const AdvancedSettingsPage()),
          ),
          ListTile(
            leading: const Icon(Icons.monitor_heart_outlined),
            title: const Text('Status'),
            subtitle: const Text('Connections, refreshes and saved data'),
            onTap: () => push(const StatusPage()),
          ),
          const SettingsHeader('About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Version'),
            subtitle: Text(version ?? ''),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Licences'),
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'Matterleast',
              applicationVersion: version,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Source code'),
            subtitle: Text(_sourceCode.host + _sourceCode.path),
            onTap: () =>
                launchUrl(_sourceCode, mode: LaunchMode.externalApplication),
          ),
        ],
      ),
    );
  }
}
