import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/json/post_extras.dart';
import 'package:matterleast/markdown/links.dart';
import 'package:matterleast/ui/markdown/image_box.dart';
import 'package:matterleast/ui/markdown/post_body.dart';
import 'package:matterleast/ui/markdown/post_environment.dart';
import 'package:matterleast/ui/tokens.dart';

/// Pure: the bar colour of an attachment: `#rgb`/`#rrggbb`, or the named
/// `good`, `warning` and `danger` of Mattermost's apps.
Color? attachmentColor(String? value) {
  final v = value?.trim().toLowerCase() ?? '';
  switch (v) {
    case 'good':
      return const Color(0xFF00C100);
    case 'warning':
      return const Color(0xFFDEDE01);
    case 'danger':
      return const Color(0xFFE40303);
  }
  var hex = v.startsWith('#') ? v.substring(1) : v;
  if (hex.length == 3) hex = [for (final c in hex.split('')) '$c$c'].join();
  if (hex.length != 6) return null;
  final rgb = int.tryParse(hex, radix: 16);
  return rgb == null ? null : Color(0xFF000000 | rgb);
}

/// A message attachment from an integration (Slack's format): pretext,
/// author, title, text, fields, image and footer beside a colour bar.
/// Buttons and menus show but act only once integrations are supported.
class AttachmentCard extends StatelessWidget {
  const AttachmentCard({
    required this.attachment,
    required this.keyPrefix,
    required this.imageSizes,
    super.key,
  });

  final Attachment attachment;

  /// Distinguishes this attachment's texts in the parse cache.
  final String keyPrefix;
  final Map<String, ImageSize> imageSizes;

  @override
  Widget build(BuildContext context) {
    final a = attachment;
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final env = PostEnvironment.maybeOf(context);
    final bar = attachmentColor(a.color) ?? tokens.hairline;
    Widget markdown(String id, String value) => PostBody(
      postId: '$keyPrefix:$id',
      message: value,
      imageSizes: imageSizes,
      collapsible: false,
    );
    final imageUrl = a.imageUrl;
    final measured = imageUrl == null ? null : imageSizes[imageUrl];
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (a.pretext?.isNotEmpty ?? false) markdown('pretext', a.pretext!),
          Container(
            margin: const EdgeInsets.only(top: Spacing.xs),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: bar, width: 4),
                top: BorderSide(color: tokens.hairline),
                right: BorderSide(color: tokens.hairline),
                bottom: BorderSide(color: tokens.hairline),
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.all(Spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Spacing.xs,
              children: [
                if (a.authorName?.isNotEmpty ?? false)
                  Text(
                    a.authorName!,
                    style: text.labelMedium?.copyWith(color: tokens.muted),
                  ),
                if (a.title?.isNotEmpty ?? false)
                  InkWell(
                    onTap: env == null || (a.titleLink?.isEmpty ?? true)
                        ? null
                        : () => env.onLink(
                            classifyLink(a.titleLink!, env.server),
                          ),
                    child: Text(
                      a.title!,
                      style: text.titleSmall?.copyWith(
                        color: (a.titleLink?.isNotEmpty ?? false)
                            ? tokens.accent
                            : tokens.text,
                      ),
                    ),
                  ),
                if (a.text?.isNotEmpty ?? false) markdown('text', a.text!),
                if (a.fields.isNotEmpty)
                  _Fields(fields: a.fields, prefix: keyPrefix),
                if (imageUrl != null && measured != null)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final box = imageBox(
                        measuredWidth: measured.width,
                        measuredHeight: measured.height,
                        maxWidth: constraints.maxWidth,
                        maxHeight: MediaQuery.sizeOf(context).height * 0.4,
                      );
                      return box == null
                          ? const SizedBox.shrink()
                          : Align(
                              alignment: Alignment.centerLeft,
                              child: ImageSlot(url: imageUrl, size: box),
                            );
                    },
                  ),
                if (a.actions.isNotEmpty)
                  Wrap(
                    spacing: Spacing.sm,
                    children: [
                      for (final action in a.actions)
                        action.type == 'select'
                            ? OutlinedButton.icon(
                                onPressed: null,
                                icon: const Icon(Icons.arrow_drop_down),
                                label: Text(action.name ?? 'Select'),
                              )
                            : OutlinedButton(
                                onPressed: null,
                                child: Text(action.name ?? ''),
                              ),
                    ],
                  ),
                if (a.footer?.isNotEmpty ?? false)
                  Text(
                    a.footer!,
                    style: text.bodySmall?.copyWith(color: tokens.muted),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Fields extends StatelessWidget {
  const _Fields({required this.fields, required this.prefix});

  final List<AttachmentField> fields;
  final String prefix;

  @override
  Widget build(BuildContext context) {
    final rows = <List<(int, AttachmentField)>>[];
    for (final (i, field) in fields.indexed) {
      final last = rows.lastOrNull;
      if ((field.short ?? false) &&
          last != null &&
          last.length == 1 &&
          (last.single.$2.short ?? false)) {
        last.add((i, field));
      } else {
        rows.add([(i, field)]);
      }
    }
    final title = Theme.of(context).textTheme.labelLarge;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.xs,
      children: [
        for (final row in rows)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (i, field) in row)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (field.title?.isNotEmpty ?? false)
                        Text(field.title!, style: title),
                      PostBody(
                        postId: '$prefix:field$i',
                        message: field.value ?? '',
                        collapsible: false,
                      ),
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
