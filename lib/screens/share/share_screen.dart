import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/actions/share_actions.dart';
import 'package:matterleast/data/files/local_copies.dart';
import 'package:matterleast/domain/post_files.dart';
import 'package:matterleast/domain/quick_switch.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/log.dart';
import 'package:matterleast/screens/add_server/add_server_screen.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:matterleast/screens/search/switch_picker.dart';
import 'package:matterleast/ui/empty_state.dart';
import 'package:matterleast/ui/progress_slot.dart';
import 'package:matterleast/ui/tokens.dart';
import 'package:path/path.dart' as p;
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'share_screen.g.dart';

/// What another app handed over: text, files the share plugin copied into
/// the app's cache, and the names of shared files the app refused.
typedef SharedContent = ({
  String text,
  List<String> files,
  List<String> refused,
});

/// The text and files of a share; null when there is nothing to show, such
/// as a link opened in the app, which is not a share. A file is taken only
/// when its path, [resolve]d (links and `..`, null when it is no regular
/// file), lies directly in [cacheDir], where the plugin puts its copies:
/// anything else may be another of the app's own files, which must never be
/// sent or deleted.
SharedContent? sharedContentOf(
  List<SharedMediaFile> media, {
  required String cacheDir,
  required String? Function(String path) resolve,
}) {
  final text = [
    for (final m in media)
      if (m.type == SharedMediaType.text) m.path,
  ].join('\n\n');
  final files = <String>[];
  final refused = <String>[];
  for (final m in media) {
    if (!const {
      SharedMediaType.image,
      SharedMediaType.video,
      SharedMediaType.file,
    }.contains(m.type)) {
      continue;
    }
    final resolved = resolve(m.path);
    if (resolved != null && isPluginCopy(cacheDir, resolved)) {
      files.add(resolved);
    } else {
      Log.warn('share', 'Refused a shared file outside the cache folder');
      refused.add(p.basename(m.path));
    }
  }
  if (text.isEmpty && files.isEmpty && refused.isEmpty) return null;
  return (text: text, files: files, refused: refused);
}

/// Pure: the files of [sizes] (path → bytes, null when unknown) that the
/// server takes, given its [limit] in bytes.
List<String> filesWithinLimit(Map<String, int?> sizes, int? limit) => [
  for (final MapEntry(key: path, value: size) in sizes.entries)
    if (limit == null || size == null || size <= limit) path,
];

/// The largest file the server takes, null when it doesn't say.
@riverpod
Future<int?> shareSizeLimit(Ref ref, String url) async {
  final session = await ref.watch(serverSessionProvider(url).future);
  return (await session.db.features()).maxFileSize;
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
  late final Map<String, int?> _sizes = {
    for (final path in widget.shared.files) path: _sizeOf(path),
  };

  static int? _sizeOf(String path) {
    try {
      return File(path).lengthSync();
    } on FileSystemException {
      return null;
    }
  }

  @override
  void dispose() {
    _message.dispose();
    final files = widget.shared.files;
    unawaited(
      LocalCopies.cacheDirectory().then(
        (dir) => LocalCopies.deleteShared(dir, files),
      ),
    );
    super.dispose();
  }

  Future<void> _send(
    ServerEntry server,
    SwitchItem channel,
    List<String> files,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _sending = true);
    try {
      final session = await ref.read(serverSessionProvider(server.url).future);
      final channelId = channel.kind == SwitchKind.person
          ? await (await ref.read(channelActionsProvider(server.url).future))
                .directChannel(channel.id)
          : channel.id;
      await sendShared(
        session,
        channelId: channelId,
        message: _message.text.trim(),
        files: files,
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
    final picked = await pickSwitchItem(
      context,
      title: 'Share to',
      hint: 'Find a channel or person',
      serverUrl: url,
      kinds: const {
        SwitchKind.channel,
        SwitchKind.privateChannel,
        SwitchKind.direct,
        SwitchKind.group,
      },
      findPeople: true,
    );
    if (picked != null && mounted) setState(() => _channel = picked);
  }

  @override
  Widget build(BuildContext context) {
    final stored = ref.watch(serversProvider).value;
    final servers = [
      for (final s in stored ?? const <ServerEntry>[])
        if (s.signedIn) s,
    ];
    final server =
        servers.where((s) => s.url == _serverUrl).firstOrNull ??
        servers.firstOrNull;
    final channel = _channel?.serverUrl == server?.url ? _channel : null;
    final limit = server == null
        ? null
        : ref.watch(shareSizeLimitProvider(server.url)).value;
    final files = filesWithinLimit(_sizes, limit);
    final canSend =
        !_sending &&
        server != null &&
        channel != null &&
        (files.isNotEmpty || _message.text.trim().isNotEmpty);
    return PopScope(
      canPop: !_sending,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Share'),
          bottom: ProgressSlot(active: _sending),
          actions: [
            Padding(
              padding: const EdgeInsetsDirectional.only(end: Spacing.sm),
              child: FilledButton.tonal(
                onPressed: canSend ? () => _send(server, channel, files) : null,
                child: const Text('Send'),
              ),
            ),
          ],
        ),
        body: stored == null
            ? const Center(child: CircularProgressIndicator())
            : server == null
            ? EmptyState(
                icon: Icons.dns_outlined,
                title: 'No server to share to',
                body:
                    'Sign in to a server first. What you shared stays here '
                    'until you send it or go back.',
                action: FilledButton.tonal(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AddServerScreen(),
                    ),
                  ),
                  child: const Text('Add server'),
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
                  for (final MapEntry(key: path, value: size) in _sizes.entries)
                    _FileRow(
                      name: p.basename(path),
                      detail: files.contains(path)
                          ? (size == null ? null : formatBytes(size))
                          : 'Not attached. It is larger than the '
                                '${formatBytes(limit!)} this server allows.',
                      attached: files.contains(path),
                    ),
                  for (final name in widget.shared.refused)
                    _FileRow(
                      name: name,
                      detail:
                          'Not attached. The other app shared this file in a '
                          "way that isn't supported.",
                      attached: false,
                    ),
                ],
              ),
      ),
    );
  }
}

class _FileRow extends StatelessWidget {
  const _FileRow({
    required this.name,
    required this.detail,
    required this.attached,
  });

  final String name;
  final String? detail;
  final bool attached;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(attached ? Icons.attach_file : Icons.block),
    title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
    subtitle: detail == null ? null : Text(detail!),
  );
}
