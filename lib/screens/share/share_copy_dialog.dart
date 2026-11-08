import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/post_files.dart';
import 'package:share_intake/share_intake.dart';

/// Shown while shared files take a moment to copy; Cancel stops the copy.
class ShareCopyDialog extends StatelessWidget {
  const ShareCopyDialog({
    required this.progress,
    required this.onCancel,
    super.key,
  });

  final ValueListenable<ShareProgress> progress;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Preparing the shared files'),
    content: ValueListenableBuilder(
      valueListenable: progress,
      builder: (context, value, _) {
        final total = value.total;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: total == null || total == 0 ? null : value.done / total,
            ),
            const SizedBox(height: 12),
            Text(
              total == null
                  ? formatBytes(value.done)
                  : '${formatBytes(value.done)} of ${formatBytes(total)}',
            ),
          ],
        );
      },
    ),
    actions: [TextButton(onPressed: onCancel, child: const Text('Cancel'))],
  );
}
