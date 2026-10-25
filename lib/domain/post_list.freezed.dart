// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_list.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PostItem {

 String get id;/// Our own unsent post keeps this key when the server id arrives.
 String get key; String get userId; String get authorName; DateTime get createAt; String get message; String get type; String get rootId; DateTime? get editAt; bool get deleted;/// `pending` or `failed` while our own post is unsent.
 String? get sendState; int get replyCount;/// Names of the people who replied, newest first, when known.
 List<String> get participants;
/// Create a copy of PostItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostItemCopyWith<PostItem> get copyWith => _$PostItemCopyWithImpl<PostItem>(this as PostItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PostItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostItem&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.key, _this.key) || other.key == _this.key)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.authorName, _this.authorName) || other.authorName == _this.authorName)&&(identical(other.createAt, _this.createAt) || other.createAt == _this.createAt)&&(identical(other.message, _this.message) || other.message == _this.message)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.rootId, _this.rootId) || other.rootId == _this.rootId)&&(identical(other.editAt, _this.editAt) || other.editAt == _this.editAt)&&(identical(other.deleted, _this.deleted) || other.deleted == _this.deleted)&&(identical(other.sendState, _this.sendState) || other.sendState == _this.sendState)&&(identical(other.replyCount, _this.replyCount) || other.replyCount == _this.replyCount)&&const DeepCollectionEquality().equals(other.participants, _this.participants));
}


@override
int get hashCode {
  final _this = this as PostItem;
  return Object.hash(runtimeType,_this.id,_this.key,_this.userId,_this.authorName,_this.createAt,_this.message,_this.type,_this.rootId,_this.editAt,_this.deleted,_this.sendState,_this.replyCount,const DeepCollectionEquality().hash(_this.participants));
}

@override
String toString() {
  final _this = this as PostItem;
  return 'PostItem(id: ${_this.id}, key: ${_this.key}, userId: ${_this.userId}, authorName: ${_this.authorName}, createAt: ${_this.createAt}, message: ${_this.message}, type: ${_this.type}, rootId: ${_this.rootId}, editAt: ${_this.editAt}, deleted: ${_this.deleted}, sendState: ${_this.sendState}, replyCount: ${_this.replyCount}, participants: ${_this.participants})';
}


}

/// @nodoc
abstract mixin class $PostItemCopyWith<$Res>  {
  factory $PostItemCopyWith(PostItem value, $Res Function(PostItem) _then) = _$PostItemCopyWithImpl;
@useResult
$Res call({
 String id, String key, String userId, String authorName, DateTime createAt, String message, String type, String rootId, DateTime? editAt, bool deleted, String? sendState, int replyCount, List<String> participants
});




}
/// @nodoc
class _$PostItemCopyWithImpl<$Res>
    implements $PostItemCopyWith<$Res> {
  _$PostItemCopyWithImpl(this._self, this._then);

  final PostItem _self;
  final $Res Function(PostItem) _then;

/// Create a copy of PostItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? key = null,Object? userId = null,Object? authorName = null,Object? createAt = null,Object? message = null,Object? type = null,Object? rootId = null,Object? editAt = freezed,Object? deleted = null,Object? sendState = freezed,Object? replyCount = null,Object? participants = null,}) {
  return _then(PostItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,authorName: null == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String,createAt: null == createAt ? _self.createAt : createAt // ignore: cast_nullable_to_non_nullable
as DateTime,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,rootId: null == rootId ? _self.rootId : rootId // ignore: cast_nullable_to_non_nullable
as String,editAt: freezed == editAt ? _self.editAt : editAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,sendState: freezed == sendState ? _self.sendState : sendState // ignore: cast_nullable_to_non_nullable
as String?,replyCount: null == replyCount ? _self.replyCount : replyCount // ignore: cast_nullable_to_non_nullable
as int,participants: null == participants ? _self.participants : participants // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [PostItem].
extension PostItemPatterns on PostItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostItem value)  $default,){
final _that = this;
switch (_that) {
case _PostItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostItem value)?  $default,){
final _that = this;
switch (_that) {
case _PostItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String key,  String userId,  String authorName,  DateTime createAt,  String message,  String type,  String rootId,  DateTime? editAt,  bool deleted,  String? sendState,  int replyCount,  List<String> participants)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostItem() when $default != null:
return $default(_that.id,_that.key,_that.userId,_that.authorName,_that.createAt,_that.message,_that.type,_that.rootId,_that.editAt,_that.deleted,_that.sendState,_that.replyCount,_that.participants);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String key,  String userId,  String authorName,  DateTime createAt,  String message,  String type,  String rootId,  DateTime? editAt,  bool deleted,  String? sendState,  int replyCount,  List<String> participants)  $default,) {final _that = this;
switch (_that) {
case _PostItem():
return $default(_that.id,_that.key,_that.userId,_that.authorName,_that.createAt,_that.message,_that.type,_that.rootId,_that.editAt,_that.deleted,_that.sendState,_that.replyCount,_that.participants);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String key,  String userId,  String authorName,  DateTime createAt,  String message,  String type,  String rootId,  DateTime? editAt,  bool deleted,  String? sendState,  int replyCount,  List<String> participants)?  $default,) {final _that = this;
switch (_that) {
case _PostItem() when $default != null:
return $default(_that.id,_that.key,_that.userId,_that.authorName,_that.createAt,_that.message,_that.type,_that.rootId,_that.editAt,_that.deleted,_that.sendState,_that.replyCount,_that.participants);case _:
  return null;

}
}

}

/// @nodoc


class _PostItem extends PostItem {
  const _PostItem({required this.id, required this.key, required this.userId, required this.authorName, required this.createAt, required this.message, this.type = '', this.rootId = '', this.editAt, this.deleted = false, this.sendState, this.replyCount = 0,  List<String> participants = const <String>[]}): _participants = participants,super._();
  

@override final  String id;
/// Our own unsent post keeps this key when the server id arrives.
@override final  String key;
@override final  String userId;
@override final  String authorName;
@override final  DateTime createAt;
@override final  String message;
@override@JsonKey() final  String type;
@override@JsonKey() final  String rootId;
@override final  DateTime? editAt;
@override@JsonKey() final  bool deleted;
/// `pending` or `failed` while our own post is unsent.
@override final  String? sendState;
@override@JsonKey() final  int replyCount;
/// Names of the people who replied, newest first, when known.
 final  List<String> _participants;
/// Names of the people who replied, newest first, when known.
@override@JsonKey() List<String> get participants {
  if (_participants is EqualUnmodifiableListView) return _participants;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_participants);
}


/// Create a copy of PostItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostItemCopyWith<_PostItem> get copyWith => __$PostItemCopyWithImpl<_PostItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostItem&&(identical(other.id, id) || other.id == id)&&(identical(other.key, key) || other.key == key)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.authorName, authorName) || other.authorName == authorName)&&(identical(other.createAt, createAt) || other.createAt == createAt)&&(identical(other.message, message) || other.message == message)&&(identical(other.type, type) || other.type == type)&&(identical(other.rootId, rootId) || other.rootId == rootId)&&(identical(other.editAt, editAt) || other.editAt == editAt)&&(identical(other.deleted, deleted) || other.deleted == deleted)&&(identical(other.sendState, sendState) || other.sendState == sendState)&&(identical(other.replyCount, replyCount) || other.replyCount == replyCount)&&const DeepCollectionEquality().equals(other.participants, _participants));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,key,userId,authorName,createAt,message,type,rootId,editAt,deleted,sendState,replyCount,const DeepCollectionEquality().hash(_participants));
}

@override
String toString() {
    return 'PostItem(id: $id, key: $key, userId: $userId, authorName: $authorName, createAt: $createAt, message: $message, type: $type, rootId: $rootId, editAt: $editAt, deleted: $deleted, sendState: $sendState, replyCount: $replyCount, participants: $participants)';
}


}

/// @nodoc
abstract mixin class _$PostItemCopyWith<$Res> implements $PostItemCopyWith<$Res> {
  factory _$PostItemCopyWith(_PostItem value, $Res Function(_PostItem) _then) = __$PostItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String key, String userId, String authorName, DateTime createAt, String message, String type, String rootId, DateTime? editAt, bool deleted, String? sendState, int replyCount, List<String> participants
});




}
/// @nodoc
class __$PostItemCopyWithImpl<$Res>
    implements _$PostItemCopyWith<$Res> {
  __$PostItemCopyWithImpl(this._self, this._then);

  final _PostItem _self;
  final $Res Function(_PostItem) _then;

/// Create a copy of PostItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? key = null,Object? userId = null,Object? authorName = null,Object? createAt = null,Object? message = null,Object? type = null,Object? rootId = null,Object? editAt = freezed,Object? deleted = null,Object? sendState = freezed,Object? replyCount = null,Object? participants = null,}) {
  return _then(_PostItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,authorName: null == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String,createAt: null == createAt ? _self.createAt : createAt // ignore: cast_nullable_to_non_nullable
as DateTime,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,rootId: null == rootId ? _self.rootId : rootId // ignore: cast_nullable_to_non_nullable
as String,editAt: freezed == editAt ? _self.editAt : editAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,sendState: freezed == sendState ? _self.sendState : sendState // ignore: cast_nullable_to_non_nullable
as String?,replyCount: null == replyCount ? _self.replyCount : replyCount // ignore: cast_nullable_to_non_nullable
as int,participants: null == participants ? _self._participants : participants // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc
mixin _$ConversationWindow {

/// Newest first; replies only, for a thread.
 List<PostItem> get posts;/// Some history is stored, possibly none (an empty channel).
 bool get loaded;/// The oldest message of the conversation is in [posts].
 bool get reachesStart;/// Older stored messages exist beyond [posts].
 bool get moreStored;/// Newer messages are stored apart from these, after a gap.
 bool get newerApart;/// The thread's first message.
 PostItem? get root; String get channelName;/// `O`, `P`, `D` or `G`; direct and group messages are named after
/// people, not by [channelName].
 String get channelType; String get teamId; int? get memberCount;
/// Create a copy of ConversationWindow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConversationWindowCopyWith<ConversationWindow> get copyWith => _$ConversationWindowCopyWithImpl<ConversationWindow>(this as ConversationWindow, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ConversationWindow;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConversationWindow&&const DeepCollectionEquality().equals(other.posts, _this.posts)&&(identical(other.loaded, _this.loaded) || other.loaded == _this.loaded)&&(identical(other.reachesStart, _this.reachesStart) || other.reachesStart == _this.reachesStart)&&(identical(other.moreStored, _this.moreStored) || other.moreStored == _this.moreStored)&&(identical(other.newerApart, _this.newerApart) || other.newerApart == _this.newerApart)&&(identical(other.root, _this.root) || other.root == _this.root)&&(identical(other.channelName, _this.channelName) || other.channelName == _this.channelName)&&(identical(other.channelType, _this.channelType) || other.channelType == _this.channelType)&&(identical(other.teamId, _this.teamId) || other.teamId == _this.teamId)&&(identical(other.memberCount, _this.memberCount) || other.memberCount == _this.memberCount));
}


@override
int get hashCode {
  final _this = this as ConversationWindow;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.posts),_this.loaded,_this.reachesStart,_this.moreStored,_this.newerApart,_this.root,_this.channelName,_this.channelType,_this.teamId,_this.memberCount);
}

@override
String toString() {
  final _this = this as ConversationWindow;
  return 'ConversationWindow(posts: ${_this.posts}, loaded: ${_this.loaded}, reachesStart: ${_this.reachesStart}, moreStored: ${_this.moreStored}, newerApart: ${_this.newerApart}, root: ${_this.root}, channelName: ${_this.channelName}, channelType: ${_this.channelType}, teamId: ${_this.teamId}, memberCount: ${_this.memberCount})';
}


}

/// @nodoc
abstract mixin class $ConversationWindowCopyWith<$Res>  {
  factory $ConversationWindowCopyWith(ConversationWindow value, $Res Function(ConversationWindow) _then) = _$ConversationWindowCopyWithImpl;
@useResult
$Res call({
 List<PostItem> posts, bool loaded, bool reachesStart, bool moreStored, bool newerApart, PostItem? root, String channelName, String channelType, String teamId, int? memberCount
});


$PostItemCopyWith<$Res>? get root;

}
/// @nodoc
class _$ConversationWindowCopyWithImpl<$Res>
    implements $ConversationWindowCopyWith<$Res> {
  _$ConversationWindowCopyWithImpl(this._self, this._then);

  final ConversationWindow _self;
  final $Res Function(ConversationWindow) _then;

/// Create a copy of ConversationWindow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? posts = null,Object? loaded = null,Object? reachesStart = null,Object? moreStored = null,Object? newerApart = null,Object? root = freezed,Object? channelName = null,Object? channelType = null,Object? teamId = null,Object? memberCount = freezed,}) {
  return _then(ConversationWindow(
posts: null == posts ? _self.posts : posts // ignore: cast_nullable_to_non_nullable
as List<PostItem>,loaded: null == loaded ? _self.loaded : loaded // ignore: cast_nullable_to_non_nullable
as bool,reachesStart: null == reachesStart ? _self.reachesStart : reachesStart // ignore: cast_nullable_to_non_nullable
as bool,moreStored: null == moreStored ? _self.moreStored : moreStored // ignore: cast_nullable_to_non_nullable
as bool,newerApart: null == newerApart ? _self.newerApart : newerApart // ignore: cast_nullable_to_non_nullable
as bool,root: freezed == root ? _self.root : root // ignore: cast_nullable_to_non_nullable
as PostItem?,channelName: null == channelName ? _self.channelName : channelName // ignore: cast_nullable_to_non_nullable
as String,channelType: null == channelType ? _self.channelType : channelType // ignore: cast_nullable_to_non_nullable
as String,teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,memberCount: freezed == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of ConversationWindow
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostItemCopyWith<$Res>? get root {
    if (_self.root == null) {
    return null;
  }

  return $PostItemCopyWith<$Res>(_self.root!, (value) {
    return _then(_self.copyWith(root: value));
  });
}
}


/// Adds pattern-matching-related methods to [ConversationWindow].
extension ConversationWindowPatterns on ConversationWindow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConversationWindow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConversationWindow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConversationWindow value)  $default,){
final _that = this;
switch (_that) {
case _ConversationWindow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConversationWindow value)?  $default,){
final _that = this;
switch (_that) {
case _ConversationWindow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<PostItem> posts,  bool loaded,  bool reachesStart,  bool moreStored,  bool newerApart,  PostItem? root,  String channelName,  String channelType,  String teamId,  int? memberCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConversationWindow() when $default != null:
return $default(_that.posts,_that.loaded,_that.reachesStart,_that.moreStored,_that.newerApart,_that.root,_that.channelName,_that.channelType,_that.teamId,_that.memberCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<PostItem> posts,  bool loaded,  bool reachesStart,  bool moreStored,  bool newerApart,  PostItem? root,  String channelName,  String channelType,  String teamId,  int? memberCount)  $default,) {final _that = this;
switch (_that) {
case _ConversationWindow():
return $default(_that.posts,_that.loaded,_that.reachesStart,_that.moreStored,_that.newerApart,_that.root,_that.channelName,_that.channelType,_that.teamId,_that.memberCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<PostItem> posts,  bool loaded,  bool reachesStart,  bool moreStored,  bool newerApart,  PostItem? root,  String channelName,  String channelType,  String teamId,  int? memberCount)?  $default,) {final _that = this;
switch (_that) {
case _ConversationWindow() when $default != null:
return $default(_that.posts,_that.loaded,_that.reachesStart,_that.moreStored,_that.newerApart,_that.root,_that.channelName,_that.channelType,_that.teamId,_that.memberCount);case _:
  return null;

}
}

}

/// @nodoc


class _ConversationWindow implements ConversationWindow {
  const _ConversationWindow({required  List<PostItem> posts, required this.loaded, this.reachesStart = false, this.moreStored = false, this.newerApart = false, this.root, this.channelName = '', this.channelType = '', this.teamId = '', this.memberCount}): _posts = posts;
  

/// Newest first; replies only, for a thread.
 final  List<PostItem> _posts;
/// Newest first; replies only, for a thread.
@override List<PostItem> get posts {
  if (_posts is EqualUnmodifiableListView) return _posts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_posts);
}

/// Some history is stored, possibly none (an empty channel).
@override final  bool loaded;
/// The oldest message of the conversation is in [posts].
@override@JsonKey() final  bool reachesStart;
/// Older stored messages exist beyond [posts].
@override@JsonKey() final  bool moreStored;
/// Newer messages are stored apart from these, after a gap.
@override@JsonKey() final  bool newerApart;
/// The thread's first message.
@override final  PostItem? root;
@override@JsonKey() final  String channelName;
/// `O`, `P`, `D` or `G`; direct and group messages are named after
/// people, not by [channelName].
@override@JsonKey() final  String channelType;
@override@JsonKey() final  String teamId;
@override final  int? memberCount;

/// Create a copy of ConversationWindow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConversationWindowCopyWith<_ConversationWindow> get copyWith => __$ConversationWindowCopyWithImpl<_ConversationWindow>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConversationWindow&&const DeepCollectionEquality().equals(other.posts, _posts)&&(identical(other.loaded, loaded) || other.loaded == loaded)&&(identical(other.reachesStart, reachesStart) || other.reachesStart == reachesStart)&&(identical(other.moreStored, moreStored) || other.moreStored == moreStored)&&(identical(other.newerApart, newerApart) || other.newerApart == newerApart)&&(identical(other.root, root) || other.root == root)&&(identical(other.channelName, channelName) || other.channelName == channelName)&&(identical(other.channelType, channelType) || other.channelType == channelType)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_posts),loaded,reachesStart,moreStored,newerApart,root,channelName,channelType,teamId,memberCount);
}

@override
String toString() {
    return 'ConversationWindow(posts: $posts, loaded: $loaded, reachesStart: $reachesStart, moreStored: $moreStored, newerApart: $newerApart, root: $root, channelName: $channelName, channelType: $channelType, teamId: $teamId, memberCount: $memberCount)';
}


}

/// @nodoc
abstract mixin class _$ConversationWindowCopyWith<$Res> implements $ConversationWindowCopyWith<$Res> {
  factory _$ConversationWindowCopyWith(_ConversationWindow value, $Res Function(_ConversationWindow) _then) = __$ConversationWindowCopyWithImpl;
@override @useResult
$Res call({
 List<PostItem> posts, bool loaded, bool reachesStart, bool moreStored, bool newerApart, PostItem? root, String channelName, String channelType, String teamId, int? memberCount
});


@override $PostItemCopyWith<$Res>? get root;

}
/// @nodoc
class __$ConversationWindowCopyWithImpl<$Res>
    implements _$ConversationWindowCopyWith<$Res> {
  __$ConversationWindowCopyWithImpl(this._self, this._then);

  final _ConversationWindow _self;
  final $Res Function(_ConversationWindow) _then;

/// Create a copy of ConversationWindow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? posts = null,Object? loaded = null,Object? reachesStart = null,Object? moreStored = null,Object? newerApart = null,Object? root = freezed,Object? channelName = null,Object? channelType = null,Object? teamId = null,Object? memberCount = freezed,}) {
  return _then(_ConversationWindow(
posts: null == posts ? _self._posts : posts // ignore: cast_nullable_to_non_nullable
as List<PostItem>,loaded: null == loaded ? _self.loaded : loaded // ignore: cast_nullable_to_non_nullable
as bool,reachesStart: null == reachesStart ? _self.reachesStart : reachesStart // ignore: cast_nullable_to_non_nullable
as bool,moreStored: null == moreStored ? _self.moreStored : moreStored // ignore: cast_nullable_to_non_nullable
as bool,newerApart: null == newerApart ? _self.newerApart : newerApart // ignore: cast_nullable_to_non_nullable
as bool,root: freezed == root ? _self.root : root // ignore: cast_nullable_to_non_nullable
as PostItem?,channelName: null == channelName ? _self.channelName : channelName // ignore: cast_nullable_to_non_nullable
as String,channelType: null == channelType ? _self.channelType : channelType // ignore: cast_nullable_to_non_nullable
as String,teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,memberCount: freezed == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of ConversationWindow
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostItemCopyWith<$Res>? get root {
    if (_self.root == null) {
    return null;
  }

  return $PostItemCopyWith<$Res>(_self.root!, (value) {
    return _then(_self.copyWith(root: value));
  });
}
}

/// @nodoc
mixin _$ListRow {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ListRow);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ListRow()';
}


}

/// @nodoc
class $ListRowCopyWith<$Res>  {
$ListRowCopyWith(ListRow _, $Res Function(ListRow) __);
}


/// Adds pattern-matching-related methods to [ListRow].
extension ListRowPatterns on ListRow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( MessageRow value)?  post,TResult Function( DaySeparator value)?  day,TResult Function( NewMessagesLine value)?  newMessages,required TResult orElse(),}){
final _that = this;
switch (_that) {
case MessageRow() when post != null:
return post(_that);case DaySeparator() when day != null:
return day(_that);case NewMessagesLine() when newMessages != null:
return newMessages(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( MessageRow value)  post,required TResult Function( DaySeparator value)  day,required TResult Function( NewMessagesLine value)  newMessages,}){
final _that = this;
switch (_that) {
case MessageRow():
return post(_that);case DaySeparator():
return day(_that);case NewMessagesLine():
return newMessages(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( MessageRow value)?  post,TResult? Function( DaySeparator value)?  day,TResult? Function( NewMessagesLine value)?  newMessages,}){
final _that = this;
switch (_that) {
case MessageRow() when post != null:
return post(_that);case DaySeparator() when day != null:
return day(_that);case NewMessagesLine() when newMessages != null:
return newMessages(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( PostItem post,  bool compact)?  post,TResult Function( DateTime day)?  day,TResult Function( int count)?  newMessages,required TResult orElse(),}) {final _that = this;
switch (_that) {
case MessageRow() when post != null:
return post(_that.post,_that.compact);case DaySeparator() when day != null:
return day(_that.day);case NewMessagesLine() when newMessages != null:
return newMessages(_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( PostItem post,  bool compact)  post,required TResult Function( DateTime day)  day,required TResult Function( int count)  newMessages,}) {final _that = this;
switch (_that) {
case MessageRow():
return post(_that.post,_that.compact);case DaySeparator():
return day(_that.day);case NewMessagesLine():
return newMessages(_that.count);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( PostItem post,  bool compact)?  post,TResult? Function( DateTime day)?  day,TResult? Function( int count)?  newMessages,}) {final _that = this;
switch (_that) {
case MessageRow() when post != null:
return post(_that.post,_that.compact);case DaySeparator() when day != null:
return day(_that.day);case NewMessagesLine() when newMessages != null:
return newMessages(_that.count);case _:
  return null;

}
}

}

/// @nodoc


class MessageRow extends ListRow {
  const MessageRow(this.post, {this.compact = false}): super._();
  

 final  PostItem post;
/// Same author shortly after their previous message: no avatar or name.
@JsonKey() final  bool compact;

/// Create a copy of ListRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageRowCopyWith<MessageRow> get copyWith => _$MessageRowCopyWithImpl<MessageRow>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageRow&&(identical(other.post, post) || other.post == post)&&(identical(other.compact, compact) || other.compact == compact));
}


@override
int get hashCode {
    return Object.hash(runtimeType,post,compact);
}

@override
String toString() {
    return 'ListRow.post(post: $post, compact: $compact)';
}


}

/// @nodoc
abstract mixin class $MessageRowCopyWith<$Res> implements $ListRowCopyWith<$Res> {
  factory $MessageRowCopyWith(MessageRow value, $Res Function(MessageRow) _then) = _$MessageRowCopyWithImpl;
@useResult
$Res call({
 PostItem post, bool compact
});


$PostItemCopyWith<$Res> get post;

}
/// @nodoc
class _$MessageRowCopyWithImpl<$Res>
    implements $MessageRowCopyWith<$Res> {
  _$MessageRowCopyWithImpl(this._self, this._then);

  final MessageRow _self;
  final $Res Function(MessageRow) _then;

/// Create a copy of ListRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? post = null,Object? compact = null,}) {
  return _then(MessageRow(
null == post ? _self.post : post // ignore: cast_nullable_to_non_nullable
as PostItem,compact: null == compact ? _self.compact : compact // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of ListRow
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostItemCopyWith<$Res> get post {
  
  return $PostItemCopyWith<$Res>(_self.post, (value) {
    return _then(_self.copyWith(post: value));
  });
}
}

/// @nodoc


class DaySeparator extends ListRow {
  const DaySeparator(this.day): super._();
  

 final  DateTime day;

/// Create a copy of ListRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DaySeparatorCopyWith<DaySeparator> get copyWith => _$DaySeparatorCopyWithImpl<DaySeparator>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DaySeparator&&(identical(other.day, day) || other.day == day));
}


@override
int get hashCode {
    return Object.hash(runtimeType,day);
}

@override
String toString() {
    return 'ListRow.day(day: $day)';
}


}

/// @nodoc
abstract mixin class $DaySeparatorCopyWith<$Res> implements $ListRowCopyWith<$Res> {
  factory $DaySeparatorCopyWith(DaySeparator value, $Res Function(DaySeparator) _then) = _$DaySeparatorCopyWithImpl;
@useResult
$Res call({
 DateTime day
});




}
/// @nodoc
class _$DaySeparatorCopyWithImpl<$Res>
    implements $DaySeparatorCopyWith<$Res> {
  _$DaySeparatorCopyWithImpl(this._self, this._then);

  final DaySeparator _self;
  final $Res Function(DaySeparator) _then;

/// Create a copy of ListRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? day = null,}) {
  return _then(DaySeparator(
null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc


class NewMessagesLine extends ListRow {
  const NewMessagesLine({required this.count}): super._();
  

 final  int count;

/// Create a copy of ListRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NewMessagesLineCopyWith<NewMessagesLine> get copyWith => _$NewMessagesLineCopyWithImpl<NewMessagesLine>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is NewMessagesLine&&(identical(other.count, count) || other.count == count));
}


@override
int get hashCode {
    return Object.hash(runtimeType,count);
}

@override
String toString() {
    return 'ListRow.newMessages(count: $count)';
}


}

/// @nodoc
abstract mixin class $NewMessagesLineCopyWith<$Res> implements $ListRowCopyWith<$Res> {
  factory $NewMessagesLineCopyWith(NewMessagesLine value, $Res Function(NewMessagesLine) _then) = _$NewMessagesLineCopyWithImpl;
@useResult
$Res call({
 int count
});




}
/// @nodoc
class _$NewMessagesLineCopyWithImpl<$Res>
    implements $NewMessagesLineCopyWith<$Res> {
  _$NewMessagesLineCopyWithImpl(this._self, this._then);

  final NewMessagesLine _self;
  final $Res Function(NewMessagesLine) _then;

/// Create a copy of ListRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? count = null,}) {
  return _then(NewMessagesLine(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
