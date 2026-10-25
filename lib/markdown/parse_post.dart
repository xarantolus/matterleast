import 'package:markdown/markdown.dart' as md;
import 'package:matterleast/markdown/post_doc.dart';
import 'package:matterleast/markdown/syntaxes.dart';

/// Parses a message the way Mattermost does: CommonMark plus mentions,
/// channel links, emoji, hashtags, LaTeX, bare links and tables. HTML stays
/// literal text. Never throws; a failure gives a [PlainPost].
PostDoc parsePost(String text, ParseOptions options) {
  try {
    final document = md.Document(
      extensionSet: md.ExtensionSet.none,
      encodeHtml: false,
      withDefaultBlockSyntaxes: false,
      blockSyntaxes: const [
        md.EmptyBlockSyntax(),
        md.SetextHeaderSyntax(),
        md.HeaderSyntax(),
        md.FencedCodeBlockSyntax(),
        md.CodeBlockSyntax(),
        md.BlockquoteSyntax(),
        md.HorizontalRuleSyntax(),
        md.UnorderedListSyntax(),
        md.OrderedListSyntax(),
        md.TableSyntax(),
        md.LinkReferenceDefinitionSyntax(),
        md.ParagraphSyntax(),
      ],
      inlineSyntaxes: [
        SizedImageSyntax(),
        StrikeSyntax(),
        AtMentionSyntax(),
        ChannelLinkSyntax(),
        EmojiSyntax(),
        EmoticonSyntax(),
        HashtagSyntax(options.minimumHashtagLength),
        if (options.latexInline) InlineLatexSyntax(),
        BareEmailSyntax(),
        BareUrlSyntax(),
      ],
    );
    final nodes = document.parse(text);
    final converter = _Converter(options);
    final blocks = converter.blocks(nodes);
    final limit = options.maxNodes;
    if (limit != null && limit > 0 && converter.count > limit) {
      return const PostDoc.tooLong();
    }
    return PostDoc.blocks(blocks);
  } on Object {
    return PostDoc.plain(text);
  }
}

final _www = RegExp(r'^www\d{0,3}\.', caseSensitive: false);

String? _withScheme(String? url) =>
    url != null && _www.hasMatch(url) ? 'http://$url' : url;

final _taskPrefix = RegExp(r'^ {0,3}\[( |x)\]\s');

class _Converter {
  _Converter(this.options);

  final ParseOptions options;
  int count = 0;

  List<Block> blocks(List<md.Node> nodes) {
    final result = <Block>[];
    final loose = <md.Node>[];
    void flush() {
      if (loose.isEmpty) return;
      final inlines = this.inlines(loose);
      if (inlines.isNotEmpty) result.add(Block.paragraph(inlines));
      loose.clear();
    }

    for (final node in nodes) {
      count++;
      final block = node is md.Element ? _block(node) : null;
      if (block == null) {
        loose.add(node);
      } else {
        flush();
        result.add(block);
      }
    }
    flush();
    return result;
  }

  Block? _block(md.Element e) {
    final children = e.children ?? const <md.Node>[];
    switch (e.tag) {
      case 'p':
        return Block.paragraph(inlines(children));
      case 'h1' || 'h2' || 'h3' || 'h4' || 'h5' || 'h6':
        return Block.heading(int.parse(e.tag.substring(1)), inlines(children));
      case 'pre':
        final code = children.isNotEmpty && children.first is md.Element
            ? children.first as md.Element
            : e;
        var source = code.textContent;
        if (source.endsWith('\n')) {
          source = source.substring(0, source.length - 1);
        }
        final language = (code.attributes['class'] ?? '').replaceFirst(
          'language-',
          '',
        );
        if (language == 'latex' &&
            options.latexBlocks &&
            !options.unsafeLinks) {
          return Block.math(source);
        }
        return Block.code(source, language: language);
      case 'blockquote':
        return Block.quote(blocks(children));
      case 'ul' || 'ol':
        return Block.list(
          [
            for (final item in children.whereType<md.Element>())
              _item(item.children ?? const []),
          ],
          ordered: e.tag == 'ol',
          start: int.tryParse(e.attributes['start'] ?? '') ?? 1,
        );
      case 'hr':
        return const Block.rule();
      case 'table':
        return _table(e);
      default:
        return null;
    }
  }

  ListItem _item(List<md.Node> children) {
    count++;
    final content = blocks(children);
    if (content.firstOrNull case Paragraph(:final inlines)) {
      if (inlines.firstOrNull case TextPart(
        :final text,
        :final marks,
        :final link,
      )) {
        final task = _taskPrefix.firstMatch(text);
        if (task != null) {
          final rest = text.substring(task.end);
          return ListItem([
            Block.paragraph([
              if (rest.isNotEmpty) Inline.text(rest, marks: marks, link: link),
              ...inlines.skip(1),
            ]),
            ...content.skip(1),
          ], checked: task[1] == 'x');
        }
      }
    }
    return ListItem(content);
  }

  Block _table(md.Element table) {
    final rows = <List<List<Inline>>>[];
    var align = <CellAlign>[];
    for (final section in table.children!.whereType<md.Element>()) {
      for (final row in section.children!.whereType<md.Element>()) {
        count++;
        final cells = row.children!.whereType<md.Element>().toList();
        if (rows.isEmpty) {
          align = [for (final cell in cells) _align(cell)];
        }
        rows.add([
          for (final cell in cells) inlines(cell.children ?? const []),
        ]);
      }
    }
    return Block.table(align, rows);
  }

  CellAlign _align(md.Element cell) =>
      switch (cell.attributes['align'] ?? cell.attributes['style']) {
        final String a when a.contains('center') => CellAlign.center,
        final String a when a.contains('right') => CellAlign.end,
        _ => CellAlign.start,
      };

  List<Inline> inlines(List<md.Node> nodes) {
    final out = <Inline>[];
    for (final node in nodes) {
      _inline(node, 0, null, out);
    }
    return _merge(out);
  }

  void _inline(md.Node node, int marks, String? link, List<Inline> out) {
    count++;
    if (node is md.Text) {
      out.add(Inline.text(node.text, marks: marks, link: link));
      return;
    }
    if (node is! md.Element) {
      out.add(Inline.text(node.textContent, marks: marks, link: link));
      return;
    }
    final a = node.attributes;
    void text(String t) => out.add(Inline.text(t, marks: marks, link: link));
    void children(int marks, String? link) {
      for (final child in node.children ?? const <md.Node>[]) {
        _inline(child, marks, link, out);
      }
    }

    final plain = options.unsafeLinks;
    switch (node.tag) {
      case 'strong':
        children(marks | Marks.bold, link);
      case 'em':
        children(marks | Marks.italic, link);
      case 'del':
        children(marks | Marks.strike, link);
      case 'code':
        out.add(Inline.code(node.textContent, marks: marks, link: link));
      case 'br':
        out.add(Inline.lineBreak(marks: marks, link: link));
      case 'a':
        children(marks, link ?? (plain ? null : _withScheme(a['href'])));
      case 'img':
        if (plain) {
          text(a['alt'] ?? '');
        } else {
          out.add(
            Inline.image(
              a['src'] ?? '',
              alt: a['alt'] ?? '',
              width: int.tryParse(a['width'] ?? ''),
              height: int.tryParse(a['height'] ?? ''),
              marks: marks,
              link: link,
            ),
          );
        }
      case 'mention':
        if (link != null) {
          text('@${a['name']}');
        } else {
          out.add(Inline.mention(a['name']!, marks: marks));
        }
      case 'channel':
        if (link != null || plain) {
          text('~${a['name']}');
        } else {
          out.add(Inline.channel(a['name']!, marks: marks));
        }
      case 'hashtag':
        if (link != null || plain) {
          text('#${a['tag']}');
        } else {
          out.add(Inline.hashtag(a['tag']!, marks: marks));
        }
      case 'emoji':
        out.add(
          Inline.emoji(a['name']!, a['literal']!, marks: marks, link: link),
        );
      case 'math':
        if (link != null || plain) {
          text('\$${a['tex']}\$');
        } else {
          out.add(Inline.math(a['tex']!, marks: marks));
        }
      default:
        children(marks, link);
    }
  }

  List<Inline> _merge(List<Inline> parts) {
    final merged = <Inline>[];
    for (final part in parts) {
      final last = merged.isEmpty ? null : merged.last;
      if (part is TextPart &&
          last is TextPart &&
          last.marks == part.marks &&
          last.link == part.link) {
        merged[merged.length - 1] = last.copyWith(text: last.text + part.text);
      } else if (part is TextPart && part.text.isEmpty) {
        continue;
      } else {
        merged.add(part);
      }
    }
    return merged;
  }
}
