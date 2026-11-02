import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/today_provider.dart';
import 'package:matterleast/domain/account_security.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/screens/settings/account_providers.dart';
import 'package:matterleast/screens/settings/settings_widgets.dart';
import 'package:matterleast/screens/you/leave_server.dart';
import 'package:matterleast/ui/confirm_dialog.dart';
import 'package:matterleast/ui/content_page.dart';
import 'package:matterleast/ui/empty_state.dart';
import 'package:matterleast/ui/tokens.dart';

/// Where the account is signed in, with a way to end each session.
class SessionsPage extends ConsumerWidget {
  const SessionsPage({required this.server, super.key});

  final ServerEntry server;

  Future<void> _signOut(
    BuildContext context,
    WidgetRef ref,
    SessionRow row,
  ) async {
    if (row.current) {
      await leaveServer(context, ref, server, remove: false);
      return;
    }
    final confirmed = await confirm(
      context,
      title: 'Sign out ${row.device}?',
      body:
          'It is signed out of ${server.displayName} and has to sign in '
          'again.',
      action: 'Sign out',
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(activeSessionsProvider(server.url).notifier)
          .revoke(row.id);
    } on Object catch (e) {
      showProblem(messenger, requestProblemText(e, server.address));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(activeSessionsProvider(server.url));
    final rows = sessions.value;
    final now = ref.watch(todayProvider);
    final use24 = MediaQuery.alwaysUse24HourFormatOf(context);
    return ContentPage(
      title: const Text('Active sessions'),
      progress: sessions.isLoading,
      body: switch (rows) {
        final rows? => ListView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            if (sessions.hasError)
              Padding(
                padding: const EdgeInsets.all(Spacing.lg),
                child: Text(
                  requestProblemText(sessions.error!, server.address),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            for (final row in rows)
              ListTile(
                leading: const Icon(Icons.devices_outlined),
                title: Text(row.device),
                subtitle: Text(
                  [
                    if (row.current) 'This device',
                    sessionActivityLabel(row.lastActive, now, use24: use24),
                  ].join(' · '),
                ),
                trailing: TextButton(
                  onPressed: () => unawaited(_signOut(context, ref, row)),
                  child: const Text('Sign out'),
                ),
              ),
          ],
        ),
        null when sessions.hasError => EmptyState(
          icon: Icons.error_outline,
          title: "Couldn't load your sessions",
          body: requestProblemText(sessions.error!, server.address),
          action: FilledButton(
            onPressed: () => ref.invalidate(activeSessionsProvider(server.url)),
            child: const Text('Try again'),
          ),
        ),
        null => const SizedBox.expand(),
      },
    );
  }
}
