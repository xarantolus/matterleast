import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/login_options.dart';
import 'package:matterleast/screens/add_server/add_server_controller.dart';
import 'package:matterleast/screens/login/login_controller.dart';
import 'package:matterleast/ui/narrow_page.dart';
import 'package:matterleast/ui/progress_slot.dart';
import 'package:matterleast/ui/tokens.dart';
import 'package:url_launcher/url_launcher.dart';

/// Signs in to a checked server with the methods it offers.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({required this.target, super.key});

  final LoginTarget target;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _loginId = TextEditingController();
  final _password = TextEditingController();
  final _code = TextEditingController();
  var _showPassword = false;

  String get _url => widget.target.server.url.toString();
  LoginOptions get _options => widget.target.server.options;

  @override
  void initState() {
    super.initState();
    final only = _options.onlySso;
    if (only != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _sso(only));
    }
  }

  @override
  void dispose() {
    _loginId.dispose();
    _password.dispose();
    _code.dispose();
    super.dispose();
  }

  LoginController get _controller =>
      ref.read(loginControllerProvider(_url).notifier);

  Future<void> _signIn() async {
    TextInput.finishAutofillContext();
    final navigator = Navigator.of(context);
    final done = await _controller.withPassword(
      widget.target,
      loginId: _loginId.text,
      password: _password.text,
      mfaCode: _code.text,
    );
    if (done) navigator.popUntil((route) => route.isFirst);
  }

  Future<void> _sso(SsoButton button) async {
    FocusScope.of(context).unfocus();
    final navigator = Navigator.of(context);
    final done = await _controller.withSso(widget.target, button);
    if (done) navigator.popUntil((route) => route.isFirst);
  }

  void _forgotPassword() {
    final link = _options.forgotPasswordLink;
    launchUrl(
      link != null ? Uri.parse(link) : Uri.parse('$_url/reset_password'),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginControllerProvider(_url));
    final server = widget.target.server;
    final text = Theme.of(context).textTheme;
    final muted = text.bodyMedium?.copyWith(color: context.tokens.muted);
    final error = Theme.of(context).colorScheme.error;
    final enabled = !state.busy;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.target.displayName),
        bottom: ProgressSlot(active: state.busy),
      ),
      body: NarrowPage(
        children: [
          Text('Sign in', style: text.headlineSmall),
          const SizedBox(height: Spacing.sm),
          Text(
            [
              server.url.authority,
              if (server.options.siteName.isNotEmpty) server.options.siteName,
            ].join(' · '),
            style: muted,
          ),
          if (!server.versionSupported) ...[
            const SizedBox(height: Spacing.lg),
            _Notice(
              icon: Icons.info_outline,
              text:
                  'This server runs Mattermost ${server.options.serverVersion}. '
                  'The app is made for ${minimumServerVersion.$1}.'
                  '${minimumServerVersion.$2} and newer, so some things '
                  'may not work.',
            ),
          ],
          if (state.error case final message?) ...[
            const SizedBox(height: Spacing.lg),
            _Notice(icon: Icons.error_outline, text: message, color: error),
          ],
          if (!_options.any) ...[
            const SizedBox(height: Spacing.lg),
            Text(
              'This server offers no sign-in method the app supports. Ask the '
              "server's admin.",
              style: muted,
            ),
          ],
          if (_options.password) ...[
            const SizedBox(height: Spacing.xl),
            AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _loginId,
                    enabled: enabled && !state.mfaNeeded,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    enableSuggestions: false,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [
                      AutofillHints.username,
                      AutofillHints.email,
                    ],
                    decoration: InputDecoration(
                      labelText: _options.loginIdLabel,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: Spacing.lg),
                  TextField(
                    controller: _password,
                    enabled: enabled && !state.mfaNeeded,
                    obscureText: !_showPassword,
                    autocorrect: false,
                    enableSuggestions: false,
                    textInputAction: TextInputAction.go,
                    autofillHints: const [AutofillHints.password],
                    onSubmitted: (_) => _signIn(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        tooltip: _showPassword
                            ? 'Hide password'
                            : 'Show password',
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () =>
                            setState(() => _showPassword = !_showPassword),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (state.mfaNeeded) ...[
              const SizedBox(height: Spacing.lg),
              TextField(
                controller: _code,
                enabled: enabled,
                autofocus: true,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.go,
                autofillHints: const [AutofillHints.oneTimeCode],
                onSubmitted: (_) => _signIn(),
                decoration: InputDecoration(
                  labelText: 'Authentication code',
                  helperText: 'The 6-digit code from your authenticator app',
                  border: const OutlineInputBorder(),
                  errorText: state.mfaError,
                  errorMaxLines: 3,
                ),
              ),
            ],
            const SizedBox(height: Spacing.xl),
            FilledButton(
              onPressed: enabled ? _signIn : null,
              style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
              child: Text(state.busy ? 'Signing in…' : 'Sign in'),
            ),
            if (_options.forgotPassword)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(
                  onPressed: _forgotPassword,
                  style: TextButton.styleFrom(minimumSize: const Size(0, 48)),
                  child: const Text('Forgot password?'),
                ),
              ),
          ],
          if (_options.sso.isNotEmpty) ...[
            if (_options.password) const _OrDivider(),
            if (!_options.password) const SizedBox(height: Spacing.xl),
            for (final button in _options.sso) ...[
              OutlinedButton.icon(
                onPressed: enabled ? () => _sso(button) : null,
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
                icon: const Icon(Icons.open_in_browser),
                label: Text('Continue with ${button.label}'),
              ),
              const SizedBox(height: Spacing.md),
            ],
            Text(
              'Opens the sign-in page in your browser. If Android asks which '
              'app should finish signing in, choose Matterleast.',
              style: text.bodySmall?.copyWith(color: context.tokens.muted),
            ),
          ],
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.text, this.color});

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colour = color ?? context.tokens.muted;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: colour, size: 20),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: colour),
          ),
        ),
      ],
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: Spacing.lg),
    child: Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
          child: Text('or', style: TextStyle(color: context.tokens.muted)),
        ),
        const Expanded(child: Divider()),
      ],
    ),
  );
}
