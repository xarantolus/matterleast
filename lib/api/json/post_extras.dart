import 'package:json_annotation/json_annotation.dart';
import 'package:matterleast/api/json/lenient.dart';

part 'post_extras.g.dart';

// Post props and embed data the OpenAPI spec leaves untyped (or, for message
// attachments, spells in the wrong case). Field names follow the server's Go
// models: `model/post.go`, `model/slack_attachment.go`,
// `model/post_metadata.go` and the OpenGraph library it embeds.

/// The props a post row reads.
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class PostProps {
  const PostProps({
    this.fromWebhook,
    this.fromBot,
    this.overrideUsername,
    this.overrideIconUrl,
    this.overrideIconEmoji,
    this.useUserIcon,
    this.unsafeLinks,
    this.attachments = const [],
    this.channelMentions = const {},
    this.username,
    this.addedUsername,
    this.removedUsername,
    this.oldHeader,
    this.newHeader,
    this.oldPurpose,
    this.newPurpose,
    this.oldDisplayname,
    this.newDisplayname,
  });

  factory PostProps.fromJson(Map<String, Object?> json) =>
      _$PostPropsFromJson(json);

  @LenientString()
  final String? fromWebhook;
  @LenientString()
  final String? fromBot;
  @LenientString()
  final String? overrideUsername;
  @LenientString()
  final String? overrideIconUrl;
  @LenientString()
  final String? overrideIconEmoji;
  @LenientString()
  final String? useUserIcon;
  @LenientString()
  final String? unsafeLinks;
  @_Attachments()
  final List<Attachment> attachments;
  @_ChannelMentions()
  final Map<String, String> channelMentions;
  @LenientString()
  final String? username;
  @LenientString()
  @JsonKey(name: 'addedUsername')
  final String? addedUsername;
  @LenientString()
  @JsonKey(name: 'removedUsername')
  final String? removedUsername;
  @LenientString()
  final String? oldHeader;
  @LenientString()
  final String? newHeader;
  @LenientString()
  final String? oldPurpose;
  @LenientString()
  final String? newPurpose;
  @LenientString()
  final String? oldDisplayname;
  @LenientString()
  final String? newDisplayname;
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class Attachment {
  const Attachment({
    this.fallback,
    this.color,
    this.pretext,
    this.authorName,
    this.authorLink,
    this.authorIcon,
    this.title,
    this.titleLink,
    this.text,
    this.fields = const [],
    this.imageUrl,
    this.thumbUrl,
    this.footer,
    this.footerIcon,
    this.actions = const [],
  });

  factory Attachment.fromJson(Map<String, Object?> json) =>
      _$AttachmentFromJson(json);

  @LenientString()
  final String? fallback;
  @LenientString()
  final String? color;
  @LenientString()
  final String? pretext;
  @LenientString()
  final String? authorName;
  @LenientString()
  final String? authorLink;
  @LenientString()
  final String? authorIcon;
  @LenientString()
  final String? title;
  @LenientString()
  final String? titleLink;
  @LenientString()
  final String? text;
  @_Fields()
  final List<AttachmentField> fields;
  @LenientString()
  final String? imageUrl;
  @LenientString()
  final String? thumbUrl;
  @LenientString()
  final String? footer;
  @LenientString()
  final String? footerIcon;
  @_Actions()
  final List<AttachmentAction> actions;
}

@JsonSerializable(createToJson: false)
class AttachmentField {
  const AttachmentField({this.title, this.value, this.short});

  factory AttachmentField.fromJson(Map<String, Object?> json) =>
      _$AttachmentFieldFromJson(json);

  @LenientString()
  final String? title;

  /// Usually text; integrations also send numbers.
  @_Scalar()
  final String? value;
  @LenientBool()
  final bool? short;
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class AttachmentAction {
  const AttachmentAction({this.id, this.name, this.type, this.style});

  factory AttachmentAction.fromJson(Map<String, Object?> json) =>
      _$AttachmentActionFromJson(json);

  @LenientString()
  final String? id;
  @LenientString()
  final String? name;

  /// `button` or `select`.
  @LenientString()
  final String? type;
  @LenientString()
  final String? style;
}

/// `metadata.embeds[].data` of an `opengraph` embed.
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class OpenGraph {
  const OpenGraph({
    this.url,
    this.title,
    this.description,
    this.siteName,
    this.images = const [],
  });

  factory OpenGraph.fromJson(Map<String, Object?> json) =>
      _$OpenGraphFromJson(json);

  @LenientString()
  final String? url;
  @LenientString()
  final String? title;
  @LenientString()
  final String? description;
  @LenientString()
  final String? siteName;
  @_Images()
  final List<OpenGraphImage> images;
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class OpenGraphImage {
  const OpenGraphImage({this.url, this.secureUrl, this.width, this.height});

  factory OpenGraphImage.fromJson(Map<String, Object?> json) =>
      _$OpenGraphImageFromJson(json);

  @LenientString()
  final String? url;
  @LenientString()
  final String? secureUrl;
  @LenientInt()
  final int? width;
  @LenientInt()
  final int? height;
}

/// `metadata.images[url]`: the size the server measured.
@JsonSerializable(createToJson: false)
class ImageSize {
  const ImageSize({this.width, this.height, this.format});

  factory ImageSize.fromJson(Map<String, Object?> json) =>
      _$ImageSizeFromJson(json);

  @LenientInt()
  final int? width;
  @LenientInt()
  final int? height;
  @LenientString()
  final String? format;
}

List<T> _objects<T>(Object? json, T Function(Map<String, Object?>) decode) =>
    json is List
    ? [
        for (final e in json)
          if (e is Map<String, Object?>) decode(e),
      ]
    : const [];

class _Attachments implements JsonConverter<List<Attachment>, Object?> {
  const _Attachments();
  @override
  List<Attachment> fromJson(Object? json) =>
      _objects(json, Attachment.fromJson);
  @override
  Object? toJson(List<Attachment> object) => throw UnsupportedError('decode');
}

class _Fields implements JsonConverter<List<AttachmentField>, Object?> {
  const _Fields();
  @override
  List<AttachmentField> fromJson(Object? json) =>
      _objects(json, AttachmentField.fromJson);
  @override
  Object? toJson(List<AttachmentField> object) =>
      throw UnsupportedError('decode');
}

class _Actions implements JsonConverter<List<AttachmentAction>, Object?> {
  const _Actions();
  @override
  List<AttachmentAction> fromJson(Object? json) =>
      _objects(json, AttachmentAction.fromJson);
  @override
  Object? toJson(List<AttachmentAction> object) =>
      throw UnsupportedError('decode');
}

class _Images implements JsonConverter<List<OpenGraphImage>, Object?> {
  const _Images();
  @override
  List<OpenGraphImage> fromJson(Object? json) =>
      _objects(json, OpenGraphImage.fromJson);
  @override
  Object? toJson(List<OpenGraphImage> object) =>
      throw UnsupportedError('decode');
}

/// `channel_mentions`: channel name → display name.
class _ChannelMentions implements JsonConverter<Map<String, String>, Object?> {
  const _ChannelMentions();
  @override
  Map<String, String> fromJson(Object? json) => json is Map<String, Object?>
      ? {
          for (final MapEntry(:key, :value) in json.entries)
            if (value is Map<String, Object?> &&
                value['display_name'] is String)
              key: value['display_name']! as String,
        }
      : const {};
  @override
  Object? toJson(Map<String, String> object) =>
      throw UnsupportedError('decode');
}

class _Scalar implements JsonConverter<String?, Object?> {
  const _Scalar();
  @override
  String? fromJson(Object? json) =>
      json is String || json is num || json is bool ? '$json' : null;
  @override
  Object? toJson(String? object) => object;
}
