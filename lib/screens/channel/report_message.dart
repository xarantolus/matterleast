import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/actions/content_flagging.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/ui/app_sheet.dart';
import 'package:matterleast/ui/tokens.dart';
import 'package:matterleast/ui/try_action.dart';

typedef _Report = ({String? reason, String comment});

/// Asks why the message is reported, with the reasons the server offers,
/// and sends the report to the people who review them.
Future<void> reportMessage(
  BuildContext context,
  String url,
  PostItem post,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final container = ProviderScope.containerOf(context, listen: false);
  final flagging = (await container.read(serverSessionProvider(url).future))
      .contentFlagging;
  if (!context.mounted) return;
  final report = await showAppSheet<_Report>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _ReportSheet(flagging: flagging, host: hostOf(url)),
  );
  if (report == null) return;
  if (!context.mounted) return;
  final reported = await tryAction(
    context,
    hostOf(url),
    failure: "Couldn't report the message.",
    () => flagging.report(
      post.id,
      reason: report.reason,
      comment: report.comment.isEmpty ? null : report.comment,
    ),
  );
  if (reported) {
    messenger.showSnackBar(const SnackBar(content: Text('Message reported')));
  }
}

class _ReportSheet extends StatefulWidget {
  const _ReportSheet({required this.flagging, required this.host});

  final ContentFlagging flagging;
  final String host;

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  final _comment = TextEditingController();
  late Future<ReportForm> _form = widget.flagging.form();
  String? _reason;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Spacing.lg,
        0,
        Spacing.lg,
        MediaQuery.viewInsetsOf(context).bottom + Spacing.lg,
      ),
      child: FutureBuilder<ReportForm>(
        future: _form,
        builder: (context, snapshot) {
          final form = snapshot.data;
          if (form == null) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Report message', style: text.titleMedium),
                const SizedBox(height: Spacing.lg),
                if (snapshot.hasError) ...[
                  Text(
                    "Couldn't load the reasons. "
                    '${requestProblemText(snapshot.error!, widget.host)}',
                  ),
                  TextButton(
                    onPressed: () =>
                        setState(() => _form = widget.flagging.form()),
                    child: const Text('Retry'),
                  ),
                ] else
                  const CircularProgressIndicator.adaptive(
                    semanticsLabel: 'Loading reasons',
                  ),
              ],
            );
          }
          final comment = _comment.text.trim();
          final ready =
              (form.reasons.isEmpty || _reason != null) &&
              (!form.commentRequired || comment.isNotEmpty);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Report message', style: text.titleMedium),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (form.reasons.isNotEmpty)
                        RadioGroup<String>(
                          groupValue: _reason,
                          onChanged: (value) => setState(() => _reason = value),
                          child: Column(
                            children: [
                              for (final reason in form.reasons)
                                RadioListTile<String>(
                                  contentPadding: EdgeInsets.zero,
                                  value: reason,
                                  title: Text(reason),
                                ),
                            ],
                          ),
                        ),
                      TextField(
                        controller: _comment,
                        minLines: 2,
                        maxLines: 5,
                        textCapitalization: TextCapitalization.sentences,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: form.commentRequired
                              ? 'Comment'
                              : 'Comment (optional)',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Spacing.md),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: FilledButton(
                  onPressed: ready
                      ? () =>
                            Navigator.of(context)
                                .pop((reason: _reason, comment: comment))
                      : null,
                  child: const Text('Report'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
