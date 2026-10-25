import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/screens/add_server/add_server_controller.dart';
import 'package:matterleast/screens/login/login_screen.dart';
import 'package:matterleast/ui/initials_badge.dart';
import 'package:matterleast/ui/narrow_page.dart';
import 'package:matterleast/ui/progress_slot.dart';
import 'package:matterleast/ui/tokens.dart';

/// Asks for a server address, checks it and goes on to its login. As the
/// first screen it also lists signed-out servers for a quick sign-in.
class AddServerScreen extends ConsumerStatefulWidget {
  const AddServerScreen({
    this.initialUrl,
    this.initialName,
    this.isRoot = false,
    super.key,
  });

  /// Pre-fills the form and connects at once.
  final String? initialUrl;
  final String? initialName;
  final bool isRoot;

  @override
  ConsumerState<AddServerScreen> createState() => _AddServerScreenState();
}

class _AddServerScreenState extends ConsumerState<AddServerScreen> {
  late final _url = TextEditingController(text: widget.initialUrl);
  late final _name = TextEditingController(text: widget.initialName);

  @override
  void initState() {
    super.initState();
    if (widget.initialUrl != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _connect());
    }
  }

  @override
  void dispose() {
    _url.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    FocusScope.of(context).unfocus();
    final navigator = Navigator.of(context);
    final target = await ref
        .read(addServerControllerProvider.notifier)
        .connect(url: _url.text, name: _name.text);
    if (target == null || !mounted) return;
    await navigator.push(
      MaterialPageRoute<void>(builder: (_) => LoginScreen(target: target)),
    );
  }

  void _signInAgain(ServerEntry server) {
    _url.text = server.url;
    _name.text = server.displayName;
    _connect();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addServerControllerProvider);
    final signedOut = widget.isRoot
        ? [
            for (final s in ref.watch(serversProvider).value ?? <ServerEntry>[])
              if (!s.signedIn) s,
          ]
        : <ServerEntry>[];
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isRoot ? 'Matterleast' : 'Add a server'),
        bottom: ProgressSlot(active: state.checking),
      ),
      body: NarrowPage(
        children: [
          Text('Connect to your server', style: text.headlineSmall),
          const SizedBox(height: Spacing.sm),
          Text(
            'Enter the address you open Mattermost at in a browser.',
            style: text.bodyMedium?.copyWith(color: context.tokens.muted),
          ),
          const SizedBox(height: Spacing.xl),
          TextField(
            controller: _url,
            enabled: !state.checking,
            keyboardType: TextInputType.url,
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.url],
            decoration: InputDecoration(
              labelText: 'Server address',
              hintText: 'chat.example.com',
              border: const OutlineInputBorder(),
              errorText: state.urlError,
              errorMaxLines: 4,
            ),
          ),
          const SizedBox(height: Spacing.lg),
          TextField(
            controller: _name,
            enabled: !state.checking,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.go,
            onSubmitted: (_) => _connect(),
            decoration: InputDecoration(
              labelText: 'Display name (optional)',
              helperText: "Leave empty to use the server's own name",
              helperMaxLines: 3,
              border: const OutlineInputBorder(),
              errorText: state.nameError,
              errorMaxLines: 3,
            ),
          ),
          const SizedBox(height: Spacing.xl),
          FilledButton(
            onPressed: state.checking ? null : _connect,
            style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
            child: Text(state.checking ? 'Checking server…' : 'Connect'),
          ),
          if (signedOut.isNotEmpty) ...[
            const SizedBox(height: Spacing.xxl),
            Text('SIGNED OUT', style: context.tokens.smallCaps),
            const SizedBox(height: Spacing.sm),
            for (final server in signedOut)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: InitialsBadge(name: server.displayName, faded: true),
                title: Text(server.displayName),
                subtitle: Text(server.address),
                trailing: const Text('Sign in'),
                enabled: !state.checking,
                onTap: () => _signInAgain(server),
              ),
          ],
        ],
      ),
    );
  }
}
