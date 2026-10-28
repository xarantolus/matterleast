import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/domain/channel_info.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/screens/channel_info/channel_providers.dart';
import 'package:matterleast/screens/open_channel.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:matterleast/ui/content_page.dart';
import 'package:matterleast/ui/narrow_page.dart';
import 'package:matterleast/ui/progress_slot.dart';
import 'package:matterleast/ui/tokens.dart';

/// Creates a channel in a team, or edits one's name, purpose and header
/// ([channel] given). Direct and group messages only have a header.
class EditChannelScreen extends ConsumerStatefulWidget {
  const EditChannelScreen({
    required this.url,
    required this.teamId,
    this.channel,
    super.key,
  });

  final String url;
  final String teamId;
  final ChannelInfo? channel;

  @override
  ConsumerState<EditChannelScreen> createState() => _EditChannelScreenState();
}

class _EditChannelScreenState extends ConsumerState<EditChannelScreen> {
  late final _name = TextEditingController(text: widget.channel?.title);
  late final _purpose = TextEditingController(text: widget.channel?.purpose);
  late final _header = TextEditingController(text: widget.channel?.header);
  var _private = false;
  var _saving = false;
  String? _error;

  bool get _creating => widget.channel == null;
  bool get _headerOnly => widget.channel?.conversation ?? false;

  @override
  void initState() {
    super.initState();
    for (final c in [_name, _purpose, _header]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _purpose.dispose();
    _header.dispose();
    super.dispose();
  }

  bool get _changed {
    final c = widget.channel;
    if (c == null) return true;
    return _name.text.trim() != c.title ||
        _purpose.text.trim() != c.purpose ||
        _header.text.trim() != c.header;
  }

  /// Private when the user may only create private channels.
  bool get _isPrivate {
    final rights = ref.read(teamRightsProvider(widget.url, widget.teamId));
    final value = rights.value;
    final onlyPrivate = value != null && !value.public && value.private;
    return onlyPrivate || _private;
  }

  bool get _valid =>
      _headerOnly || (_name.text.trim().isNotEmpty && _name.text.length <= 64);

  Future<void> _save() async {
    final navigator = Navigator.of(context);
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final actions = await ref.read(channelActionsProvider(widget.url).future);
      final channel = widget.channel;
      if (channel == null) {
        final name = _name.text.trim();
        final slug = channelSlug(name);
        final id = await actions.create(
          teamId: widget.teamId,
          displayName: name,
          // Names without letters or digits still need a unique URL part.
          name: slug.length >= 2
              ? slug
              : 'channel-${DateTime.now().millisecondsSinceEpoch}',
          private: _isPrivate,
          purpose: _purpose.text.trim(),
          header: _header.text.trim(),
        );
        if (!mounted) return;
        // This screen goes first, so the conversation opens over the list.
        navigator.pop();
        unawaited(
          openConversation(
            navigator,
            url: widget.url,
            channelId: id,
            title: name,
            teamId: widget.teamId,
          ),
        );
      } else {
        await actions.patch(
          channel.id,
          displayName: _headerOnly ? null : _name.text.trim(),
          purpose: _headerOnly ? null : _purpose.text.trim(),
          header: _header.text.trim(),
        );
        navigator.pop();
      }
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = switch (e) {
          ServerError(:final id?) when id.contains('exists') =>
            'A channel with this name already exists. Pick another name.',
          _ => requestProblemText(e, Uri.parse(widget.url).host),
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final rights = ref.watch(teamRightsProvider(widget.url, widget.teamId));
    final canPublic = rights.value?.public ?? true;
    final canPrivate = rights.value?.private ?? true;
    final slug = channelSlug(_name.text);
    return ContentPage(
      title: Text(
        _creating
            ? 'New channel'
            : _headerOnly
            ? 'Edit header'
            : 'Edit channel',
      ),
      actions: [
        TextButton(
          style: context.barButtonStyle,
          onPressed: _saving || !_valid || !_changed ? null : _save,
          child: Text(_creating ? 'Create' : 'Save'),
        ),
      ],
      bottom: ProgressSlot(active: _saving),
      body: NarrowPage(
        children: [
          if (_creating && canPublic && canPrivate) ...[
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  label: Text('Public'),
                  icon: Icon(Icons.tag),
                ),
                ButtonSegment(
                  value: true,
                  label: Text('Private'),
                  icon: Icon(Icons.lock_outline),
                ),
              ],
              selected: {_private},
              onSelectionChanged: (s) => setState(() => _private = s.first),
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              _isPrivate
                  ? 'Only people you add can find and read it.'
                  : 'Anyone in the team can find and join it.',
              style: TextStyle(color: context.tokens.muted),
            ),
            const SizedBox(height: Spacing.lg),
          ],
          if (!_headerOnly) ...[
            TextField(
              controller: _name,
              enabled: !_saving,
              autofocus: _creating,
              maxLength: 64,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Name',
                border: const OutlineInputBorder(),
                helperText: _creating && slug.isNotEmpty
                    ? 'Link: ~$slug'
                    : null,
              ),
            ),
            const SizedBox(height: Spacing.md),
            TextField(
              controller: _purpose,
              enabled: !_saving,
              maxLength: 250,
              minLines: 2,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Purpose (optional)',
                helperText: 'What the channel is for, shown in its info.',
                helperMaxLines: 2,
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: Spacing.md),
          ],
          TextField(
            controller: _header,
            enabled: !_saving,
            maxLength: 1024,
            minLines: 2,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Header (optional)',
              helperText: 'Shown above the messages.',
              helperMaxLines: 2,
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
          if (_error case final error?) ...[
            const SizedBox(height: Spacing.md),
            Text(
              error,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
    );
  }
}
