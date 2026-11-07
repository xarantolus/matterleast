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
import 'package:matterleast/ui/tokens.dart';

/// Turns a group message into a private channel: asks for its name and
/// the team it moves into, then opens it.
class ConvertGroupScreen extends ConsumerStatefulWidget {
  const ConvertGroupScreen({
    required this.url,
    required this.channelId,
    required this.initialTeamId,
    super.key,
  });

  final String url;
  final String channelId;

  /// The team the list shows, preselected when the user may use it.
  final String initialTeamId;

  @override
  ConsumerState<ConvertGroupScreen> createState() => _ConvertGroupState();
}

class _ConvertGroupState extends ConsumerState<ConvertGroupScreen> {
  final _name = TextEditingController();
  String? _teamId;
  var _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _convert(String teamId) async {
    final navigator = Navigator.of(context);
    final name = _name.text.trim();
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final actions = await ref.read(channelActionsProvider(widget.url).future);
      final id = await actions.convertGroup(
        channelId: widget.channelId,
        teamId: teamId,
        displayName: name,
        name: channelNameFor(
          name,
          unique: DateTime.now().millisecondsSinceEpoch,
        ),
      );
      if (!mounted) return;
      navigator.pop();
      unawaited(
        openConversation(
          navigator,
          url: widget.url,
          channelId: id,
          title: name,
          teamId: teamId,
        ),
      );
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = switch (e) {
          ServerError(:final id?) when id.contains('exists') =>
            'A channel with this name already exists. Pick another name.',
          _ => requestProblemText(e, hostOf(widget.url)),
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final targets = ref.watch(convertTargetsProvider(widget.url)).value ?? [];
    final teamId = targets.any((t) => t.id == _teamId)
        ? _teamId
        : targets.any((t) => t.id == widget.initialTeamId)
        ? widget.initialTeamId
        : targets.firstOrNull?.id;
    final valid = teamId != null && _name.text.trim().isNotEmpty;
    return ContentPage(
      title: const Text('Convert to private channel'),
      progress: _saving,
      actions: [
        TextButton(
          style: context.barButtonStyle,
          onPressed: _saving || !valid ? null : () => _convert(teamId),
          child: const Text('Convert'),
        ),
      ],
      body: NarrowPage(
        children: [
          Text(
            'The messages and members stay. The channel is private, so only '
            'people added to it can read it. This can not be undone.',
            style: TextStyle(color: context.tokens.muted),
          ),
          const SizedBox(height: Spacing.lg),
          TextField(
            controller: _name,
            enabled: !_saving,
            autofocus: true,
            maxLength: 64,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Channel name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: Spacing.md),
          if (targets.length > 1)
            DropdownButtonFormField<String>(
              initialValue: teamId,
              decoration: const InputDecoration(
                labelText: 'Team',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final t in targets)
                  DropdownMenuItem(value: t.id, child: Text(t.displayName)),
              ],
              onChanged: _saving ? null : (id) => setState(() => _teamId = id),
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
