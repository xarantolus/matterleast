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


/// @nodoc
mixin _$OpenConversations {

 Map<String, SavedConversation> get open; Map<String, SavedConversation> get closed;
/// Create a copy of OpenConversations
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OpenConversationsCopyWith<OpenConversations> get copyWith => _$OpenConversationsCopyWithImpl<OpenConversations>(this as OpenConversations, _$identity);

  /// Serializes this OpenConversations to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OpenConversations;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OpenConversations&&const DeepCollectionEquality().equals(other.open, _this.open)&&const DeepCollectionEquality().equals(other.closed, _this.closed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OpenConversations;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.open),const DeepCollectionEquality().hash(_this.closed));
}

@override
String toString() {
  final _this = this as OpenConversations;
  return 'OpenConversations(open: ${_this.open}, closed: ${_this.closed})';
}


}

/// @nodoc
abstract mixin class $OpenConversationsCopyWith<$Res>  {
  factory $OpenConversationsCopyWith(OpenConversations value, $Res Function(OpenConversations) _then) = _$OpenConversationsCopyWithImpl;
@useResult
$Res call({
 Map<String, SavedConversation> open, Map<String, SavedConversation> closed
});




}
/// @nodoc
class _$OpenConversationsCopyWithImpl<$Res>
    implements $OpenConversationsCopyWith<$Res> {
  _$OpenConversationsCopyWithImpl(this._self, this._then);

  final OpenConversations _self;
  final $Res Function(OpenConversations) _then;

/// Create a copy of OpenConversations
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? open = null,Object? closed = null,}) {
  return _then(OpenConversations(
open: null == open ? _self.open : open // ignore: cast_nullable_to_non_nullable
as Map<String, SavedConversation>,closed: null == closed ? _self.closed : closed // ignore: cast_nullable_to_non_nullable
as Map<String, SavedConversation>,
  ));
}

}


/// Adds pattern-matching-related methods to [OpenConversations].
extension OpenConversationsPatterns on OpenConversations {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OpenConversations value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OpenConversations() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OpenConversations value)  $default,){
final _that = this;
switch (_that) {
case _OpenConversations():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OpenConversations value)?  $default,){
final _that = this;
switch (_that) {
case _OpenConversations() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, SavedConversation> open,  Map<String, SavedConversation> closed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OpenConversations() when $default != null:
return $default(_that.open,_that.closed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, SavedConversation> open,  Map<String, SavedConversation> closed)  $default,) {final _that = this;
switch (_that) {
case _OpenConversations():
return $default(_that.open,_that.closed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, SavedConversation> open,  Map<String, SavedConversation> closed)?  $default,) {final _that = this;
switch (_that) {
case _OpenConversations() when $default != null:
return $default(_that.open,_that.closed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OpenConversations extends OpenConversations {
  const _OpenConversations({ Map<String, SavedConversation> open = const <String, SavedConversation>{},  Map<String, SavedConversation> closed = const <String, SavedConversation>{}}): _open = open,_closed = closed,super._();
  factory _OpenConversations.fromJson(Map<String, dynamic> json) => _$OpenConversationsFromJson(json);

 final  Map<String, SavedConversation> _open;
@override@JsonKey() Map<String, SavedConversation> get open {
  if (_open is EqualUnmodifiableMapView) return _open;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_open);
}

 final  Map<String, SavedConversation> _closed;
@override@JsonKey() Map<String, SavedConversation> get closed {
  if (_closed is EqualUnmodifiableMapView) return _closed;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_closed);
}


/// Create a copy of OpenConversations
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OpenConversationsCopyWith<_OpenConversations> get copyWith => __$OpenConversationsCopyWithImpl<_OpenConversations>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OpenConversationsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OpenConversations&&const DeepCollectionEquality().equals(other.open, _open)&&const DeepCollectionEquality().equals(other.closed, _closed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_open),const DeepCollectionEquality().hash(_closed));
}

@override
String toString() {
    return 'OpenConversations(open: $open, closed: $closed)';
}


}

/// @nodoc
abstract mixin class _$OpenConversationsCopyWith<$Res> implements $OpenConversationsCopyWith<$Res> {
  factory _$OpenConversationsCopyWith(_OpenConversations value, $Res Function(_OpenConversations) _then) = __$OpenConversationsCopyWithImpl;
@override @useResult
$Res call({
 Map<String, SavedConversation> open, Map<String, SavedConversation> closed
});




}
/// @nodoc
class __$OpenConversationsCopyWithImpl<$Res>
    implements _$OpenConversationsCopyWith<$Res> {
  __$OpenConversationsCopyWithImpl(this._self, this._then);

  final _OpenConversations _self;
  final $Res Function(_OpenConversations) _then;

/// Create a copy of OpenConversations
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? open = null,Object? closed = null,}) {
  return _then(_OpenConversations(
open: null == open ? _self._open : open // ignore: cast_nullable_to_non_nullable
as Map<String, SavedConversation>,closed: null == closed ? _self._closed : closed // ignore: cast_nullable_to_non_nullable
as Map<String, SavedConversation>,
  ));
}


}

// dart format on
