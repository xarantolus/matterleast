import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/ui/sheet_header.dart';
import 'package:matterleast/ui/tokens.dart';

const passwordResetSentText =
    'If that address has an account, an email is on its way.';

/// Asks for the account's email and has the server send a reset link. The
/// answer is the same whether or not the address is known.
class ForgotPasswordSheet extends StatefulWidget {
  const ForgotPasswordSheet({
    required this.host,
    required this.send,
    this.initialEmail = '',
    super.key,
  });

  final String host;
  final Future<void> Function(String email) send;
  final String initialEmail;

  @override
  State<ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<ForgotPasswordSheet> {
  late final _email = TextEditingController(
    text: widget.initialEmail.contains('@') ? widget.initialEmail : '',
  );
  var _busy = false;
  var _sent = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    if (_busy || email.isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.send(email);
      if (mounted) {
        setState(() {
          _busy = false;
          _sent = true;
        });
      }
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = requestProblemText(e, widget.host);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final muted = text.bodyMedium?.copyWith(color: context.tokens.muted);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Spacing.lg,
        0,
        Spacing.lg,
        Spacing.lg + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetHeader('Reset your password'),
            if (_sent) ...[
              Text(passwordResetSentText, style: text.bodyLarge),
              const SizedBox(height: Spacing.lg),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ] else ...[
              Text(
                'Enter the email address of your account and the server '
                'sends you a link to choose a new password.',
                style: muted,
              ),
              const SizedBox(height: Spacing.lg),
              TextField(
                controller: _email,
                enabled: !_busy,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                enableSuggestions: false,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _submit(),
                autofillHints: const [AutofillHints.email],
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: const OutlineInputBorder(),
                  errorText: _error,
                  errorMaxLines: 4,
                ),
              ),
              const SizedBox(height: Spacing.lg),
              FilledButton(
                onPressed: _busy ? null : _submit,
                child: Text(_busy ? 'Sending…' : 'Send reset link'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
