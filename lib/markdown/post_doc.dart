import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_doc.freezed.dart';

/// What the parser needs to know besides the text: server settings and post
/// props.
@freezed
abstract class ParseOptions with _$ParseOptions {
  const factory ParseOptions({
    @Default(false) bool latexBlocks,
    @Default(false) bool latexInline,
    @Default(3) int minimumHashtagLength,

    /// More nodes than this and the post is not rendered.
    int? maxNodes,

    /// Links, channel links, hashtags, images and LaTeX stay plain text.
    @Default(false) bool unsafeLinks,
  }) = _ParseOptions;
}

/// A parsed message.
@freezed
sealed class PostDoc with _$PostDoc {
  const factory PostDoc.blocks(List<Block> blocks) = ParsedPost;

  /// Over the server's node limit.
  const factory PostDoc.tooLong() = TooLongPost;

  /// The parser failed; the text is shown as it is.
  const factory PostDoc.plain(String text) = PlainPost;
}

@freezed
sealed class Block with _$Block {
  const factory Block.paragraph(List<Inline> inlines) = Paragraph;
  const factory Block.heading(int level, List<Inline> inlines) = Heading;
  const factory Block.code(String code, {@Default('') String language}) =
      CodeBlock;
  const factory Block.math(String tex) = MathBlock;
  const factory Block.quote(List<Block> blocks) = Quote;
  const factory Block.list(
    List<ListItem> items, {
    @Default(false) bool ordered,
    @Default(1) int start,
  }) = ListBlock;
  const factory Block.table(
    List<CellAlign> align,
    List<List<List<Inline>>> rows,
  ) = TableBlock;
  const factory Block.rule() = Rule;
}

@freezed
abstract class ListItem with _$ListItem {
  const factory ListItem(
    List<Block> blocks, {

    /// A task list item: done or not.
    bool? checked,
  }) = _ListItem;
}

enum CellAlign { start, center, end }

/// Text styles an inline carries; combined as bits.
abstract final class Marks {
  static const bold = 1;
  static const italic = 2;
  static const strike = 4;
}

/// A piece of a paragraph. [marks] are [Marks] bits; [link] is the target
/// when the piece sits inside a link.
@freezed
sealed class Inline with _$Inline {
  const factory Inline.text(
    String text, {
    @Default(0) int marks,
    String? link,
  }) = TextPart;
  const factory Inline.code(
    String text, {
    @Default(0) int marks,
    String? link,
  }) = CodePart;

  /// `@name` as typed; which prefix is a username is decided when shown.
  const factory Inline.mention(
    String name, {
    @Default(0) int marks,
    String? link,
  }) = MentionPart;
  const factory Inline.channel(
    String name, {
    @Default(0) int marks,
    String? link,
  }) = ChannelPart;

  /// `:name:` or an emoticon; [literal] is shown when the name is unknown.
  const factory Inline.emoji(
    String name,
    String literal, {
    @Default(0) int marks,
    String? link,
  }) = EmojiPart;
  const factory Inline.hashtag(
    String tag, {
    @Default(0) int marks,
    String? link,
  }) = HashtagPart;
  const factory Inline.math(String tex, {@Default(0) int marks, String? link}) =
      MathPart;
  const factory Inline.image(
    String url, {
    @Default('') String alt,
    int? width,
    int? height,
    @Default(0) int marks,
    String? link,
  }) = ImagePart;
  const factory Inline.lineBreak({@Default(0) int marks, String? link}) =
      BreakPart;
}
