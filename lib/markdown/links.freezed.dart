// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'links.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LinkTarget {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LinkTarget);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'LinkTarget()';
}


}

/// @nodoc
class $LinkTargetCopyWith<$Res>  {
$LinkTargetCopyWith(LinkTarget _, $Res Function(LinkTarget) __);
}


/// Adds pattern-matching-related methods to [LinkTarget].
extension LinkTargetPatterns on LinkTarget {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ExternalLink value)?  external,TResult Function( PermalinkLink value)?  permalink,TResult Function( ChannelLink value)?  channel,TResult Function( NoLink value)?  none,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ExternalLink() when external != null:
return external(_that);case PermalinkLink() when permalink != null:
return permalink(_that);case ChannelLink() when channel != null:
return channel(_that);case NoLink() when none != null:
return none(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ExternalLink value)  external,required TResult Function( PermalinkLink value)  permalink,required TResult Function( ChannelLink value)  channel,required TResult Function( NoLink value)  none,}){
final _that = this;
switch (_that) {
case ExternalLink():
return external(_that);case PermalinkLink():
return permalink(_that);case ChannelLink():
return channel(_that);case NoLink():
return none(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ExternalLink value)?  external,TResult? Function( PermalinkLink value)?  permalink,TResult? Function( ChannelLink value)?  channel,TResult? Function( NoLink value)?  none,}){
final _that = this;
switch (_that) {
case ExternalLink() when external != null:
return external(_that);case PermalinkLink() when permalink != null:
return permalink(_that);case ChannelLink() when channel != null:
return channel(_that);case NoLink() when none != null:
return none(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( Uri uri)?  external,TResult Function( String team,  String postId)?  permalink,TResult Function( String team,  String name)?  channel,TResult Function()?  none,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ExternalLink() when external != null:
return external(_that.uri);case PermalinkLink() when permalink != null:
return permalink(_that.team,_that.postId);case ChannelLink() when channel != null:
return channel(_that.team,_that.name);case NoLink() when none != null:
return none();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( Uri uri)  external,required TResult Function( String team,  String postId)  permalink,required TResult Function( String team,  String name)  channel,required TResult Function()  none,}) {final _that = this;
switch (_that) {
case ExternalLink():
return external(_that.uri);case PermalinkLink():
return permalink(_that.team,_that.postId);case ChannelLink():
return channel(_that.team,_that.name);case NoLink():
return none();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( Uri uri)?  external,TResult? Function( String team,  String postId)?  permalink,TResult? Function( String team,  String name)?  channel,TResult? Function()?  none,}) {final _that = this;
switch (_that) {
case ExternalLink() when external != null:
return external(_that.uri);case PermalinkLink() when permalink != null:
return permalink(_that.team,_that.postId);case ChannelLink() when channel != null:
return channel(_that.team,_that.name);case NoLink() when none != null:
return none();case _:
  return null;

}
}

}

/// @nodoc


class ExternalLink implements LinkTarget {
  const ExternalLink(this.uri);
  

 final  Uri uri;

/// Create a copy of LinkTarget
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExternalLinkCopyWith<ExternalLink> get copyWith => _$ExternalLinkCopyWithImpl<ExternalLink>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ExternalLink&&(identical(other.uri, uri) || other.uri == uri));
}


@override
int get hashCode {
    return Object.hash(runtimeType,uri);
}

@override
String toString() {
    return 'LinkTarget.external(uri: $uri)';
}


}

/// @nodoc
abstract mixin class $ExternalLinkCopyWith<$Res> implements $LinkTargetCopyWith<$Res> {
  factory $ExternalLinkCopyWith(ExternalLink value, $Res Function(ExternalLink) _then) = _$ExternalLinkCopyWithImpl;
@useResult
$Res call({
 Uri uri
});




}
/// @nodoc
class _$ExternalLinkCopyWithImpl<$Res>
    implements $ExternalLinkCopyWith<$Res> {
  _$ExternalLinkCopyWithImpl(this._self, this._then);

  final ExternalLink _self;
  final $Res Function(ExternalLink) _then;

/// Create a copy of LinkTarget
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? uri = null,}) {
  return _then(ExternalLink(
null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as Uri,
  ));
}


}

/// @nodoc


class PermalinkLink implements LinkTarget {
  const PermalinkLink(this.team, this.postId);
  

 final  String team;
 final  String postId;

/// Create a copy of LinkTarget
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PermalinkLinkCopyWith<PermalinkLink> get copyWith => _$PermalinkLinkCopyWithImpl<PermalinkLink>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PermalinkLink&&(identical(other.team, team) || other.team == team)&&(identical(other.postId, postId) || other.postId == postId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,team,postId);
}

@override
String toString() {
    return 'LinkTarget.permalink(team: $team, postId: $postId)';
}


}

/// @nodoc
abstract mixin class $PermalinkLinkCopyWith<$Res> implements $LinkTargetCopyWith<$Res> {
  factory $PermalinkLinkCopyWith(PermalinkLink value, $Res Function(PermalinkLink) _then) = _$PermalinkLinkCopyWithImpl;
@useResult
$Res call({
 String team, String postId
});




}
/// @nodoc
class _$PermalinkLinkCopyWithImpl<$Res>
    implements $PermalinkLinkCopyWith<$Res> {
  _$PermalinkLinkCopyWithImpl(this._self, this._then);

  final PermalinkLink _self;
  final $Res Function(PermalinkLink) _then;

/// Create a copy of LinkTarget
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? team = null,Object? postId = null,}) {
  return _then(PermalinkLink(
null == team ? _self.team : team // ignore: cast_nullable_to_non_nullable
as String,null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ChannelLink implements LinkTarget {
  const ChannelLink(this.team, this.name);
  

 final  String team;
 final  String name;

/// Create a copy of LinkTarget
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChannelLinkCopyWith<ChannelLink> get copyWith => _$ChannelLinkCopyWithImpl<ChannelLink>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ChannelLink&&(identical(other.team, team) || other.team == team)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode {
    return Object.hash(runtimeType,team,name);
}

@override
String toString() {
    return 'LinkTarget.channel(team: $team, name: $name)';
}


}

/// @nodoc
abstract mixin class $ChannelLinkCopyWith<$Res> implements $LinkTargetCopyWith<$Res> {
  factory $ChannelLinkCopyWith(ChannelLink value, $Res Function(ChannelLink) _then) = _$ChannelLinkCopyWithImpl;
@useResult
$Res call({
 String team, String name
});




}
/// @nodoc
class _$ChannelLinkCopyWithImpl<$Res>
    implements $ChannelLinkCopyWith<$Res> {
  _$ChannelLinkCopyWithImpl(this._self, this._then);

  final ChannelLink _self;
  final $Res Function(ChannelLink) _then;

/// Create a copy of LinkTarget
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? team = null,Object? name = null,}) {
  return _then(ChannelLink(
null == team ? _self.team : team // ignore: cast_nullable_to_non_nullable
as String,null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class NoLink implements LinkTarget {
  const NoLink();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is NoLink);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'LinkTarget.none()';
}


}




// dart format on
