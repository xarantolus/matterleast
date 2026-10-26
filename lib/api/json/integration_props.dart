import 'package:json_annotation/json_annotation.dart';
import 'package:matterleast/api/json/lenient.dart';
import 'package:matterleast/api/json/post_extras.dart';

part 'integration_props.g.dart';

// The interactive content integrations put in post props, which the server
// stores without looking at it: Mattermost's own blocks (`mm_blocks`), Slack
// Block Kit (`blocks`), Adaptive Cards (`cards`) and message attachments
// (`attachments`). Shapes follow mattermost-mobile's
// `types/api/mm_blocks.d.ts` and its translation sources; one class per
// format holds the fields of every block type of that format.

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class IntegrationProps {
  const IntegrationProps({
    this.mmBlocks = const [],
    this.mmBlocksActions,
    this.blocks = const [],
    this.cards = const [],
    this.attachments = const [],
  });

  factory IntegrationProps.fromJson(Map<String, Object?> json) =>
      _$IntegrationPropsFromJson(json);

  @_MmBlocks()
  final List<MmBlockJson> mmBlocks;

  /// The cookie the server sealed for the post's `mm_blocks` actions.
  @LenientString()
  final String? mmBlocksActions;
  @_BlockKit()
  final List<BlockKitJson> blocks;
  @_Cards()
  final List<AdaptiveCardJson> cards;
  @AttachmentList()
  final List<Attachment> attachments;
}

/// One entry of `mm_blocks`, any of its types.
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class MmBlockJson {
  const MmBlockJson({
    this.type,
    this.text,
    this.isSubtle,
    this.size,
    this.url,
    this.altText,
    this.title,
    this.maxWidth,
    this.maxHeight,
    this.imageStyle,
    this.horizontalAlignment,
    this.items,
    this.columns,
    this.width,
    this.gap,
    this.content,
    this.header,
    this.collapsed,
    this.border,
    this.accentColor,
    this.flow,
    this.background,
    this.actionId,
    this.style,
    this.tooltip,
    this.disabled,
    this.query,
    this.cookie,
    this.placeholder,
    this.options = const [],
    this.initialOption,
    this.dataSource,
  });

  factory MmBlockJson.fromJson(Map<String, Object?> json) =>
      _$MmBlockJsonFromJson(json);

  @LenientString()
  final String? type;
  @LenientString()
  final String? text;
  @LenientBool()
  final bool? isSubtle;
  @LenientString()
  final String? size;
  @LenientString()
  final String? url;
  @LenientString()
  final String? altText;
  @LenientString()
  final String? title;

  /// For an image, pixels; for a container, a preset name.
  @_Scalar()
  final String? maxWidth;
  @_Scalar()
  final String? maxHeight;
  @LenientString()
  final String? imageStyle;
  @LenientString()
  final String? horizontalAlignment;

  /// Null when absent, so a block missing a required list can be told from
  /// an empty one.
  @_MmBlocksOrNull()
  final List<MmBlockJson>? items;
  @_MmBlocksOrNull()
  final List<MmBlockJson>? columns;
  @LenientString()
  final String? width;
  @LenientString()
  final String? gap;
  @_MmBlocksOrNull()
  final List<MmBlockJson>? content;
  @_MmBlocksOrNull()
  final List<MmBlockJson>? header;
  @LenientBool()
  final bool? collapsed;
  @LenientBool()
  final bool? border;
  @LenientString()
  final String? accentColor;
  @LenientString()
  final String? flow;
  @LenientString()
  final String? background;
  @LenientString()
  final String? actionId;
  @LenientString()
  final String? style;
  @LenientString()
  final String? tooltip;
  @LenientBool()
  final bool? disabled;
  @StringMap()
  final Map<String, String>? query;
  @LenientString()
  final String? cookie;
  @LenientString()
  final String? placeholder;
  @_Options()
  final List<SelectOptionJson> options;
  @LenientString()
  final String? initialOption;
  @LenientString()
  final String? dataSource;
}

@JsonSerializable(createToJson: false)
class SelectOptionJson {
  const SelectOptionJson({this.text, this.value});

  factory SelectOptionJson.fromJson(Map<String, Object?> json) =>
      _$SelectOptionJsonFromJson(json);

  /// Plain for `mm_blocks` and attachments, a text object in Block Kit.
  @SlackText()
  final String? text;
  @_Scalar()
  final String? value;
}

/// One Block Kit block or element (section accessory, actions element).
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class BlockKitJson {
  const BlockKitJson({
    this.type,
    this.text,
    this.fields = const [],
    this.accessory,
    this.elements = const [],
    this.imageUrl,
    this.altText,
    this.title,
    this.actionId,
    this.style,
    this.placeholder,
    this.options = const [],
  });

  factory BlockKitJson.fromJson(Map<String, Object?> json) =>
      _$BlockKitJsonFromJson(json);

  @LenientString()
  final String? type;

  /// A text object's text; a `markdown` block has it plain.
  @SlackText()
  final String? text;
  @_SlackTexts()
  final List<String> fields;
  @_BlockKitOne()
  final BlockKitJson? accessory;
  @_BlockKit()
  final List<BlockKitJson> elements;
  @LenientString()
  final String? imageUrl;
  @LenientString()
  final String? altText;
  @SlackText()
  final String? title;
  @LenientString()
  final String? actionId;
  @LenientString()
  final String? style;
  @SlackText()
  final String? placeholder;
  @_Options()
  final List<SelectOptionJson> options;
}

/// An Adaptive Card, or one of its elements, columns or actions.
@JsonSerializable(createToJson: false)
class AdaptiveCardJson {
  const AdaptiveCardJson({
    this.type,
    this.body = const [],
    this.actions = const [],
    this.text,
    this.isSubtle,
    this.size,
    this.items = const [],
    this.columns = const [],
    this.width,
    this.height,
    this.url,
    this.altText,
    this.style,
    this.horizontalAlignment,
    this.title,
    this.id,
  });

  factory AdaptiveCardJson.fromJson(Map<String, Object?> json) =>
      _$AdaptiveCardJsonFromJson(json);

  @LenientString()
  final String? type;
  @_Cards()
  final List<AdaptiveCardJson> body;
  @_Cards()
  final List<AdaptiveCardJson> actions;
  @LenientString()
  final String? text;
  @LenientBool()
  final bool? isSubtle;
  @LenientString()
  final String? size;
  @_Cards()
  final List<AdaptiveCardJson> items;
  @_Cards()
  final List<AdaptiveCardJson> columns;

  /// `auto`, `stretch`, a weight or pixels such as `80px`.
  @_Scalar()
  final String? width;
  @_Scalar()
  final String? height;
  @LenientString()
  final String? url;
  @LenientString()
  final String? altText;
  @LenientString()
  final String? style;
  @LenientString()
  final String? horizontalAlignment;
  @LenientString()
  final String? title;
  @LenientString()
  final String? id;
}

/// The body of `POST /posts/{id}/actions/{action_id}`.
@JsonSerializable(createFactory: false, includeIfNull: false)
class PostActionBody {
  const PostActionBody({
    required this.selectedOption,
    required this.integrationFormat,
    this.cookie,
    this.query,
  });

  @JsonKey(name: 'selected_option')
  final String selectedOption;
  final String? cookie;
  final Map<String, String>? query;
  @JsonKey(name: 'integration_format')
  final String integrationFormat;

  Map<String, Object?> toJson() => _$PostActionBodyToJson(this);
}

/// The answer to a post action.
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class PostActionAnswer {
  const PostActionAnswer({this.triggerId, this.gotoLocation});

  factory PostActionAnswer.fromJson(Map<String, Object?> json) =>
      _$PostActionAnswerFromJson(json);

  @LenientString()
  final String? triggerId;
  @LenientString()
  final String? gotoLocation;
}

List<T> _list<T>(Object? json, T Function(Map<String, Object?>) decode) =>
    json is List
    ? [
        for (final e in json)
          if (e is Map<String, Object?>) decode(e),
      ]
    : const [];

class _MmBlocks implements JsonConverter<List<MmBlockJson>, Object?> {
  const _MmBlocks();
  @override
  List<MmBlockJson> fromJson(Object? json) => _list(json, MmBlockJson.fromJson);
  @override
  Object? toJson(List<MmBlockJson> object) => throw UnsupportedError('decode');
}

class _MmBlocksOrNull implements JsonConverter<List<MmBlockJson>?, Object?> {
  const _MmBlocksOrNull();
  @override
  List<MmBlockJson>? fromJson(Object? json) =>
      json is List ? _list(json, MmBlockJson.fromJson) : null;
  @override
  Object? toJson(List<MmBlockJson>? object) => throw UnsupportedError('decode');
}

class _BlockKit implements JsonConverter<List<BlockKitJson>, Object?> {
  const _BlockKit();
  @override
  List<BlockKitJson> fromJson(Object? json) =>
      _list(json, BlockKitJson.fromJson);
  @override
  Object? toJson(List<BlockKitJson> object) => throw UnsupportedError('decode');
}

class _BlockKitOne implements JsonConverter<BlockKitJson?, Object?> {
  const _BlockKitOne();
  @override
  BlockKitJson? fromJson(Object? json) =>
      json is Map<String, Object?> ? BlockKitJson.fromJson(json) : null;
  @override
  Object? toJson(BlockKitJson? object) => throw UnsupportedError('decode');
}

class _Cards implements JsonConverter<List<AdaptiveCardJson>, Object?> {
  const _Cards();
  @override
  List<AdaptiveCardJson> fromJson(Object? json) =>
      _list(json, AdaptiveCardJson.fromJson);
  @override
  Object? toJson(List<AdaptiveCardJson> object) =>
      throw UnsupportedError('decode');
}

class _Options implements JsonConverter<List<SelectOptionJson>, Object?> {
  const _Options();
  @override
  List<SelectOptionJson> fromJson(Object? json) =>
      _list(json, SelectOptionJson.fromJson);
  @override
  Object? toJson(List<SelectOptionJson> object) =>
      throw UnsupportedError('decode');
}

/// Slack's text: a plain string or a text object `{type, text}`.
class SlackText implements JsonConverter<String?, Object?> {
  const SlackText();
  @override
  String? fromJson(Object? json) => switch (json) {
    final String s => s,
    {'text': final String s} => s,
    _ => null,
  };
  @override
  Object? toJson(String? object) => object;
}

class _SlackTexts implements JsonConverter<List<String>, Object?> {
  const _SlackTexts();
  @override
  List<String> fromJson(Object? json) => json is List
      ? [for (final e in json) ?const SlackText().fromJson(e)]
      : const [];
  @override
  Object? toJson(List<String> object) => object;
}

/// A map of strings; null when any value is not one.
class StringMap implements JsonConverter<Map<String, String>?, Object?> {
  const StringMap();
  @override
  Map<String, String>? fromJson(Object? json) {
    if (json is! Map<String, Object?>) return null;
    final out = <String, String>{};
    for (final MapEntry(:key, :value) in json.entries) {
      if (value is! String) return null;
      out[key] = value;
    }
    return out;
  }

  @override
  Object? toJson(Map<String, String>? object) => object;
}

class _Scalar implements JsonConverter<String?, Object?> {
  const _Scalar();
  @override
  String? fromJson(Object? json) =>
      json is String || json is num || json is bool ? '$json' : null;
  @override
  Object? toJson(String? object) => object;
}
