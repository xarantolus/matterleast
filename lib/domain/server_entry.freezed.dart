// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'server_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ServerEntry {

 String get url; String get displayName; String? get siteName; String? get serverVersion; String? get diagnosticId; DateTime? get lastActiveAt; String? get ssoScheme;
/// Create a copy of ServerEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerEntryCopyWith<ServerEntry> get copyWith => _$ServerEntryCopyWithImpl<ServerEntry>(this as ServerEntry, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ServerEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerEntry&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.displayName, _this.displayName) || other.displayName == _this.displayName)&&(identical(other.siteName, _this.siteName) || other.siteName == _this.siteName)&&(identical(other.serverVersion, _this.serverVersion) || other.serverVersion == _this.serverVersion)&&(identical(other.diagnosticId, _this.diagnosticId) || other.diagnosticId == _this.diagnosticId)&&(identical(other.lastActiveAt, _this.lastActiveAt) || other.lastActiveAt == _this.lastActiveAt)&&(identical(other.ssoScheme, _this.ssoScheme) || other.ssoScheme == _this.ssoScheme));
}


@override
int get hashCode {
  final _this = this as ServerEntry;
  return Object.hash(runtimeType,_this.url,_this.displayName,_this.siteName,_this.serverVersion,_this.diagnosticId,_this.lastActiveAt,_this.ssoScheme);
}

@override
String toString() {
  final _this = this as ServerEntry;
  return 'ServerEntry(url: ${_this.url}, displayName: ${_this.displayName}, siteName: ${_this.siteName}, serverVersion: ${_this.serverVersion}, diagnosticId: ${_this.diagnosticId}, lastActiveAt: ${_this.lastActiveAt}, ssoScheme: ${_this.ssoScheme})';
}


}

/// @nodoc
abstract mixin class $ServerEntryCopyWith<$Res>  {
  factory $ServerEntryCopyWith(ServerEntry value, $Res Function(ServerEntry) _then) = _$ServerEntryCopyWithImpl;
@useResult
$Res call({
 String url, String displayName, String? siteName, String? serverVersion, String? diagnosticId, DateTime? lastActiveAt, String? ssoScheme
});




}
/// @nodoc
class _$ServerEntryCopyWithImpl<$Res>
    implements $ServerEntryCopyWith<$Res> {
  _$ServerEntryCopyWithImpl(this._self, this._then);

  final ServerEntry _self;
  final $Res Function(ServerEntry) _then;

/// Create a copy of ServerEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? displayName = null,Object? siteName = freezed,Object? serverVersion = freezed,Object? diagnosticId = freezed,Object? lastActiveAt = freezed,Object? ssoScheme = freezed,}) {
  return _then(ServerEntry(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,siteName: freezed == siteName ? _self.siteName : siteName // ignore: cast_nullable_to_non_nullable
as String?,serverVersion: freezed == serverVersion ? _self.serverVersion : serverVersion // ignore: cast_nullable_to_non_nullable
as String?,diagnosticId: freezed == diagnosticId ? _self.diagnosticId : diagnosticId // ignore: cast_nullable_to_non_nullable
as String?,lastActiveAt: freezed == lastActiveAt ? _self.lastActiveAt : lastActiveAt // ignore: cast_nullable_to_non_nullable
as DateTime?,ssoScheme: freezed == ssoScheme ? _self.ssoScheme : ssoScheme // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ServerEntry].
extension ServerEntryPatterns on ServerEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ServerEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ServerEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ServerEntry value)  $default,){
final _that = this;
switch (_that) {
case _ServerEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ServerEntry value)?  $default,){
final _that = this;
switch (_that) {
case _ServerEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url,  String displayName,  String? siteName,  String? serverVersion,  String? diagnosticId,  DateTime? lastActiveAt,  String? ssoScheme)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServerEntry() when $default != null:
return $default(_that.url,_that.displayName,_that.siteName,_that.serverVersion,_that.diagnosticId,_that.lastActiveAt,_that.ssoScheme);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url,  String displayName,  String? siteName,  String? serverVersion,  String? diagnosticId,  DateTime? lastActiveAt,  String? ssoScheme)  $default,) {final _that = this;
switch (_that) {
case _ServerEntry():
return $default(_that.url,_that.displayName,_that.siteName,_that.serverVersion,_that.diagnosticId,_that.lastActiveAt,_that.ssoScheme);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url,  String displayName,  String? siteName,  String? serverVersion,  String? diagnosticId,  DateTime? lastActiveAt,  String? ssoScheme)?  $default,) {final _that = this;
switch (_that) {
case _ServerEntry() when $default != null:
return $default(_that.url,_that.displayName,_that.siteName,_that.serverVersion,_that.diagnosticId,_that.lastActiveAt,_that.ssoScheme);case _:
  return null;

}
}

}

/// @nodoc


class _ServerEntry extends ServerEntry {
  const _ServerEntry({required this.url, required this.displayName, required this.siteName, required this.serverVersion, required this.diagnosticId, required this.lastActiveAt, required this.ssoScheme}): super._();
  

@override final  String url;
@override final  String displayName;
@override final  String? siteName;
@override final  String? serverVersion;
@override final  String? diagnosticId;
@override final  DateTime? lastActiveAt;
@override final  String? ssoScheme;

/// Create a copy of ServerEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServerEntryCopyWith<_ServerEntry> get copyWith => __$ServerEntryCopyWithImpl<_ServerEntry>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServerEntry&&(identical(other.url, url) || other.url == url)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.siteName, siteName) || other.siteName == siteName)&&(identical(other.serverVersion, serverVersion) || other.serverVersion == serverVersion)&&(identical(other.diagnosticId, diagnosticId) || other.diagnosticId == diagnosticId)&&(identical(other.lastActiveAt, lastActiveAt) || other.lastActiveAt == lastActiveAt)&&(identical(other.ssoScheme, ssoScheme) || other.ssoScheme == ssoScheme));
}


@override
int get hashCode {
    return Object.hash(runtimeType,url,displayName,siteName,serverVersion,diagnosticId,lastActiveAt,ssoScheme);
}

@override
String toString() {
    return 'ServerEntry(url: $url, displayName: $displayName, siteName: $siteName, serverVersion: $serverVersion, diagnosticId: $diagnosticId, lastActiveAt: $lastActiveAt, ssoScheme: $ssoScheme)';
}


}

/// @nodoc
abstract mixin class _$ServerEntryCopyWith<$Res> implements $ServerEntryCopyWith<$Res> {
  factory _$ServerEntryCopyWith(_ServerEntry value, $Res Function(_ServerEntry) _then) = __$ServerEntryCopyWithImpl;
@override @useResult
$Res call({
 String url, String displayName, String? siteName, String? serverVersion, String? diagnosticId, DateTime? lastActiveAt, String? ssoScheme
});




}
/// @nodoc
class __$ServerEntryCopyWithImpl<$Res>
    implements _$ServerEntryCopyWith<$Res> {
  __$ServerEntryCopyWithImpl(this._self, this._then);

  final _ServerEntry _self;
  final $Res Function(_ServerEntry) _then;

/// Create a copy of ServerEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? displayName = null,Object? siteName = freezed,Object? serverVersion = freezed,Object? diagnosticId = freezed,Object? lastActiveAt = freezed,Object? ssoScheme = freezed,}) {
  return _then(_ServerEntry(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,siteName: freezed == siteName ? _self.siteName : siteName // ignore: cast_nullable_to_non_nullable
as String?,serverVersion: freezed == serverVersion ? _self.serverVersion : serverVersion // ignore: cast_nullable_to_non_nullable
as String?,diagnosticId: freezed == diagnosticId ? _self.diagnosticId : diagnosticId // ignore: cast_nullable_to_non_nullable
as String?,lastActiveAt: freezed == lastActiveAt ? _self.lastActiveAt : lastActiveAt // ignore: cast_nullable_to_non_nullable
as DateTime?,ssoScheme: freezed == ssoScheme ? _self.ssoScheme : ssoScheme // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$Me {

 String get id; String get username; String get firstName; String get lastName; String get nickname;
/// Create a copy of Me
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MeCopyWith<Me> get copyWith => _$MeCopyWithImpl<Me>(this as Me, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Me;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Me&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.firstName, _this.firstName) || other.firstName == _this.firstName)&&(identical(other.lastName, _this.lastName) || other.lastName == _this.lastName)&&(identical(other.nickname, _this.nickname) || other.nickname == _this.nickname));
}


@override
int get hashCode {
  final _this = this as Me;
  return Object.hash(runtimeType,_this.id,_this.username,_this.firstName,_this.lastName,_this.nickname);
}

@override
String toString() {
  final _this = this as Me;
  return 'Me(id: ${_this.id}, username: ${_this.username}, firstName: ${_this.firstName}, lastName: ${_this.lastName}, nickname: ${_this.nickname})';
}


}

/// @nodoc
abstract mixin class $MeCopyWith<$Res>  {
  factory $MeCopyWith(Me value, $Res Function(Me) _then) = _$MeCopyWithImpl;
@useResult
$Res call({
 String id, String username, String firstName, String lastName, String nickname
});




}
/// @nodoc
class _$MeCopyWithImpl<$Res>
    implements $MeCopyWith<$Res> {
  _$MeCopyWithImpl(this._self, this._then);

  final Me _self;
  final $Res Function(Me) _then;

/// Create a copy of Me
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? username = null,Object? firstName = null,Object? lastName = null,Object? nickname = null,}) {
  return _then(Me(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,nickname: null == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Me].
extension MePatterns on Me {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Me value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Me() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Me value)  $default,){
final _that = this;
switch (_that) {
case _Me():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Me value)?  $default,){
final _that = this;
switch (_that) {
case _Me() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String username,  String firstName,  String lastName,  String nickname)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Me() when $default != null:
return $default(_that.id,_that.username,_that.firstName,_that.lastName,_that.nickname);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String username,  String firstName,  String lastName,  String nickname)  $default,) {final _that = this;
switch (_that) {
case _Me():
return $default(_that.id,_that.username,_that.firstName,_that.lastName,_that.nickname);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String username,  String firstName,  String lastName,  String nickname)?  $default,) {final _that = this;
switch (_that) {
case _Me() when $default != null:
return $default(_that.id,_that.username,_that.firstName,_that.lastName,_that.nickname);case _:
  return null;

}
}

}

/// @nodoc


class _Me extends Me {
  const _Me({required this.id, required this.username, required this.firstName, required this.lastName, required this.nickname}): super._();
  

@override final  String id;
@override final  String username;
@override final  String firstName;
@override final  String lastName;
@override final  String nickname;

/// Create a copy of Me
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MeCopyWith<_Me> get copyWith => __$MeCopyWithImpl<_Me>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Me&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.nickname, nickname) || other.nickname == nickname));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,username,firstName,lastName,nickname);
}

@override
String toString() {
    return 'Me(id: $id, username: $username, firstName: $firstName, lastName: $lastName, nickname: $nickname)';
}


}

/// @nodoc
abstract mixin class _$MeCopyWith<$Res> implements $MeCopyWith<$Res> {
  factory _$MeCopyWith(_Me value, $Res Function(_Me) _then) = __$MeCopyWithImpl;
@override @useResult
$Res call({
 String id, String username, String firstName, String lastName, String nickname
});




}
/// @nodoc
class __$MeCopyWithImpl<$Res>
    implements _$MeCopyWith<$Res> {
  __$MeCopyWithImpl(this._self, this._then);

  final _Me _self;
  final $Res Function(_Me) _then;

/// Create a copy of Me
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? username = null,Object? firstName = null,Object? lastName = null,Object? nickname = null,}) {
  return _then(_Me(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,nickname: null == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
