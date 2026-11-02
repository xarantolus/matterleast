import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/screens/settings/account_providers.dart';
import 'package:matterleast/ui/confirm_dialog.dart';
import 'package:matterleast/ui/markdown/post_body.dart';
import 'package:matterleast/ui/tokens.dart';

/// Shows [child], and over it the server's terms of service while the user
/// hasn't accepted the current ones. Nothing below can be reached until
/// they accept or decline and leave.
class TermsGate extends ConsumerWidget {
  const TermsGate({required this.url, required this.child, super.key});

  final String url;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final terms = ref.watch(termsToAcceptProvider(url)).value;
    return Stack(
      children: [
        child,
        if (terms != null)
          Positioned.fill(
            child: _TermsScreen(
              key: ValueKey(terms.id),
              url: url,
              terms: terms,
            ),
          ),
      ],
    );
  }
}

class _TermsScreen extends ConsumerStatefulWidget {
  const _TermsScreen({required this.url, required this.terms, super.key});

  final String url;
  final api.TermsOfService terms;

  @override
  ConsumerState<_TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends ConsumerState<_TermsScreen> {
  var _busy = false;
  String? _error;

  String get _host => Uri.parse(widget.url).authority;

  Future<void> _answer({required bool accept}) async {
    if (_busy) return;
    if (!accept) {
      final leave = await confirm(
        context,
        title: 'You must accept the terms',
        body:
            'To use $_host you have to accept its terms of service. If you '
            'decline you are signed out; sign in again to accept them.',
        action: 'Decline and sign out',
        destructive: true,
      );
      if (!leave) return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final manager = ref.read(serverManagerProvider);
    try {
      final actions = await ref.read(accountActionsProvider(widget.url).future);
      await actions.answerTerms(widget.terms.id ?? '', accepted: accept);
      if (accept) {
        ref.invalidate(termsToAcceptProvider(widget.url));
      } else if (!await manager.signOut(widget.url)) {
        await manager.signOut(widget.url, force: true);
      }
    } on Object catch (e) {
      if (mounted) setState(() => _error = requestProblemText(e, _host));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final terms = widget.terms;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Terms of service'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(Spacing.lg),
              child: PostBody(
                postId: 'terms-${terms.id}',
                message: terms.text ?? '',
                collapsible: false,
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(Spacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_error case final error?)
                    Padding(
                      padding: const EdgeInsets.only(bottom: Spacing.md),
                      child: Text(
                        error,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _busy
                              ? null
                              : () => unawaited(_answer(accept: false)),
                          child: const Text('Decline'),
                        ),
                      ),
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: FilledButton(
                          onPressed: _busy
                              ? null
                              : () => unawaited(_answer(accept: true)),
                          child: const Text('Accept'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
