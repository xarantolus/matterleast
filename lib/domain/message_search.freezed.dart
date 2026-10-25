// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_search.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SearchScope {

 String get teamId;/// Searches every team the user is in; [teamId] stays the home of the
/// recent searches.
 bool get allTeams;/// `in:` takes the channel's name (or `@username` for a direct
/// message); [channelLabel] is what the chip says.
 String? get channelId; String? get channelName; String? get channelLabel;/// `from:` takes the username.
 String? get userId; String? get username; String? get userLabel; DateTime? get on; DateTime? get before; DateTime? get after;/// Files only: `ext:` for each of its extensions.
 FileKind? get fileKind;
/// Create a copy of SearchScope
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchScopeCopyWith<SearchScope> get copyWith => _$SearchScopeCopyWithImpl<SearchScope>(this as SearchScope, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SearchScope;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchScope&&(identical(other.teamId, _this.teamId) || other.teamId == _this.teamId)&&(identical(other.allTeams, _this.allTeams) || other.allTeams == _this.allTeams)&&(identical(other.channelId, _this.channelId) || other.channelId == _this.channelId)&&(identical(other.channelName, _this.channelName) || other.channelName == _this.channelName)&&(identical(other.channelLabel, _this.channelLabel) || other.channelLabel == _this.channelLabel)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.userLabel, _this.userLabel) || other.userLabel == _this.userLabel)&&(identical(other.on, _this.on) || other.on == _this.on)&&(identical(other.before, _this.before) || other.before == _this.before)&&(identical(other.after, _this.after) || other.after == _this.after)&&(identical(other.fileKind, _this.fileKind) || other.fileKind == _this.fileKind));
}


@override
int get hashCode {
  final _this = this as SearchScope;
  return Object.hash(runtimeType,_this.teamId,_this.allTeams,_this.channelId,_this.channelName,_this.channelLabel,_this.userId,_this.username,_this.userLabel,_this.on,_this.before,_this.after,_this.fileKind);
}

@override
String toString() {
  final _this = this as SearchScope;
  return 'SearchScope(teamId: ${_this.teamId}, allTeams: ${_this.allTeams}, channelId: ${_this.channelId}, channelName: ${_this.channelName}, channelLabel: ${_this.channelLabel}, userId: ${_this.userId}, username: ${_this.username}, userLabel: ${_this.userLabel}, on: ${_this.on}, before: ${_this.before}, after: ${_this.after}, fileKind: ${_this.fileKind})';
}


}

/// @nodoc
abstract mixin class $SearchScopeCopyWith<$Res>  {
  factory $SearchScopeCopyWith(SearchScope value, $Res Function(SearchScope) _then) = _$SearchScopeCopyWithImpl;
@useResult
$Res call({
 String teamId, bool allTeams, String? channelId, String? channelName, String? channelLabel, String? userId, String? username, String? userLabel, DateTime? on, DateTime? before, DateTime? after, FileKind? fileKind
});




}
/// @nodoc
class _$SearchScopeCopyWithImpl<$Res>
    implements $SearchScopeCopyWith<$Res> {
  _$SearchScopeCopyWithImpl(this._self, this._then);

  final SearchScope _self;
  final $Res Function(SearchScope) _then;

/// Create a copy of SearchScope
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? teamId = null,Object? allTeams = null,Object? channelId = freezed,Object? channelName = freezed,Object? channelLabel = freezed,Object? userId = freezed,Object? username = freezed,Object? userLabel = freezed,Object? on = freezed,Object? before = freezed,Object? after = freezed,Object? fileKind = freezed,}) {
  return _then(SearchScope(
teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,allTeams: null == allTeams ? _self.allTeams : allTeams // ignore: cast_nullable_to_non_nullable
as bool,channelId: freezed == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String?,channelName: freezed == channelName ? _self.channelName : channelName // ignore: cast_nullable_to_non_nullable
as String?,channelLabel: freezed == channelLabel ? _self.channelLabel : channelLabel // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,userLabel: freezed == userLabel ? _self.userLabel : userLabel // ignore: cast_nullable_to_non_nullable
as String?,on: freezed == on ? _self.on : on // ignore: cast_nullable_to_non_nullable
as DateTime?,before: freezed == before ? _self.before : before // ignore: cast_nullable_to_non_nullable
as DateTime?,after: freezed == after ? _self.after : after // ignore: cast_nullable_to_non_nullable
as DateTime?,fileKind: freezed == fileKind ? _self.fileKind : fileKind // ignore: cast_nullable_to_non_nullable
as FileKind?,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchScope].
extension SearchScopePatterns on SearchScope {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchScope value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchScope() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchScope value)  $default,){
final _that = this;
switch (_that) {
case _SearchScope():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchScope value)?  $default,){
final _that = this;
switch (_that) {
case _SearchScope() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String teamId,  bool allTeams,  String? channelId,  String? channelName,  String? channelLabel,  String? userId,  String? username,  String? userLabel,  DateTime? on,  DateTime? before,  DateTime? after,  FileKind? fileKind)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchScope() when $default != null:
return $default(_that.teamId,_that.allTeams,_that.channelId,_that.channelName,_that.channelLabel,_that.userId,_that.username,_that.userLabel,_that.on,_that.before,_that.after,_that.fileKind);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String teamId,  bool allTeams,  String? channelId,  String? channelName,  String? channelLabel,  String? userId,  String? username,  String? userLabel,  DateTime? on,  DateTime? before,  DateTime? after,  FileKind? fileKind)  $default,) {final _that = this;
switch (_that) {
case _SearchScope():
return $default(_that.teamId,_that.allTeams,_that.channelId,_that.channelName,_that.channelLabel,_that.userId,_that.username,_that.userLabel,_that.on,_that.before,_that.after,_that.fileKind);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String teamId,  bool allTeams,  String? channelId,  String? channelName,  String? channelLabel,  String? userId,  String? username,  String? userLabel,  DateTime? on,  DateTime? before,  DateTime? after,  FileKind? fileKind)?  $default,) {final _that = this;
switch (_that) {
case _SearchScope() when $default != null:
return $default(_that.teamId,_that.allTeams,_that.channelId,_that.channelName,_that.channelLabel,_that.userId,_that.username,_that.userLabel,_that.on,_that.before,_that.after,_that.fileKind);case _:
  return null;

}
}

}

/// @nodoc


class _SearchScope implements SearchScope {
  const _SearchScope({required this.teamId, this.allTeams = false, this.channelId, this.channelName, this.channelLabel, this.userId, this.username, this.userLabel, this.on, this.before, this.after, this.fileKind});
  

@override final  String teamId;
/// Searches every team the user is in; [teamId] stays the home of the
/// recent searches.
@override@JsonKey() final  bool allTeams;
/// `in:` takes the channel's name (or `@username` for a direct
/// message); [channelLabel] is what the chip says.
@override final  String? channelId;
@override final  String? channelName;
@override final  String? channelLabel;
/// `from:` takes the username.
@override final  String? userId;
@override final  String? username;
@override final  String? userLabel;
@override final  DateTime? on;
@override final  DateTime? before;
@override final  DateTime? after;
/// Files only: `ext:` for each of its extensions.
@override final  FileKind? fileKind;

/// Create a copy of SearchScope
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchScopeCopyWith<_SearchScope> get copyWith => __$SearchScopeCopyWithImpl<_SearchScope>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchScope&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.allTeams, allTeams) || other.allTeams == allTeams)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.channelName, channelName) || other.channelName == channelName)&&(identical(other.channelLabel, channelLabel) || other.channelLabel == channelLabel)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.userLabel, userLabel) || other.userLabel == userLabel)&&(identical(other.on, on) || other.on == on)&&(identical(other.before, before) || other.before == before)&&(identical(other.after, after) || other.after == after)&&(identical(other.fileKind, fileKind) || other.fileKind == fileKind));
}


@override
int get hashCode {
    return Object.hash(runtimeType,teamId,allTeams,channelId,channelName,channelLabel,userId,username,userLabel,on,before,after,fileKind);
}

@override
String toString() {
    return 'SearchScope(teamId: $teamId, allTeams: $allTeams, channelId: $channelId, channelName: $channelName, channelLabel: $channelLabel, userId: $userId, username: $username, userLabel: $userLabel, on: $on, before: $before, after: $after, fileKind: $fileKind)';
}


}

/// @nodoc
abstract mixin class _$SearchScopeCopyWith<$Res> implements $SearchScopeCopyWith<$Res> {
  factory _$SearchScopeCopyWith(_SearchScope value, $Res Function(_SearchScope) _then) = __$SearchScopeCopyWithImpl;
@override @useResult
$Res call({
 String teamId, bool allTeams, String? channelId, String? channelName, String? channelLabel, String? userId, String? username, String? userLabel, DateTime? on, DateTime? before, DateTime? after, FileKind? fileKind
});




}
/// @nodoc
class __$SearchScopeCopyWithImpl<$Res>
    implements _$SearchScopeCopyWith<$Res> {
  __$SearchScopeCopyWithImpl(this._self, this._then);

  final _SearchScope _self;
  final $Res Function(_SearchScope) _then;

/// Create a copy of SearchScope
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? teamId = null,Object? allTeams = null,Object? channelId = freezed,Object? channelName = freezed,Object? channelLabel = freezed,Object? userId = freezed,Object? username = freezed,Object? userLabel = freezed,Object? on = freezed,Object? before = freezed,Object? after = freezed,Object? fileKind = freezed,}) {
  return _then(_SearchScope(
teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,allTeams: null == allTeams ? _self.allTeams : allTeams // ignore: cast_nullable_to_non_nullable
as bool,channelId: freezed == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String?,channelName: freezed == channelName ? _self.channelName : channelName // ignore: cast_nullable_to_non_nullable
as String?,channelLabel: freezed == channelLabel ? _self.channelLabel : channelLabel // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,userLabel: freezed == userLabel ? _self.userLabel : userLabel // ignore: cast_nullable_to_non_nullable
as String?,on: freezed == on ? _self.on : on // ignore: cast_nullable_to_non_nullable
as DateTime?,before: freezed == before ? _self.before : before // ignore: cast_nullable_to_non_nullable
as DateTime?,after: freezed == after ? _self.after : after // ignore: cast_nullable_to_non_nullable
as DateTime?,fileKind: freezed == fileKind ? _self.fileKind : fileKind // ignore: cast_nullable_to_non_nullable
as FileKind?,
  ));
}


}

/// @nodoc
mixin _$FileHit {

 String get id; String get name; String get extension; String get mimeType; int get size; String get postId; String get channelId;/// Where it was posted, such as `#town-square` or a person's name.
 String get place; DateTime? get createAt;
/// Create a copy of FileHit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FileHitCopyWith<FileHit> get copyWith => _$FileHitCopyWithImpl<FileHit>(this as FileHit, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FileHit;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileHit&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.extension, _this.extension) || other.extension == _this.extension)&&(identical(other.mimeType, _this.mimeType) || other.mimeType == _this.mimeType)&&(identical(other.size, _this.size) || other.size == _this.size)&&(identical(other.postId, _this.postId) || other.postId == _this.postId)&&(identical(other.channelId, _this.channelId) || other.channelId == _this.channelId)&&(identical(other.place, _this.place) || other.place == _this.place)&&(identical(other.createAt, _this.createAt) || other.createAt == _this.createAt));
}


@override
int get hashCode {
  final _this = this as FileHit;
  return Object.hash(runtimeType,_this.id,_this.name,_this.extension,_this.mimeType,_this.size,_this.postId,_this.channelId,_this.place,_this.createAt);
}

@override
String toString() {
  final _this = this as FileHit;
  return 'FileHit(id: ${_this.id}, name: ${_this.name}, extension: ${_this.extension}, mimeType: ${_this.mimeType}, size: ${_this.size}, postId: ${_this.postId}, channelId: ${_this.channelId}, place: ${_this.place}, createAt: ${_this.createAt})';
}


}

/// @nodoc
abstract mixin class $FileHitCopyWith<$Res>  {
  factory $FileHitCopyWith(FileHit value, $Res Function(FileHit) _then) = _$FileHitCopyWithImpl;
@useResult
$Res call({
 String id, String name, String extension, String mimeType, int size, String postId, String channelId, String place, DateTime? createAt
});




}
/// @nodoc
class _$FileHitCopyWithImpl<$Res>
    implements $FileHitCopyWith<$Res> {
  _$FileHitCopyWithImpl(this._self, this._then);

  final FileHit _self;
  final $Res Function(FileHit) _then;

/// Create a copy of FileHit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? extension = null,Object? mimeType = null,Object? size = null,Object? postId = null,Object? channelId = null,Object? place = null,Object? createAt = freezed,}) {
  return _then(FileHit(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,extension: null == extension ? _self.extension : extension // ignore: cast_nullable_to_non_nullable
as String,mimeType: null == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,place: null == place ? _self.place : place // ignore: cast_nullable_to_non_nullable
as String,createAt: freezed == createAt ? _self.createAt : createAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [FileHit].
extension FileHitPatterns on FileHit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FileHit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FileHit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FileHit value)  $default,){
final _that = this;
switch (_that) {
case _FileHit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FileHit value)?  $default,){
final _that = this;
switch (_that) {
case _FileHit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String extension,  String mimeType,  int size,  String postId,  String channelId,  String place,  DateTime? createAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FileHit() when $default != null:
return $default(_that.id,_that.name,_that.extension,_that.mimeType,_that.size,_that.postId,_that.channelId,_that.place,_that.createAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String extension,  String mimeType,  int size,  String postId,  String channelId,  String place,  DateTime? createAt)  $default,) {final _that = this;
switch (_that) {
case _FileHit():
return $default(_that.id,_that.name,_that.extension,_that.mimeType,_that.size,_that.postId,_that.channelId,_that.place,_that.createAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String extension,  String mimeType,  int size,  String postId,  String channelId,  String place,  DateTime? createAt)?  $default,) {final _that = this;
switch (_that) {
case _FileHit() when $default != null:
return $default(_that.id,_that.name,_that.extension,_that.mimeType,_that.size,_that.postId,_that.channelId,_that.place,_that.createAt);case _:
  return null;

}
}

}

/// @nodoc


class _FileHit implements FileHit {
  const _FileHit({required this.id, required this.name, required this.extension, required this.mimeType, required this.size, required this.postId, required this.channelId, required this.place, this.createAt});
  

@override final  String id;
@override final  String name;
@override final  String extension;
@override final  String mimeType;
@override final  int size;
@override final  String postId;
@override final  String channelId;
/// Where it was posted, such as `#town-square` or a person's name.
@override final  String place;
@override final  DateTime? createAt;

/// Create a copy of FileHit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FileHitCopyWith<_FileHit> get copyWith => __$FileHitCopyWithImpl<_FileHit>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FileHit&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.extension, extension) || other.extension == extension)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.size, size) || other.size == size)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.place, place) || other.place == place)&&(identical(other.createAt, createAt) || other.createAt == createAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,extension,mimeType,size,postId,channelId,place,createAt);
}

@override
String toString() {
    return 'FileHit(id: $id, name: $name, extension: $extension, mimeType: $mimeType, size: $size, postId: $postId, channelId: $channelId, place: $place, createAt: $createAt)';
}


}

/// @nodoc
abstract mixin class _$FileHitCopyWith<$Res> implements $FileHitCopyWith<$Res> {
  factory _$FileHitCopyWith(_FileHit value, $Res Function(_FileHit) _then) = __$FileHitCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String extension, String mimeType, int size, String postId, String channelId, String place, DateTime? createAt
});




}
/// @nodoc
class __$FileHitCopyWithImpl<$Res>
    implements _$FileHitCopyWith<$Res> {
  __$FileHitCopyWithImpl(this._self, this._then);

  final _FileHit _self;
  final $Res Function(_FileHit) _then;

/// Create a copy of FileHit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? extension = null,Object? mimeType = null,Object? size = null,Object? postId = null,Object? channelId = null,Object? place = null,Object? createAt = freezed,}) {
  return _then(_FileHit(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,extension: null == extension ? _self.extension : extension // ignore: cast_nullable_to_non_nullable
as String,mimeType: null == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,place: null == place ? _self.place : place // ignore: cast_nullable_to_non_nullable
as String,createAt: freezed == createAt ? _self.createAt : createAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
