import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/domain/user_profile.dart';
import 'package:matterleast/screens/you/profile_providers.dart';
import 'package:matterleast/ui/emoji_glyph.dart';
import 'package:matterleast/ui/emoji_picker.dart';
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
    final recent =
        ref.watch(recentCustomStatusesProvider(widget.url)).value ?? const [];
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
                    final picked = await showEmojiPicker(context, widget.url);
                    if (picked != null) setState(() => _emoji = picked);
                  },
                  icon: _emoji.isEmpty
                      ? const Icon(Icons.add_reaction_outlined)
                      : EmojiGlyph(
                          name: _emoji,
                          size: 24,
                          serverUrl: widget.url,
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
          if (recent.isNotEmpty) ...[
            const PaneLabel('Recent'),
            for (final s in recent)
              ListTile(
                leading: SizedBox(
                  width: 40,
                  child: Center(
                    child: EmojiGlyph(
                      name: s.emoji,
                      size: 24,
                      serverUrl: widget.url,
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
          const PaneLabel('Suggestions'),
          for (final s in _suggestions)
            if (!recent.any((r) => r.emoji == s.emoji && r.text == s.text))
              ListTile(
                leading: SizedBox(
                  width: 40,
                  child: Center(
                    child: EmojiGlyph(
                      name: s.emoji,
                      size: 24,
                      serverUrl: widget.url,
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
