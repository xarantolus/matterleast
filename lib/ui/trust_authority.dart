import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/trusted_authorities.dart';
import 'package:matterleast/domain/ca_certificate.dart';
import 'package:matterleast/domain/time_labels.dart';

/// Lets the user pick a CA certificate file for [server], shows what it is
/// and stores it once they confirm. True when a CA was added.
Future<bool> trustAuthority(BuildContext context, Uri server) async {
  final messenger = ScaffoldMessenger.of(context);
  final picked = (await FilePicker.pickFiles()).singleOrNull?.xFile;
  if (picked == null) return false;
  // Certificates are a few kilobytes; anything big isn't one.
  final ca = await picked.length() > 1 << 20
      ? null
      : parseCaCertificate(await picked.readAsBytes());
  if (!context.mounted) return false;
  if (ca == null) {
    messenger.showSnackBar(
      const SnackBar(
        content: Text(
          "That file isn't a certificate. Pick a PEM or DER file (.pem, "
          '.crt, .cer).',
        ),
      ),
    );
    return false;
  }
  final now = DateTime.now();
  String date(DateTime at) => dateLabel(at.toLocal(), now, alwaysYear: true);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Trust this certificate authority?'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connections to ${server.authority} will accept certificates '
              'it signed. Only continue if your server admin gave you this '
              'file and the fingerprint matches.',
            ),
            const SizedBox(height: 16),
            _Field('Subject', ca.subject.isEmpty ? '–' : ca.subject),
            _Field('Valid', '${date(ca.notBefore)} to ${date(ca.notAfter)}'),
            _Field('SHA-256 fingerprint', ca.fingerprint, mono: true),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Trust'),
        ),
      ],
    ),
  );
  if (confirmed != true) return false;
  try {
    await TrustedAuthorities.instance.trust(server, ca);
    return true;
  } on TlsException {
    messenger.showSnackBar(
      const SnackBar(content: Text("The certificate couldn't be loaded.")),
    );
    return false;
  }
}

class _Field extends StatelessWidget {
  const _Field(this.label, this.value, {this.mono = false});

  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium),
          SelectableText(
            value,
            style: mono
                ? theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace')
                : theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
