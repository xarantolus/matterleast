import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/domain/ui_zoom.dart';
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

/// Makes the whole window larger or smaller, or back to 100 %.
class ZoomIntent extends AppIntent {
  const ZoomIntent(this.change);

  final ZoomChange change;
}

/// Shift+Up in an empty composer: the reply to the newest message.
class ReplyToNewestIntent extends AppIntent {
  const ReplyToNewestIntent();
}

/// Recent mentions, on Home.
class OpenMentionsIntent extends AppIntent {
  const OpenMentionsIntent();
}

/// The direct message picker.
class NewMessageIntent extends AppIntent {
  const NewMessageIntent();
}

/// The cursor into the message field of the open conversation.
class FocusComposerIntent extends AppIntent {
  const FocusComposerIntent();
}

enum Format { bold, italic, strike, link }

/// Formats the composer's selection.
class FormatIntent extends AppIntent {
  const FormatIntent(this.format);

  final Format format;
}

/// Replaces the composer's text with an older (or newer) message of the
/// user's own.
class StepHistoryIntent extends AppIntent {
  const StepHistoryIntent({required this.older});

  final bool older;
}

/// Marks the open channel read.
class MarkReadIntent extends AppIntent {
  const MarkReadIntent();
}

/// Closes what is on top: a content view, a thread, a conversation.
class CloseOnTopIntent extends AppIntent {
  const CloseOnTopIntent();
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
  final void Function(T intent) onInvoke;

  @override
  bool isEnabled(T intent) => enabled();

  @override
  Object? invoke(T intent) {
    onInvoke(intent);
    return null;
  }
}

@immutable
class AppShortcut {
  const AppShortcut(
    this.description,
    this.keys,
    this.intent, {
    this.alsoKeys = const [],
  });

  final String description;
  final SingleActivator keys;
  final Intent intent;

  /// Other keys for the same, not listed: keyboard layouts and the numpad.
  final List<SingleActivator> alsoKeys;
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
    'Focus the message field',
    SingleActivator(LogicalKeyboardKey.keyL, control: true, shift: true),
    FocusComposerIntent(),
  ),
  AppShortcut(
    'Recent mentions',
    SingleActivator(LogicalKeyboardKey.keyM, control: true, shift: true),
    OpenMentionsIntent(),
  ),
  AppShortcut(
    'New message',
    SingleActivator(LogicalKeyboardKey.keyK, control: true, shift: true),
    NewMessageIntent(),
  ),
  AppShortcut(
    'Bold',
    SingleActivator(LogicalKeyboardKey.keyB, control: true),
    FormatIntent(Format.bold),
  ),
  AppShortcut(
    'Italic',
    SingleActivator(LogicalKeyboardKey.keyI, control: true),
    FormatIntent(Format.italic),
  ),
  AppShortcut(
    'Strikethrough',
    SingleActivator(LogicalKeyboardKey.keyX, control: true, shift: true),
    FormatIntent(Format.strike),
  ),
  AppShortcut(
    'Link',
    SingleActivator(LogicalKeyboardKey.keyK, control: true, alt: true),
    FormatIntent(Format.link),
  ),
  AppShortcut(
    'Your previous message',
    SingleActivator(LogicalKeyboardKey.arrowUp, control: true),
    StepHistoryIntent(older: true),
  ),
  AppShortcut(
    'Your next message',
    SingleActivator(LogicalKeyboardKey.arrowDown, control: true),
    StepHistoryIntent(older: false),
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
    'Mark as read, or close the popup, thread or page',
    SingleActivator(LogicalKeyboardKey.escape),
    PrioritizedIntents(
      orderedIntents: [MarkReadIntent(), DismissIntent(), CloseOnTopIntent()],
    ),
  ),
  AppShortcut(
    'Zoom in',
    SingleActivator(LogicalKeyboardKey.equal, control: true),
    ZoomIntent(ZoomChange.zoomIn),
    alsoKeys: [
      SingleActivator(LogicalKeyboardKey.equal, control: true, shift: true),
      SingleActivator(LogicalKeyboardKey.add, control: true),
      SingleActivator(LogicalKeyboardKey.add, control: true, shift: true),
      SingleActivator(LogicalKeyboardKey.numpadAdd, control: true),
    ],
  ),
  AppShortcut(
    'Zoom out',
    SingleActivator(LogicalKeyboardKey.minus, control: true),
    ZoomIntent(ZoomChange.zoomOut),
    alsoKeys: [
      SingleActivator(LogicalKeyboardKey.numpadSubtract, control: true),
    ],
  ),
  AppShortcut(
    'Actual size',
    SingleActivator(LogicalKeyboardKey.digit0, control: true),
    ZoomIntent(ZoomChange.reset),
    alsoKeys: [SingleActivator(LogicalKeyboardKey.numpad0, control: true)],
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
  LogicalKeyboardKey.equal: '+',
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
    for (final s in appShortcuts) ...{
      s.keys: s.intent,
      for (final keys in s.alsoKeys) keys: s.intent,
    },
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

/// When the focus is outside what provides an action, as after a page above
/// it closed or in the channel list, the keys still reach actions on the
/// page the focus belongs to: the first widget there that provides one
/// takes the key. Only the page on top counts, and only the window's first
/// page also reaches into the panes beside it; a popout or a page over it
/// keeps its keys to itself.
class _ShortcutManager extends ShortcutManager {
  _ShortcutManager(Map<ShortcutActivator, Intent> shortcuts)
    : super(shortcuts: shortcuts);

  @override
  KeyEventResult handleKeypress(BuildContext context, KeyEvent event) {
    final result = super.handleKeypress(context, event);
    final scope = FocusManager.instance.primaryFocus?.nearestScope;
    final home = scope?.context;
    if (result != KeyEventResult.ignored || scope == null || home == null) {
      return result;
    }
    final homeRoute = ModalRoute.of(home);
    if (homeRoute == null || !homeRoute.isCurrent) return result;
    final intent = shortcuts.entries
        .where((e) => e.key.accepts(event, HardwareKeyboard.instance))
        .firstOrNull
        ?.value;
    if (intent is! AppIntent && intent is! PrioritizedIntents) return result;
    final candidates = intent is PrioritizedIntents
        ? intent.orderedIntents
        : [intent!];
    // A page whose widgets live in nested navigators has none of its own.
    final nodes = scope.descendants.isEmpty
        ? FocusManager.instance.rootScope.descendants
        : scope.descendants;
    for (final node in nodes) {
      final at = node.context;
      if (at == null) continue;
      final route = ModalRoute.of(at);
      if (route == null ||
          !route.isCurrent ||
          (route != homeRoute && !homeRoute.isFirst)) {
        continue;
      }
      // The framework's own prioritised action looks from the focus, not
      // from this node, so the intents are tried here in order.
      for (final candidate in candidates) {
        final action = Actions.maybeFind<Intent>(at, intent: candidate);
        if (action == null) continue;
        final (enabled, _) = Actions.of(at)
            .invokeActionIfEnabled(action, candidate, at);
        if (enabled) return KeyEventResult.handled;
      }
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
