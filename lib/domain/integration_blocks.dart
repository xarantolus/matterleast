import 'package:matterleast/api/json/integration_props.dart';
import 'package:matterleast/api/json/post_extras.dart';

// Interactive content from integrations, translated from the four formats
// Mattermost's apps render into one block model, as mattermost-mobile does
// in `components/block_renderer/translation/`.

/// The `integration_format` a post action names, by where the post's
/// content came from.
enum IntegrationFormat {
  attachment('attachment'),
  block('block'),
  card('card'),
  mmBlock('mm_block');

  const IntegrationFormat(this.json);
  final String json;
}

/// A button, menu choice or inline `mmaction://` link of an integration's
/// post, to send to the server.
typedef PostActionRequest = ({
  String postId,
  String actionId,
  String? cookie,
  String selectedOption,
  Map<String, String>? query,
  IntegrationFormat format,
});

enum BlockGap { none, small, medium, large, xlarge }

/// Size presets loosely following Adaptive Cards; `stretch` is a message
/// attachment's image.
enum ImageSizePreset { auto, xsmall, small, medium, large, stretch }

enum ImageAlignment { left, center, right }

/// How tall a container may grow before it is cut with "Show more".
enum ContainerHeight { none, small, medium, large }

/// Where a menu's choices come from.
enum SelectSource { options, users, channels }

sealed class IntegrationBlock {
  const IntegrationBlock();
}

/// Markdown.
final class TextBlock extends IntegrationBlock {
  const TextBlock(this.text, {this.subtle = false, this.small = false});
  final String text;
  final bool subtle;
  final bool small;
}

final class ImageBlock extends IntegrationBlock {
  const ImageBlock({
    required this.url,
    this.altText = '',
    this.title,
    this.size = ImageSizePreset.stretch,
    this.maxWidth,
    this.maxHeight,
    this.person = false,
    this.alignment = ImageAlignment.left,
  });
  final String url;
  final String altText;
  final String? title;
  final ImageSizePreset size;
  final double? maxWidth;
  final double? maxHeight;

  /// Cropped round, like a profile picture.
  final bool person;
  final ImageAlignment alignment;
}

final class DividerBlock extends IntegrationBlock {
  const DividerBlock();
}

final class ContainerBlock extends IntegrationBlock {
  const ContainerBlock(
    this.content, {
    this.border = false,
    this.accent,
    this.horizontal = false,
    this.gap,
    this.gray = false,
    this.maxHeight = ContainerHeight.none,
  });
  final List<IntegrationBlock> content;
  final bool border;

  /// The bar on the left: `default`, `primary`, `good`, `warning`,
  /// `danger` or a colour such as `#2389d7`.
  final String? accent;
  final bool horizontal;
  final BlockGap? gap;
  final bool gray;
  final ContainerHeight maxHeight;
}

final class ColumnSetBlock extends IntegrationBlock {
  const ColumnSetBlock(this.columns, {this.gap});
  final List<ColumnBlock> columns;
  final BlockGap? gap;
}

final class ColumnBlock extends IntegrationBlock {
  const ColumnBlock(this.items, {this.stretch = false, this.gap});
  final List<IntegrationBlock> items;

  /// Takes the room left; otherwise as wide as its content.
  final bool stretch;
  final BlockGap? gap;
}

final class CollapsibleBlock extends IntegrationBlock {
  const CollapsibleBlock({
    required this.header,
    required this.content,
    this.collapsed = true,
  });
  final List<IntegrationBlock> header;
  final List<IntegrationBlock> content;
  final bool collapsed;
}

final class ButtonBlock extends IntegrationBlock {
  const ButtonBlock({
    required this.text,
    required this.actionId,
    this.style,
    this.tooltip,
    this.disabled = false,
    this.query,
    this.cookie,
  });
  final String text;
  final String actionId;

  /// `primary`, `danger`, `good`, `success`, `warning` or a `#rrggbb`
  /// colour; null for the default look.
  final String? style;
  final String? tooltip;
  final bool disabled;
  final Map<String, String>? query;

  /// A message attachment's own cookie for this action.
  final String? cookie;
}

typedef SelectOption = ({String text, String value});

final class SelectBlock extends IntegrationBlock {
  const SelectBlock({
    required this.actionId,
    required this.placeholder,
    this.options = const [],
    this.initialOption,
    this.disabled = false,
    this.source = SelectSource.options,
    this.query,
    this.cookie,
  });
  final String actionId;
  final String placeholder;
  final List<SelectOption> options;
  final String? initialOption;
  final bool disabled;
  final SelectSource source;
  final Map<String, String>? query;
  final String? cookie;
}

/// What a post's integration content shows, and how its actions are sent.
class InteractiveContent {
  const InteractiveContent({
    required this.blocks,
    required this.format,
    this.cookie,
  });
  final List<IntegrationBlock> blocks;
  final IntegrationFormat format;

  /// The post's cookie for actions of formats other than attachments.
  final String? cookie;

  /// The cookie a post action of [block] sends.
  String? cookieFor(IntegrationBlock block) {
    if (format != IntegrationFormat.attachment) return cookie;
    return switch (block) {
      ButtonBlock(:final cookie) || SelectBlock(:final cookie) => cookie,
      _ => null,
    };
  }
}

const translationErrorTitle =
    'This interactive message could not be displayed.';

/// Pure: the card shown in place of content that could not be read.
List<IntegrationBlock> translationErrorBlocks(String detail) => [
  ContainerBlock(
    [
      const TextBlock('**$translationErrorTitle**'),
      TextBlock(detail, subtle: true),
    ],
    accent: 'danger',
    border: true,
  ),
];

/// Pure: the interactive content of a post's props, from the first format
/// present in the order `mm_blocks` (only with [mmBlocks], the server's
/// `FeatureFlagMmBlocksEnabled`), `blocks`, `cards`, `attachments`; null
/// when there is none.
InteractiveContent? interactiveContent(
  IntegrationProps props, {
  required bool mmBlocks,
}) {
  final (format, blocks) = switch (props) {
    _ when mmBlocks && props.mmBlocks.isNotEmpty => (
      IntegrationFormat.mmBlock,
      translateMmBlocks(props.mmBlocks),
    ),
    _ when props.blocks.isNotEmpty => (
      IntegrationFormat.block,
      translateBlockKit(props.blocks),
    ),
    _ when props.cards.isNotEmpty => (
      IntegrationFormat.card,
      translateAdaptiveCards(props.cards),
    ),
    _ when props.attachments.isNotEmpty => (
      IntegrationFormat.attachment,
      translateAttachments(props.attachments),
    ),
    _ => (null, const <IntegrationBlock>[]),
  };
  if (format == null) return null;
  return InteractiveContent(
    blocks: applyBlockLimits(blocks),
    format: format,
    cookie: props.mmBlocksActions,
  );
}

// --- limits -------------------------------------------------------------

const maxBlockDepth = 32;
const maxBlocks = 100;
const maxMarkdownText = 16000;

/// Pure: [blocks] cut to [maxBlockDepth] levels, [maxBlocks] blocks and
/// [maxMarkdownText] characters of text; containers left empty go.
List<IntegrationBlock> applyBlockLimits(List<IntegrationBlock> blocks) =>
    _Limiter().blocks(blocks, 1);

class _Limiter {
  var _count = 0;
  var _text = 0;

  List<IntegrationBlock> blocks(List<IntegrationBlock> blocks, int depth) {
    if (depth > maxBlockDepth) return const [];
    final out = <IntegrationBlock>[];
    for (final block in blocks) {
      if (_count >= maxBlocks) break;
      if (_block(block, depth) case final kept?) out.add(kept);
    }
    return out;
  }

  String? _limitText(String text) {
    final left = maxMarkdownText - _text;
    if (left <= 0) return null;
    final kept = text.length <= left ? text : text.substring(0, left);
    _text += kept.length;
    return kept;
  }

  IntegrationBlock? _block(IntegrationBlock block, int depth) {
    _count++;
    final kept = _limited(block, depth);
    if (kept == null) _count--;
    return kept;
  }

  IntegrationBlock? _limited(IntegrationBlock block, int depth) {
    switch (block) {
      case TextBlock(:final text, :final subtle, :final small):
        final kept = _limitText(text);
        if (kept == null || kept.isEmpty) return null;
        return identical(kept, text)
            ? block
            : TextBlock(kept, subtle: subtle, small: small);
      case ButtonBlock():
        final kept = _limitText(block.text);
        if (kept == null || kept.isEmpty) return null;
        return identical(kept, block.text)
            ? block
            : ButtonBlock(
                text: kept,
                actionId: block.actionId,
                style: block.style,
                tooltip: block.tooltip,
                disabled: block.disabled,
                query: block.query,
                cookie: block.cookie,
              );
      case ContainerBlock():
        final content = blocks(block.content, depth + 1);
        if (content.isEmpty) return null;
        return ContainerBlock(
          content,
          border: block.border,
          accent: block.accent,
          horizontal: block.horizontal,
          gap: block.gap,
          gray: block.gray,
          maxHeight: block.maxHeight,
        );
      case ColumnBlock():
        final items = blocks(block.items, depth + 1);
        if (items.isEmpty) return null;
        return ColumnBlock(items, stretch: block.stretch, gap: block.gap);
      case ColumnSetBlock():
        final columns = blocks(block.columns, depth + 1).cast<ColumnBlock>();
        if (columns.isEmpty) return null;
        return ColumnSetBlock(columns, gap: block.gap);
      case CollapsibleBlock():
        final header = blocks(block.header, depth + 1);
        final content = blocks(block.content, depth + 1);
        if (header.isEmpty || content.isEmpty) return null;
        return CollapsibleBlock(
          header: header,
          content: content,
          collapsed: block.collapsed,
        );
      case ImageBlock() || DividerBlock() || SelectBlock():
        return block;
    }
  }
}

// --- shared -------------------------------------------------------------

const _buttonStyles = {
  'default',
  'primary',
  'danger',
  'good',
  'success',
  'warning',
};
final _hexColour = RegExp(r'^#(?:[0-9a-fA-F]{3}){1,2}$');

/// Pure: a button style kept when it is a known name or a hex colour.
String? buttonStyle(String? style) =>
    style != null &&
        (_buttonStyles.contains(style) || _hexColour.hasMatch(style))
    ? style
    : null;

const _safeSchemes = {'http', 'https', 'mailto', 'tel', 'ftp'};

/// Whether a link from an integration may be written as a markdown link.
bool _safeUrl(String url) {
  if (url.startsWith('/')) return true;
  final uri = Uri.tryParse(url.trim());
  return uri != null && _safeSchemes.contains(uri.scheme.toLowerCase());
}

T? _named<T extends Enum>(List<T> values, String? name) {
  for (final v in values) {
    if (v.name == name) return v;
  }
  return null;
}

bool _nonEmpty(String? s) => s != null && s.trim().isNotEmpty;

// --- mm_blocks ----------------------------------------------------------

/// Pure: native `mm_blocks`; entries that break the schema are left out.
List<IntegrationBlock> translateMmBlocks(List<MmBlockJson> raw) => [
  for (final r in raw) ?_mmBlock(r, 1),
];

List<IntegrationBlock> _mmChildren(List<MmBlockJson> raw, int depth) => [
  for (final r in raw) ?_mmBlock(r, depth + 1),
];

IntegrationBlock? _mmBlock(MmBlockJson r, int depth) {
  if (depth > maxBlockDepth) return null;
  switch (r.type) {
    case 'text':
      final text = r.text;
      if (text == null) return null;
      if (r.size != null && r.size != 'small' && r.size != 'default') {
        return null;
      }
      return TextBlock(
        text,
        subtle: r.isSubtle ?? false,
        small: r.size == 'small',
      );
    case 'divider':
      return const DividerBlock();
    case 'button':
      if (!_nonEmpty(r.text) || !_nonEmpty(r.actionId)) return null;
      final style = buttonStyle(r.style);
      return ButtonBlock(
        text: r.text!,
        actionId: r.actionId!,
        style: style == 'default' ? null : style,
        tooltip: r.tooltip,
        disabled: r.disabled ?? false,
        query: r.query,
        cookie: r.cookie,
      );
    case 'static_select':
      if (!_nonEmpty(r.actionId) || !_nonEmpty(r.placeholder)) return null;
      return SelectBlock(
        actionId: r.actionId!,
        placeholder: r.placeholder!,
        options: _options(r.options),
        initialOption: r.initialOption,
        disabled: r.disabled ?? false,
        source: _source(r.dataSource),
        query: r.query,
        cookie: r.cookie,
      );
    case 'image':
      final url = r.url;
      if (url == null || url.isEmpty) return null;
      final size = r.size == null
          ? ImageSizePreset.stretch
          : _named(ImageSizePreset.values, r.size);
      if (size == null) return null;
      return ImageBlock(
        url: url,
        altText: r.altText ?? '',
        title: r.title,
        size: size,
        maxWidth: _pixels(r.maxWidth),
        maxHeight: _pixels(r.maxHeight),
        person: r.imageStyle == 'person',
        alignment:
            _named(ImageAlignment.values, r.horizontalAlignment) ??
            ImageAlignment.left,
      );
    case 'column':
      return _mmColumn(r, depth);
    case 'column_set':
      final raw = r.columns;
      if (raw == null) return null;
      final columns = <ColumnBlock>[];
      for (final c in raw) {
        if (c.type != 'column') return null;
        final column = _mmColumn(c, depth + 1);
        if (column == null) return null;
        columns.add(column);
      }
      if (columns.isEmpty) return null;
      return ColumnSetBlock(columns, gap: _named(BlockGap.values, r.gap));
    case 'container':
      final raw = r.content;
      if (raw == null) return null;
      final content = _mmChildren(raw, depth);
      if (content.isEmpty) return null;
      final height = r.maxHeight == null
          ? ContainerHeight.none
          : _named(ContainerHeight.values, r.maxHeight);
      if (height == null) return null;
      return ContainerBlock(
        content,
        border: r.border ?? false,
        accent: r.accentColor,
        horizontal: r.flow == 'horizontal',
        gap: _named(BlockGap.values, r.gap),
        gray: r.background == 'gray',
        maxHeight: height,
      );
    case 'collapsible':
      final header = _mmChildren(r.header ?? const [], depth);
      final content = _mmChildren(r.content ?? const [], depth);
      if (header.isEmpty || content.isEmpty) return null;
      return CollapsibleBlock(
        header: header,
        content: content,
        collapsed: r.collapsed ?? true,
      );
    default:
      return null;
  }
}

ColumnBlock? _mmColumn(MmBlockJson r, int depth) {
  final raw = r.items;
  if (raw == null) return null;
  final items = _mmChildren(raw, depth);
  if (items.isEmpty) return null;
  return ColumnBlock(
    items,
    stretch: r.width == 'stretch',
    gap: _named(BlockGap.values, r.gap),
  );
}

List<SelectOption> _options(List<SelectOptionJson> raw) => [
  for (final o in raw)
    if (_nonEmpty(o.text) && _nonEmpty(o.value))
      (text: o.text!, value: o.value!),
];

SelectSource _source(String? dataSource) => switch (dataSource) {
  'users' => SelectSource.users,
  'channels' => SelectSource.channels,
  _ => SelectSource.options,
};

final _pxValue = RegExp(r'^(\d+(?:\.\d+)?)(px)?$', caseSensitive: false);

/// Pixels from `80`, `80.5` or `80px`; null for anything else.
double? _pixels(String? value) {
  final match = _pxValue.firstMatch(value?.trim() ?? '');
  if (match == null) return null;
  final px = double.parse(match[1]!);
  return px > 0 ? px.roundToDouble() : null;
}

// --- Block Kit ----------------------------------------------------------

/// Pure: Slack Block Kit `section`, `header`, `markdown`, `image`, `divider`
/// and `actions`; other blocks are left out.
List<IntegrationBlock> translateBlockKit(List<BlockKitJson> raw) => [
  for (final b in raw) ?_blockKit(b),
];

IntegrationBlock? _blockKit(BlockKitJson b) => switch (b.type) {
  'section' => _section(b),
  'header' when _nonEmpty(b.text) => TextBlock('# ${b.text}'),
  'markdown' when _nonEmpty(b.text) => TextBlock(b.text!),
  'divider' => const DividerBlock(),
  'image' => _blockKitImage(b, ImageSizePreset.large),
  'actions' => _blockKitActions(b.elements),
  _ => null,
};

IntegrationBlock? _section(BlockKitJson b) {
  final text = _nonEmpty(b.text) ? b.text : null;
  final fields = _pairs(b.fields);
  if (text == null && fields.isEmpty) return null;
  final main = <IntegrationBlock>[
    ?(text == null ? null : TextBlock(text)),
    ...fields,
  ];
  final accessory = switch (b.accessory) {
    final a? => _accessory(a),
    null => null,
  };
  if (accessory == null) return ContainerBlock(main);
  return ContainerBlock([
    ColumnSetBlock([
      ColumnBlock(main, stretch: true),
      ColumnBlock([accessory]),
    ]),
  ]);
}

/// Section fields, two to a row.
List<IntegrationBlock> _pairs(List<String> fields) {
  final texts = [
    for (final f in fields)
      if (f.isNotEmpty) f,
  ];
  return [
    for (var i = 0; i < texts.length; i += 2)
      if (i + 1 < texts.length)
        ColumnSetBlock([
          ColumnBlock([TextBlock(texts[i])], stretch: true),
          ColumnBlock([TextBlock(texts[i + 1])], stretch: true),
        ])
      else
        TextBlock(texts[i]),
  ];
}

IntegrationBlock? _accessory(BlockKitJson a) => switch (a.type) {
  'button' when _nonEmpty(a.text) && _nonEmpty(a.actionId) => ButtonBlock(
    text: a.text!,
    actionId: a.actionId!,
    style: buttonStyle(a.style),
  ),
  'image' => _blockKitImage(a, ImageSizePreset.small),
  _ => null,
};

IntegrationBlock? _blockKitImage(BlockKitJson b, ImageSizePreset size) {
  if (!_nonEmpty(b.imageUrl) || !_nonEmpty(b.altText)) return null;
  return ImageBlock(
    url: b.imageUrl!,
    altText: b.altText!,
    title: _nonEmpty(b.title) ? b.title : null,
    size: size,
  );
}

IntegrationBlock? _blockKitActions(List<BlockKitJson> elements) {
  final content = <IntegrationBlock>[
    for (final e in elements)
      if (e.type == 'button' && _nonEmpty(e.text) && _nonEmpty(e.actionId))
        ButtonBlock(
          text: e.text!,
          actionId: e.actionId!,
          style: buttonStyle(e.style),
        )
      else if (e.type == 'static_select' &&
          _nonEmpty(e.placeholder) &&
          _nonEmpty(e.actionId) &&
          _options(e.options).isNotEmpty)
        SelectBlock(
          actionId: e.actionId!,
          placeholder: e.placeholder!,
          options: _options(e.options),
        ),
  ];
  return content.isEmpty ? null : ContainerBlock(content, horizontal: true);
}

// --- Adaptive Cards -----------------------------------------------------

/// Pure: Adaptive Cards' `TextBlock`, `Image`, `Container`, `ColumnSet` and
/// `ActionSet`, and a card's `Action.Submit` actions.
List<IntegrationBlock> translateAdaptiveCards(List<AdaptiveCardJson> cards) {
  final out = <IntegrationBlock>[];
  for (final card in cards) {
    if (card.type != 'AdaptiveCard') continue;
    out.addAll([for (final item in card.body) ?_cardItem(item, 1)]);
    if (_cardActions(card.actions) case final actions?) out.add(actions);
  }
  return out;
}

IntegrationBlock? _cardItem(AdaptiveCardJson i, int depth) {
  if (depth > maxBlockDepth) return null;
  List<IntegrationBlock> children(List<AdaptiveCardJson> raw) => [
    for (final r in raw) ?_cardItem(r, depth + 1),
  ];
  switch (i.type) {
    case 'TextBlock':
      final text = i.text;
      if (text == null || text.isEmpty) return null;
      return TextBlock(
        text,
        subtle: i.isSubtle ?? false,
        small: i.size == 'Small',
      );
    case 'Container':
      final items = children(i.items);
      return items.isEmpty ? null : ContainerBlock(items);
    case 'ColumnSet':
      final columns = [
        for (final c in i.columns)
          ColumnBlock(children(c.items), stretch: c.width == 'stretch'),
      ];
      return columns.isEmpty ? null : ColumnSetBlock(columns);
    case 'Image':
      final url = i.url;
      if (url == null || url.isEmpty) return null;
      return ImageBlock(
        url: url,
        altText: i.altText ?? '',
        size:
            _named(ImageSizePreset.values, i.size?.toLowerCase()) ??
            ImageSizePreset.stretch,
        maxWidth: _pixels(i.width),
        maxHeight: _pixels(i.height),
        person: i.style == 'person',
        alignment:
            _named(
              ImageAlignment.values,
              i.horizontalAlignment?.toLowerCase(),
            ) ??
            ImageAlignment.left,
      );
    case 'ActionSet':
      return _cardActions(i.actions);
    default:
      return null;
  }
}

IntegrationBlock? _cardActions(List<AdaptiveCardJson> actions) {
  final content = <IntegrationBlock>[
    for (final a in actions)
      if (a.type == 'Action.Submit' && _nonEmpty(a.title) && _nonEmpty(a.id))
        ButtonBlock(
          text: a.title!,
          actionId: a.id!,
          style: switch (a.style) {
            'positive' => 'primary',
            'destructive' => 'danger',
            _ => null,
          },
        ),
  ];
  return content.isEmpty ? null : ContainerBlock(content, horizontal: true);
}

// --- message attachments ------------------------------------------------

const _authorIconSize = 20.0;
const _footerIconSize = 16.0;

/// Pure: message attachments as a bordered container each, behind their
/// pretext: author, title, text, image, fields, footer, a thumbnail beside
/// them, then the buttons and menus.
List<IntegrationBlock> translateAttachments(List<Attachment> attachments) {
  final out = <IntegrationBlock>[];
  for (final a in attachments) {
    final items = <IntegrationBlock>[?_author(a)];
    if (_nonEmpty(a.title)) {
      final link = a.titleLink;
      items.add(
        TextBlock(
          link != null && link.isNotEmpty && _safeUrl(link)
              ? '**[${a.title}]($link)**'
              : '**${a.title}**',
        ),
      );
    }
    final body = <IntegrationBlock>[
      if (_nonEmpty(a.text)) TextBlock(a.text!),
      if (_nonEmpty(a.imageUrl))
        ImageBlock(
          url: a.imageUrl!,
          altText: 'Attachment image',
          size: ImageSizePreset.medium,
        ),
      ?_fields(a.fields),
      ?_footer(a),
    ];
    final thumb = a.thumbUrl;
    if (thumb != null && thumb.isNotEmpty) {
      items.add(
        ColumnSetBlock([
          ColumnBlock(
            body.isEmpty ? const [TextBlock('\u200b')] : body,
            stretch: true,
          ),
          ColumnBlock([
            ImageBlock(
              url: thumb,
              altText: 'Attachment image',
              size: ImageSizePreset.small,
            ),
          ]),
        ]),
      );
    } else {
      items.addAll(body);
    }
    if (_attachmentActions(a.actions) case final actions?) items.add(actions);
    if (_nonEmpty(a.pretext)) out.add(TextBlock(a.pretext!));
    if (items.isNotEmpty) {
      final colour = a.color?.trim() ?? '';
      out.add(
        ContainerBlock(
          items,
          border: true,
          accent: colour.isEmpty ? null : colour,
        ),
      );
    }
  }
  return out;
}

IntegrationBlock? _author(Attachment a) {
  final name = a.authorName;
  final link = a.authorLink;
  final pieces = <IntegrationBlock>[
    if (_nonEmpty(a.authorIcon))
      ImageBlock(
        url: a.authorIcon!,
        altText: 'Attachment author icon',
        size: ImageSizePreset.auto,
        maxWidth: _authorIconSize,
        maxHeight: _authorIconSize,
      ),
    if (name != null && name.isNotEmpty)
      TextBlock(
        link != null && link.isNotEmpty && _safeUrl(link)
            ? '[$name]($link)'
            : name,
      ),
  ];
  return switch (pieces) {
    [] => null,
    [final one] => one,
    _ => ContainerBlock(pieces, horizontal: true, gap: BlockGap.small),
  };
}

IntegrationBlock? _footer(Attachment a) {
  final footer = a.footer;
  if (footer == null || footer.trim().isEmpty) return null;
  final text = TextBlock(footer, subtle: true, small: true);
  if (!_nonEmpty(a.footerIcon)) return text;
  return ContainerBlock(
    [
      ImageBlock(
        url: a.footerIcon!,
        altText: 'Attachment footer icon',
        size: ImageSizePreset.auto,
        maxWidth: _footerIconSize,
        maxHeight: _footerIconSize,
      ),
      text,
    ],
    horizontal: true,
    gap: BlockGap.small,
  );
}

IntegrationBlock? _fields(List<AttachmentField> fields) {
  final parsed = [
    for (final f in fields)
      if (f.value case final value? when value.isNotEmpty)
        (title: f.title?.trim() ?? '', value: value, short: f.short ?? false),
  ];
  if (parsed.isEmpty) return null;
  List<IntegrationBlock> blocks(({String title, String value, bool short}) f) =>
      [if (f.title.isNotEmpty) TextBlock('**${f.title}**'), TextBlock(f.value)];
  IntegrationBlock whole(({String title, String value, bool short}) f) =>
      ContainerBlock(blocks(f), gap: BlockGap.none);
  final content = <IntegrationBlock>[];
  ({String title, String value, bool short})? pending;
  for (final field in parsed) {
    if (field.short) {
      if (pending == null) {
        pending = field;
        continue;
      }
      content.add(
        ColumnSetBlock([
          ColumnBlock(blocks(pending), stretch: true, gap: BlockGap.none),
          ColumnBlock(blocks(field), stretch: true, gap: BlockGap.none),
        ]),
      );
      pending = null;
    } else {
      if (pending != null) content.add(whole(pending));
      pending = null;
      content.add(whole(field));
    }
  }
  if (pending != null) content.add(whole(pending));
  return ContainerBlock(content, gap: BlockGap.medium);
}

IntegrationBlock? _attachmentActions(List<AttachmentAction> actions) {
  final content = <IntegrationBlock>[];
  for (final a in actions) {
    final id = a.id;
    if (id == null || id.isEmpty) continue;
    if (a.type == 'select') {
      final source = _source(a.dataSource);
      final options = [
        for (final o in a.options)
          if (_nonEmpty(o.text) && _nonEmpty(o.value))
            (text: o.text!, value: o.value!),
      ];
      if (source == SelectSource.options && options.isEmpty) continue;
      content.add(
        SelectBlock(
          actionId: id,
          placeholder: a.name ?? '',
          options: options,
          initialOption: _nonEmpty(a.defaultOption) ? a.defaultOption : null,
          disabled: a.disabled ?? false,
          source: source,
          cookie: _nonEmpty(a.cookie) ? a.cookie : null,
        ),
      );
    } else {
      final name = a.name;
      if (name == null || name.isEmpty) continue;
      content.add(
        ButtonBlock(
          text: name,
          actionId: id,
          style: buttonStyle(a.style),
          tooltip: _nonEmpty(a.tooltip) ? a.tooltip : null,
          disabled: a.disabled ?? false,
          cookie: _nonEmpty(a.cookie) ? a.cookie : null,
        ),
      );
    }
  }
  return content.isEmpty
      ? null
      : ContainerBlock(content, horizontal: true, gap: BlockGap.medium);
}

// --- inline actions -----------------------------------------------------

/// A markdown link `mmaction://<action id>?<query>` in an integration's
/// text, which runs a post action instead of opening anything.
typedef InlineAction = ({String actionId, Map<String, String> query});

final _actionId = RegExp(r'^[A-Za-z0-9]+$');
const _maxInlineQuery = 2048;

bool isInlineActionLink(String href) => href.startsWith('mmaction://');

/// Pure: the action an `mmaction://` link runs; null for any other link or
/// one that breaks the server's rules.
InlineAction? parseInlineAction(String href) {
  if (!isInlineActionLink(href)) return null;
  final rest = href.substring('mmaction://'.length);
  final id = rest.split(RegExp('[/?#]')).first;
  if (!_actionId.hasMatch(id)) return null;
  final start = rest.indexOf('?');
  final raw = start < 0 ? '' : rest.substring(start + 1).split('#').first;
  if (raw.length > _maxInlineQuery) return null;
  try {
    return (actionId: id, query: Uri.splitQueryString(raw));
  } on ArgumentError {
    return null;
  }
}
