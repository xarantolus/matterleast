import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/ui/empty_state.dart';

/// A first load that failed: what the server (or the connection) said, and
/// a way to try again.
class FailedState extends StatelessWidget {
  const FailedState({
    required this.title,
    required this.error,
    required this.host,
    required this.onRetry,
    this.icon = Icons.cloud_off,
    this.retryLabel = 'Retry',
    super.key,
  });

  final String title;
  final Object error;
  final String host;
  final VoidCallback onRetry;
  final IconData icon;
  final String retryLabel;

  @override
  Widget build(BuildContext context) => EmptyState(
    icon: icon,
    title: title,
    body: requestProblemText(error, host),
    action: FilledButton.tonal(onPressed: onRetry, child: Text(retryLabel)),
  );
}
