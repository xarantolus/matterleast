import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/app_db/settings.dart';
import 'package:matterleast/notifications/stay_connected.dart';
import 'package:matterleast/screens/settings/settings_widgets.dart';

/// Notifications on this phone, for every server: whether Android lets the
/// app notify, and the opt-in stay-connected service.
class PhoneNotifications extends ConsumerStatefulWidget {
  const PhoneNotifications({super.key});

  @override
  ConsumerState<PhoneNotifications> createState() => _PhoneNotificationsState();
}

class _PhoneNotificationsState extends ConsumerState<PhoneNotifications> {
  bool? _permitted;
  bool? _stayConnected;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // The user may change either in the system settings and come back.
    _lifecycle = AppLifecycleListener(onResume: () => unawaited(_load()));
    unawaited(_load());
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final permitted = await ref.read(notifierProvider).permitted();
    final stay = await StayConnected.enabled();
    if (!mounted) return;
    setState(() {
      _permitted = permitted;
      _stayConnected = stay;
    });
  }

  Future<void> _allow() async {
    final notifier = ref.read(notifierProvider);
    // Android stops asking after the second refusal; its settings still work.
    if (!await notifier.requestPermission()) await notifier.openSettings();
    await _load();
  }

  Future<void> _setStayConnected(bool on) async {
    setState(() => _stayConnected = on);
    if (on) {
      if (!await ref.read(notifierProvider).permitted()) await _allow();
      await StayConnected.enable();
    } else {
      await StayConnected.disable();
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final permitted = _permitted;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SettingsHeader('On this phone'),
        if (permitted == false)
          ListTile(
            leading: const Icon(Icons.notifications_off_outlined),
            title: const Text('Notifications are off'),
            subtitle: const Text(
              'Android blocks them for Matterleast. Allow them to hear about '
              'new messages while the app is closed.',
            ),
            trailing: FilledButton.tonal(
              onPressed: _allow,
              child: const Text('Allow'),
            ),
          )
        else if (permitted == true)
          ListTile(
            leading: const Icon(Icons.tune),
            title: const Text('Sound and importance'),
            subtitle: const Text('Per kind of message, in the system settings'),
            onTap: () => unawaited(ref.read(notifierProvider).openSettings()),
          ),
        SwitchListTile(
          secondary: const Icon(Icons.sync),
          title: const Text('Stay connected'),
          subtitle: const Text(
            'Notifications right away instead of about every 15 minutes. '
            'Keeps a connection open, with a permanent notification, and '
            'uses more battery.',
          ),
          value: _stayConnected ?? false,
          onChanged: _stayConnected == null ? null : _setStayConnected,
        ),
      ],
    );
  }
}

/// Notifications on this computer: they come while the app runs, also
/// with its window closed into the tray.
class ComputerNotifications extends ConsumerWidget {
  const ComputerNotifications({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(settingsStoreProvider);
    final closeToTray = ref.watch(closeToTrayProvider).value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SettingsHeader('On this computer'),
        SwitchListTile(
          secondary: const Icon(Icons.move_to_inbox_outlined),
          title: const Text('Close to tray'),
          subtitle: const Text(
            'Closing the window keeps Matterleast running in the tray, so '
            'notifications keep coming. Otherwise closing quits.',
          ),
          value: closeToTray ?? Settings.closeToTray.defaultValue,
          onChanged: closeToTray == null
              ? null
              : (on) => store.write(Settings.closeToTray, on),
        ),
      ],
    );
  }
}
