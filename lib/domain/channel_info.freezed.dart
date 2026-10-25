// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'channel_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChannelInfo {

 String get id;/// `O`, `P`, `D` or `G`.
 String get type; String get name; String get title; String get teamId; String get teamName; String get teamDisplayName; String get purpose; String get header; bool get archived; bool get joined; bool get favorite; bool get muted; int? get memberCount;/// The other person of a direct message.
 String? get partnerId; String? get creatorName; DateTime? get createAt; ChannelNotify get notify; bool get canEdit; bool get canArchive; bool get canManageMembers;
/// Create a copy of ChannelInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChannelInfoCopyWith<ChannelInfo> get copyWith => _$ChannelInfoCopyWithImpl<ChannelInfo>(this as ChannelInfo, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ChannelInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChannelInfo&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.teamId, _this.teamId) || other.teamId == _this.teamId)&&(identical(other.teamName, _this.teamName) || other.teamName == _this.teamName)&&(identical(other.teamDisplayName, _this.teamDisplayName) || other.teamDisplayName == _this.teamDisplayName)&&(identical(other.purpose, _this.purpose) || other.purpose == _this.purpose)&&(identical(other.header, _this.header) || other.header == _this.header)&&(identical(other.archived, _this.archived) || other.archived == _this.archived)&&(identical(other.joined, _this.joined) || other.joined == _this.joined)&&(identical(other.favorite, _this.favorite) || other.favorite == _this.favorite)&&(identical(other.muted, _this.muted) || other.muted == _this.muted)&&(identical(other.memberCount, _this.memberCount) || other.memberCount == _this.memberCount)&&(identical(other.partnerId, _this.partnerId) || other.partnerId == _this.partnerId)&&(identical(other.creatorName, _this.creatorName) || other.creatorName == _this.creatorName)&&(identical(other.createAt, _this.createAt) || other.createAt == _this.createAt)&&(identical(other.notify, _this.notify) || other.notify == _this.notify)&&(identical(other.canEdit, _this.canEdit) || other.canEdit == _this.canEdit)&&(identical(other.canArchive, _this.canArchive) || other.canArchive == _this.canArchive)&&(identical(other.canManageMembers, _this.canManageMembers) || other.canManageMembers == _this.canManageMembers));
}


@override
int get hashCode {
  final _this = this as ChannelInfo;
  return Object.hashAll([runtimeType,_this.id,_this.type,_this.name,_this.title,_this.teamId,_this.teamName,_this.teamDisplayName,_this.purpose,_this.header,_this.archived,_this.joined,_this.favorite,_this.muted,_this.memberCount,_this.partnerId,_this.creatorName,_this.createAt,_this.notify,_this.canEdit,_this.canArchive,_this.canManageMembers]);
}

@override
String toString() {
  final _this = this as ChannelInfo;
  return 'ChannelInfo(id: ${_this.id}, type: ${_this.type}, name: ${_this.name}, title: ${_this.title}, teamId: ${_this.teamId}, teamName: ${_this.teamName}, teamDisplayName: ${_this.teamDisplayName}, purpose: ${_this.purpose}, header: ${_this.header}, archived: ${_this.archived}, joined: ${_this.joined}, favorite: ${_this.favorite}, muted: ${_this.muted}, memberCount: ${_this.memberCount}, partnerId: ${_this.partnerId}, creatorName: ${_this.creatorName}, createAt: ${_this.createAt}, notify: ${_this.notify}, canEdit: ${_this.canEdit}, canArchive: ${_this.canArchive}, canManageMembers: ${_this.canManageMembers})';
}


}

/// @nodoc
abstract mixin class $ChannelInfoCopyWith<$Res>  {
  factory $ChannelInfoCopyWith(ChannelInfo value, $Res Function(ChannelInfo) _then) = _$ChannelInfoCopyWithImpl;
@useResult
$Res call({
 String id, String type, String name, String title, String teamId, String teamName, String teamDisplayName, String purpose, String header, bool archived, bool joined, bool favorite, bool muted, int? memberCount, String? partnerId, String? creatorName, DateTime? createAt, ChannelNotify notify, bool canEdit, bool canArchive, bool canManageMembers
});


$ChannelNotifyCopyWith<$Res> get notify;

}
/// @nodoc
class _$ChannelInfoCopyWithImpl<$Res>
    implements $ChannelInfoCopyWith<$Res> {
  _$ChannelInfoCopyWithImpl(this._self, this._then);

  final ChannelInfo _self;
  final $Res Function(ChannelInfo) _then;

/// Create a copy of ChannelInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? name = null,Object? title = null,Object? teamId = null,Object? teamName = null,Object? teamDisplayName = null,Object? purpose = null,Object? header = null,Object? archived = null,Object? joined = null,Object? favorite = null,Object? muted = null,Object? memberCount = freezed,Object? partnerId = freezed,Object? creatorName = freezed,Object? createAt = freezed,Object? notify = null,Object? canEdit = null,Object? canArchive = null,Object? canManageMembers = null,}) {
  return _then(ChannelInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,teamName: null == teamName ? _self.teamName : teamName // ignore: cast_nullable_to_non_nullable
as String,teamDisplayName: null == teamDisplayName ? _self.teamDisplayName : teamDisplayName // ignore: cast_nullable_to_non_nullable
as String,purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as String,header: null == header ? _self.header : header // ignore: cast_nullable_to_non_nullable
as String,archived: null == archived ? _self.archived : archived // ignore: cast_nullable_to_non_nullable
as bool,joined: null == joined ? _self.joined : joined // ignore: cast_nullable_to_non_nullable
as bool,favorite: null == favorite ? _self.favorite : favorite // ignore: cast_nullable_to_non_nullable
as bool,muted: null == muted ? _self.muted : muted // ignore: cast_nullable_to_non_nullable
as bool,memberCount: freezed == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int?,partnerId: freezed == partnerId ? _self.partnerId : partnerId // ignore: cast_nullable_to_non_nullable
as String?,creatorName: freezed == creatorName ? _self.creatorName : creatorName // ignore: cast_nullable_to_non_nullable
as String?,createAt: freezed == createAt ? _self.createAt : createAt // ignore: cast_nullable_to_non_nullable
as DateTime?,notify: null == notify ? _self.notify : notify // ignore: cast_nullable_to_non_nullable
as ChannelNotify,canEdit: null == canEdit ? _self.canEdit : canEdit // ignore: cast_nullable_to_non_nullable
as bool,canArchive: null == canArchive ? _self.canArchive : canArchive // ignore: cast_nullable_to_non_nullable
as bool,canManageMembers: null == canManageMembers ? _self.canManageMembers : canManageMembers // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of ChannelInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChannelNotifyCopyWith<$Res> get notify {
  
  return $ChannelNotifyCopyWith<$Res>(_self.notify, (value) {
    return _then(_self.copyWith(notify: value));
  });
}
}


/// Adds pattern-matching-related methods to [ChannelInfo].
extension ChannelInfoPatterns on ChannelInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChannelInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChannelInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChannelInfo value)  $default,){
final _that = this;
switch (_that) {
case _ChannelInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChannelInfo value)?  $default,){
final _that = this;
switch (_that) {
case _ChannelInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String type,  String name,  String title,  String teamId,  String teamName,  String teamDisplayName,  String purpose,  String header,  bool archived,  bool joined,  bool favorite,  bool muted,  int? memberCount,  String? partnerId,  String? creatorName,  DateTime? createAt,  ChannelNotify notify,  bool canEdit,  bool canArchive,  bool canManageMembers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChannelInfo() when $default != null:
return $default(_that.id,_that.type,_that.name,_that.title,_that.teamId,_that.teamName,_that.teamDisplayName,_that.purpose,_that.header,_that.archived,_that.joined,_that.favorite,_that.muted,_that.memberCount,_that.partnerId,_that.creatorName,_that.createAt,_that.notify,_that.canEdit,_that.canArchive,_that.canManageMembers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String type,  String name,  String title,  String teamId,  String teamName,  String teamDisplayName,  String purpose,  String header,  bool archived,  bool joined,  bool favorite,  bool muted,  int? memberCount,  String? partnerId,  String? creatorName,  DateTime? createAt,  ChannelNotify notify,  bool canEdit,  bool canArchive,  bool canManageMembers)  $default,) {final _that = this;
switch (_that) {
case _ChannelInfo():
return $default(_that.id,_that.type,_that.name,_that.title,_that.teamId,_that.teamName,_that.teamDisplayName,_that.purpose,_that.header,_that.archived,_that.joined,_that.favorite,_that.muted,_that.memberCount,_that.partnerId,_that.creatorName,_that.createAt,_that.notify,_that.canEdit,_that.canArchive,_that.canManageMembers);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String type,  String name,  String title,  String teamId,  String teamName,  String teamDisplayName,  String purpose,  String header,  bool archived,  bool joined,  bool favorite,  bool muted,  int? memberCount,  String? partnerId,  String? creatorName,  DateTime? createAt,  ChannelNotify notify,  bool canEdit,  bool canArchive,  bool canManageMembers)?  $default,) {final _that = this;
switch (_that) {
case _ChannelInfo() when $default != null:
return $default(_that.id,_that.type,_that.name,_that.title,_that.teamId,_that.teamName,_that.teamDisplayName,_that.purpose,_that.header,_that.archived,_that.joined,_that.favorite,_that.muted,_that.memberCount,_that.partnerId,_that.creatorName,_that.createAt,_that.notify,_that.canEdit,_that.canArchive,_that.canManageMembers);case _:
  return null;

}
}

}

/// @nodoc


class _ChannelInfo extends ChannelInfo {
  const _ChannelInfo({required this.id, required this.type, required this.name, required this.title, required this.teamId, required this.teamName, required this.teamDisplayName, required this.purpose, required this.header, required this.archived, required this.joined, required this.favorite, required this.muted, this.memberCount, this.partnerId, this.creatorName, this.createAt, required this.notify, required this.canEdit, required this.canArchive, required this.canManageMembers}): super._();
  

@override final  String id;
/// `O`, `P`, `D` or `G`.
@override final  String type;
@override final  String name;
@override final  String title;
@override final  String teamId;
@override final  String teamName;
@override final  String teamDisplayName;
@override final  String purpose;
@override final  String header;
@override final  bool archived;
@override final  bool joined;
@override final  bool favorite;
@override final  bool muted;
@override final  int? memberCount;
/// The other person of a direct message.
@override final  String? partnerId;
@override final  String? creatorName;
@override final  DateTime? createAt;
@override final  ChannelNotify notify;
@override final  bool canEdit;
@override final  bool canArchive;
@override final  bool canManageMembers;

/// Create a copy of ChannelInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChannelInfoCopyWith<_ChannelInfo> get copyWith => __$ChannelInfoCopyWithImpl<_ChannelInfo>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChannelInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.title, title) || other.title == title)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.teamName, teamName) || other.teamName == teamName)&&(identical(other.teamDisplayName, teamDisplayName) || other.teamDisplayName == teamDisplayName)&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.header, header) || other.header == header)&&(identical(other.archived, archived) || other.archived == archived)&&(identical(other.joined, joined) || other.joined == joined)&&(identical(other.favorite, favorite) || other.favorite == favorite)&&(identical(other.muted, muted) || other.muted == muted)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount)&&(identical(other.partnerId, partnerId) || other.partnerId == partnerId)&&(identical(other.creatorName, creatorName) || other.creatorName == creatorName)&&(identical(other.createAt, createAt) || other.createAt == createAt)&&(identical(other.notify, notify) || other.notify == notify)&&(identical(other.canEdit, canEdit) || other.canEdit == canEdit)&&(identical(other.canArchive, canArchive) || other.canArchive == canArchive)&&(identical(other.canManageMembers, canManageMembers) || other.canManageMembers == canManageMembers));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,id,type,name,title,teamId,teamName,teamDisplayName,purpose,header,archived,joined,favorite,muted,memberCount,partnerId,creatorName,createAt,notify,canEdit,canArchive,canManageMembers]);
}

@override
String toString() {
    return 'ChannelInfo(id: $id, type: $type, name: $name, title: $title, teamId: $teamId, teamName: $teamName, teamDisplayName: $teamDisplayName, purpose: $purpose, header: $header, archived: $archived, joined: $joined, favorite: $favorite, muted: $muted, memberCount: $memberCount, partnerId: $partnerId, creatorName: $creatorName, createAt: $createAt, notify: $notify, canEdit: $canEdit, canArchive: $canArchive, canManageMembers: $canManageMembers)';
}


}

/// @nodoc
abstract mixin class _$ChannelInfoCopyWith<$Res> implements $ChannelInfoCopyWith<$Res> {
  factory _$ChannelInfoCopyWith(_ChannelInfo value, $Res Function(_ChannelInfo) _then) = __$ChannelInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, String type, String name, String title, String teamId, String teamName, String teamDisplayName, String purpose, String header, bool archived, bool joined, bool favorite, bool muted, int? memberCount, String? partnerId, String? creatorName, DateTime? createAt, ChannelNotify notify, bool canEdit, bool canArchive, bool canManageMembers
});


@override $ChannelNotifyCopyWith<$Res> get notify;

}
/// @nodoc
class __$ChannelInfoCopyWithImpl<$Res>
    implements _$ChannelInfoCopyWith<$Res> {
  __$ChannelInfoCopyWithImpl(this._self, this._then);

  final _ChannelInfo _self;
  final $Res Function(_ChannelInfo) _then;

/// Create a copy of ChannelInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? name = null,Object? title = null,Object? teamId = null,Object? teamName = null,Object? teamDisplayName = null,Object? purpose = null,Object? header = null,Object? archived = null,Object? joined = null,Object? favorite = null,Object? muted = null,Object? memberCount = freezed,Object? partnerId = freezed,Object? creatorName = freezed,Object? createAt = freezed,Object? notify = null,Object? canEdit = null,Object? canArchive = null,Object? canManageMembers = null,}) {
  return _then(_ChannelInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,teamName: null == teamName ? _self.teamName : teamName // ignore: cast_nullable_to_non_nullable
as String,teamDisplayName: null == teamDisplayName ? _self.teamDisplayName : teamDisplayName // ignore: cast_nullable_to_non_nullable
as String,purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as String,header: null == header ? _self.header : header // ignore: cast_nullable_to_non_nullable
as String,archived: null == archived ? _self.archived : archived // ignore: cast_nullable_to_non_nullable
as bool,joined: null == joined ? _self.joined : joined // ignore: cast_nullable_to_non_nullable
as bool,favorite: null == favorite ? _self.favorite : favorite // ignore: cast_nullable_to_non_nullable
as bool,muted: null == muted ? _self.muted : muted // ignore: cast_nullable_to_non_nullable
as bool,memberCount: freezed == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int?,partnerId: freezed == partnerId ? _self.partnerId : partnerId // ignore: cast_nullable_to_non_nullable
as String?,creatorName: freezed == creatorName ? _self.creatorName : creatorName // ignore: cast_nullable_to_non_nullable
as String?,createAt: freezed == createAt ? _self.createAt : createAt // ignore: cast_nullable_to_non_nullable
as DateTime?,notify: null == notify ? _self.notify : notify // ignore: cast_nullable_to_non_nullable
as ChannelNotify,canEdit: null == canEdit ? _self.canEdit : canEdit // ignore: cast_nullable_to_non_nullable
as bool,canArchive: null == canArchive ? _self.canArchive : canArchive // ignore: cast_nullable_to_non_nullable
as bool,canManageMembers: null == canManageMembers ? _self.canManageMembers : canManageMembers // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of ChannelInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChannelNotifyCopyWith<$Res> get notify {
  
  return $ChannelNotifyCopyWith<$Res>(_self.notify, (value) {
    return _then(_self.copyWith(notify: value));
  });
}
}

/// @nodoc
mixin _$ChannelNotify {

 String get push; String get desktop; String get ignoreChannelMentions;/// The account's own settings, which `default` stands for.
 String get accountPush; String get accountDesktop;
/// Create a copy of ChannelNotify
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChannelNotifyCopyWith<ChannelNotify> get copyWith => _$ChannelNotifyCopyWithImpl<ChannelNotify>(this as ChannelNotify, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ChannelNotify;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChannelNotify&&(identical(other.push, _this.push) || other.push == _this.push)&&(identical(other.desktop, _this.desktop) || other.desktop == _this.desktop)&&(identical(other.ignoreChannelMentions, _this.ignoreChannelMentions) || other.ignoreChannelMentions == _this.ignoreChannelMentions)&&(identical(other.accountPush, _this.accountPush) || other.accountPush == _this.accountPush)&&(identical(other.accountDesktop, _this.accountDesktop) || other.accountDesktop == _this.accountDesktop));
}


@override
int get hashCode {
  final _this = this as ChannelNotify;
  return Object.hash(runtimeType,_this.push,_this.desktop,_this.ignoreChannelMentions,_this.accountPush,_this.accountDesktop);
}

@override
String toString() {
  final _this = this as ChannelNotify;
  return 'ChannelNotify(push: ${_this.push}, desktop: ${_this.desktop}, ignoreChannelMentions: ${_this.ignoreChannelMentions}, accountPush: ${_this.accountPush}, accountDesktop: ${_this.accountDesktop})';
}


}

/// @nodoc
abstract mixin class $ChannelNotifyCopyWith<$Res>  {
  factory $ChannelNotifyCopyWith(ChannelNotify value, $Res Function(ChannelNotify) _then) = _$ChannelNotifyCopyWithImpl;
@useResult
$Res call({
 String push, String desktop, String ignoreChannelMentions, String accountPush, String accountDesktop
});




}
/// @nodoc
class _$ChannelNotifyCopyWithImpl<$Res>
    implements $ChannelNotifyCopyWith<$Res> {
  _$ChannelNotifyCopyWithImpl(this._self, this._then);

  final ChannelNotify _self;
  final $Res Function(ChannelNotify) _then;

/// Create a copy of ChannelNotify
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? push = null,Object? desktop = null,Object? ignoreChannelMentions = null,Object? accountPush = null,Object? accountDesktop = null,}) {
  return _then(ChannelNotify(
push: null == push ? _self.push : push // ignore: cast_nullable_to_non_nullable
as String,desktop: null == desktop ? _self.desktop : desktop // ignore: cast_nullable_to_non_nullable
as String,ignoreChannelMentions: null == ignoreChannelMentions ? _self.ignoreChannelMentions : ignoreChannelMentions // ignore: cast_nullable_to_non_nullable
as String,accountPush: null == accountPush ? _self.accountPush : accountPush // ignore: cast_nullable_to_non_nullable
as String,accountDesktop: null == accountDesktop ? _self.accountDesktop : accountDesktop // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ChannelNotify].
extension ChannelNotifyPatterns on ChannelNotify {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChannelNotify value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChannelNotify() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChannelNotify value)  $default,){
final _that = this;
switch (_that) {
case _ChannelNotify():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChannelNotify value)?  $default,){
final _that = this;
switch (_that) {
case _ChannelNotify() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String push,  String desktop,  String ignoreChannelMentions,  String accountPush,  String accountDesktop)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChannelNotify() when $default != null:
return $default(_that.push,_that.desktop,_that.ignoreChannelMentions,_that.accountPush,_that.accountDesktop);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String push,  String desktop,  String ignoreChannelMentions,  String accountPush,  String accountDesktop)  $default,) {final _that = this;
switch (_that) {
case _ChannelNotify():
return $default(_that.push,_that.desktop,_that.ignoreChannelMentions,_that.accountPush,_that.accountDesktop);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String push,  String desktop,  String ignoreChannelMentions,  String accountPush,  String accountDesktop)?  $default,) {final _that = this;
switch (_that) {
case _ChannelNotify() when $default != null:
return $default(_that.push,_that.desktop,_that.ignoreChannelMentions,_that.accountPush,_that.accountDesktop);case _:
  return null;

}
}

}

/// @nodoc


class _ChannelNotify implements ChannelNotify {
  const _ChannelNotify({this.push = 'default', this.desktop = 'default', this.ignoreChannelMentions = 'default', this.accountPush = 'mention', this.accountDesktop = 'mention'});
  

@override@JsonKey() final  String push;
@override@JsonKey() final  String desktop;
@override@JsonKey() final  String ignoreChannelMentions;
/// The account's own settings, which `default` stands for.
@override@JsonKey() final  String accountPush;
@override@JsonKey() final  String accountDesktop;

/// Create a copy of ChannelNotify
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChannelNotifyCopyWith<_ChannelNotify> get copyWith => __$ChannelNotifyCopyWithImpl<_ChannelNotify>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChannelNotify&&(identical(other.push, push) || other.push == push)&&(identical(other.desktop, desktop) || other.desktop == desktop)&&(identical(other.ignoreChannelMentions, ignoreChannelMentions) || other.ignoreChannelMentions == ignoreChannelMentions)&&(identical(other.accountPush, accountPush) || other.accountPush == accountPush)&&(identical(other.accountDesktop, accountDesktop) || other.accountDesktop == accountDesktop));
}


@override
int get hashCode {
    return Object.hash(runtimeType,push,desktop,ignoreChannelMentions,accountPush,accountDesktop);
}

@override
String toString() {
    return 'ChannelNotify(push: $push, desktop: $desktop, ignoreChannelMentions: $ignoreChannelMentions, accountPush: $accountPush, accountDesktop: $accountDesktop)';
}


}

/// @nodoc
abstract mixin class _$ChannelNotifyCopyWith<$Res> implements $ChannelNotifyCopyWith<$Res> {
  factory _$ChannelNotifyCopyWith(_ChannelNotify value, $Res Function(_ChannelNotify) _then) = __$ChannelNotifyCopyWithImpl;
@override @useResult
$Res call({
 String push, String desktop, String ignoreChannelMentions, String accountPush, String accountDesktop
});




}
/// @nodoc
class __$ChannelNotifyCopyWithImpl<$Res>
    implements _$ChannelNotifyCopyWith<$Res> {
  __$ChannelNotifyCopyWithImpl(this._self, this._then);

  final _ChannelNotify _self;
  final $Res Function(_ChannelNotify) _then;

/// Create a copy of ChannelNotify
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? push = null,Object? desktop = null,Object? ignoreChannelMentions = null,Object? accountPush = null,Object? accountDesktop = null,}) {
  return _then(_ChannelNotify(
push: null == push ? _self.push : push // ignore: cast_nullable_to_non_nullable
as String,desktop: null == desktop ? _self.desktop : desktop // ignore: cast_nullable_to_non_nullable
as String,ignoreChannelMentions: null == ignoreChannelMentions ? _self.ignoreChannelMentions : ignoreChannelMentions // ignore: cast_nullable_to_non_nullable
as String,accountPush: null == accountPush ? _self.accountPush : accountPush // ignore: cast_nullable_to_non_nullable
as String,accountDesktop: null == accountDesktop ? _self.accountDesktop : accountDesktop // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
