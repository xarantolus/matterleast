import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/data/emoji/emoji.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/domain/user_profile.dart';
import 'package:matterleast/screens/you/profile_providers.dart';
import 'package:matterleast/screens/you/user_profile_sheet.dart';
import 'package:matterleast/ui/pane_label.dart';
import 'package:matterleast/ui/progress_slot.dart';
import 'package:matterleast/ui/tokens.dart';

typedef _Suggestion = ({String emoji, String text, String duration});

const _suggestions = <_Suggestion>[
  (emoji: 'calendar', text: 'In a meeting', duration: 'one_hour'),
  (emoji: 'hamburger', text: 'Out for lunch', duration: 'thirty_minutes'),
  (emoji: 'sneezing_face', text: 'Out sick', duration: 'today'),
  (emoji: 'house', text: 'Working from home', duration: 'today'),
  (emoji: 'palm_tree', text: 'On a vacation', duration: 'this_week'),
];

/// Words for how long a custom status stays.
String durationLabel(String duration) => switch (duration) {
  'thirty_minutes' => '30 minutes',
  'one_hour' => '1 hour',
  'four_hours' => '4 hours',
  'today' => 'Today',
  'this_week' => 'This week',
  _ => "Don't clear",
};

/// Sets or clears the user's custom status on one server.
class CustomStatusScreen extends ConsumerStatefulWidget {
  const CustomStatusScreen({required this.url, this.current, super.key});

  final String url;
  final CustomStatus? current;

  @override
  ConsumerState<CustomStatusScreen> createState() => _CustomStatusScreenState();
}

class _CustomStatusScreenState extends ConsumerState<CustomStatusScreen> {
  late final _text = TextEditingController(text: widget.current?.text);
  late String _emoji = widget.current?.emoji ?? '';
  late String _duration = widget.current?.duration ?? 'today';
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _text.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  bool get _empty => _text.text.trim().isEmpty && _emoji.isEmpty;

  Future<void> _done() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      final actions = await ref.read(profileActionsProvider(widget.url).future);
      await actions.setCustomStatus(
        _empty
            ? null
            : CustomStatus(
                // A status with only text still shows an emoji, as on the web.
                emoji: _emoji.isEmpty ? 'speech_balloon' : _emoji,
                // Newlines would not show in one-line places.
                text: _text.text.trim().replaceAll(RegExp(r'\s*\n\s*'), ' '),
                duration: _duration,
                expiresAt: customStatusExpiry(_duration, DateTime.now()),
              ),
      );
      navigator.pop();
    } on Object catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            "Couldn't set your status. "
            '${requestProblemText(e, Uri.parse(widget.url).host)}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom status'),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
            ),
            onPressed: _saving || (_empty && widget.current == null)
                ? null
                : _done,
            child: Text(_empty && widget.current != null ? 'Clear' : 'Done'),
          ),
        ],
        bottom: ProgressSlot(active: _saving),
      ),
      body: ListView(
        padding: EdgeInsets.only(bottom: bottom + Spacing.lg),
        children: [
          Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: TextField(
              controller: _text,
              enabled: !_saving,
              maxLength: 100,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: "What's your status?",
                border: const OutlineInputBorder(),
                prefixIcon: IconButton(
                  tooltip: 'Pick an emoji',
                  onPressed: () async {
                    final picked = await pickStatusEmoji(context);
                    if (picked != null) setState(() => _emoji = picked);
                  },
                  icon: _emoji.isEmpty
                      ? const Icon(Icons.add_reaction_outlined)
                      : Text(
                          emojiText(_emoji),
                          style: const TextStyle(fontSize: 22),
                        ),
                ),
                suffixIcon: _empty
                    ? null
                    : IconButton(
                        tooltip: 'Clear',
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() {
                          _text.clear();
                          _emoji = '';
                        }),
                      ),
              ),
            ),
          ),
          const PaneLabel('Clear after'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
            child: Wrap(
              spacing: Spacing.sm,
              runSpacing: Spacing.xs,
              children: [
                for (final d in const [
                  '',
                  'thirty_minutes',
                  'one_hour',
                  'four_hours',
                  'today',
                  'this_week',
                ])
                  ChoiceChip(
                    label: Text(durationLabel(d)),
                    selected: _duration == d,
                    onSelected: (_) => setState(() => _duration = d),
                  ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),
          const PaneLabel('Suggestions'),
          for (final s in _suggestions)
            ListTile(
              leading: SizedBox(
                width: 40,
                child: Center(
                  child: Text(
                    emojiText(s.emoji),
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              title: Text(s.text),
              subtitle: Text(durationLabel(s.duration)),
              onTap: () => setState(() {
                _emoji = s.emoji;
                _text.text = s.text;
                _duration = s.duration;
              }),
            ),
        ],
      ),
    );
  }
}

/// A searchable grid of system emoji; the picked short name, or null.
Future<String?> pickStatusEmoji(BuildContext context) =>
    showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _EmojiSheet(),
    );

class _EmojiSheet extends StatefulWidget {
  const _EmojiSheet();

  @override
  State<_EmojiSheet> createState() => _EmojiSheetState();
}

class _EmojiSheetState extends State<_EmojiSheet> {
  static final _all = {
    for (final name in systemEmojiNames()) canonicalName(name),
  }.toList();
  var _term = '';

  @override
  Widget build(BuildContext context) {
    final term = _term.trim().toLowerCase().replaceAll(':', '');
    final names = term.isEmpty
        ? _all
        : {
            for (final name in systemEmojiNames())
              if (name.contains(term)) canonicalName(name),
          }.toList();
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.7,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.md,
                0,
                Spacing.md,
                Spacing.sm,
              ),
              child: SearchBar(
                hintText: 'Search emoji',
                leading: const Icon(Icons.search),
                elevation: const WidgetStatePropertyAll(0),
                onChanged: (text) => setState(() => _term = text),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 52,
                ),
                itemCount: names.length,
                itemBuilder: (context, i) => Semantics(
                  label: names[i].replaceAll('_', ' '),
                  button: true,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => Navigator.pop(context, names[i]),
                    child: Center(
                      child: ExcludeSemantics(
                        child: Text(
                          emojiText(names[i]),
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
