import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/actions/share_actions.dart';
import 'package:matterleast/domain/post_files.dart';
import 'package:matterleast/domain/quick_switch.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/screens/search/search_providers.dart';
import 'package:matterleast/ui/progress_slot.dart';
import 'package:matterleast/ui/tokens.dart';
import 'package:path/path.dart' as p;
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

/// What another app handed over: text and files already copied into the
/// app's cache.
typedef SharedContent = ({String text, List<String> files});

/// The text and files of a share; null when there is nothing to send, such
/// as a link opened in the app, which is not a share.
SharedContent? sharedContentOf(List<SharedMediaFile> media) {
  final text = [
    for (final m in media)
      if (m.type == SharedMediaType.text) m.path,
  ].join('\n\n');
  final files = [
    for (final m in media)
      if (const {
        SharedMediaType.image,
        SharedMediaType.video,
        SharedMediaType.file,
      }.contains(m.type))
        m.path,
  ];
  if (text.isEmpty && files.isEmpty) return null;
  return (text: text, files: files);
}

/// Sends shared text and files to a channel the user picks.
class ShareScreen extends ConsumerStatefulWidget {
  const ShareScreen({required this.shared, super.key});

  final SharedContent shared;

  @override
  ConsumerState<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends ConsumerState<ShareScreen> {
  late final _message = TextEditingController(text: widget.shared.text);
  String? _serverUrl;
  SwitchItem? _channel;
  var _sending = false;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _send(ServerEntry server, SwitchItem channel) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _sending = true);
    try {
      final session = await ref.read(serverSessionProvider(server.url).future);
      await sendShared(
        session,
        channelId: channel.id,
        message: _message.text.trim(),
        files: widget.shared.files,
      );
      messenger.showSnackBar(
        SnackBar(content: Text('Sent to ${channel.title}')),
      );
      navigator.pop();
    } on Object catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            "Couldn't send. ${requestProblemText(e, server.address)}",
          ),
        ),
      );
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _pickChannel(String url) async {
    final picked = await showModalBottomSheet<SwitchItem>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _ChannelPicker(url: url),
    );
    if (picked != null && mounted) setState(() => _channel = picked);
  }

  @override
  Widget build(BuildContext context) {
    final servers = [
      for (final s in ref.watch(serversProvider).value ?? const <ServerEntry>[])
        if (s.signedIn) s,
    ];
    final server =
        servers.where((s) => s.url == _serverUrl).firstOrNull ??
        servers.firstOrNull;
    final channel = _channel?.serverUrl == server?.url ? _channel : null;
    final files = widget.shared.files;
    final canSend =
        !_sending &&
        server != null &&
        channel != null &&
        (files.isNotEmpty || _message.text.trim().isNotEmpty);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share'),
        bottom: ProgressSlot(active: _sending),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: Spacing.sm),
            child: FilledButton.tonal(
              onPressed: canSend ? () => _send(server, channel) : null,
              child: const Text('Send'),
            ),
          ),
        ],
      ),
      body: server == null
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(Spacing.xl),
                child: Text('Sign in to a server first, then share again.'),
              ),
            )
          : ListView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.paddingOf(context).bottom + Spacing.lg,
              ),
              children: [
                if (servers.length > 1)
                  ListTile(
                    leading: const Icon(Icons.dns_outlined),
                    title: const Text('Server'),
                    subtitle: Text(server.displayName),
                    onTap: _sending
                        ? null
                        : () async {
                            final picked = await showDialog<String>(
                              context: context,
                              builder: (context) => SimpleDialog(
                                title: const Text('Server'),
                                children: [
                                  for (final s in servers)
                                    SimpleDialogOption(
                                      onPressed: () =>
                                          Navigator.of(context).pop(s.url),
                                      child: Text(s.displayName),
                                    ),
                                ],
                              ),
                            );
                            if (picked != null && mounted) {
                              setState(() => _serverUrl = picked);
                            }
                          },
                  ),
                ListTile(
                  leading: const Icon(Icons.tag),
                  title: const Text('Channel'),
                  subtitle: Text(channel?.title ?? 'Pick a channel'),
                  onTap: _sending ? null : () => _pickChannel(server.url),
                ),
                Padding(
                  padding: const EdgeInsets.all(Spacing.lg),
                  child: TextField(
                    controller: _message,
                    enabled: !_sending,
                    minLines: 3,
                    maxLines: 10,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                for (final path in files) _FileRow(path: path),
              ],
            ),
    );
  }
}

class _FileRow extends StatelessWidget {
  const _FileRow({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final file = File(path);
    final size = file.existsSync() ? file.lengthSync() : null;
    return ListTile(
      leading: const Icon(Icons.attach_file),
      title: Text(
        p.basename(path),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: size == null ? null : Text(formatBytes(size)),
    );
  }
}

class _ChannelPicker extends ConsumerWidget {
  const _ChannelPicker({required this.url});

  final String url;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = [
      for (final item
          in ref.watch(switchItemsProvider(url)).value ?? const <SwitchItem>[])
        if (const {
          SwitchKind.channel,
          SwitchKind.privateChannel,
          SwitchKind.direct,
          SwitchKind.group,
        }.contains(item.kind))
          item,
    ];
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.7,
      child: ListView(
        children: [
          for (final item in items)
            ListTile(
              title: Text(item.title),
              subtitle: item.subtitle == null ? null : Text(item.subtitle!),
              onTap: () => Navigator.of(context).pop(item),
            ),
        ],
      ),
    );
  }
}
