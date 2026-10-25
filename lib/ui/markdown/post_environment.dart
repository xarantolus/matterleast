import 'package:material_ui/material_ui.dart';
import 'package:matterleast/markdown/links.dart';
import 'package:matterleast/markdown/post_doc.dart';

/// What message bodies in a conversation need from around them: the server,
/// the parse options, and what taps on mentions, channels and links do.
class PostEnvironment extends InheritedWidget {
  const PostEnvironment({
    required this.server,
    required this.options,
    required this.myUsername,
    required this.onMention,
    required this.onChannel,
    required this.onLink,
    required super.child,
    this.customEmoji,
    this.image,
    super.key,
  });

  final Uri server;
  final ParseOptions options;
  final String myUsername;
  final ValueChanged<String> onMention;
  final ValueChanged<String> onChannel;
  final ValueChanged<LinkTarget> onLink;

  /// The image of a custom emoji in a square of [size], or null when the
  /// name is not a known custom emoji.
  final Widget? Function(String name, double size)? customEmoji;

  /// An image from a message, filling [size].
  final Widget Function(String url, Size size)? image;

  static PostEnvironment? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PostEnvironment>();

  @override
  bool updateShouldNotify(PostEnvironment old) =>
      server != old.server ||
      options != old.options ||
      myUsername != old.myUsername ||
      customEmoji != old.customEmoji ||
      image != old.image;
}
