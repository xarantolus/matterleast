import 'package:material_ui/material_ui.dart';
import 'package:matterleast/screens/channel/message_environment.dart';
import 'package:matterleast/ui/density.dart';
import 'package:matterleast/ui/markdown/post_body.dart';
import 'package:matterleast/ui/tokens.dart';

/// Editing or previewing the draft, switched by the chip above the field.
class PreviewChip extends StatelessWidget {
  const PreviewChip({required this.onEdit, super.key});

  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(Spacing.md, Spacing.sm, Spacing.md, 0),
    child: Align(
      alignment: AlignmentDirectional.centerStart,
      child: SegmentedButton<bool>(
        showSelectedIcon: false,
        style: const ButtonStyle(visualDensity: VisualDensity.compact),
        segments: const [
          ButtonSegment(value: false, label: Text('Editing')),
          ButtonSegment(value: true, label: Text('Preview')),
        ],
        selected: const {true},
        onSelectionChanged: (_) => onEdit(),
      ),
    ),
  );
}

/// The draft as a sent message shows it, in the place of the field, as
/// high as its content up to [maxHeight]. Tapping it goes back to editing.
class ComposerPreview extends StatelessWidget {
  const ComposerPreview({
    required this.url,
    required this.teamId,
    required this.channelId,
    required this.text,
    required this.style,
    required this.padding,
    required this.maxHeight,
    required this.onEdit,
    super.key,
  });

  final String url;
  final String teamId;
  final String channelId;
  final String text;
  final TextStyle? style;

  /// Above and below the text, as in the field.
  final double padding;
  final double maxHeight;
  final VoidCallback onEdit;

  static const _hint = 'Nothing to preview yet';

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final density = context.density;
    final radius = BorderRadius.circular(density.fieldRadius);
    final hint = text.trim().isEmpty;
    return Focus(
      autofocus: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onEdit,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            color: density.plainComposer
                ? null
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            border: density.plainComposer
                ? Border.all(color: tokens.divider)
                : null,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: SingleChildScrollView(
              padding: EdgeInsetsDirectional.fromSTEB(
                Spacing.lg,
                padding,
                Spacing.lg,
                padding,
              ),
              child: hint
                  ? Text(_hint, style: style?.copyWith(color: tokens.muted))
                  : AbsorbPointer(
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: MessageEnvironment(
                          url: url,
                          teamId: teamId,
                          channelId: channelId,
                          child: PostBody(
                            postId: 'composer-preview',
                            message: text,
                            collapsible: false,
                            style: style,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
