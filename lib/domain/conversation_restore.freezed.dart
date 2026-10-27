// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conversation_restore.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SavedConversation {

 String get url; String get channelId; String get title; String? get teamId; String? get rootId;
/// Create a copy of SavedConversation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavedConversationCopyWith<SavedConversation> get copyWith => _$SavedConversationCopyWithImpl<SavedConversation>(this as SavedConversation, _$identity);

  /// Serializes this SavedConversation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SavedConversation;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SavedConversation&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.channelId, _this.channelId) || other.channelId == _this.channelId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.teamId, _this.teamId) || other.teamId == _this.teamId)&&(identical(other.rootId, _this.rootId) || other.rootId == _this.rootId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SavedConversation;
  return Object.hash(runtimeType,_this.url,_this.channelId,_this.title,_this.teamId,_this.rootId);
}

@override
String toString() {
  final _this = this as SavedConversation;
  return 'SavedConversation(url: ${_this.url}, channelId: ${_this.channelId}, title: ${_this.title}, teamId: ${_this.teamId}, rootId: ${_this.rootId})';
}


}

/// @nodoc
abstract mixin class $SavedConversationCopyWith<$Res>  {
  factory $SavedConversationCopyWith(SavedConversation value, $Res Function(SavedConversation) _then) = _$SavedConversationCopyWithImpl;
@useResult
$Res call({
 String url, String channelId, String title, String? teamId, String? rootId
});




}
/// @nodoc
class _$SavedConversationCopyWithImpl<$Res>
    implements $SavedConversationCopyWith<$Res> {
  _$SavedConversationCopyWithImpl(this._self, this._then);

  final SavedConversation _self;
  final $Res Function(SavedConversation) _then;

/// Create a copy of SavedConversation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? channelId = null,Object? title = null,Object? teamId = freezed,Object? rootId = freezed,}) {
  return _then(SavedConversation(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,teamId: freezed == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String?,rootId: freezed == rootId ? _self.rootId : rootId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SavedConversation].
extension SavedConversationPatterns on SavedConversation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SavedConversation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SavedConversation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SavedConversation value)  $default,){
final _that = this;
switch (_that) {
case _SavedConversation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SavedConversation value)?  $default,){
final _that = this;
switch (_that) {
case _SavedConversation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url,  String channelId,  String title,  String? teamId,  String? rootId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SavedConversation() when $default != null:
return $default(_that.url,_that.channelId,_that.title,_that.teamId,_that.rootId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url,  String channelId,  String title,  String? teamId,  String? rootId)  $default,) {final _that = this;
switch (_that) {
case _SavedConversation():
return $default(_that.url,_that.channelId,_that.title,_that.teamId,_that.rootId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url,  String channelId,  String title,  String? teamId,  String? rootId)?  $default,) {final _that = this;
switch (_that) {
case _SavedConversation() when $default != null:
return $default(_that.url,_that.channelId,_that.title,_that.teamId,_that.rootId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SavedConversation implements SavedConversation {
  const _SavedConversation({required this.url, required this.channelId, required this.title, this.teamId, this.rootId});
  factory _SavedConversation.fromJson(Map<String, dynamic> json) => _$SavedConversationFromJson(json);

@override final  String url;
@override final  String channelId;
@override final  String title;
@override final  String? teamId;
@override final  String? rootId;

/// Create a copy of SavedConversation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavedConversationCopyWith<_SavedConversation> get copyWith => __$SavedConversationCopyWithImpl<_SavedConversation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SavedConversationToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SavedConversation&&(identical(other.url, url) || other.url == url)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.title, title) || other.title == title)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.rootId, rootId) || other.rootId == rootId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,url,channelId,title,teamId,rootId);
}

@override
String toString() {
    return 'SavedConversation(url: $url, channelId: $channelId, title: $title, teamId: $teamId, rootId: $rootId)';
}


}

/// @nodoc
abstract mixin class _$SavedConversationCopyWith<$Res> implements $SavedConversationCopyWith<$Res> {
  factory _$SavedConversationCopyWith(_SavedConversation value, $Res Function(_SavedConversation) _then) = __$SavedConversationCopyWithImpl;
@override @useResult
$Res call({
 String url, String channelId, String title, String? teamId, String? rootId
});




}
/// @nodoc
class __$SavedConversationCopyWithImpl<$Res>
    implements _$SavedConversationCopyWith<$Res> {
  __$SavedConversationCopyWithImpl(this._self, this._then);

  final _SavedConversation _self;
  final $Res Function(_SavedConversation) _then;

/// Create a copy of SavedConversation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? channelId = null,Object? title = null,Object? teamId = freezed,Object? rootId = freezed,}) {
  return _then(_SavedConversation(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,teamId: freezed == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String?,rootId: freezed == rootId ? _self.rootId : rootId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
