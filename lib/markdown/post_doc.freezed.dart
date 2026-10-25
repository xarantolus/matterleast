// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_doc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ParseOptions {

 bool get latexBlocks; bool get latexInline; int get minimumHashtagLength;/// More nodes than this and the post is not rendered.
 int? get maxNodes;/// Links, channel links, hashtags, images and LaTeX stay plain text.
 bool get unsafeLinks;
/// Create a copy of ParseOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParseOptionsCopyWith<ParseOptions> get copyWith => _$ParseOptionsCopyWithImpl<ParseOptions>(this as ParseOptions, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ParseOptions;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParseOptions&&(identical(other.latexBlocks, _this.latexBlocks) || other.latexBlocks == _this.latexBlocks)&&(identical(other.latexInline, _this.latexInline) || other.latexInline == _this.latexInline)&&(identical(other.minimumHashtagLength, _this.minimumHashtagLength) || other.minimumHashtagLength == _this.minimumHashtagLength)&&(identical(other.maxNodes, _this.maxNodes) || other.maxNodes == _this.maxNodes)&&(identical(other.unsafeLinks, _this.unsafeLinks) || other.unsafeLinks == _this.unsafeLinks));
}


@override
int get hashCode {
  final _this = this as ParseOptions;
  return Object.hash(runtimeType,_this.latexBlocks,_this.latexInline,_this.minimumHashtagLength,_this.maxNodes,_this.unsafeLinks);
}

@override
String toString() {
  final _this = this as ParseOptions;
  return 'ParseOptions(latexBlocks: ${_this.latexBlocks}, latexInline: ${_this.latexInline}, minimumHashtagLength: ${_this.minimumHashtagLength}, maxNodes: ${_this.maxNodes}, unsafeLinks: ${_this.unsafeLinks})';
}


}

/// @nodoc
abstract mixin class $ParseOptionsCopyWith<$Res>  {
  factory $ParseOptionsCopyWith(ParseOptions value, $Res Function(ParseOptions) _then) = _$ParseOptionsCopyWithImpl;
@useResult
$Res call({
 bool latexBlocks, bool latexInline, int minimumHashtagLength, int? maxNodes, bool unsafeLinks
});




}
/// @nodoc
class _$ParseOptionsCopyWithImpl<$Res>
    implements $ParseOptionsCopyWith<$Res> {
  _$ParseOptionsCopyWithImpl(this._self, this._then);

  final ParseOptions _self;
  final $Res Function(ParseOptions) _then;

/// Create a copy of ParseOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? latexBlocks = null,Object? latexInline = null,Object? minimumHashtagLength = null,Object? maxNodes = freezed,Object? unsafeLinks = null,}) {
  return _then(ParseOptions(
latexBlocks: null == latexBlocks ? _self.latexBlocks : latexBlocks // ignore: cast_nullable_to_non_nullable
as bool,latexInline: null == latexInline ? _self.latexInline : latexInline // ignore: cast_nullable_to_non_nullable
as bool,minimumHashtagLength: null == minimumHashtagLength ? _self.minimumHashtagLength : minimumHashtagLength // ignore: cast_nullable_to_non_nullable
as int,maxNodes: freezed == maxNodes ? _self.maxNodes : maxNodes // ignore: cast_nullable_to_non_nullable
as int?,unsafeLinks: null == unsafeLinks ? _self.unsafeLinks : unsafeLinks // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ParseOptions].
extension ParseOptionsPatterns on ParseOptions {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ParseOptions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ParseOptions() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ParseOptions value)  $default,){
final _that = this;
switch (_that) {
case _ParseOptions():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ParseOptions value)?  $default,){
final _that = this;
switch (_that) {
case _ParseOptions() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool latexBlocks,  bool latexInline,  int minimumHashtagLength,  int? maxNodes,  bool unsafeLinks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ParseOptions() when $default != null:
return $default(_that.latexBlocks,_that.latexInline,_that.minimumHashtagLength,_that.maxNodes,_that.unsafeLinks);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool latexBlocks,  bool latexInline,  int minimumHashtagLength,  int? maxNodes,  bool unsafeLinks)  $default,) {final _that = this;
switch (_that) {
case _ParseOptions():
return $default(_that.latexBlocks,_that.latexInline,_that.minimumHashtagLength,_that.maxNodes,_that.unsafeLinks);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool latexBlocks,  bool latexInline,  int minimumHashtagLength,  int? maxNodes,  bool unsafeLinks)?  $default,) {final _that = this;
switch (_that) {
case _ParseOptions() when $default != null:
return $default(_that.latexBlocks,_that.latexInline,_that.minimumHashtagLength,_that.maxNodes,_that.unsafeLinks);case _:
  return null;

}
}

}

/// @nodoc


class _ParseOptions implements ParseOptions {
  const _ParseOptions({this.latexBlocks = false, this.latexInline = false, this.minimumHashtagLength = 3, this.maxNodes, this.unsafeLinks = false});
  

@override@JsonKey() final  bool latexBlocks;
@override@JsonKey() final  bool latexInline;
@override@JsonKey() final  int minimumHashtagLength;
/// More nodes than this and the post is not rendered.
@override final  int? maxNodes;
/// Links, channel links, hashtags, images and LaTeX stay plain text.
@override@JsonKey() final  bool unsafeLinks;

/// Create a copy of ParseOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParseOptionsCopyWith<_ParseOptions> get copyWith => __$ParseOptionsCopyWithImpl<_ParseOptions>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ParseOptions&&(identical(other.latexBlocks, latexBlocks) || other.latexBlocks == latexBlocks)&&(identical(other.latexInline, latexInline) || other.latexInline == latexInline)&&(identical(other.minimumHashtagLength, minimumHashtagLength) || other.minimumHashtagLength == minimumHashtagLength)&&(identical(other.maxNodes, maxNodes) || other.maxNodes == maxNodes)&&(identical(other.unsafeLinks, unsafeLinks) || other.unsafeLinks == unsafeLinks));
}


@override
int get hashCode {
    return Object.hash(runtimeType,latexBlocks,latexInline,minimumHashtagLength,maxNodes,unsafeLinks);
}

@override
String toString() {
    return 'ParseOptions(latexBlocks: $latexBlocks, latexInline: $latexInline, minimumHashtagLength: $minimumHashtagLength, maxNodes: $maxNodes, unsafeLinks: $unsafeLinks)';
}


}

/// @nodoc
abstract mixin class _$ParseOptionsCopyWith<$Res> implements $ParseOptionsCopyWith<$Res> {
  factory _$ParseOptionsCopyWith(_ParseOptions value, $Res Function(_ParseOptions) _then) = __$ParseOptionsCopyWithImpl;
@override @useResult
$Res call({
 bool latexBlocks, bool latexInline, int minimumHashtagLength, int? maxNodes, bool unsafeLinks
});




}
/// @nodoc
class __$ParseOptionsCopyWithImpl<$Res>
    implements _$ParseOptionsCopyWith<$Res> {
  __$ParseOptionsCopyWithImpl(this._self, this._then);

  final _ParseOptions _self;
  final $Res Function(_ParseOptions) _then;

/// Create a copy of ParseOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? latexBlocks = null,Object? latexInline = null,Object? minimumHashtagLength = null,Object? maxNodes = freezed,Object? unsafeLinks = null,}) {
  return _then(_ParseOptions(
latexBlocks: null == latexBlocks ? _self.latexBlocks : latexBlocks // ignore: cast_nullable_to_non_nullable
as bool,latexInline: null == latexInline ? _self.latexInline : latexInline // ignore: cast_nullable_to_non_nullable
as bool,minimumHashtagLength: null == minimumHashtagLength ? _self.minimumHashtagLength : minimumHashtagLength // ignore: cast_nullable_to_non_nullable
as int,maxNodes: freezed == maxNodes ? _self.maxNodes : maxNodes // ignore: cast_nullable_to_non_nullable
as int?,unsafeLinks: null == unsafeLinks ? _self.unsafeLinks : unsafeLinks // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$PostDoc {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PostDoc);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'PostDoc()';
}


}

/// @nodoc
class $PostDocCopyWith<$Res>  {
$PostDocCopyWith(PostDoc _, $Res Function(PostDoc) __);
}


/// Adds pattern-matching-related methods to [PostDoc].
extension PostDocPatterns on PostDoc {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ParsedPost value)?  blocks,TResult Function( TooLongPost value)?  tooLong,TResult Function( PlainPost value)?  plain,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ParsedPost() when blocks != null:
return blocks(_that);case TooLongPost() when tooLong != null:
return tooLong(_that);case PlainPost() when plain != null:
return plain(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ParsedPost value)  blocks,required TResult Function( TooLongPost value)  tooLong,required TResult Function( PlainPost value)  plain,}){
final _that = this;
switch (_that) {
case ParsedPost():
return blocks(_that);case TooLongPost():
return tooLong(_that);case PlainPost():
return plain(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ParsedPost value)?  blocks,TResult? Function( TooLongPost value)?  tooLong,TResult? Function( PlainPost value)?  plain,}){
final _that = this;
switch (_that) {
case ParsedPost() when blocks != null:
return blocks(_that);case TooLongPost() when tooLong != null:
return tooLong(_that);case PlainPost() when plain != null:
return plain(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( List<Block> blocks)?  blocks,TResult Function()?  tooLong,TResult Function( String text)?  plain,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ParsedPost() when blocks != null:
return blocks(_that.blocks);case TooLongPost() when tooLong != null:
return tooLong();case PlainPost() when plain != null:
return plain(_that.text);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( List<Block> blocks)  blocks,required TResult Function()  tooLong,required TResult Function( String text)  plain,}) {final _that = this;
switch (_that) {
case ParsedPost():
return blocks(_that.blocks);case TooLongPost():
return tooLong();case PlainPost():
return plain(_that.text);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( List<Block> blocks)?  blocks,TResult? Function()?  tooLong,TResult? Function( String text)?  plain,}) {final _that = this;
switch (_that) {
case ParsedPost() when blocks != null:
return blocks(_that.blocks);case TooLongPost() when tooLong != null:
return tooLong();case PlainPost() when plain != null:
return plain(_that.text);case _:
  return null;

}
}

}

/// @nodoc


class ParsedPost implements PostDoc {
  const ParsedPost( List<Block> blocks): _blocks = blocks;
  

 final  List<Block> _blocks;
 List<Block> get blocks {
  if (_blocks is EqualUnmodifiableListView) return _blocks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_blocks);
}


/// Create a copy of PostDoc
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParsedPostCopyWith<ParsedPost> get copyWith => _$ParsedPostCopyWithImpl<ParsedPost>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ParsedPost&&const DeepCollectionEquality().equals(other.blocks, _blocks));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_blocks));
}

@override
String toString() {
    return 'PostDoc.blocks(blocks: $blocks)';
}


}

/// @nodoc
abstract mixin class $ParsedPostCopyWith<$Res> implements $PostDocCopyWith<$Res> {
  factory $ParsedPostCopyWith(ParsedPost value, $Res Function(ParsedPost) _then) = _$ParsedPostCopyWithImpl;
@useResult
$Res call({
 List<Block> blocks
});




}
/// @nodoc
class _$ParsedPostCopyWithImpl<$Res>
    implements $ParsedPostCopyWith<$Res> {
  _$ParsedPostCopyWithImpl(this._self, this._then);

  final ParsedPost _self;
  final $Res Function(ParsedPost) _then;

/// Create a copy of PostDoc
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? blocks = null,}) {
  return _then(ParsedPost(
null == blocks ? _self._blocks : blocks // ignore: cast_nullable_to_non_nullable
as List<Block>,
  ));
}


}

/// @nodoc


class TooLongPost implements PostDoc {
  const TooLongPost();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TooLongPost);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'PostDoc.tooLong()';
}


}




/// @nodoc


class PlainPost implements PostDoc {
  const PlainPost(this.text);
  

 final  String text;

/// Create a copy of PostDoc
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlainPostCopyWith<PlainPost> get copyWith => _$PlainPostCopyWithImpl<PlainPost>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PlainPost&&(identical(other.text, text) || other.text == text));
}


@override
int get hashCode {
    return Object.hash(runtimeType,text);
}

@override
String toString() {
    return 'PostDoc.plain(text: $text)';
}


}

/// @nodoc
abstract mixin class $PlainPostCopyWith<$Res> implements $PostDocCopyWith<$Res> {
  factory $PlainPostCopyWith(PlainPost value, $Res Function(PlainPost) _then) = _$PlainPostCopyWithImpl;
@useResult
$Res call({
 String text
});




}
/// @nodoc
class _$PlainPostCopyWithImpl<$Res>
    implements $PlainPostCopyWith<$Res> {
  _$PlainPostCopyWithImpl(this._self, this._then);

  final PlainPost _self;
  final $Res Function(PlainPost) _then;

/// Create a copy of PostDoc
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? text = null,}) {
  return _then(PlainPost(
null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$Block {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Block);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'Block()';
}


}

/// @nodoc
class $BlockCopyWith<$Res>  {
$BlockCopyWith(Block _, $Res Function(Block) __);
}


/// Adds pattern-matching-related methods to [Block].
extension BlockPatterns on Block {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Paragraph value)?  paragraph,TResult Function( Heading value)?  heading,TResult Function( CodeBlock value)?  code,TResult Function( MathBlock value)?  math,TResult Function( Quote value)?  quote,TResult Function( ListBlock value)?  list,TResult Function( TableBlock value)?  table,TResult Function( Rule value)?  rule,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Paragraph() when paragraph != null:
return paragraph(_that);case Heading() when heading != null:
return heading(_that);case CodeBlock() when code != null:
return code(_that);case MathBlock() when math != null:
return math(_that);case Quote() when quote != null:
return quote(_that);case ListBlock() when list != null:
return list(_that);case TableBlock() when table != null:
return table(_that);case Rule() when rule != null:
return rule(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Paragraph value)  paragraph,required TResult Function( Heading value)  heading,required TResult Function( CodeBlock value)  code,required TResult Function( MathBlock value)  math,required TResult Function( Quote value)  quote,required TResult Function( ListBlock value)  list,required TResult Function( TableBlock value)  table,required TResult Function( Rule value)  rule,}){
final _that = this;
switch (_that) {
case Paragraph():
return paragraph(_that);case Heading():
return heading(_that);case CodeBlock():
return code(_that);case MathBlock():
return math(_that);case Quote():
return quote(_that);case ListBlock():
return list(_that);case TableBlock():
return table(_that);case Rule():
return rule(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Paragraph value)?  paragraph,TResult? Function( Heading value)?  heading,TResult? Function( CodeBlock value)?  code,TResult? Function( MathBlock value)?  math,TResult? Function( Quote value)?  quote,TResult? Function( ListBlock value)?  list,TResult? Function( TableBlock value)?  table,TResult? Function( Rule value)?  rule,}){
final _that = this;
switch (_that) {
case Paragraph() when paragraph != null:
return paragraph(_that);case Heading() when heading != null:
return heading(_that);case CodeBlock() when code != null:
return code(_that);case MathBlock() when math != null:
return math(_that);case Quote() when quote != null:
return quote(_that);case ListBlock() when list != null:
return list(_that);case TableBlock() when table != null:
return table(_that);case Rule() when rule != null:
return rule(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( List<Inline> inlines)?  paragraph,TResult Function( int level,  List<Inline> inlines)?  heading,TResult Function( String code,  String language)?  code,TResult Function( String tex)?  math,TResult Function( List<Block> blocks)?  quote,TResult Function( List<ListItem> items,  bool ordered,  int start)?  list,TResult Function( List<CellAlign> align,  List<List<List<Inline>>> rows)?  table,TResult Function()?  rule,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Paragraph() when paragraph != null:
return paragraph(_that.inlines);case Heading() when heading != null:
return heading(_that.level,_that.inlines);case CodeBlock() when code != null:
return code(_that.code,_that.language);case MathBlock() when math != null:
return math(_that.tex);case Quote() when quote != null:
return quote(_that.blocks);case ListBlock() when list != null:
return list(_that.items,_that.ordered,_that.start);case TableBlock() when table != null:
return table(_that.align,_that.rows);case Rule() when rule != null:
return rule();case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( List<Inline> inlines)  paragraph,required TResult Function( int level,  List<Inline> inlines)  heading,required TResult Function( String code,  String language)  code,required TResult Function( String tex)  math,required TResult Function( List<Block> blocks)  quote,required TResult Function( List<ListItem> items,  bool ordered,  int start)  list,required TResult Function( List<CellAlign> align,  List<List<List<Inline>>> rows)  table,required TResult Function()  rule,}) {final _that = this;
switch (_that) {
case Paragraph():
return paragraph(_that.inlines);case Heading():
return heading(_that.level,_that.inlines);case CodeBlock():
return code(_that.code,_that.language);case MathBlock():
return math(_that.tex);case Quote():
return quote(_that.blocks);case ListBlock():
return list(_that.items,_that.ordered,_that.start);case TableBlock():
return table(_that.align,_that.rows);case Rule():
return rule();}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( List<Inline> inlines)?  paragraph,TResult? Function( int level,  List<Inline> inlines)?  heading,TResult? Function( String code,  String language)?  code,TResult? Function( String tex)?  math,TResult? Function( List<Block> blocks)?  quote,TResult? Function( List<ListItem> items,  bool ordered,  int start)?  list,TResult? Function( List<CellAlign> align,  List<List<List<Inline>>> rows)?  table,TResult? Function()?  rule,}) {final _that = this;
switch (_that) {
case Paragraph() when paragraph != null:
return paragraph(_that.inlines);case Heading() when heading != null:
return heading(_that.level,_that.inlines);case CodeBlock() when code != null:
return code(_that.code,_that.language);case MathBlock() when math != null:
return math(_that.tex);case Quote() when quote != null:
return quote(_that.blocks);case ListBlock() when list != null:
return list(_that.items,_that.ordered,_that.start);case TableBlock() when table != null:
return table(_that.align,_that.rows);case Rule() when rule != null:
return rule();case _:
  return null;

}
}

}

/// @nodoc


class Paragraph implements Block {
  const Paragraph( List<Inline> inlines): _inlines = inlines;
  

 final  List<Inline> _inlines;
 List<Inline> get inlines {
  if (_inlines is EqualUnmodifiableListView) return _inlines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_inlines);
}


/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParagraphCopyWith<Paragraph> get copyWith => _$ParagraphCopyWithImpl<Paragraph>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Paragraph&&const DeepCollectionEquality().equals(other.inlines, _inlines));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_inlines));
}

@override
String toString() {
    return 'Block.paragraph(inlines: $inlines)';
}


}

/// @nodoc
abstract mixin class $ParagraphCopyWith<$Res> implements $BlockCopyWith<$Res> {
  factory $ParagraphCopyWith(Paragraph value, $Res Function(Paragraph) _then) = _$ParagraphCopyWithImpl;
@useResult
$Res call({
 List<Inline> inlines
});




}
/// @nodoc
class _$ParagraphCopyWithImpl<$Res>
    implements $ParagraphCopyWith<$Res> {
  _$ParagraphCopyWithImpl(this._self, this._then);

  final Paragraph _self;
  final $Res Function(Paragraph) _then;

/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? inlines = null,}) {
  return _then(Paragraph(
null == inlines ? _self._inlines : inlines // ignore: cast_nullable_to_non_nullable
as List<Inline>,
  ));
}


}

/// @nodoc


class Heading implements Block {
  const Heading(this.level,  List<Inline> inlines): _inlines = inlines;
  

 final  int level;
 final  List<Inline> _inlines;
 List<Inline> get inlines {
  if (_inlines is EqualUnmodifiableListView) return _inlines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_inlines);
}


/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HeadingCopyWith<Heading> get copyWith => _$HeadingCopyWithImpl<Heading>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Heading&&(identical(other.level, level) || other.level == level)&&const DeepCollectionEquality().equals(other.inlines, _inlines));
}


@override
int get hashCode {
    return Object.hash(runtimeType,level,const DeepCollectionEquality().hash(_inlines));
}

@override
String toString() {
    return 'Block.heading(level: $level, inlines: $inlines)';
}


}

/// @nodoc
abstract mixin class $HeadingCopyWith<$Res> implements $BlockCopyWith<$Res> {
  factory $HeadingCopyWith(Heading value, $Res Function(Heading) _then) = _$HeadingCopyWithImpl;
@useResult
$Res call({
 int level, List<Inline> inlines
});




}
/// @nodoc
class _$HeadingCopyWithImpl<$Res>
    implements $HeadingCopyWith<$Res> {
  _$HeadingCopyWithImpl(this._self, this._then);

  final Heading _self;
  final $Res Function(Heading) _then;

/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? level = null,Object? inlines = null,}) {
  return _then(Heading(
null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,null == inlines ? _self._inlines : inlines // ignore: cast_nullable_to_non_nullable
as List<Inline>,
  ));
}


}

/// @nodoc


class CodeBlock implements Block {
  const CodeBlock(this.code, {this.language = ''});
  

 final  String code;
@JsonKey() final  String language;

/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CodeBlockCopyWith<CodeBlock> get copyWith => _$CodeBlockCopyWithImpl<CodeBlock>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CodeBlock&&(identical(other.code, code) || other.code == code)&&(identical(other.language, language) || other.language == language));
}


@override
int get hashCode {
    return Object.hash(runtimeType,code,language);
}

@override
String toString() {
    return 'Block.code(code: $code, language: $language)';
}


}

/// @nodoc
abstract mixin class $CodeBlockCopyWith<$Res> implements $BlockCopyWith<$Res> {
  factory $CodeBlockCopyWith(CodeBlock value, $Res Function(CodeBlock) _then) = _$CodeBlockCopyWithImpl;
@useResult
$Res call({
 String code, String language
});




}
/// @nodoc
class _$CodeBlockCopyWithImpl<$Res>
    implements $CodeBlockCopyWith<$Res> {
  _$CodeBlockCopyWithImpl(this._self, this._then);

  final CodeBlock _self;
  final $Res Function(CodeBlock) _then;

/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? code = null,Object? language = null,}) {
  return _then(CodeBlock(
null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class MathBlock implements Block {
  const MathBlock(this.tex);
  

 final  String tex;

/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MathBlockCopyWith<MathBlock> get copyWith => _$MathBlockCopyWithImpl<MathBlock>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MathBlock&&(identical(other.tex, tex) || other.tex == tex));
}


@override
int get hashCode {
    return Object.hash(runtimeType,tex);
}

@override
String toString() {
    return 'Block.math(tex: $tex)';
}


}

/// @nodoc
abstract mixin class $MathBlockCopyWith<$Res> implements $BlockCopyWith<$Res> {
  factory $MathBlockCopyWith(MathBlock value, $Res Function(MathBlock) _then) = _$MathBlockCopyWithImpl;
@useResult
$Res call({
 String tex
});




}
/// @nodoc
class _$MathBlockCopyWithImpl<$Res>
    implements $MathBlockCopyWith<$Res> {
  _$MathBlockCopyWithImpl(this._self, this._then);

  final MathBlock _self;
  final $Res Function(MathBlock) _then;

/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? tex = null,}) {
  return _then(MathBlock(
null == tex ? _self.tex : tex // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class Quote implements Block {
  const Quote( List<Block> blocks): _blocks = blocks;
  

 final  List<Block> _blocks;
 List<Block> get blocks {
  if (_blocks is EqualUnmodifiableListView) return _blocks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_blocks);
}


/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuoteCopyWith<Quote> get copyWith => _$QuoteCopyWithImpl<Quote>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Quote&&const DeepCollectionEquality().equals(other.blocks, _blocks));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_blocks));
}

@override
String toString() {
    return 'Block.quote(blocks: $blocks)';
}


}

/// @nodoc
abstract mixin class $QuoteCopyWith<$Res> implements $BlockCopyWith<$Res> {
  factory $QuoteCopyWith(Quote value, $Res Function(Quote) _then) = _$QuoteCopyWithImpl;
@useResult
$Res call({
 List<Block> blocks
});




}
/// @nodoc
class _$QuoteCopyWithImpl<$Res>
    implements $QuoteCopyWith<$Res> {
  _$QuoteCopyWithImpl(this._self, this._then);

  final Quote _self;
  final $Res Function(Quote) _then;

/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? blocks = null,}) {
  return _then(Quote(
null == blocks ? _self._blocks : blocks // ignore: cast_nullable_to_non_nullable
as List<Block>,
  ));
}


}

/// @nodoc


class ListBlock implements Block {
  const ListBlock( List<ListItem> items, {this.ordered = false, this.start = 1}): _items = items;
  

 final  List<ListItem> _items;
 List<ListItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@JsonKey() final  bool ordered;
@JsonKey() final  int start;

/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListBlockCopyWith<ListBlock> get copyWith => _$ListBlockCopyWithImpl<ListBlock>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ListBlock&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.ordered, ordered) || other.ordered == ordered)&&(identical(other.start, start) || other.start == start));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),ordered,start);
}

@override
String toString() {
    return 'Block.list(items: $items, ordered: $ordered, start: $start)';
}


}

/// @nodoc
abstract mixin class $ListBlockCopyWith<$Res> implements $BlockCopyWith<$Res> {
  factory $ListBlockCopyWith(ListBlock value, $Res Function(ListBlock) _then) = _$ListBlockCopyWithImpl;
@useResult
$Res call({
 List<ListItem> items, bool ordered, int start
});




}
/// @nodoc
class _$ListBlockCopyWithImpl<$Res>
    implements $ListBlockCopyWith<$Res> {
  _$ListBlockCopyWithImpl(this._self, this._then);

  final ListBlock _self;
  final $Res Function(ListBlock) _then;

/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? items = null,Object? ordered = null,Object? start = null,}) {
  return _then(ListBlock(
null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ListItem>,ordered: null == ordered ? _self.ordered : ordered // ignore: cast_nullable_to_non_nullable
as bool,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class TableBlock implements Block {
  const TableBlock( List<CellAlign> align,  List<List<List<Inline>>> rows): _align = align,_rows = rows;
  

 final  List<CellAlign> _align;
 List<CellAlign> get align {
  if (_align is EqualUnmodifiableListView) return _align;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_align);
}

 final  List<List<List<Inline>>> _rows;
 List<List<List<Inline>>> get rows {
  if (_rows is EqualUnmodifiableListView) return _rows;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rows);
}


/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TableBlockCopyWith<TableBlock> get copyWith => _$TableBlockCopyWithImpl<TableBlock>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TableBlock&&const DeepCollectionEquality().equals(other.align, _align)&&const DeepCollectionEquality().equals(other.rows, _rows));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_align),const DeepCollectionEquality().hash(_rows));
}

@override
String toString() {
    return 'Block.table(align: $align, rows: $rows)';
}


}

/// @nodoc
abstract mixin class $TableBlockCopyWith<$Res> implements $BlockCopyWith<$Res> {
  factory $TableBlockCopyWith(TableBlock value, $Res Function(TableBlock) _then) = _$TableBlockCopyWithImpl;
@useResult
$Res call({
 List<CellAlign> align, List<List<List<Inline>>> rows
});




}
/// @nodoc
class _$TableBlockCopyWithImpl<$Res>
    implements $TableBlockCopyWith<$Res> {
  _$TableBlockCopyWithImpl(this._self, this._then);

  final TableBlock _self;
  final $Res Function(TableBlock) _then;

/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? align = null,Object? rows = null,}) {
  return _then(TableBlock(
null == align ? _self._align : align // ignore: cast_nullable_to_non_nullable
as List<CellAlign>,null == rows ? _self._rows : rows // ignore: cast_nullable_to_non_nullable
as List<List<List<Inline>>>,
  ));
}


}

/// @nodoc


class Rule implements Block {
  const Rule();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Rule);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'Block.rule()';
}


}




/// @nodoc
mixin _$ListItem {

 List<Block> get blocks;/// A task list item: done or not.
 bool? get checked;
/// Create a copy of ListItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListItemCopyWith<ListItem> get copyWith => _$ListItemCopyWithImpl<ListItem>(this as ListItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ListItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListItem&&const DeepCollectionEquality().equals(other.blocks, _this.blocks)&&(identical(other.checked, _this.checked) || other.checked == _this.checked));
}


@override
int get hashCode {
  final _this = this as ListItem;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.blocks),_this.checked);
}

@override
String toString() {
  final _this = this as ListItem;
  return 'ListItem(blocks: ${_this.blocks}, checked: ${_this.checked})';
}


}

/// @nodoc
abstract mixin class $ListItemCopyWith<$Res>  {
  factory $ListItemCopyWith(ListItem value, $Res Function(ListItem) _then) = _$ListItemCopyWithImpl;
@useResult
$Res call({
 List<Block> blocks, bool? checked
});




}
/// @nodoc
class _$ListItemCopyWithImpl<$Res>
    implements $ListItemCopyWith<$Res> {
  _$ListItemCopyWithImpl(this._self, this._then);

  final ListItem _self;
  final $Res Function(ListItem) _then;

/// Create a copy of ListItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? blocks = null,Object? checked = freezed,}) {
  return _then(ListItem(
null == blocks ? _self.blocks : blocks // ignore: cast_nullable_to_non_nullable
as List<Block>,checked: freezed == checked ? _self.checked : checked // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [ListItem].
extension ListItemPatterns on ListItem {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListItem() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListItem value)  $default,){
final _that = this;
switch (_that) {
case _ListItem():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListItem value)?  $default,){
final _that = this;
switch (_that) {
case _ListItem() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Block> blocks,  bool? checked)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListItem() when $default != null:
return $default(_that.blocks,_that.checked);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Block> blocks,  bool? checked)  $default,) {final _that = this;
switch (_that) {
case _ListItem():
return $default(_that.blocks,_that.checked);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Block> blocks,  bool? checked)?  $default,) {final _that = this;
switch (_that) {
case _ListItem() when $default != null:
return $default(_that.blocks,_that.checked);case _:
  return null;

}
}

}

/// @nodoc


class _ListItem implements ListItem {
  const _ListItem( List<Block> blocks, {this.checked}): _blocks = blocks;
  

 final  List<Block> _blocks;
@override List<Block> get blocks {
  if (_blocks is EqualUnmodifiableListView) return _blocks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_blocks);
}

/// A task list item: done or not.
@override final  bool? checked;

/// Create a copy of ListItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListItemCopyWith<_ListItem> get copyWith => __$ListItemCopyWithImpl<_ListItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListItem&&const DeepCollectionEquality().equals(other.blocks, _blocks)&&(identical(other.checked, checked) || other.checked == checked));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_blocks),checked);
}

@override
String toString() {
    return 'ListItem(blocks: $blocks, checked: $checked)';
}


}

/// @nodoc
abstract mixin class _$ListItemCopyWith<$Res> implements $ListItemCopyWith<$Res> {
  factory _$ListItemCopyWith(_ListItem value, $Res Function(_ListItem) _then) = __$ListItemCopyWithImpl;
@override @useResult
$Res call({
 List<Block> blocks, bool? checked
});




}
/// @nodoc
class __$ListItemCopyWithImpl<$Res>
    implements _$ListItemCopyWith<$Res> {
  __$ListItemCopyWithImpl(this._self, this._then);

  final _ListItem _self;
  final $Res Function(_ListItem) _then;

/// Create a copy of ListItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? blocks = null,Object? checked = freezed,}) {
  return _then(_ListItem(
null == blocks ? _self._blocks : blocks // ignore: cast_nullable_to_non_nullable
as List<Block>,checked: freezed == checked ? _self.checked : checked // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

/// @nodoc
mixin _$Inline {

 int get marks; String? get link;
/// Create a copy of Inline
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InlineCopyWith<Inline> get copyWith => _$InlineCopyWithImpl<Inline>(this as Inline, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Inline;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Inline&&(identical(other.marks, _this.marks) || other.marks == _this.marks)&&(identical(other.link, _this.link) || other.link == _this.link));
}


@override
int get hashCode {
  final _this = this as Inline;
  return Object.hash(runtimeType,_this.marks,_this.link);
}

@override
String toString() {
  final _this = this as Inline;
  return 'Inline(marks: ${_this.marks}, link: ${_this.link})';
}


}

/// @nodoc
abstract mixin class $InlineCopyWith<$Res>  {
  factory $InlineCopyWith(Inline value, $Res Function(Inline) _then) = _$InlineCopyWithImpl;
@useResult
$Res call({
 int marks, String? link
});




}
/// @nodoc
class _$InlineCopyWithImpl<$Res>
    implements $InlineCopyWith<$Res> {
  _$InlineCopyWithImpl(this._self, this._then);

  final Inline _self;
  final $Res Function(Inline) _then;

/// Create a copy of Inline
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? marks = null,Object? link = freezed,}) {
  return _then(_self.copyWith(
marks: null == marks ? _self.marks : marks // ignore: cast_nullable_to_non_nullable
as int,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Inline].
extension InlinePatterns on Inline {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( TextPart value)?  text,TResult Function( CodePart value)?  code,TResult Function( MentionPart value)?  mention,TResult Function( ChannelPart value)?  channel,TResult Function( EmojiPart value)?  emoji,TResult Function( HashtagPart value)?  hashtag,TResult Function( MathPart value)?  math,TResult Function( ImagePart value)?  image,TResult Function( BreakPart value)?  lineBreak,required TResult orElse(),}){
final _that = this;
switch (_that) {
case TextPart() when text != null:
return text(_that);case CodePart() when code != null:
return code(_that);case MentionPart() when mention != null:
return mention(_that);case ChannelPart() when channel != null:
return channel(_that);case EmojiPart() when emoji != null:
return emoji(_that);case HashtagPart() when hashtag != null:
return hashtag(_that);case MathPart() when math != null:
return math(_that);case ImagePart() when image != null:
return image(_that);case BreakPart() when lineBreak != null:
return lineBreak(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( TextPart value)  text,required TResult Function( CodePart value)  code,required TResult Function( MentionPart value)  mention,required TResult Function( ChannelPart value)  channel,required TResult Function( EmojiPart value)  emoji,required TResult Function( HashtagPart value)  hashtag,required TResult Function( MathPart value)  math,required TResult Function( ImagePart value)  image,required TResult Function( BreakPart value)  lineBreak,}){
final _that = this;
switch (_that) {
case TextPart():
return text(_that);case CodePart():
return code(_that);case MentionPart():
return mention(_that);case ChannelPart():
return channel(_that);case EmojiPart():
return emoji(_that);case HashtagPart():
return hashtag(_that);case MathPart():
return math(_that);case ImagePart():
return image(_that);case BreakPart():
return lineBreak(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( TextPart value)?  text,TResult? Function( CodePart value)?  code,TResult? Function( MentionPart value)?  mention,TResult? Function( ChannelPart value)?  channel,TResult? Function( EmojiPart value)?  emoji,TResult? Function( HashtagPart value)?  hashtag,TResult? Function( MathPart value)?  math,TResult? Function( ImagePart value)?  image,TResult? Function( BreakPart value)?  lineBreak,}){
final _that = this;
switch (_that) {
case TextPart() when text != null:
return text(_that);case CodePart() when code != null:
return code(_that);case MentionPart() when mention != null:
return mention(_that);case ChannelPart() when channel != null:
return channel(_that);case EmojiPart() when emoji != null:
return emoji(_that);case HashtagPart() when hashtag != null:
return hashtag(_that);case MathPart() when math != null:
return math(_that);case ImagePart() when image != null:
return image(_that);case BreakPart() when lineBreak != null:
return lineBreak(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String text,  int marks,  String? link)?  text,TResult Function( String text,  int marks,  String? link)?  code,TResult Function( String name,  int marks,  String? link)?  mention,TResult Function( String name,  int marks,  String? link)?  channel,TResult Function( String name,  String literal,  int marks,  String? link)?  emoji,TResult Function( String tag,  int marks,  String? link)?  hashtag,TResult Function( String tex,  int marks,  String? link)?  math,TResult Function( String url,  String alt,  int? width,  int? height,  int marks,  String? link)?  image,TResult Function( int marks,  String? link)?  lineBreak,required TResult orElse(),}) {final _that = this;
switch (_that) {
case TextPart() when text != null:
return text(_that.text,_that.marks,_that.link);case CodePart() when code != null:
return code(_that.text,_that.marks,_that.link);case MentionPart() when mention != null:
return mention(_that.name,_that.marks,_that.link);case ChannelPart() when channel != null:
return channel(_that.name,_that.marks,_that.link);case EmojiPart() when emoji != null:
return emoji(_that.name,_that.literal,_that.marks,_that.link);case HashtagPart() when hashtag != null:
return hashtag(_that.tag,_that.marks,_that.link);case MathPart() when math != null:
return math(_that.tex,_that.marks,_that.link);case ImagePart() when image != null:
return image(_that.url,_that.alt,_that.width,_that.height,_that.marks,_that.link);case BreakPart() when lineBreak != null:
return lineBreak(_that.marks,_that.link);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String text,  int marks,  String? link)  text,required TResult Function( String text,  int marks,  String? link)  code,required TResult Function( String name,  int marks,  String? link)  mention,required TResult Function( String name,  int marks,  String? link)  channel,required TResult Function( String name,  String literal,  int marks,  String? link)  emoji,required TResult Function( String tag,  int marks,  String? link)  hashtag,required TResult Function( String tex,  int marks,  String? link)  math,required TResult Function( String url,  String alt,  int? width,  int? height,  int marks,  String? link)  image,required TResult Function( int marks,  String? link)  lineBreak,}) {final _that = this;
switch (_that) {
case TextPart():
return text(_that.text,_that.marks,_that.link);case CodePart():
return code(_that.text,_that.marks,_that.link);case MentionPart():
return mention(_that.name,_that.marks,_that.link);case ChannelPart():
return channel(_that.name,_that.marks,_that.link);case EmojiPart():
return emoji(_that.name,_that.literal,_that.marks,_that.link);case HashtagPart():
return hashtag(_that.tag,_that.marks,_that.link);case MathPart():
return math(_that.tex,_that.marks,_that.link);case ImagePart():
return image(_that.url,_that.alt,_that.width,_that.height,_that.marks,_that.link);case BreakPart():
return lineBreak(_that.marks,_that.link);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String text,  int marks,  String? link)?  text,TResult? Function( String text,  int marks,  String? link)?  code,TResult? Function( String name,  int marks,  String? link)?  mention,TResult? Function( String name,  int marks,  String? link)?  channel,TResult? Function( String name,  String literal,  int marks,  String? link)?  emoji,TResult? Function( String tag,  int marks,  String? link)?  hashtag,TResult? Function( String tex,  int marks,  String? link)?  math,TResult? Function( String url,  String alt,  int? width,  int? height,  int marks,  String? link)?  image,TResult? Function( int marks,  String? link)?  lineBreak,}) {final _that = this;
switch (_that) {
case TextPart() when text != null:
return text(_that.text,_that.marks,_that.link);case CodePart() when code != null:
return code(_that.text,_that.marks,_that.link);case MentionPart() when mention != null:
return mention(_that.name,_that.marks,_that.link);case ChannelPart() when channel != null:
return channel(_that.name,_that.marks,_that.link);case EmojiPart() when emoji != null:
return emoji(_that.name,_that.literal,_that.marks,_that.link);case HashtagPart() when hashtag != null:
return hashtag(_that.tag,_that.marks,_that.link);case MathPart() when math != null:
return math(_that.tex,_that.marks,_that.link);case ImagePart() when image != null:
return image(_that.url,_that.alt,_that.width,_that.height,_that.marks,_that.link);case BreakPart() when lineBreak != null:
return lineBreak(_that.marks,_that.link);case _:
  return null;

}
}

}

/// @nodoc


class TextPart implements Inline {
  const TextPart(this.text, {this.marks = 0, this.link});
  

 final  String text;
@override@JsonKey() final  int marks;
@override final  String? link;

/// Create a copy of Inline
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TextPartCopyWith<TextPart> get copyWith => _$TextPartCopyWithImpl<TextPart>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TextPart&&(identical(other.text, text) || other.text == text)&&(identical(other.marks, marks) || other.marks == marks)&&(identical(other.link, link) || other.link == link));
}


@override
int get hashCode {
    return Object.hash(runtimeType,text,marks,link);
}

@override
String toString() {
    return 'Inline.text(text: $text, marks: $marks, link: $link)';
}


}

/// @nodoc
abstract mixin class $TextPartCopyWith<$Res> implements $InlineCopyWith<$Res> {
  factory $TextPartCopyWith(TextPart value, $Res Function(TextPart) _then) = _$TextPartCopyWithImpl;
@override @useResult
$Res call({
 String text, int marks, String? link
});




}
/// @nodoc
class _$TextPartCopyWithImpl<$Res>
    implements $TextPartCopyWith<$Res> {
  _$TextPartCopyWithImpl(this._self, this._then);

  final TextPart _self;
  final $Res Function(TextPart) _then;

/// Create a copy of Inline
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? marks = null,Object? link = freezed,}) {
  return _then(TextPart(
null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,marks: null == marks ? _self.marks : marks // ignore: cast_nullable_to_non_nullable
as int,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class CodePart implements Inline {
  const CodePart(this.text, {this.marks = 0, this.link});
  

 final  String text;
@override@JsonKey() final  int marks;
@override final  String? link;

/// Create a copy of Inline
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CodePartCopyWith<CodePart> get copyWith => _$CodePartCopyWithImpl<CodePart>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CodePart&&(identical(other.text, text) || other.text == text)&&(identical(other.marks, marks) || other.marks == marks)&&(identical(other.link, link) || other.link == link));
}


@override
int get hashCode {
    return Object.hash(runtimeType,text,marks,link);
}

@override
String toString() {
    return 'Inline.code(text: $text, marks: $marks, link: $link)';
}


}

/// @nodoc
abstract mixin class $CodePartCopyWith<$Res> implements $InlineCopyWith<$Res> {
  factory $CodePartCopyWith(CodePart value, $Res Function(CodePart) _then) = _$CodePartCopyWithImpl;
@override @useResult
$Res call({
 String text, int marks, String? link
});




}
/// @nodoc
class _$CodePartCopyWithImpl<$Res>
    implements $CodePartCopyWith<$Res> {
  _$CodePartCopyWithImpl(this._self, this._then);

  final CodePart _self;
  final $Res Function(CodePart) _then;

/// Create a copy of Inline
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? marks = null,Object? link = freezed,}) {
  return _then(CodePart(
null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,marks: null == marks ? _self.marks : marks // ignore: cast_nullable_to_non_nullable
as int,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class MentionPart implements Inline {
  const MentionPart(this.name, {this.marks = 0, this.link});
  

 final  String name;
@override@JsonKey() final  int marks;
@override final  String? link;

/// Create a copy of Inline
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MentionPartCopyWith<MentionPart> get copyWith => _$MentionPartCopyWithImpl<MentionPart>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MentionPart&&(identical(other.name, name) || other.name == name)&&(identical(other.marks, marks) || other.marks == marks)&&(identical(other.link, link) || other.link == link));
}


@override
int get hashCode {
    return Object.hash(runtimeType,name,marks,link);
}

@override
String toString() {
    return 'Inline.mention(name: $name, marks: $marks, link: $link)';
}


}

/// @nodoc
abstract mixin class $MentionPartCopyWith<$Res> implements $InlineCopyWith<$Res> {
  factory $MentionPartCopyWith(MentionPart value, $Res Function(MentionPart) _then) = _$MentionPartCopyWithImpl;
@override @useResult
$Res call({
 String name, int marks, String? link
});




}
/// @nodoc
class _$MentionPartCopyWithImpl<$Res>
    implements $MentionPartCopyWith<$Res> {
  _$MentionPartCopyWithImpl(this._self, this._then);

  final MentionPart _self;
  final $Res Function(MentionPart) _then;

/// Create a copy of Inline
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? marks = null,Object? link = freezed,}) {
  return _then(MentionPart(
null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,marks: null == marks ? _self.marks : marks // ignore: cast_nullable_to_non_nullable
as int,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class ChannelPart implements Inline {
  const ChannelPart(this.name, {this.marks = 0, this.link});
  

 final  String name;
@override@JsonKey() final  int marks;
@override final  String? link;

/// Create a copy of Inline
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChannelPartCopyWith<ChannelPart> get copyWith => _$ChannelPartCopyWithImpl<ChannelPart>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ChannelPart&&(identical(other.name, name) || other.name == name)&&(identical(other.marks, marks) || other.marks == marks)&&(identical(other.link, link) || other.link == link));
}


@override
int get hashCode {
    return Object.hash(runtimeType,name,marks,link);
}

@override
String toString() {
    return 'Inline.channel(name: $name, marks: $marks, link: $link)';
}


}

/// @nodoc
abstract mixin class $ChannelPartCopyWith<$Res> implements $InlineCopyWith<$Res> {
  factory $ChannelPartCopyWith(ChannelPart value, $Res Function(ChannelPart) _then) = _$ChannelPartCopyWithImpl;
@override @useResult
$Res call({
 String name, int marks, String? link
});




}
/// @nodoc
class _$ChannelPartCopyWithImpl<$Res>
    implements $ChannelPartCopyWith<$Res> {
  _$ChannelPartCopyWithImpl(this._self, this._then);

  final ChannelPart _self;
  final $Res Function(ChannelPart) _then;

/// Create a copy of Inline
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? marks = null,Object? link = freezed,}) {
  return _then(ChannelPart(
null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,marks: null == marks ? _self.marks : marks // ignore: cast_nullable_to_non_nullable
as int,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class EmojiPart implements Inline {
  const EmojiPart(this.name, this.literal, {this.marks = 0, this.link});
  

 final  String name;
 final  String literal;
@override@JsonKey() final  int marks;
@override final  String? link;

/// Create a copy of Inline
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmojiPartCopyWith<EmojiPart> get copyWith => _$EmojiPartCopyWithImpl<EmojiPart>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EmojiPart&&(identical(other.name, name) || other.name == name)&&(identical(other.literal, literal) || other.literal == literal)&&(identical(other.marks, marks) || other.marks == marks)&&(identical(other.link, link) || other.link == link));
}


@override
int get hashCode {
    return Object.hash(runtimeType,name,literal,marks,link);
}

@override
String toString() {
    return 'Inline.emoji(name: $name, literal: $literal, marks: $marks, link: $link)';
}


}

/// @nodoc
abstract mixin class $EmojiPartCopyWith<$Res> implements $InlineCopyWith<$Res> {
  factory $EmojiPartCopyWith(EmojiPart value, $Res Function(EmojiPart) _then) = _$EmojiPartCopyWithImpl;
@override @useResult
$Res call({
 String name, String literal, int marks, String? link
});




}
/// @nodoc
class _$EmojiPartCopyWithImpl<$Res>
    implements $EmojiPartCopyWith<$Res> {
  _$EmojiPartCopyWithImpl(this._self, this._then);

  final EmojiPart _self;
  final $Res Function(EmojiPart) _then;

/// Create a copy of Inline
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? literal = null,Object? marks = null,Object? link = freezed,}) {
  return _then(EmojiPart(
null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,null == literal ? _self.literal : literal // ignore: cast_nullable_to_non_nullable
as String,marks: null == marks ? _self.marks : marks // ignore: cast_nullable_to_non_nullable
as int,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class HashtagPart implements Inline {
  const HashtagPart(this.tag, {this.marks = 0, this.link});
  

 final  String tag;
@override@JsonKey() final  int marks;
@override final  String? link;

/// Create a copy of Inline
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HashtagPartCopyWith<HashtagPart> get copyWith => _$HashtagPartCopyWithImpl<HashtagPart>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is HashtagPart&&(identical(other.tag, tag) || other.tag == tag)&&(identical(other.marks, marks) || other.marks == marks)&&(identical(other.link, link) || other.link == link));
}


@override
int get hashCode {
    return Object.hash(runtimeType,tag,marks,link);
}

@override
String toString() {
    return 'Inline.hashtag(tag: $tag, marks: $marks, link: $link)';
}


}

/// @nodoc
abstract mixin class $HashtagPartCopyWith<$Res> implements $InlineCopyWith<$Res> {
  factory $HashtagPartCopyWith(HashtagPart value, $Res Function(HashtagPart) _then) = _$HashtagPartCopyWithImpl;
@override @useResult
$Res call({
 String tag, int marks, String? link
});




}
/// @nodoc
class _$HashtagPartCopyWithImpl<$Res>
    implements $HashtagPartCopyWith<$Res> {
  _$HashtagPartCopyWithImpl(this._self, this._then);

  final HashtagPart _self;
  final $Res Function(HashtagPart) _then;

/// Create a copy of Inline
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tag = null,Object? marks = null,Object? link = freezed,}) {
  return _then(HashtagPart(
null == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as String,marks: null == marks ? _self.marks : marks // ignore: cast_nullable_to_non_nullable
as int,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class MathPart implements Inline {
  const MathPart(this.tex, {this.marks = 0, this.link});
  

 final  String tex;
@override@JsonKey() final  int marks;
@override final  String? link;

/// Create a copy of Inline
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MathPartCopyWith<MathPart> get copyWith => _$MathPartCopyWithImpl<MathPart>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MathPart&&(identical(other.tex, tex) || other.tex == tex)&&(identical(other.marks, marks) || other.marks == marks)&&(identical(other.link, link) || other.link == link));
}


@override
int get hashCode {
    return Object.hash(runtimeType,tex,marks,link);
}

@override
String toString() {
    return 'Inline.math(tex: $tex, marks: $marks, link: $link)';
}


}

/// @nodoc
abstract mixin class $MathPartCopyWith<$Res> implements $InlineCopyWith<$Res> {
  factory $MathPartCopyWith(MathPart value, $Res Function(MathPart) _then) = _$MathPartCopyWithImpl;
@override @useResult
$Res call({
 String tex, int marks, String? link
});




}
/// @nodoc
class _$MathPartCopyWithImpl<$Res>
    implements $MathPartCopyWith<$Res> {
  _$MathPartCopyWithImpl(this._self, this._then);

  final MathPart _self;
  final $Res Function(MathPart) _then;

/// Create a copy of Inline
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tex = null,Object? marks = null,Object? link = freezed,}) {
  return _then(MathPart(
null == tex ? _self.tex : tex // ignore: cast_nullable_to_non_nullable
as String,marks: null == marks ? _self.marks : marks // ignore: cast_nullable_to_non_nullable
as int,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class ImagePart implements Inline {
  const ImagePart(this.url, {this.alt = '', this.width, this.height, this.marks = 0, this.link});
  

 final  String url;
@JsonKey() final  String alt;
 final  int? width;
 final  int? height;
@override@JsonKey() final  int marks;
@override final  String? link;

/// Create a copy of Inline
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImagePartCopyWith<ImagePart> get copyWith => _$ImagePartCopyWithImpl<ImagePart>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ImagePart&&(identical(other.url, url) || other.url == url)&&(identical(other.alt, alt) || other.alt == alt)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.marks, marks) || other.marks == marks)&&(identical(other.link, link) || other.link == link));
}


@override
int get hashCode {
    return Object.hash(runtimeType,url,alt,width,height,marks,link);
}

@override
String toString() {
    return 'Inline.image(url: $url, alt: $alt, width: $width, height: $height, marks: $marks, link: $link)';
}


}

/// @nodoc
abstract mixin class $ImagePartCopyWith<$Res> implements $InlineCopyWith<$Res> {
  factory $ImagePartCopyWith(ImagePart value, $Res Function(ImagePart) _then) = _$ImagePartCopyWithImpl;
@override @useResult
$Res call({
 String url, String alt, int? width, int? height, int marks, String? link
});




}
/// @nodoc
class _$ImagePartCopyWithImpl<$Res>
    implements $ImagePartCopyWith<$Res> {
  _$ImagePartCopyWithImpl(this._self, this._then);

  final ImagePart _self;
  final $Res Function(ImagePart) _then;

/// Create a copy of Inline
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? alt = null,Object? width = freezed,Object? height = freezed,Object? marks = null,Object? link = freezed,}) {
  return _then(ImagePart(
null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,alt: null == alt ? _self.alt : alt // ignore: cast_nullable_to_non_nullable
as String,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,marks: null == marks ? _self.marks : marks // ignore: cast_nullable_to_non_nullable
as int,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class BreakPart implements Inline {
  const BreakPart({this.marks = 0, this.link});
  

@override@JsonKey() final  int marks;
@override final  String? link;

/// Create a copy of Inline
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BreakPartCopyWith<BreakPart> get copyWith => _$BreakPartCopyWithImpl<BreakPart>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is BreakPart&&(identical(other.marks, marks) || other.marks == marks)&&(identical(other.link, link) || other.link == link));
}


@override
int get hashCode {
    return Object.hash(runtimeType,marks,link);
}

@override
String toString() {
    return 'Inline.lineBreak(marks: $marks, link: $link)';
}


}

/// @nodoc
abstract mixin class $BreakPartCopyWith<$Res> implements $InlineCopyWith<$Res> {
  factory $BreakPartCopyWith(BreakPart value, $Res Function(BreakPart) _then) = _$BreakPartCopyWithImpl;
@override @useResult
$Res call({
 int marks, String? link
});




}
/// @nodoc
class _$BreakPartCopyWithImpl<$Res>
    implements $BreakPartCopyWith<$Res> {
  _$BreakPartCopyWithImpl(this._self, this._then);

  final BreakPart _self;
  final $Res Function(BreakPart) _then;

/// Create a copy of Inline
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? marks = null,Object? link = freezed,}) {
  return _then(BreakPart(
marks: null == marks ? _self.marks : marks // ignore: cast_nullable_to_non_nullable
as int,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
