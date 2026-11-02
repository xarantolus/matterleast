import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/sign_in_problems.dart';

/// Runs [action]; when it fails, says the failure and what the server said in a
/// snackbar, the words coming from [problem]; [onFailed] sees the error first.
/// True when it succeeded.
Future<bool> tryAction(
  BuildContext context,
  String host,
  Future<void> Function() action, {
  String failure = '',
  String Function(Object error, String host) problem = requestProblemText,
  void Function(Object error)? onFailed,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await action();
    return true;
  } on Object catch (e) {
    onFailed?.call(e);
    final why = problem(e, host);
    messenger.showSnackBar(
      SnackBar(content: Text(failure.isEmpty ? why : '$failure $why')),
    );
    return false;
  }
}
