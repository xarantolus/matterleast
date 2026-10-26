import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/app/composer_providers.dart';
import 'package:matterleast/domain/burn_on_read.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/ui/markdown/post_environment.dart';
import 'package:matterleast/ui/tokens.dart';

/// A burn-on-read message: a "View message" placeholder until the reader
/// opens it, then [child] with a countdown; it leaves when it burns.
class BurnOnReadView extends ConsumerStatefulWidget {
  const BurnOnReadView({required this.post, required this.child, super.key});

  final PostItem post;
  final Widget child;

  @override
  ConsumerState<BurnOnReadView> createState() => _BurnOnReadViewState();
}

class _BurnOnReadViewState extends ConsumerState<BurnOnReadView> {
  Timer? _tick;
  var _revealing = false;

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  Uri? get _server => PostEnvironment.maybeOf(context)?.server;

  Future<void> _reveal() async {
    final server = _server;
    if (server == null || _revealing) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _revealing = true);
    try {
      final actions = await ref.read(postActionsProvider('$server').future);
      await actions.reveal(widget.post.id);
    } on ApiError catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(requestProblemText(e, server.host))),
      );
    } finally {
      if (mounted) setState(() => _revealing = false);
    }
  }

  void _burned() {
    final server = _server;
    if (server == null) return;
    unawaited(
      ref
          .read(postActionsProvider('$server').future)
          .then((a) => a.burned())
          .catchError((Object _) {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    final env = PostEnvironment.maybeOf(context);
    final post = widget.post;
    final ends = burnEnds(post.propsJson, post.metadataJson);
    final now = DateTime.now().toUtc();
    final state = burnState(
      own: env != null && post.authorUsername == env.myUsername,
      expireAt: ends.expireAt,
      maxExpireAt: ends.maxExpireAt,
      now: now,
    );
    _tick?.cancel();
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    switch (state) {
      case BurnExpired():
        WidgetsBinding.instance.addPostFrameCallback((_) => _burned());
        return const SizedBox.shrink();
      case BurnUnrevealed():
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: FilledButton.tonalIcon(
              onPressed: post.sendState == null ? _reveal : null,
              icon: _revealing
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.visibility_outlined),
              label: const Text('View message'),
            ),
          ),
        );
      case BurnReadable(:final at):
        if (at != null) {
          _tick = Timer(
            const Duration(seconds: 1),
            () => mounted ? setState(() {}) : null,
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            widget.child,
            Padding(
              padding: const EdgeInsets.only(top: Spacing.xs),
              child: Row(
                children: [
                  Icon(
                    Icons.local_fire_department_outlined,
                    size: 16,
                    color: scheme.error,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Text(
                    at == null
                        ? 'Burn on read'
                        : 'Burns in ${burnCountdown(at.difference(now))}',
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: tokens.muted),
                  ),
                ],
              ),
            ),
          ],
        );
    }
  }
}
