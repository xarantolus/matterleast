import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/data/actions/account_actions.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/screens/settings/account_providers.dart';
import 'package:matterleast/screens/settings/settings_widgets.dart';
import 'package:matterleast/ui/confirm_dialog.dart';
import 'package:matterleast/ui/content_page.dart';
import 'package:matterleast/ui/empty_state.dart';
import 'package:matterleast/ui/narrow_page.dart';
import 'package:matterleast/ui/tokens.dart';

/// Turns two-factor authentication on, with the secret to scan or type
/// into an authenticator app and the code that proves it works, or off.
class TwoFactorPage extends ConsumerStatefulWidget {
  const TwoFactorPage({required this.server, super.key});

  final ServerEntry server;

  @override
  ConsumerState<TwoFactorPage> createState() => _TwoFactorPageState();
}

class _TwoFactorPageState extends ConsumerState<TwoFactorPage> {
  final _code = TextEditingController();
  MfaSecret? _secret;
  var _busy = false;
  String? _error;

  String get _url => widget.server.url;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<AccountActions> _actions() =>
      ref.read(accountActionsProvider(_url).future);

  Future<void> _run(Future<void> Function() work, {String? done}) async {
    if (_busy) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await work();
      if (done != null) messenger.showSnackBar(SnackBar(content: Text(done)));
    } on Object catch (e) {
      if (mounted) {
        setState(() => _error = requestProblemText(e, widget.server.address));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _start() => _run(() async {
    final secret = await (await _actions()).generateMfa();
    if (mounted) setState(() => _secret = secret);
  });

  Future<void> _turnOn() => _run(() async {
    await (await _actions()).setMfa(activate: true, code: _code.text.trim());
    _code.clear();
    if (mounted) setState(() => _secret = null);
    ref.invalidate(accountMeProvider(_url));
  }, done: 'Two-factor authentication is on');

  Future<void> _turnOff() async {
    final confirmed = await confirm(
      context,
      title: 'Turn off two-factor authentication?',
      body: 'Signing in then needs only your password.',
      action: 'Turn off',
      destructive: true,
    );
    if (!confirmed) return;
    await _run(() async {
      await (await _actions()).setMfa(activate: false);
      ref.invalidate(accountMeProvider(_url));
    }, done: 'Two-factor authentication is off');
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(accountMeProvider(_url));
    final user = me.value;
    return ContentPage(
      title: const Text('Two-factor authentication'),
      progress: _busy || me.isLoading,
      body: switch (user) {
        null when me.hasError => EmptyState(
          icon: Icons.error_outline,
          title: "Couldn't load your account",
          body: requestProblemText(me.error!, widget.server.address),
          action: FilledButton(
            onPressed: () => ref.invalidate(accountMeProvider(_url)),
            child: const Text('Try again'),
          ),
        ),
        null => const SizedBox.expand(),
        final user => NarrowPage(
          children: [
            ..._intro(user.mfaActive ?? false),
            if (_error case final error?) ...[
              const SizedBox(height: Spacing.lg),
              Text(
                error,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: Spacing.lg),
            if (user.mfaActive ?? false)
              OutlinedButton(
                onPressed: _busy ? null : _turnOff,
                child: const Text('Turn off'),
              )
            else if (_secret case final secret?)
              ..._setup(secret)
            else
              FilledButton(
                onPressed: _busy ? null : _start,
                child: const Text('Set up'),
              ),
          ],
        ),
      },
    );
  }

  List<Widget> _intro(bool on) => [
    Text(
      on
          ? 'Two-factor authentication is on. Signing in asks for a code '
                'from your authenticator app.'
          : 'Two-factor authentication asks for a code from an authenticator '
                'app, as well as your password, when you sign in.',
    ),
  ];

  double _qrSize(BuildContext context) =>
      (MediaQuery.sizeOf(context).shortestSide * 0.5).clamp(160, 280);

  List<Widget> _setup(MfaSecret secret) {
    final qr = secret.qrImage;
    return [
      const SettingsHeader('1. Add the account to your app'),
      if (qr != null)
        Center(
          child: Image.memory(
            qr,
            width: _qrSize(context),
            height: _qrSize(context),
            filterQuality: FilterQuality.none,
            semanticLabel: 'QR code to scan with an authenticator app',
          ),
        ),
      const SizedBox(height: Spacing.md),
      Text(
        qr != null
            ? 'Scan the code, or type this secret into your app:'
            : 'Type this secret into your authenticator app:',
      ),
      Row(
        children: [
          Expanded(
            child: SelectableText(
              secret.secret,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
          IconButton(
            tooltip: 'Copy secret',
            icon: const Icon(Icons.copy_outlined),
            onPressed: () => unawaited(
              Clipboard.setData(ClipboardData(text: secret.secret)),
            ),
          ),
        ],
      ),
      const SettingsHeader('2. Enter the code it shows'),
      TextField(
        controller: _code,
        enabled: !_busy,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.go,
        onSubmitted: (_) => unawaited(_turnOn()),
        decoration: const InputDecoration(
          labelText: 'Authentication code',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: Spacing.lg),
      FilledButton(
        onPressed: _busy ? null : _turnOn,
        child: const Text('Turn on'),
      ),
    ];
  }
}
