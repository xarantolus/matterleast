import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/image_providers.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/app/theme_providers.dart';
import 'package:matterleast/data/app_db/settings.dart';
import 'package:matterleast/domain/message_text_size.dart';
import 'package:matterleast/domain/notify_props.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/domain/server_theme.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/screens/settings/settings_providers.dart';
import 'package:matterleast/screens/settings/settings_widgets.dart';
import 'package:matterleast/ui/progress_slot.dart';

enum _Clock {
  system(null, 'Like the phone'),
  twelve(false, '12-hour (1:30 PM)'),
  twentyFour(true, '24-hour (13:30)');

  const _Clock(this.use24, this.label);
  final bool? use24;
  final String label;

  static _Clock of(bool? use24) => values.firstWhere((c) => c.use24 == use24);
}

String _textSizeLabel(MessageTextSize size) => switch (size) {
  MessageTextSize.small => 'Small',
  MessageTextSize.normal => 'Default',
  MessageTextSize.large => 'Large',
  MessageTextSize.larger => 'Larger',
};

String _themeLabel(ThemeSource source) => switch (source) {
  ThemeSource.brand => 'Matterleast colours',
  ThemeSource.server => 'My theme on the server',
  ThemeSource.wallpaper => 'Wallpaper colours (Material You)',
};

/// How messages and people look: the app-wide clock and images, and the
/// account's theme, threads and names on one server.
class DisplaySettingsPage extends ConsumerStatefulWidget {
  const DisplaySettingsPage({required this.server, super.key});

  final ServerEntry? server;

  @override
  ConsumerState<DisplaySettingsPage> createState() =>
      _DisplaySettingsPageState();
}

class _DisplaySettingsPageState extends ConsumerState<DisplaySettingsPage> {
  var _saving = false;

  Future<void> _save(
    ServerEntry server,
    Future<void> Function(String url) save,
  ) async {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      await save(server.url);
    } on Object catch (e) {
      showProblem(
        messenger,
        "Couldn't save. ${requestProblemText(e, server.address)}",
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.read(settingsStoreProvider);
    final clock = _Clock.of(ref.watch(use24HourClockProvider).value);
    final images = ref.watch(imagesOnMobileDataProvider).value ?? true;
    final textSize =
        ref.watch(messageTextSizeProvider).value ?? MessageTextSize.normal;
    final wrapCode = ref.watch(wrapCodeProvider).value ?? false;
    final server = widget.server;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Display'),
        bottom: ProgressSlot(active: _saving),
      ),
      body: ListView(
        padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
        children: [
          ListTile(
            title: const Text('Clock'),
            subtitle: Text(clock.label),
            onTap: () async {
              final picked = await pickOne(
                context,
                title: 'Clock',
                options: _Clock.values,
                current: clock,
                label: (c) => c.label,
              );
              if (picked != null) {
                await store.write(Settings.use24HourClock, picked.use24);
              }
            },
          ),
          ListTile(
            title: const Text('Message text size'),
            subtitle: Text(
              '${_textSizeLabel(textSize)}, on top of the phone\'s font size',
            ),
            onTap: () async {
              final picked = await pickOne(
                context,
                title: 'Message text size',
                options: MessageTextSize.values,
                current: textSize,
                label: _textSizeLabel,
              );
              if (picked != null) {
                await store.write(Settings.messageTextSize, picked);
              }
            },
          ),
          SwitchListTile(
            title: const Text('Wrap lines in code'),
            subtitle: const Text(
              'Otherwise long lines scroll sideways. Each code block can '
              'switch on its own.',
            ),
            value: wrapCode,
            onChanged: (on) => store.write(Settings.wrapCode, on),
          ),
          SwitchListTile(
            title: const Text('Load images on mobile data'),
            subtitle: const Text('Otherwise tap an image to load it'),
            value: images,
            onChanged: (on) => store.write(Settings.imagesOnMobileData, on),
          ),
          if (server != null) ..._serverTiles(context, server),
        ],
      ),
    );
  }

  List<Widget> _serverTiles(BuildContext context, ServerEntry server) {
    final url = server.url;
    final theme = ref.watch(themeModeProvider(url)).value ?? ThemeSource.brand;
    final noWallpaper =
        theme == ThemeSource.wallpaper &&
        ref.watch(wallpaperPaletteProvider).value == null;
    final prefs = ref.watch(displayPrefsProvider(url)).value;
    return [
      SettingsHeader('Saved on the server · ${server.displayName}'),
      ListTile(
        title: const Text('Colours'),
        subtitle: Text(
          noWallpaper
              ? '${_themeLabel(theme)}. This phone has none, so the app uses '
                    'Matterleast colours.'
              : _themeLabel(theme),
        ),
        onTap: () async {
          final picked = await pickOne(
            context,
            title: 'Colours',
            options: ThemeSource.values,
            current: theme,
            label: _themeLabel,
          );
          if (picked != null) {
            await ref.read(appDatabaseProvider).setThemeMode(url, picked);
          }
        },
      ),
      if (prefs != null) ...[
        SwitchListTile(
          title: const Text('Collapsed reply threads'),
          subtitle: Text(
            prefs.threadsChangeable
                ? 'Replies stay in their thread instead of the channel'
                : 'Set by the server',
          ),
          value: prefs.threadsOn,
          onChanged: prefs.threadsChangeable && !_saving
              ? (on) => _save(
                  server,
                  (url) async =>
                      (await ref.read(settingsActionsProvider(url).future))
                          .setCollapsedThreads(on),
                )
              : null,
        ),
        ListTile(
          enabled: !prefs.nameFormatLocked && !_saving,
          title: const Text('Show people by'),
          subtitle: Text(
            prefs.nameFormatLocked
                ? '${prefs.nameFormat.label}, set by the server'
                : prefs.nameFormat.label,
          ),
          onTap: () async {
            final picked = await pickOne(
              context,
              title: 'Show people by',
              options: NameFormat.values,
              current: prefs.nameFormat,
              label: (f) => f.label,
            );
            if (picked == null) return;
            await _save(
              server,
              (url) async =>
                  (await ref.read(settingsActionsProvider(url).future))
                      .setNameFormat(picked),
            );
          },
        ),
      ],
    ];
  }
}
