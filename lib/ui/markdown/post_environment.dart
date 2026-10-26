import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/integration_blocks.dart';
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
    this.linkPreviews = true,
    this.usernameOverride = false,
    this.iconOverride = false,
    this.mmBlocks = false,
    this.onAction,
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

  /// Link preview cards show.
  final bool linkPreviews;

  /// Integration posts may show another name or picture than their
  /// creator's; otherwise they could pass for someone else.
  final bool usernameOverride;
  final bool iconOverride;

  /// The server renders Mattermost's own interactive blocks
  /// (`FeatureFlagMmBlocksEnabled`).
  final bool mmBlocks;

  /// Runs an integration's action; completes when the server answered and
  /// the user was told of any failure.
  final Future<void> Function(PostActionRequest request)? onAction;

  static PostEnvironment? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PostEnvironment>();

  @override
  bool updateShouldNotify(PostEnvironment old) =>
      server != old.server ||
      options != old.options ||
      myUsername != old.myUsername ||
      customEmoji != old.customEmoji ||
      image != old.image ||
      linkPreviews != old.linkPreviews ||
      usernameOverride != old.usernameOverride ||
      iconOverride != old.iconOverride ||
      mmBlocks != old.mmBlocks ||
      onAction != old.onAction;
}
