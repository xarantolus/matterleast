// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quick_switch.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SwitchItem {

 String get serverUrl; SwitchKind get kind;/// The channel id, or the user id for [SwitchKind.person].
 String get id; String get title;/// The team or `@username` under the title.
 String? get subtitle;/// How search modifiers name it: the channel's name, `@username` for a
/// direct message, or the person's username.
 String? get handle;/// What the term is matched against, besides the title.
 List<String> get keys;/// The team to show in the rail when opened.
 String? get teamId;/// Whose picture the row shows: the other person of a direct message, or
/// the person.
 String? get userId; int? get pictureUpdate; String? get status; DateTime? get lastViewedAt; bool get unread; int get mentions; bool get muted;
/// Create a copy of SwitchItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SwitchItemCopyWith<SwitchItem> get copyWith => _$SwitchItemCopyWithImpl<SwitchItem>(this as SwitchItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SwitchItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SwitchItem&&(identical(other.serverUrl, _this.serverUrl) || other.serverUrl == _this.serverUrl)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.subtitle, _this.subtitle) || other.subtitle == _this.subtitle)&&(identical(other.handle, _this.handle) || other.handle == _this.handle)&&const DeepCollectionEquality().equals(other.keys, _this.keys)&&(identical(other.teamId, _this.teamId) || other.teamId == _this.teamId)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.pictureUpdate, _this.pictureUpdate) || other.pictureUpdate == _this.pictureUpdate)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.lastViewedAt, _this.lastViewedAt) || other.lastViewedAt == _this.lastViewedAt)&&(identical(other.unread, _this.unread) || other.unread == _this.unread)&&(identical(other.mentions, _this.mentions) || other.mentions == _this.mentions)&&(identical(other.muted, _this.muted) || other.muted == _this.muted));
}


@override
int get hashCode {
  final _this = this as SwitchItem;
  return Object.hash(runtimeType,_this.serverUrl,_this.kind,_this.id,_this.title,_this.subtitle,_this.handle,const DeepCollectionEquality().hash(_this.keys),_this.teamId,_this.userId,_this.pictureUpdate,_this.status,_this.lastViewedAt,_this.unread,_this.mentions,_this.muted);
}

@override
String toString() {
  final _this = this as SwitchItem;
  return 'SwitchItem(serverUrl: ${_this.serverUrl}, kind: ${_this.kind}, id: ${_this.id}, title: ${_this.title}, subtitle: ${_this.subtitle}, handle: ${_this.handle}, keys: ${_this.keys}, teamId: ${_this.teamId}, userId: ${_this.userId}, pictureUpdate: ${_this.pictureUpdate}, status: ${_this.status}, lastViewedAt: ${_this.lastViewedAt}, unread: ${_this.unread}, mentions: ${_this.mentions}, muted: ${_this.muted})';
}


}

/// @nodoc
abstract mixin class $SwitchItemCopyWith<$Res>  {
  factory $SwitchItemCopyWith(SwitchItem value, $Res Function(SwitchItem) _then) = _$SwitchItemCopyWithImpl;
@useResult
$Res call({
 String serverUrl, SwitchKind kind, String id, String title, String? subtitle, String? handle, List<String> keys, String? teamId, String? userId, int? pictureUpdate, String? status, DateTime? lastViewedAt, bool unread, int mentions, bool muted
});




}
/// @nodoc
class _$SwitchItemCopyWithImpl<$Res>
    implements $SwitchItemCopyWith<$Res> {
  _$SwitchItemCopyWithImpl(this._self, this._then);

  final SwitchItem _self;
  final $Res Function(SwitchItem) _then;

/// Create a copy of SwitchItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? serverUrl = null,Object? kind = null,Object? id = null,Object? title = null,Object? subtitle = freezed,Object? handle = freezed,Object? keys = null,Object? teamId = freezed,Object? userId = freezed,Object? pictureUpdate = freezed,Object? status = freezed,Object? lastViewedAt = freezed,Object? unread = null,Object? mentions = null,Object? muted = null,}) {
  return _then(SwitchItem(
serverUrl: null == serverUrl ? _self.serverUrl : serverUrl // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as SwitchKind,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,handle: freezed == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String?,keys: null == keys ? _self.keys : keys // ignore: cast_nullable_to_non_nullable
as List<String>,teamId: freezed == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,pictureUpdate: freezed == pictureUpdate ? _self.pictureUpdate : pictureUpdate // ignore: cast_nullable_to_non_nullable
as int?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,lastViewedAt: freezed == lastViewedAt ? _self.lastViewedAt : lastViewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,unread: null == unread ? _self.unread : unread // ignore: cast_nullable_to_non_nullable
as bool,mentions: null == mentions ? _self.mentions : mentions // ignore: cast_nullable_to_non_nullable
as int,muted: null == muted ? _self.muted : muted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SwitchItem].
extension SwitchItemPatterns on SwitchItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SwitchItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SwitchItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SwitchItem value)  $default,){
final _that = this;
switch (_that) {
case _SwitchItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SwitchItem value)?  $default,){
final _that = this;
switch (_that) {
case _SwitchItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String serverUrl,  SwitchKind kind,  String id,  String title,  String? subtitle,  String? handle,  List<String> keys,  String? teamId,  String? userId,  int? pictureUpdate,  String? status,  DateTime? lastViewedAt,  bool unread,  int mentions,  bool muted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SwitchItem() when $default != null:
return $default(_that.serverUrl,_that.kind,_that.id,_that.title,_that.subtitle,_that.handle,_that.keys,_that.teamId,_that.userId,_that.pictureUpdate,_that.status,_that.lastViewedAt,_that.unread,_that.mentions,_that.muted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String serverUrl,  SwitchKind kind,  String id,  String title,  String? subtitle,  String? handle,  List<String> keys,  String? teamId,  String? userId,  int? pictureUpdate,  String? status,  DateTime? lastViewedAt,  bool unread,  int mentions,  bool muted)  $default,) {final _that = this;
switch (_that) {
case _SwitchItem():
return $default(_that.serverUrl,_that.kind,_that.id,_that.title,_that.subtitle,_that.handle,_that.keys,_that.teamId,_that.userId,_that.pictureUpdate,_that.status,_that.lastViewedAt,_that.unread,_that.mentions,_that.muted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String serverUrl,  SwitchKind kind,  String id,  String title,  String? subtitle,  String? handle,  List<String> keys,  String? teamId,  String? userId,  int? pictureUpdate,  String? status,  DateTime? lastViewedAt,  bool unread,  int mentions,  bool muted)?  $default,) {final _that = this;
switch (_that) {
case _SwitchItem() when $default != null:
return $default(_that.serverUrl,_that.kind,_that.id,_that.title,_that.subtitle,_that.handle,_that.keys,_that.teamId,_that.userId,_that.pictureUpdate,_that.status,_that.lastViewedAt,_that.unread,_that.mentions,_that.muted);case _:
  return null;

}
}

}

/// @nodoc


class _SwitchItem extends SwitchItem {
  const _SwitchItem({required this.serverUrl, required this.kind, required this.id, required this.title, this.subtitle, this.handle,  List<String> keys = const <String>[], this.teamId, this.userId, this.pictureUpdate, this.status, this.lastViewedAt, this.unread = false, this.mentions = 0, this.muted = false}): _keys = keys,super._();
  

@override final  String serverUrl;
@override final  SwitchKind kind;
/// The channel id, or the user id for [SwitchKind.person].
@override final  String id;
@override final  String title;
/// The team or `@username` under the title.
@override final  String? subtitle;
/// How search modifiers name it: the channel's name, `@username` for a
/// direct message, or the person's username.
@override final  String? handle;
/// What the term is matched against, besides the title.
 final  List<String> _keys;
/// What the term is matched against, besides the title.
@override@JsonKey() List<String> get keys {
  if (_keys is EqualUnmodifiableListView) return _keys;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_keys);
}

/// The team to show in the rail when opened.
@override final  String? teamId;
/// Whose picture the row shows: the other person of a direct message, or
/// the person.
@override final  String? userId;
@override final  int? pictureUpdate;
@override final  String? status;
@override final  DateTime? lastViewedAt;
@override@JsonKey() final  bool unread;
@override@JsonKey() final  int mentions;
@override@JsonKey() final  bool muted;

/// Create a copy of SwitchItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SwitchItemCopyWith<_SwitchItem> get copyWith => __$SwitchItemCopyWithImpl<_SwitchItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SwitchItem&&(identical(other.serverUrl, serverUrl) || other.serverUrl == serverUrl)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.handle, handle) || other.handle == handle)&&const DeepCollectionEquality().equals(other.keys, _keys)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.pictureUpdate, pictureUpdate) || other.pictureUpdate == pictureUpdate)&&(identical(other.status, status) || other.status == status)&&(identical(other.lastViewedAt, lastViewedAt) || other.lastViewedAt == lastViewedAt)&&(identical(other.unread, unread) || other.unread == unread)&&(identical(other.mentions, mentions) || other.mentions == mentions)&&(identical(other.muted, muted) || other.muted == muted));
}


@override
int get hashCode {
    return Object.hash(runtimeType,serverUrl,kind,id,title,subtitle,handle,const DeepCollectionEquality().hash(_keys),teamId,userId,pictureUpdate,status,lastViewedAt,unread,mentions,muted);
}

@override
String toString() {
    return 'SwitchItem(serverUrl: $serverUrl, kind: $kind, id: $id, title: $title, subtitle: $subtitle, handle: $handle, keys: $keys, teamId: $teamId, userId: $userId, pictureUpdate: $pictureUpdate, status: $status, lastViewedAt: $lastViewedAt, unread: $unread, mentions: $mentions, muted: $muted)';
}


}

/// @nodoc
abstract mixin class _$SwitchItemCopyWith<$Res> implements $SwitchItemCopyWith<$Res> {
  factory _$SwitchItemCopyWith(_SwitchItem value, $Res Function(_SwitchItem) _then) = __$SwitchItemCopyWithImpl;
@override @useResult
$Res call({
 String serverUrl, SwitchKind kind, String id, String title, String? subtitle, String? handle, List<String> keys, String? teamId, String? userId, int? pictureUpdate, String? status, DateTime? lastViewedAt, bool unread, int mentions, bool muted
});




}
/// @nodoc
class __$SwitchItemCopyWithImpl<$Res>
    implements _$SwitchItemCopyWith<$Res> {
  __$SwitchItemCopyWithImpl(this._self, this._then);

  final _SwitchItem _self;
  final $Res Function(_SwitchItem) _then;

/// Create a copy of SwitchItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? serverUrl = null,Object? kind = null,Object? id = null,Object? title = null,Object? subtitle = freezed,Object? handle = freezed,Object? keys = null,Object? teamId = freezed,Object? userId = freezed,Object? pictureUpdate = freezed,Object? status = freezed,Object? lastViewedAt = freezed,Object? unread = null,Object? mentions = null,Object? muted = null,}) {
  return _then(_SwitchItem(
serverUrl: null == serverUrl ? _self.serverUrl : serverUrl // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as SwitchKind,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,handle: freezed == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String?,keys: null == keys ? _self._keys : keys // ignore: cast_nullable_to_non_nullable
as List<String>,teamId: freezed == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,pictureUpdate: freezed == pictureUpdate ? _self.pictureUpdate : pictureUpdate // ignore: cast_nullable_to_non_nullable
as int?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,lastViewedAt: freezed == lastViewedAt ? _self.lastViewedAt : lastViewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,unread: null == unread ? _self.unread : unread // ignore: cast_nullable_to_non_nullable
as bool,mentions: null == mentions ? _self.mentions : mentions // ignore: cast_nullable_to_non_nullable
as int,muted: null == muted ? _self.muted : muted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
