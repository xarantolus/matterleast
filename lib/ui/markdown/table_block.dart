import 'package:material_ui/material_ui.dart';
import 'package:matterleast/markdown/post_doc.dart';
import 'package:matterleast/screens/open_page.dart';
import 'package:matterleast/ui/content_page.dart';
import 'package:matterleast/ui/markdown/inline_text.dart';
import 'package:matterleast/ui/message_display.dart';
import 'package:matterleast/ui/tokens.dart';

const _previewHeight = 300.0;
const _cellMaxWidth = 240.0;

/// A table in a message: scrolls sideways, at most [_previewHeight] tall;
/// tap shows it whole.
class TablePreview extends StatelessWidget {
  const TablePreview({required this.table, super.key});

  final TableBlock table;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () =>
              openPage(Navigator.of(context), TableScreen(table: table)),
          child: Container(
            constraints: const BoxConstraints(maxHeight: _previewHeight),
            decoration: BoxDecoration(
              border: Border.all(color: tokens.hairline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRect(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: MessageTable(
                    table: table,
                    maxCellWidth: _cellMaxWidth,
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

class MessageTable extends StatelessWidget {
  const MessageTable({required this.table, this.maxCellWidth, super.key});

  final TableBlock table;
  final double? maxCellWidth;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final body = Theme.of(context).textTheme.bodyMedium!
        .copyWith(color: tokens.text)
        .forMessages(context);
    final columns = table.rows.fold(0, (n, r) => r.length > n ? r.length : n);
    return Table(
      defaultColumnWidth: const IntrinsicColumnWidth(),
      border: TableBorder.symmetric(inside: BorderSide(color: tokens.hairline)),
      children: [
        for (final (index, row) in table.rows.indexed)
          TableRow(
            decoration: index == 0
                ? BoxDecoration(color: tokens.codeBackground)
                : null,
            children: [
              for (var c = 0; c < columns; c++)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.sm,
                    vertical: Spacing.xs + 2,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: maxCellWidth ?? double.infinity,
                    ),
                    child: c < row.length
                        ? Align(
                            alignment: switch (c < table.align.length
                                ? table.align[c]
                                : CellAlign.start) {
                              CellAlign.start =>
                                AlignmentDirectional.centerStart,
                              CellAlign.center => Alignment.center,
                              CellAlign.end => AlignmentDirectional.centerEnd,
                            },
                            widthFactor: 1,
                            child: InlineText(
                              inlines: row[c],
                              style: index == 0
                                  ? body.copyWith(fontWeight: FontWeight.w600)
                                  : body,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class TableScreen extends StatelessWidget {
  const TableScreen({required this.table, super.key});

  final TableBlock table;

  @override
  Widget build(BuildContext context) => ContentPage(
    title: const Text('Table'),
    body: SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.md),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: MessageTable(table: table, maxCellWidth: 400),
        ),
      ),
    ),
  );
}
