import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/app/composer_providers.dart';
import 'package:matterleast/domain/edit_history.dart';
import 'package:matterleast/domain/server_features.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/domain/time_labels.dart';
import 'package:matterleast/screens/channel/message_menu.dart';
import 'package:matterleast/ui/app_sheet.dart';
import 'package:matterleast/ui/confirm_dialog.dart';
import 'package:matterleast/ui/markdown/post_body.dart';
import 'package:matterleast/ui/tokens.dart';

/// Shows the earlier versions of the user's own message, with a way to put
/// one back. Returns false when the server doesn't have the history, so
/// the caller keeps to telling when the message was edited.
Future<bool> showEditHistory(
  BuildContext context,
  String url,
  String postId,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final load = ProviderScope.containerOf(context, listen: false)
      .read(postActionsProvider(url).future)
      .then((actions) => actions.editHistory(postId))
      .then(editVersions);
  var absent = false;
  final restore = await showAppSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _EditHistory(
      load: load,
      onFailed: (e) {
        if (endpointUnavailable(e, refusalMeansAbsent: true)) {
          absent = true;
          return;
        }
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              "Couldn't load the edit history. "
              '${requestProblemText(e, hostOf(url))}',
            ),
          ),
        );
      },
    ),
  );
  if (absent) return false;
  if (restore == null || !context.mounted) return true;
  await runPostAction(context, url, (a) async {
    await a.restoreVersion(postId, restore);
    messenger.showSnackBar(const SnackBar(content: Text('Version restored')));
  }, "Couldn't restore the version.");
  return true;
}

class _EditHistory extends StatefulWidget {
  const _EditHistory({required this.load, required this.onFailed});

  final Future<List<EditVersion>> load;
  final void Function(ApiError error) onFailed;

  @override
  State<_EditHistory> createState() => _EditHistoryState();
}

class _EditHistoryState extends State<_EditHistory> {
  List<EditVersion>? _versions;

  @override
  void initState() {
    super.initState();
    unawaited(
      widget.load.then(
        (versions) {
          if (mounted) setState(() => _versions = versions);
        },
        onError: (Object e) {
          if (e is! ApiError) throw e;
          if (!mounted) return;
          widget.onFailed(e);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final versions = _versions;
    final text = Theme.of(context).textTheme;
    final now = DateTime.now();
    final use24 = MediaQuery.alwaysUse24HourFormatOf(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(Spacing.lg, 0, Spacing.lg, Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Edit history', style: text.titleMedium),
          const SizedBox(height: Spacing.md),
          if (versions == null)
            const LinearProgressIndicator()
          else if (versions.isEmpty)
            const Text('There are no earlier versions of this message.'),
          for (final version in versions ?? const <EditVersion>[])
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.md),
              child: Card.outlined(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              momentLabel(version.at, now, use24: use24),
                              style: text.labelLarge?.copyWith(
                                color: context.tokens.muted,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final sheet = Navigator.of(context);
                              if (!await confirm(
                                    context,
                                    title: 'Restore this version?',
                                    body:
                                        'The message goes back to this text '
                                        'for everyone.',
                                    action: 'Restore',
                                  ) ||
                                  !context.mounted) {
                                return;
                              }
                              sheet.pop(version.id);
                            },
                            child: const Text('Restore'),
                          ),
                        ],
                      ),
                      PostBody(
                        postId: version.id,
                        message: version.message,
                        collapsible: false,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
