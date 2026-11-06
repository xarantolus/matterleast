import 'package:material_ui/material_ui.dart';
import 'package:matterleast/ui/tokens.dart';

/// Shown after the server emailed a guest a sign-in link. On a phone the
/// link opens in the browser, not in the app, so it can be pasted here.
class LinkSentView extends StatefulWidget {
  const LinkSentView({
    required this.busy,
    required this.error,
    required this.onPasted,
    required this.onBack,
    super.key,
  });

  final bool busy;
  final String? error;
  final void Function(String link) onPasted;
  final VoidCallback onBack;

  @override
  State<LinkSentView> createState() => _LinkSentViewState();
}

class _LinkSentViewState extends State<LinkSentView> {
  final _link = TextEditingController();

  @override
  void dispose() {
    _link.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final muted = text.bodyMedium?.copyWith(color: context.tokens.muted);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.mark_email_read_outlined, size: 56),
        const SizedBox(height: Spacing.lg),
        Text('We sent you a link to login', style: text.headlineSmall),
        const SizedBox(height: Spacing.sm),
        Text(
          'Please check your email for the link to login. Your link will '
          'expire in 5 minutes.',
          style: muted,
        ),
        const SizedBox(height: Spacing.xl),
        TextField(
          controller: _link,
          enabled: !widget.busy,
          keyboardType: TextInputType.url,
          autocorrect: false,
          enableSuggestions: false,
          textInputAction: TextInputAction.go,
          onSubmitted: widget.onPasted,
          decoration: InputDecoration(
            labelText: 'Link from the email',
            helperText:
                'If the link opens in your browser, copy it and paste it here.',
            helperMaxLines: 3,
            errorText: widget.error,
            errorMaxLines: 3,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: Spacing.lg),
        FilledButton(
          onPressed: widget.busy ? null : () => widget.onPasted(_link.text),
          style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
          child: Text(widget.busy ? 'Signing in…' : 'Sign in'),
        ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton(
            onPressed: widget.busy ? null : widget.onBack,
            child: const Text('Use another login'),
          ),
        ),
      ],
    );
  }
}
