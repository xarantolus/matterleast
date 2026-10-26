import 'dart:convert';

import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/api/json/integration_props.dart';
import 'package:matterleast/api/json/post_extras.dart';
import 'package:matterleast/domain/integration_blocks.dart';
import 'package:matterleast/domain/post_files.dart';

/// What a post row shows beyond its text, decoded from the stored props and
/// metadata JSON once per version.
class PostDetails {
  const PostDetails({
    this.props = const PostProps(),
    this.imageSizes = const {},
    this.preview,
    this.priority,
    this.customEmoji = const {},
    this.files = const [],
    this.integration = const IntegrationProps(),
    this.integrationError,
    this.permalink,
    this.ackRequested = false,
    this.acknowledgements = const [],
  });

  /// Pure: decodes [propsJson] and [metadataJson]; anything malformed is
  /// left out.
  factory PostDetails.decode(String? propsJson, String? metadataJson) {
    final props = _object(propsJson);
    final metadata = _object(metadataJson);
    final meta = metadata == null ? null : api.PostMetadata.fromJson(metadata);
    final sizes = <String, ImageSize>{
      for (final MapEntry(:key, :value) in (meta?.images ?? const {}).entries)
        if (value is Map<String, Object?>) key: ImageSize.fromJson(value),
    };
    LinkPreview? preview;
    PermalinkEmbed? permalink;
    final first = meta?.embeds.firstOrNull;
    if (first != null && first.type?.json == 'permalink') {
      final embed = PermalinkEmbed.fromJson(first.data ?? const {});
      if ((embed.postId?.isNotEmpty ?? false) && embed.post != null) {
        permalink = embed;
      }
    }
    if (first != null && first.type?.json == 'opengraph') {
      final og = OpenGraph.fromJson(first.data ?? const {});
      final image = og.images.firstOrNull;
      final imageUrl = image?.secureUrl?.isNotEmpty ?? false
          ? image!.secureUrl
          : image?.url;
      if ((og.title?.isNotEmpty ?? false) ||
          (og.description?.isNotEmpty ?? false)) {
        preview = LinkPreview(
          url: og.url ?? first.url ?? '',
          title: og.title ?? '',
          siteName: og.siteName ?? '',
          description: og.description ?? '',
          imageUrl: imageUrl,
          imageSize: imageUrl == null
              ? null
              : sizes[imageUrl] ??
                    ImageSize(width: image?.width, height: image?.height),
        );
      }
    }
    final (integration, integrationError) = _integration(props);
    return PostDetails(
      props: props == null ? const PostProps() : PostProps.fromJson(props),
      integration: integration,
      integrationError: integrationError,
      imageSizes: sizes,
      preview: preview,
      priority: switch (meta?.priority?.priority?.json) {
        'urgent' => PostPriorityLabel.urgent,
        'important' => PostPriorityLabel.important,
        _ => null,
      },
      customEmoji: {
        for (final e in meta?.emojis ?? const <api.Emoji>[])
          if (e.name != null && e.id != null) e.name!: e.id!,
      },
      files: [
        for (final f in meta?.files ?? const <api.FileInfo>[])
          if (f.id != null && f.deleteAt == null) PostFile.from(f),
      ],
      permalink: permalink,
      ackRequested: meta?.priority?.requestedAck ?? false,
      acknowledgements: [
        for (final a
            in meta?.acknowledgements ?? const <api.PostAcknowledgement>[])
          if (a.userId case final userId? when userId.isNotEmpty)
            (userId: userId, at: a.acknowledgedAt),
      ],
    );
  }

  final PostProps props;
  final Map<String, ImageSize> imageSizes;
  final LinkPreview? preview;
  final PostPriorityLabel? priority;

  /// Custom emoji the post uses, name → id.
  final Map<String, String> customEmoji;

  /// Attached files, in the order the author added them.
  final List<PostFile> files;

  /// Interactive content from an integration, as sent.
  final IntegrationProps integration;

  /// Why [integration] could not be read, when it could not.
  final String? integrationError;

  /// The message a permalink in this one points to, as the server
  /// embedded it.
  final PermalinkEmbed? permalink;

  /// The author asked readers to acknowledge the message.
  final bool ackRequested;
  final List<({String userId, DateTime? at})> acknowledgements;

  bool get fromWebhook => props.fromWebhook == 'true';
  bool get unsafeLinks => props.unsafeLinks == 'true';
}

enum PostPriorityLabel { urgent, important }

/// An OpenGraph preview the server attached to a post.
class LinkPreview {
  const LinkPreview({
    required this.url,
    required this.title,
    required this.siteName,
    required this.description,
    this.imageUrl,
    this.imageSize,
  });

  final String url;
  final String title;
  final String siteName;
  final String description;
  final String? imageUrl;
  final ImageSize? imageSize;
}

Map<String, Object?>? _object(String? json) {
  if (json == null || json.isEmpty) return null;
  try {
    final decoded = jsonDecode(json);
    return decoded is Map<String, Object?> ? decoded : null;
  } on FormatException {
    return null;
  }
}

/// Integrations nest blocks as deep as they like; one that cannot be read
/// shows as an error card instead of failing the post.
(IntegrationProps, String?) _integration(Map<String, Object?>? props) {
  if (props == null) return (const IntegrationProps(), null);
  try {
    return (IntegrationProps.fromJson(props), null);
  } on Object catch (e) {
    return (const IntegrationProps(), e.runtimeType.toString());
  }
}

final _withMmBlocks = Expando<(InteractiveContent?,)>();
final _withoutMmBlocks = Expando<(InteractiveContent?,)>();

/// The interactive content of [details], translated once per version; null
/// when there is none.
InteractiveContent? interactiveContentOf(
  PostDetails details, {
  required bool mmBlocks,
}) {
  if (details.integrationError case final error?) {
    return InteractiveContent(
      blocks: translationErrorBlocks(error),
      format: IntegrationFormat.attachment,
    );
  }
  final cache = mmBlocks ? _withMmBlocks : _withoutMmBlocks;
  return (cache[details] ??= (
    interactiveContent(details.integration, mmBlocks: mmBlocks),
  )).$1;
}

final _details = <(String, String?, String?), PostDetails>{};

/// [PostDetails.decode], kept for the most recently drawn posts.
PostDetails detailsFor(String postId, String? propsJson, String? metadataJson) {
  final key = (postId, propsJson, metadataJson);
  final hit = _details.remove(key);
  if (hit != null) return _details[key] = hit;
  final details = PostDetails.decode(propsJson, metadataJson);
  _details[key] = details;
  if (_details.length > 1000) _details.remove(_details.keys.first);
  return details;
}
