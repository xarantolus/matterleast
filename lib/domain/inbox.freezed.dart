// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inbox.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$InboxItem {

 String get serverUrl; InboxKind get kind; String get channelId;/// The team to show in the rail when the row is opened.
 String? get teamId; String get title;/// Whose initials the avatar shows.
 String get avatarName;/// Whose picture the avatar shows, and its version; null for groups.
 String? get avatarUserId; int? get avatarPictureUpdate;/// Who wrote the previewed message; null when the title already says.
 String? get author; String get preview;/// Where the message is, for rows whose title doesn't say it, such as
/// `#town-square` for a thread.
 String? get place; DateTime get time;/// Unread messages or new replies; 0 shows a dot when [unread].
 int get count; bool get unread; String? get postId; String? get rootId;/// A reply under collapsed threads: it opens in its thread.
 bool get inThread;/// Presence of the other person in a direct message.
 String? get status;
/// Create a copy of InboxItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InboxItemCopyWith<InboxItem> get copyWith => _$InboxItemCopyWithImpl<InboxItem>(this as InboxItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as InboxItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InboxItem&&(identical(other.serverUrl, _this.serverUrl) || other.serverUrl == _this.serverUrl)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.channelId, _this.channelId) || other.channelId == _this.channelId)&&(identical(other.teamId, _this.teamId) || other.teamId == _this.teamId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.avatarName, _this.avatarName) || other.avatarName == _this.avatarName)&&(identical(other.avatarUserId, _this.avatarUserId) || other.avatarUserId == _this.avatarUserId)&&(identical(other.avatarPictureUpdate, _this.avatarPictureUpdate) || other.avatarPictureUpdate == _this.avatarPictureUpdate)&&(identical(other.author, _this.author) || other.author == _this.author)&&(identical(other.preview, _this.preview) || other.preview == _this.preview)&&(identical(other.place, _this.place) || other.place == _this.place)&&(identical(other.time, _this.time) || other.time == _this.time)&&(identical(other.count, _this.count) || other.count == _this.count)&&(identical(other.unread, _this.unread) || other.unread == _this.unread)&&(identical(other.postId, _this.postId) || other.postId == _this.postId)&&(identical(other.rootId, _this.rootId) || other.rootId == _this.rootId)&&(identical(other.inThread, _this.inThread) || other.inThread == _this.inThread)&&(identical(other.status, _this.status) || other.status == _this.status));
}


@override
int get hashCode {
  final _this = this as InboxItem;
  return Object.hash(runtimeType,_this.serverUrl,_this.kind,_this.channelId,_this.teamId,_this.title,_this.avatarName,_this.avatarUserId,_this.avatarPictureUpdate,_this.author,_this.preview,_this.place,_this.time,_this.count,_this.unread,_this.postId,_this.rootId,_this.inThread,_this.status);
}

@override
String toString() {
  final _this = this as InboxItem;
  return 'InboxItem(serverUrl: ${_this.serverUrl}, kind: ${_this.kind}, channelId: ${_this.channelId}, teamId: ${_this.teamId}, title: ${_this.title}, avatarName: ${_this.avatarName}, avatarUserId: ${_this.avatarUserId}, avatarPictureUpdate: ${_this.avatarPictureUpdate}, author: ${_this.author}, preview: ${_this.preview}, place: ${_this.place}, time: ${_this.time}, count: ${_this.count}, unread: ${_this.unread}, postId: ${_this.postId}, rootId: ${_this.rootId}, inThread: ${_this.inThread}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $InboxItemCopyWith<$Res>  {
  factory $InboxItemCopyWith(InboxItem value, $Res Function(InboxItem) _then) = _$InboxItemCopyWithImpl;
@useResult
$Res call({
 String serverUrl, InboxKind kind, String channelId, String? teamId, String title, String avatarName, String? avatarUserId, int? avatarPictureUpdate, String? author, String preview, String? place, DateTime time, int count, bool unread, String? postId, String? rootId, bool inThread, String? status
});




}
/// @nodoc
class _$InboxItemCopyWithImpl<$Res>
    implements $InboxItemCopyWith<$Res> {
  _$InboxItemCopyWithImpl(this._self, this._then);

  final InboxItem _self;
  final $Res Function(InboxItem) _then;

/// Create a copy of InboxItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? serverUrl = null,Object? kind = null,Object? channelId = null,Object? teamId = freezed,Object? title = null,Object? avatarName = null,Object? avatarUserId = freezed,Object? avatarPictureUpdate = freezed,Object? author = freezed,Object? preview = null,Object? place = freezed,Object? time = null,Object? count = null,Object? unread = null,Object? postId = freezed,Object? rootId = freezed,Object? inThread = null,Object? status = freezed,}) {
  return _then(InboxItem(
serverUrl: null == serverUrl ? _self.serverUrl : serverUrl // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as InboxKind,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,teamId: freezed == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,avatarName: null == avatarName ? _self.avatarName : avatarName // ignore: cast_nullable_to_non_nullable
as String,avatarUserId: freezed == avatarUserId ? _self.avatarUserId : avatarUserId // ignore: cast_nullable_to_non_nullable
as String?,avatarPictureUpdate: freezed == avatarPictureUpdate ? _self.avatarPictureUpdate : avatarPictureUpdate // ignore: cast_nullable_to_non_nullable
as int?,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String?,preview: null == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as String,place: freezed == place ? _self.place : place // ignore: cast_nullable_to_non_nullable
as String?,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as DateTime,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,unread: null == unread ? _self.unread : unread // ignore: cast_nullable_to_non_nullable
as bool,postId: freezed == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String?,rootId: freezed == rootId ? _self.rootId : rootId // ignore: cast_nullable_to_non_nullable
as String?,inThread: null == inThread ? _self.inThread : inThread // ignore: cast_nullable_to_non_nullable
as bool,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [InboxItem].
extension InboxItemPatterns on InboxItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InboxItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InboxItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InboxItem value)  $default,){
final _that = this;
switch (_that) {
case _InboxItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InboxItem value)?  $default,){
final _that = this;
switch (_that) {
case _InboxItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String serverUrl,  InboxKind kind,  String channelId,  String? teamId,  String title,  String avatarName,  String? avatarUserId,  int? avatarPictureUpdate,  String? author,  String preview,  String? place,  DateTime time,  int count,  bool unread,  String? postId,  String? rootId,  bool inThread,  String? status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InboxItem() when $default != null:
return $default(_that.serverUrl,_that.kind,_that.channelId,_that.teamId,_that.title,_that.avatarName,_that.avatarUserId,_that.avatarPictureUpdate,_that.author,_that.preview,_that.place,_that.time,_that.count,_that.unread,_that.postId,_that.rootId,_that.inThread,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String serverUrl,  InboxKind kind,  String channelId,  String? teamId,  String title,  String avatarName,  String? avatarUserId,  int? avatarPictureUpdate,  String? author,  String preview,  String? place,  DateTime time,  int count,  bool unread,  String? postId,  String? rootId,  bool inThread,  String? status)  $default,) {final _that = this;
switch (_that) {
case _InboxItem():
return $default(_that.serverUrl,_that.kind,_that.channelId,_that.teamId,_that.title,_that.avatarName,_that.avatarUserId,_that.avatarPictureUpdate,_that.author,_that.preview,_that.place,_that.time,_that.count,_that.unread,_that.postId,_that.rootId,_that.inThread,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String serverUrl,  InboxKind kind,  String channelId,  String? teamId,  String title,  String avatarName,  String? avatarUserId,  int? avatarPictureUpdate,  String? author,  String preview,  String? place,  DateTime time,  int count,  bool unread,  String? postId,  String? rootId,  bool inThread,  String? status)?  $default,) {final _that = this;
switch (_that) {
case _InboxItem() when $default != null:
return $default(_that.serverUrl,_that.kind,_that.channelId,_that.teamId,_that.title,_that.avatarName,_that.avatarUserId,_that.avatarPictureUpdate,_that.author,_that.preview,_that.place,_that.time,_that.count,_that.unread,_that.postId,_that.rootId,_that.inThread,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _InboxItem extends InboxItem {
  const _InboxItem({required this.serverUrl, required this.kind, required this.channelId, required this.teamId, required this.title, required this.avatarName, this.avatarUserId, this.avatarPictureUpdate, required this.author, required this.preview, required this.place, required this.time, required this.count, required this.unread, this.postId, this.rootId, this.inThread = false, this.status}): super._();
  

@override final  String serverUrl;
@override final  InboxKind kind;
@override final  String channelId;
/// The team to show in the rail when the row is opened.
@override final  String? teamId;
@override final  String title;
/// Whose initials the avatar shows.
@override final  String avatarName;
/// Whose picture the avatar shows, and its version; null for groups.
@override final  String? avatarUserId;
@override final  int? avatarPictureUpdate;
/// Who wrote the previewed message; null when the title already says.
@override final  String? author;
@override final  String preview;
/// Where the message is, for rows whose title doesn't say it, such as
/// `#town-square` for a thread.
@override final  String? place;
@override final  DateTime time;
/// Unread messages or new replies; 0 shows a dot when [unread].
@override final  int count;
@override final  bool unread;
@override final  String? postId;
@override final  String? rootId;
/// A reply under collapsed threads: it opens in its thread.
@override@JsonKey() final  bool inThread;
/// Presence of the other person in a direct message.
@override final  String? status;

/// Create a copy of InboxItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InboxItemCopyWith<_InboxItem> get copyWith => __$InboxItemCopyWithImpl<_InboxItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InboxItem&&(identical(other.serverUrl, serverUrl) || other.serverUrl == serverUrl)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.title, title) || other.title == title)&&(identical(other.avatarName, avatarName) || other.avatarName == avatarName)&&(identical(other.avatarUserId, avatarUserId) || other.avatarUserId == avatarUserId)&&(identical(other.avatarPictureUpdate, avatarPictureUpdate) || other.avatarPictureUpdate == avatarPictureUpdate)&&(identical(other.author, author) || other.author == author)&&(identical(other.preview, preview) || other.preview == preview)&&(identical(other.place, place) || other.place == place)&&(identical(other.time, time) || other.time == time)&&(identical(other.count, count) || other.count == count)&&(identical(other.unread, unread) || other.unread == unread)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.rootId, rootId) || other.rootId == rootId)&&(identical(other.inThread, inThread) || other.inThread == inThread)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode {
    return Object.hash(runtimeType,serverUrl,kind,channelId,teamId,title,avatarName,avatarUserId,avatarPictureUpdate,author,preview,place,time,count,unread,postId,rootId,inThread,status);
}

@override
String toString() {
    return 'InboxItem(serverUrl: $serverUrl, kind: $kind, channelId: $channelId, teamId: $teamId, title: $title, avatarName: $avatarName, avatarUserId: $avatarUserId, avatarPictureUpdate: $avatarPictureUpdate, author: $author, preview: $preview, place: $place, time: $time, count: $count, unread: $unread, postId: $postId, rootId: $rootId, inThread: $inThread, status: $status)';
}


}

/// @nodoc
abstract mixin class _$InboxItemCopyWith<$Res> implements $InboxItemCopyWith<$Res> {
  factory _$InboxItemCopyWith(_InboxItem value, $Res Function(_InboxItem) _then) = __$InboxItemCopyWithImpl;
@override @useResult
$Res call({
 String serverUrl, InboxKind kind, String channelId, String? teamId, String title, String avatarName, String? avatarUserId, int? avatarPictureUpdate, String? author, String preview, String? place, DateTime time, int count, bool unread, String? postId, String? rootId, bool inThread, String? status
});




}
/// @nodoc
class __$InboxItemCopyWithImpl<$Res>
    implements _$InboxItemCopyWith<$Res> {
  __$InboxItemCopyWithImpl(this._self, this._then);

  final _InboxItem _self;
  final $Res Function(_InboxItem) _then;

/// Create a copy of InboxItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? serverUrl = null,Object? kind = null,Object? channelId = null,Object? teamId = freezed,Object? title = null,Object? avatarName = null,Object? avatarUserId = freezed,Object? avatarPictureUpdate = freezed,Object? author = freezed,Object? preview = null,Object? place = freezed,Object? time = null,Object? count = null,Object? unread = null,Object? postId = freezed,Object? rootId = freezed,Object? inThread = null,Object? status = freezed,}) {
  return _then(_InboxItem(
serverUrl: null == serverUrl ? _self.serverUrl : serverUrl // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as InboxKind,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,teamId: freezed == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,avatarName: null == avatarName ? _self.avatarName : avatarName // ignore: cast_nullable_to_non_nullable
as String,avatarUserId: freezed == avatarUserId ? _self.avatarUserId : avatarUserId // ignore: cast_nullable_to_non_nullable
as String?,avatarPictureUpdate: freezed == avatarPictureUpdate ? _self.avatarPictureUpdate : avatarPictureUpdate // ignore: cast_nullable_to_non_nullable
as int?,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String?,preview: null == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as String,place: freezed == place ? _self.place : place // ignore: cast_nullable_to_non_nullable
as String?,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as DateTime,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,unread: null == unread ? _self.unread : unread // ignore: cast_nullable_to_non_nullable
as bool,postId: freezed == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String?,rootId: freezed == rootId ? _self.rootId : rootId // ignore: cast_nullable_to_non_nullable
as String?,inThread: null == inThread ? _self.inThread : inThread // ignore: cast_nullable_to_non_nullable
as bool,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$ServerInbox {

 List<InboxItem> get unread; List<InboxItem> get mentions; List<InboxItem> get threads; List<InboxItem> get saved; Set<InboxFilter> get known;
/// Create a copy of ServerInbox
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerInboxCopyWith<ServerInbox> get copyWith => _$ServerInboxCopyWithImpl<ServerInbox>(this as ServerInbox, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ServerInbox;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerInbox&&const DeepCollectionEquality().equals(other.unread, _this.unread)&&const DeepCollectionEquality().equals(other.mentions, _this.mentions)&&const DeepCollectionEquality().equals(other.threads, _this.threads)&&const DeepCollectionEquality().equals(other.saved, _this.saved)&&const DeepCollectionEquality().equals(other.known, _this.known));
}


@override
int get hashCode {
  final _this = this as ServerInbox;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.unread),const DeepCollectionEquality().hash(_this.mentions),const DeepCollectionEquality().hash(_this.threads),const DeepCollectionEquality().hash(_this.saved),const DeepCollectionEquality().hash(_this.known));
}

@override
String toString() {
  final _this = this as ServerInbox;
  return 'ServerInbox(unread: ${_this.unread}, mentions: ${_this.mentions}, threads: ${_this.threads}, saved: ${_this.saved}, known: ${_this.known})';
}


}

/// @nodoc
abstract mixin class $ServerInboxCopyWith<$Res>  {
  factory $ServerInboxCopyWith(ServerInbox value, $Res Function(ServerInbox) _then) = _$ServerInboxCopyWithImpl;
@useResult
$Res call({
 List<InboxItem> unread, List<InboxItem> mentions, List<InboxItem> threads, List<InboxItem> saved, Set<InboxFilter> known
});




}
/// @nodoc
class _$ServerInboxCopyWithImpl<$Res>
    implements $ServerInboxCopyWith<$Res> {
  _$ServerInboxCopyWithImpl(this._self, this._then);

  final ServerInbox _self;
  final $Res Function(ServerInbox) _then;

/// Create a copy of ServerInbox
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? unread = null,Object? mentions = null,Object? threads = null,Object? saved = null,Object? known = null,}) {
  return _then(ServerInbox(
unread: null == unread ? _self.unread : unread // ignore: cast_nullable_to_non_nullable
as List<InboxItem>,mentions: null == mentions ? _self.mentions : mentions // ignore: cast_nullable_to_non_nullable
as List<InboxItem>,threads: null == threads ? _self.threads : threads // ignore: cast_nullable_to_non_nullable
as List<InboxItem>,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as List<InboxItem>,known: null == known ? _self.known : known // ignore: cast_nullable_to_non_nullable
as Set<InboxFilter>,
  ));
}

}


/// Adds pattern-matching-related methods to [ServerInbox].
extension ServerInboxPatterns on ServerInbox {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ServerInbox value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ServerInbox() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ServerInbox value)  $default,){
final _that = this;
switch (_that) {
case _ServerInbox():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ServerInbox value)?  $default,){
final _that = this;
switch (_that) {
case _ServerInbox() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<InboxItem> unread,  List<InboxItem> mentions,  List<InboxItem> threads,  List<InboxItem> saved,  Set<InboxFilter> known)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServerInbox() when $default != null:
return $default(_that.unread,_that.mentions,_that.threads,_that.saved,_that.known);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<InboxItem> unread,  List<InboxItem> mentions,  List<InboxItem> threads,  List<InboxItem> saved,  Set<InboxFilter> known)  $default,) {final _that = this;
switch (_that) {
case _ServerInbox():
return $default(_that.unread,_that.mentions,_that.threads,_that.saved,_that.known);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<InboxItem> unread,  List<InboxItem> mentions,  List<InboxItem> threads,  List<InboxItem> saved,  Set<InboxFilter> known)?  $default,) {final _that = this;
switch (_that) {
case _ServerInbox() when $default != null:
return $default(_that.unread,_that.mentions,_that.threads,_that.saved,_that.known);case _:
  return null;

}
}

}

/// @nodoc


class _ServerInbox extends ServerInbox {
  const _ServerInbox({required  List<InboxItem> unread, required  List<InboxItem> mentions, required  List<InboxItem> threads, required  List<InboxItem> saved, required  Set<InboxFilter> known}): _unread = unread,_mentions = mentions,_threads = threads,_saved = saved,_known = known,super._();
  

 final  List<InboxItem> _unread;
@override List<InboxItem> get unread {
  if (_unread is EqualUnmodifiableListView) return _unread;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_unread);
}

 final  List<InboxItem> _mentions;
@override List<InboxItem> get mentions {
  if (_mentions is EqualUnmodifiableListView) return _mentions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mentions);
}

 final  List<InboxItem> _threads;
@override List<InboxItem> get threads {
  if (_threads is EqualUnmodifiableListView) return _threads;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_threads);
}

 final  List<InboxItem> _saved;
@override List<InboxItem> get saved {
  if (_saved is EqualUnmodifiableListView) return _saved;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_saved);
}

 final  Set<InboxFilter> _known;
@override Set<InboxFilter> get known {
  if (_known is EqualUnmodifiableSetView) return _known;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_known);
}


/// Create a copy of ServerInbox
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServerInboxCopyWith<_ServerInbox> get copyWith => __$ServerInboxCopyWithImpl<_ServerInbox>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServerInbox&&const DeepCollectionEquality().equals(other.unread, _unread)&&const DeepCollectionEquality().equals(other.mentions, _mentions)&&const DeepCollectionEquality().equals(other.threads, _threads)&&const DeepCollectionEquality().equals(other.saved, _saved)&&const DeepCollectionEquality().equals(other.known, _known));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_unread),const DeepCollectionEquality().hash(_mentions),const DeepCollectionEquality().hash(_threads),const DeepCollectionEquality().hash(_saved),const DeepCollectionEquality().hash(_known));
}

@override
String toString() {
    return 'ServerInbox(unread: $unread, mentions: $mentions, threads: $threads, saved: $saved, known: $known)';
}


}

/// @nodoc
abstract mixin class _$ServerInboxCopyWith<$Res> implements $ServerInboxCopyWith<$Res> {
  factory _$ServerInboxCopyWith(_ServerInbox value, $Res Function(_ServerInbox) _then) = __$ServerInboxCopyWithImpl;
@override @useResult
$Res call({
 List<InboxItem> unread, List<InboxItem> mentions, List<InboxItem> threads, List<InboxItem> saved, Set<InboxFilter> known
});




}
/// @nodoc
class __$ServerInboxCopyWithImpl<$Res>
    implements _$ServerInboxCopyWith<$Res> {
  __$ServerInboxCopyWithImpl(this._self, this._then);

  final _ServerInbox _self;
  final $Res Function(_ServerInbox) _then;

/// Create a copy of ServerInbox
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? unread = null,Object? mentions = null,Object? threads = null,Object? saved = null,Object? known = null,}) {
  return _then(_ServerInbox(
unread: null == unread ? _self._unread : unread // ignore: cast_nullable_to_non_nullable
as List<InboxItem>,mentions: null == mentions ? _self._mentions : mentions // ignore: cast_nullable_to_non_nullable
as List<InboxItem>,threads: null == threads ? _self._threads : threads // ignore: cast_nullable_to_non_nullable
as List<InboxItem>,saved: null == saved ? _self._saved : saved // ignore: cast_nullable_to_non_nullable
as List<InboxItem>,known: null == known ? _self._known : known // ignore: cast_nullable_to_non_nullable
as Set<InboxFilter>,
  ));
}


}

// dart format on
