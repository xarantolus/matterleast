import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/ui/focus_region.dart';
import 'package:matterleast/ui/tokens.dart';

/// What the app's own keyboard shortcuts ask for; the screen that can do
/// it provides the action.
sealed class AppIntent extends Intent {
  const AppIntent();
}

class OpenSwitcherIntent extends AppIntent {
  const OpenSwitcherIntent();
}

/// The channel above or below the open one in the list, or the nearest
/// unread one with [unreadOnly].
class ChannelStepIntent extends AppIntent {
  const ChannelStepIntent({required this.forward, this.unreadOnly = false});

  final bool forward;
  final bool unreadOnly;
}

class OpenAccountIntent extends AppIntent {
  const OpenAccountIntent();
}

class ShowShortcutsIntent extends AppIntent {
  const ShowShortcutsIntent();
}

/// Focus into the next (or previous) region of the window: rail, channel
/// list, conversation, composer.
class FocusRegionIntent extends AppIntent {
  const FocusRegionIntent({required this.forward});

  final bool forward;
}

/// Shift+Up in an empty composer: the reply to the newest message.
class ReplyToNewestIntent extends AppIntent {
  const ReplyToNewestIntent();
}

/// Searches the messages of the open conversation.
class SearchChannelIntent extends AppIntent {
  const SearchChannelIntent();
}

/// An action that runs [onInvoke] while [enabled] says so; a key it
/// doesn't take goes on to the field.
class EnabledAction<T extends Intent> extends Action<T> {
  EnabledAction({required this.enabled, required this.onInvoke});

  final bool Function() enabled;
  final VoidCallback onInvoke;

  @override
  bool isEnabled(T intent) => enabled();

  @override
  Object? invoke(T intent) {
    onInvoke();
    return null;
  }
}

@immutable
class AppShortcut {
  const AppShortcut(this.description, this.keys, this.intent);

  final String description;
  final SingleActivator keys;
  final Intent intent;
}

/// Every desktop shortcut, as Mattermost's web app has them where it has
/// them. None of them is one a text field needs (Alt+Up and Alt+Down jump
/// to the start or end of a field elsewhere; Ctrl+Home and Ctrl+End still
/// do).
const appShortcuts = <AppShortcut>[
  AppShortcut(
    'Find a channel or person',
    SingleActivator(LogicalKeyboardKey.keyK, control: true),
    OpenSwitcherIntent(),
  ),
  AppShortcut(
    'Previous channel',
    SingleActivator(LogicalKeyboardKey.arrowUp, alt: true),
    ChannelStepIntent(forward: false),
  ),
  AppShortcut(
    'Next channel',
    SingleActivator(LogicalKeyboardKey.arrowDown, alt: true),
    ChannelStepIntent(forward: true),
  ),
  AppShortcut(
    'Previous unread channel',
    SingleActivator(LogicalKeyboardKey.arrowUp, alt: true, shift: true),
    ChannelStepIntent(forward: false, unreadOnly: true),
  ),
  AppShortcut(
    'Next unread channel',
    SingleActivator(LogicalKeyboardKey.arrowDown, alt: true, shift: true),
    ChannelStepIntent(forward: true, unreadOnly: true),
  ),
  AppShortcut(
    'Search this conversation',
    SingleActivator(LogicalKeyboardKey.keyF, control: true),
    SearchChannelIntent(),
  ),
  AppShortcut(
    'Reply to the newest message',
    SingleActivator(LogicalKeyboardKey.arrowUp, shift: true),
    ReplyToNewestIntent(),
  ),
  AppShortcut(
    'Profile and settings',
    SingleActivator(LogicalKeyboardKey.keyA, control: true, shift: true),
    OpenAccountIntent(),
  ),
  AppShortcut(
    'Next part of the window',
    SingleActivator(LogicalKeyboardKey.f6),
    FocusRegionIntent(forward: true),
  ),
  AppShortcut(
    'Previous part of the window',
    SingleActivator(LogicalKeyboardKey.f6, shift: true),
    FocusRegionIntent(forward: false),
  ),
  AppShortcut(
    'Close the popup, thread or page',
    SingleActivator(LogicalKeyboardKey.escape),
    DismissIntent(),
  ),
  AppShortcut(
    'Keyboard shortcuts',
    SingleActivator(LogicalKeyboardKey.slash, control: true),
    ShowShortcutsIntent(),
  ),
];

final _keyNames = {
  LogicalKeyboardKey.arrowUp: 'Up',
  LogicalKeyboardKey.arrowDown: 'Down',
  LogicalKeyboardKey.escape: 'Esc',
  LogicalKeyboardKey.slash: '/',
};

/// Pure: [keys] as people write them, such as "Ctrl+Shift+A".
String keysLabel(SingleActivator keys) => [
  if (keys.control) 'Ctrl',
  if (keys.alt) 'Alt',
  if (keys.shift) 'Shift',
  if (keys.meta) 'Meta',
  _keyNames[keys.trigger] ?? keys.trigger.keyLabel,
].join('+');

/// The shortcuts of [appShortcuts] over the whole app, on desktop.
class AppShortcuts extends StatefulWidget {
  const AppShortcuts({required this.child, super.key});

  final Widget child;

  @override
  State<AppShortcuts> createState() => _AppShortcutsState();
}

class _AppShortcutsState extends State<AppShortcuts> {
  final _manager = _ShortcutManager({
    for (final s in appShortcuts) s.keys: s.intent,
  });
  final _showList = _ShowShortcuts();

  @override
  void dispose() {
    _manager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isDesktop) return widget.child;
    return Shortcuts.manager(
      manager: _manager,
      child: Actions(
        actions: {
          ShowShortcutsIntent: _showList,
          FocusRegionIntent: CallbackAction<FocusRegionIntent>(
            onInvoke: (intent) => FocusRegion.move(forward: intent.forward),
          ),
        },
        child: widget.child,
      ),
    );
  }
}

/// When nothing on the page on top has the focus, as after a page above
/// it closed, the keys still reach that page's actions: the first widget on
/// it that provides one takes the key.
class _ShortcutManager extends ShortcutManager {
  _ShortcutManager(Map<ShortcutActivator, Intent> shortcuts)
    : super(shortcuts: shortcuts);

  @override
  KeyEventResult handleKeypress(BuildContext context, KeyEvent event) {
    final result = super.handleKeypress(context, event);
    final scope = FocusManager.instance.primaryFocus;
    if (result != KeyEventResult.ignored || scope is! FocusScopeNode) {
      return result;
    }
    final intent = shortcuts.entries
        .where((e) => e.key.accepts(event, HardwareKeyboard.instance))
        .firstOrNull
        ?.value;
    if (intent is! AppIntent) return result;
    for (final node in scope.descendants) {
      final at = node.context;
      if (at == null || !(ModalRoute.of(at)?.isCurrent ?? false)) continue;
      final action = Actions.maybeFind<AppIntent>(at, intent: intent);
      if (action == null) continue;
      final (enabled, _) = Actions.of(at)
          .invokeActionIfEnabled(action, intent, at);
      if (enabled) return KeyEventResult.handled;
    }
    return result;
  }
}

class _ShowShortcuts extends ContextAction<ShowShortcutsIntent> {
  var _open = false;

  @override
  Future<void> invoke(
    ShowShortcutsIntent intent, [
    BuildContext? context,
  ]) async {
    if (context == null || _open) return;
    _open = true;
    try {
      await showShortcutList(context);
    } finally {
      _open = false;
    }
  }
}

/// Every shortcut of [appShortcuts] with its keys.
Future<void> showShortcutList(BuildContext context) => showDialog<void>(
  context: context,
  builder: (dialog) => AlertDialog(
    title: const Text('Keyboard shortcuts'),
    content: SizedBox(
      width: 420,
      child: ListView(
        shrinkWrap: true,
        children: [
          for (final s in appShortcuts)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
              child: Row(
                children: [
                  Expanded(child: Text(s.description)),
                  const SizedBox(width: Spacing.md),
                  _Keys(keysLabel(s.keys)),
                ],
              ),
            ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(dialog).pop(),
        child: const Text('Close'),
      ),
    ],
  ),
);

class _Keys extends StatelessWidget {
  const _Keys(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(Spacing.xs),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: 2,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge
              ?.copyWith(fontFamily: 'monospace'),
        ),
      ),
    );
  }
}
