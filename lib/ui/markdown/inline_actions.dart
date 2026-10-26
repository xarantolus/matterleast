import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/integration_blocks.dart';

/// Lets `mmaction://` links in the text below run [postId]'s actions. Only
/// integrations' posts get one; elsewhere such links are plain text.
class InlineActions extends InheritedWidget {
  const InlineActions({
    required this.postId,
    required this.format,
    required super.child,
    this.cookie,
    super.key,
  });

  final String postId;
  final IntegrationFormat format;
  final String? cookie;

  static InlineActions? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<InlineActions>();

  /// The request an inline action link in this scope sends.
  PostActionRequest request(InlineAction action) => (
    postId: postId,
    actionId: action.actionId,
    cookie: cookie,
    selectedOption: '',
    query: action.query,
    format: format,
  );

  @override
  bool updateShouldNotify(InlineActions old) =>
      postId != old.postId || format != old.format || cookie != old.cookie;
}
