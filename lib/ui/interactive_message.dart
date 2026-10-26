import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/json/post_extras.dart';
import 'package:matterleast/data/images/image_rules.dart';
import 'package:matterleast/domain/integration_blocks.dart';
import 'package:matterleast/domain/post_details.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/domain/quick_switch.dart';
import 'package:matterleast/screens/search/switch_picker.dart';
import 'package:matterleast/ui/markdown/image_box.dart';
import 'package:matterleast/ui/markdown/inline_actions.dart';
import 'package:matterleast/ui/markdown/post_body.dart';
import 'package:matterleast/ui/markdown/post_environment.dart';
import 'package:matterleast/ui/markdown/show_more.dart';
import 'package:matterleast/ui/tokens.dart';

const _good = Color(0xFF339970);
const _warning = Color(0xFFCC8F00);

/// Pure: the colour a container's bar or a button's style names: `#rgb`,
/// `#rrggbb`, or `good`, `success`, `warning`, `danger`; null for `primary`,
/// `default` and anything else, which the theme decides.
Color? namedColour(String? value) {
  final v = value?.trim().toLowerCase() ?? '';
  switch (v) {
    case 'good' || 'success':
      return _good;
    case 'warning':
      return _warning;
    case 'danger':
      return const Color(0xFFD24B4E);
  }
  var hex = v.startsWith('#') ? v.substring(1) : v;
  if (hex.length == 3) hex = [for (final c in hex.split('')) '$c$c'].join();
  if (hex.length != 6) return null;
  final rgb = int.tryParse(hex, radix: 16);
  return rgb == null ? null : Color(0xFF000000 | rgb);
}

double _gap(BlockGap? gap) => switch (gap ?? BlockGap.medium) {
  BlockGap.none => 0,
  BlockGap.small => 8,
  BlockGap.medium => 12,
  BlockGap.large => 16,
  BlockGap.xlarge => 20,
};

double? _height(ContainerHeight height) => switch (height) {
  ContainerHeight.none => null,
  ContainerHeight.small => 160,
  ContainerHeight.medium => 280,
  ContainerHeight.large => 420,
};

/// Image size presets as upstream draws them; `auto` has no cap.
(double, double)? _caps(ImageSizePreset size) => switch (size) {
  ImageSizePreset.auto => null,
  ImageSizePreset.xsmall => (108, 64),
  ImageSizePreset.small => (204, 120),
  ImageSizePreset.medium => (320, 184),
  ImageSizePreset.large => (428, 240),
  ImageSizePreset.stretch => (500, 350),
};

/// Pure: the box an integration's image takes before it loads. A measured
/// image keeps its aspect ratio inside the caps; an unmeasured one gets the
/// caps (4:3 when only a width is known), so nothing moves when it arrives.
Size integrationImageBox(
  ImageBlock block, {
  required ImageSize? measured,
  required double maxWidth,
  required double screenHeight,
}) {
  final caps = _caps(block.size);
  final capWidth = block.maxWidth ?? caps?.$1;
  final capHeight = block.maxHeight ?? caps?.$2;
  final width = capWidth == null || capWidth > maxWidth ? maxWidth : capWidth;
  final height = capHeight ?? screenHeight * 0.45;
  final box = measured == null
      ? null
      : imageBox(
          measuredWidth: measured.width,
          measuredHeight: measured.height,
          maxWidth: width,
          maxHeight: height,
        );
  if (box != null) return box;
  if (block.maxWidth != null && block.maxHeight != null) {
    return Size(width, height);
  }
  final h = width * 0.75;
  return Size(width, h < height ? h : height);
}

/// An integration's interactive content: one renderer for message
/// attachments, Block Kit, Adaptive Cards and Mattermost's blocks.
class InteractiveMessage extends StatelessWidget {
  const InteractiveMessage({
    required this.postId,
    required this.content,
    required this.keyPrefix,
    this.imageSizes = const {},
    super.key,
  });

  final String postId;
  final InteractiveContent content;

  /// Distinguishes this post version's texts in the parse cache.
  final String keyPrefix;
  final Map<String, ImageSize> imageSizes;

  @override
  Widget build(BuildContext context) => InlineActions(
    postId: postId,
    format: content.format,
    cookie: content.cookie,
    child: _Scope(
      message: this,
      child: Padding(
        padding: const EdgeInsets.only(top: Spacing.xs),
        child: _Blocks(blocks: content.blocks, path: ''),
      ),
    ),
  );
}

/// What every block below needs from the message it belongs to.
class _Scope extends InheritedWidget {
  const _Scope({required this.message, required super.child});

  final InteractiveMessage message;

  static InteractiveMessage of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_Scope>()!.message;

  @override
  bool updateShouldNotify(_Scope old) => message != old.message;
}

class _Blocks extends StatelessWidget {
  const _Blocks({
    required this.blocks,
    required this.path,
    this.horizontal = false,
    this.gap,
    this.fill = true,
  });

  final List<IntegrationBlock> blocks;
  final String path;
  final bool horizontal;
  final BlockGap? gap;

  /// Stretches the blocks of a vertical flow to its width; otherwise the
  /// flow is as wide as its widest block.
  final bool fill;

  @override
  Widget build(BuildContext context) {
    final children = [
      for (final (i, b) in blocks.indexed) _Block(block: b, path: '$path/$i'),
    ];
    final space = _gap(gap);
    if (horizontal) {
      return Wrap(
        spacing: space,
        runSpacing: space,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: children,
      );
    }
    return Column(
      crossAxisAlignment: fill
          ? CrossAxisAlignment.stretch
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: space,
      children: children,
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.block, required this.path});

  final IntegrationBlock block;
  final String path;

  @override
  Widget build(BuildContext context) => switch (block) {
    final TextBlock b => _Text(block: b, path: path),
    final ImageBlock b => _Image(block: b),
    DividerBlock() => Divider(height: 1, color: context.tokens.hairline),
    final ContainerBlock b => _Container(block: b, path: path),
    final ColumnSetBlock b => _ColumnSet(block: b, path: path),
    final ColumnBlock b => _Blocks(blocks: b.items, path: path, gap: b.gap),
    final CollapsibleBlock b => _Collapsible(block: b, path: path),
    // Controls keep their own width in a column.
    final ButtonBlock b => Align(
      alignment: AlignmentDirectional.centerStart,
      widthFactor: 1,
      child: _Button(block: b),
    ),
    final SelectBlock b => Align(
      alignment: AlignmentDirectional.centerStart,
      widthFactor: 1,
      child: _Select(block: b),
    ),
  };
}

class _Text extends StatelessWidget {
  const _Text({required this.block, required this.path});

  final TextBlock block;
  final String path;

  @override
  Widget build(BuildContext context) {
    final message = _Scope.of(context);
    final tokens = context.tokens;
    final theme = Theme.of(context).textTheme;
    final quiet = block.subtle || block.small;
    return PostBody(
      postId: '${message.keyPrefix}$path',
      message: block.text,
      imageSizes: message.imageSizes,
      collapsible: false,
      style: quiet
          ? (block.small ? theme.bodySmall : theme.bodyMedium)?.copyWith(
              color: block.subtle ? tokens.muted : tokens.text,
            )
          : null,
    );
  }
}

class _Image extends StatelessWidget {
  const _Image({required this.block});

  final ImageBlock block;

  @override
  Widget build(BuildContext context) {
    final b = block;
    if (!canLoadImage(b.url)) {
      return b.altText.isEmpty ? const SizedBox.shrink() : Text(b.altText);
    }
    final message = _Scope.of(context);
    final env = PostEnvironment.maybeOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final box = integrationImageBox(
          b,
          measured: message.imageSizes[b.url],
          maxWidth: constraints.maxWidth,
          screenHeight: MediaQuery.sizeOf(context).height,
        );
        final image = SizedBox.fromSize(
          size: box,
          child:
              env?.image?.call(b.url, box) ??
              ColoredBox(color: context.tokens.codeBackground),
        );
        Widget shown = b.person
            ? ClipOval(child: image)
            : ClipRRect(borderRadius: BorderRadius.circular(4), child: image);
        shown = Semantics(
          image: true,
          label: b.altText.isEmpty ? null : b.altText,
          child: shown,
        );
        if (b.title case final title? when title.isNotEmpty) {
          shown = Tooltip(message: title, child: shown);
        }
        return switch (b.alignment) {
          ImageAlignment.left => shown,
          ImageAlignment.center => Center(child: shown),
          ImageAlignment.right => Align(
            alignment: Alignment.centerRight,
            child: shown,
          ),
        };
      },
    );
  }
}

class _Container extends StatelessWidget {
  const _Container({required this.block, required this.path});

  final ContainerBlock block;
  final String path;

  @override
  Widget build(BuildContext context) {
    final b = block;
    final tokens = context.tokens;
    Widget inner = _Blocks(
      blocks: b.content,
      path: path,
      horizontal: b.horizontal,
      gap: b.gap,
    );
    if (_height(b.maxHeight) case final limit?) {
      inner = ShowMore(
        id: '${_Scope.of(context).keyPrefix}$path',
        limit: limit,
        child: inner,
      );
    }
    final accent = switch (b.accent) {
      null => null,
      'primary' => tokens.accent,
      'default' => tokens.accent.withValues(alpha: 0.32),
      final named => namedColour(named) ?? tokens.hairline,
    };
    if (!b.border && accent == null && !b.gray) return inner;
    final framed = b.border || accent != null;
    final radius = BorderRadius.circular(4);
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Container(
          // A rounded border must be one colour, so the bar is a second
          // border inside the clip.
          foregroundDecoration: b.border
              ? BoxDecoration(
                  border: Border.all(color: tokens.hairline),
                  borderRadius: radius,
                )
              : null,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: radius,
            color: b.gray ? tokens.codeBackground : null,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: accent == null
                  ? null
                  : Border(left: BorderSide(color: accent, width: 4)),
            ),
            child: Padding(
              padding: EdgeInsets.all(framed ? Spacing.md : Spacing.sm),
              child: inner,
            ),
          ),
        ),
      ),
    );
  }
}

class _ColumnSet extends StatelessWidget {
  const _ColumnSet({required this.block, required this.path});

  final ColumnSetBlock block;
  final String path;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      // Columns sized to their content share what the stretching ones
      // leave, but never take more than half the row.
      final anyStretch = block.columns.any((c) => c.stretch);
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: _gap(block.gap),
        children: [
          for (final (i, column) in block.columns.indexed)
            _column(column, i, anyStretch, constraints.maxWidth),
        ],
      );
    },
  );

  Widget _column(ColumnBlock column, int i, bool anyStretch, double width) {
    final blocks = _Blocks(
      blocks: column.items,
      path: '$path/$i',
      gap: column.gap,
    );
    if (column.stretch) return Expanded(child: blocks);
    if (!anyStretch) return Flexible(child: blocks);
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width / 2),
      child: _Blocks(
        blocks: column.items,
        path: '$path/$i',
        gap: column.gap,
        fill: false,
      ),
    );
  }
}

class _Collapsible extends StatefulWidget {
  const _Collapsible({required this.block, required this.path});

  final CollapsibleBlock block;
  final String path;

  @override
  State<_Collapsible> createState() => _CollapsibleState();
}

class _CollapsibleState extends State<_Collapsible> {
  late var _open = !widget.block.collapsed;

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 200);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          expanded: _open,
          child: InkWell(
            onTap: () => setState(() => _open = !_open),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedRotation(
                  turns: _open ? 0.25 : 0,
                  duration: duration,
                  child: const Icon(Icons.chevron_right),
                ),
                const SizedBox(width: Spacing.xs),
                Expanded(
                  child: _Blocks(
                    blocks: widget.block.header,
                    path: '${widget.path}/h',
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: duration,
          alignment: Alignment.topCenter,
          child: _open
              ? Padding(
                  padding: const EdgeInsets.only(
                    top: Spacing.sm,
                    left: Spacing.xl + Spacing.xs,
                  ),
                  child: _Blocks(
                    blocks: widget.block.content,
                    path: '${widget.path}/c',
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

/// Runs the action of [block] with [selected]; [busy] says whether it is
/// still running, so a second tap is ignored.
mixin _Acting<T extends StatefulWidget> on State<T> {
  var busy = false;

  Future<void> act(
    IntegrationBlock block, {
    required String actionId,
    required Map<String, String>? query,
    String selected = '',
  }) async {
    final run = PostEnvironment.maybeOf(context)?.onAction;
    if (busy || run == null) return;
    final message = _Scope.of(context);
    setState(() => busy = true);
    try {
      await run((
        postId: message.postId,
        actionId: actionId,
        cookie: message.content.cookieFor(block),
        selectedOption: selected,
        query: query,
        format: message.content.format,
      ));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}

class _Button extends StatefulWidget {
  const _Button({required this.block});

  final ButtonBlock block;

  @override
  State<_Button> createState() => _ButtonState();
}

class _ButtonState extends State<_Button> with _Acting {
  @override
  Widget build(BuildContext context) {
    final b = widget.block;
    final scheme = Theme.of(context).colorScheme;
    final enabled =
        !b.disabled && PostEnvironment.maybeOf(context)?.onAction != null;
    final onPressed = enabled && !busy
        ? () => unawaited(act(b, actionId: b.actionId, query: b.query))
        : null;
    final label = busy
        ? Row(
            mainAxisSize: MainAxisSize.min,
            spacing: Spacing.sm,
            children: [
              const SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              Flexible(child: Text(b.text)),
            ],
          )
        : Text(b.text);
    final colour = namedColour(b.style);
    final Widget button = switch (b.style) {
      'primary' => FilledButton(onPressed: onPressed, child: label),
      'danger' => FilledButton.tonal(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.errorContainer,
          foregroundColor: scheme.onErrorContainer,
        ),
        onPressed: onPressed,
        child: label,
      ),
      // The colour marks the edge; text keeps the theme's contrast.
      _ when colour != null => OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: colour, width: 2),
        ),
        onPressed: onPressed,
        child: label,
      ),
      _ => FilledButton.tonal(onPressed: onPressed, child: label),
    };
    final tip = b.tooltip;
    return tip == null || tip.isEmpty
        ? button
        : Tooltip(message: tip, child: button);
  }
}

class _Select extends StatefulWidget {
  const _Select({required this.block});

  final SelectBlock block;

  @override
  State<_Select> createState() => _SelectState();
}

class _SelectState extends State<_Select> with _Acting {
  late String? _shown = _initial();

  String? _initial() {
    final initial = widget.block.initialOption;
    if (initial == null) return null;
    for (final o in widget.block.options) {
      if (o.value == initial) return o.text;
    }
    return widget.block.source == SelectSource.options ? null : initial;
  }

  Future<void> _pick() async {
    final b = widget.block;
    final env = PostEnvironment.maybeOf(context);
    if (env == null) return;
    final SelectOption? picked;
    switch (b.source) {
      case SelectSource.options:
        picked = await _pickOption(context, b);
      case SelectSource.users:
        final item = await pickSwitchItem(
          context,
          title: b.placeholder,
          hint: 'Find a person',
          serverUrl: env.server.toString(),
          kinds: const {SwitchKind.person, SwitchKind.direct},
          findPeople: true,
        );
        final userId = item?.kind == SwitchKind.direct
            ? item?.userId
            : item?.id;
        picked = item == null || userId == null
            ? null
            : (text: item.title, value: userId);
      case SelectSource.channels:
        final item = await pickSwitchItem(
          context,
          title: b.placeholder,
          hint: 'Find a channel',
          serverUrl: env.server.toString(),
          kinds: const {SwitchKind.channel, SwitchKind.privateChannel},
        );
        picked = item == null ? null : (text: item.title, value: item.id);
    }
    if (picked == null || !mounted) return;
    // The choice stays shown; the integration's answer usually replaces
    // the post.
    setState(() => _shown = picked!.text);
    await act(b, actionId: b.actionId, query: b.query, selected: picked.value);
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.block;
    final tokens = context.tokens;
    final enabled =
        !b.disabled && PostEnvironment.maybeOf(context)?.onAction != null;
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 160, maxWidth: 320),
      child: OutlinedButton(
        onPressed: enabled && !busy ? () => unawaited(_pick()) : null,
        style: OutlinedButton.styleFrom(
          alignment: AlignmentDirectional.centerStart,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: Spacing.sm,
          children: [
            Flexible(
              child: Text(
                _shown ?? b.placeholder,
                overflow: TextOverflow.ellipsis,
                style: _shown == null
                    ? TextStyle(color: tokens.muted)
                    : TextStyle(color: tokens.text),
              ),
            ),
            if (busy)
              const SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}

Future<SelectOption?> _pickOption(BuildContext context, SelectBlock block) =>
    showModalBottomSheet<SelectOption>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheet) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (sheet, controller) => ListView(
          controller: controller,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.lg,
                0,
                Spacing.lg,
                Spacing.sm,
              ),
              child: Text(
                block.placeholder,
                style: Theme.of(sheet).textTheme.titleMedium,
              ),
            ),
            for (final o in block.options)
              ListTile(
                title: Text(o.text),
                onTap: () => Navigator.pop(sheet, o),
              ),
          ],
        ),
      ),
    );

/// A post's interactive content from an integration, if it has any.
class PostIntegration extends StatelessWidget {
  const PostIntegration({required this.post, required this.details, super.key});

  final PostItem post;
  final PostDetails details;

  @override
  Widget build(BuildContext context) {
    final env = PostEnvironment.maybeOf(context);
    final content = interactiveContentOf(
      details,
      mmBlocks: env?.mmBlocks ?? false,
    );
    if (content == null || content.blocks.isEmpty || post.deleted) {
      return const SizedBox.shrink();
    }
    return InteractiveMessage(
      postId: post.id,
      content: content,
      keyPrefix: '${post.id}:${post.editAt?.millisecondsSinceEpoch}',
      imageSizes: details.imageSizes,
    );
  }
}

/// Lets `mmaction://` links in [child], the text of [post], run its
/// actions when an integration (bot, webhook or plugin) wrote it.
class PostTextActions extends StatelessWidget {
  const PostTextActions({
    required this.post,
    required this.details,
    required this.child,
    super.key,
  });

  final PostItem post;
  final PostDetails details;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final props = details.props;
    final integration =
        props.fromBot == 'true' ||
        details.fromWebhook ||
        props.fromPlugin == 'true';
    if (!integration || post.isEphemeral) return child;
    final content = interactiveContentOf(
      details,
      mmBlocks: PostEnvironment.maybeOf(context)?.mmBlocks ?? false,
    );
    return InlineActions(
      postId: post.id,
      format: content?.format ?? IntegrationFormat.mmBlock,
      cookie: details.integration.mmBlocksActions,
      child: child,
    );
  }
}
