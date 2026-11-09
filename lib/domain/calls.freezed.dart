// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calls.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CallSession {

 String get userId; bool get muted; bool get speaking;/// When the hand went up; 0 while it is down.
 int get raisedHand;
/// Create a copy of CallSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CallSessionCopyWith<CallSession> get copyWith => _$CallSessionCopyWithImpl<CallSession>(this as CallSession, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CallSession;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CallSession&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.muted, _this.muted) || other.muted == _this.muted)&&(identical(other.speaking, _this.speaking) || other.speaking == _this.speaking)&&(identical(other.raisedHand, _this.raisedHand) || other.raisedHand == _this.raisedHand));
}


@override
int get hashCode {
  final _this = this as CallSession;
  return Object.hash(runtimeType,_this.userId,_this.muted,_this.speaking,_this.raisedHand);
}

@override
String toString() {
  final _this = this as CallSession;
  return 'CallSession(userId: ${_this.userId}, muted: ${_this.muted}, speaking: ${_this.speaking}, raisedHand: ${_this.raisedHand})';
}


}

/// @nodoc
abstract mixin class $CallSessionCopyWith<$Res>  {
  factory $CallSessionCopyWith(CallSession value, $Res Function(CallSession) _then) = _$CallSessionCopyWithImpl;
@useResult
$Res call({
 String userId, bool muted, bool speaking, int raisedHand
});




}
/// @nodoc
class _$CallSessionCopyWithImpl<$Res>
    implements $CallSessionCopyWith<$Res> {
  _$CallSessionCopyWithImpl(this._self, this._then);

  final CallSession _self;
  final $Res Function(CallSession) _then;

/// Create a copy of CallSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? muted = null,Object? speaking = null,Object? raisedHand = null,}) {
  return _then(CallSession(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,muted: null == muted ? _self.muted : muted // ignore: cast_nullable_to_non_nullable
as bool,speaking: null == speaking ? _self.speaking : speaking // ignore: cast_nullable_to_non_nullable
as bool,raisedHand: null == raisedHand ? _self.raisedHand : raisedHand // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CallSession].
extension CallSessionPatterns on CallSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CallSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CallSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CallSession value)  $default,){
final _that = this;
switch (_that) {
case _CallSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CallSession value)?  $default,){
final _that = this;
switch (_that) {
case _CallSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  bool muted,  bool speaking,  int raisedHand)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CallSession() when $default != null:
return $default(_that.userId,_that.muted,_that.speaking,_that.raisedHand);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  bool muted,  bool speaking,  int raisedHand)  $default,) {final _that = this;
switch (_that) {
case _CallSession():
return $default(_that.userId,_that.muted,_that.speaking,_that.raisedHand);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  bool muted,  bool speaking,  int raisedHand)?  $default,) {final _that = this;
switch (_that) {
case _CallSession() when $default != null:
return $default(_that.userId,_that.muted,_that.speaking,_that.raisedHand);case _:
  return null;

}
}

}

/// @nodoc


class _CallSession implements CallSession {
  const _CallSession({required this.userId, this.muted = true, this.speaking = false, this.raisedHand = 0});
  

@override final  String userId;
@override@JsonKey() final  bool muted;
@override@JsonKey() final  bool speaking;
/// When the hand went up; 0 while it is down.
@override@JsonKey() final  int raisedHand;

/// Create a copy of CallSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CallSessionCopyWith<_CallSession> get copyWith => __$CallSessionCopyWithImpl<_CallSession>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CallSession&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.muted, muted) || other.muted == muted)&&(identical(other.speaking, speaking) || other.speaking == speaking)&&(identical(other.raisedHand, raisedHand) || other.raisedHand == raisedHand));
}


@override
int get hashCode {
    return Object.hash(runtimeType,userId,muted,speaking,raisedHand);
}

@override
String toString() {
    return 'CallSession(userId: $userId, muted: $muted, speaking: $speaking, raisedHand: $raisedHand)';
}


}

/// @nodoc
abstract mixin class _$CallSessionCopyWith<$Res> implements $CallSessionCopyWith<$Res> {
  factory _$CallSessionCopyWith(_CallSession value, $Res Function(_CallSession) _then) = __$CallSessionCopyWithImpl;
@override @useResult
$Res call({
 String userId, bool muted, bool speaking, int raisedHand
});




}
/// @nodoc
class __$CallSessionCopyWithImpl<$Res>
    implements _$CallSessionCopyWith<$Res> {
  __$CallSessionCopyWithImpl(this._self, this._then);

  final _CallSession _self;
  final $Res Function(_CallSession) _then;

/// Create a copy of CallSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? muted = null,Object? speaking = null,Object? raisedHand = null,}) {
  return _then(_CallSession(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,muted: null == muted ? _self.muted : muted // ignore: cast_nullable_to_non_nullable
as bool,speaking: null == speaking ? _self.speaking : speaking // ignore: cast_nullable_to_non_nullable
as bool,raisedHand: null == raisedHand ? _self.raisedHand : raisedHand // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$ActiveCall {

 String get id; DateTime? get startAt; String? get threadId; String? get postId; String? get ownerId; String? get hostId; String? get screenSharingSessionId; Map<String, CallSession> get sessions;
/// Create a copy of ActiveCall
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActiveCallCopyWith<ActiveCall> get copyWith => _$ActiveCallCopyWithImpl<ActiveCall>(this as ActiveCall, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ActiveCall;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActiveCall&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.startAt, _this.startAt) || other.startAt == _this.startAt)&&(identical(other.threadId, _this.threadId) || other.threadId == _this.threadId)&&(identical(other.postId, _this.postId) || other.postId == _this.postId)&&(identical(other.ownerId, _this.ownerId) || other.ownerId == _this.ownerId)&&(identical(other.hostId, _this.hostId) || other.hostId == _this.hostId)&&(identical(other.screenSharingSessionId, _this.screenSharingSessionId) || other.screenSharingSessionId == _this.screenSharingSessionId)&&const DeepCollectionEquality().equals(other.sessions, _this.sessions));
}


@override
int get hashCode {
  final _this = this as ActiveCall;
  return Object.hash(runtimeType,_this.id,_this.startAt,_this.threadId,_this.postId,_this.ownerId,_this.hostId,_this.screenSharingSessionId,const DeepCollectionEquality().hash(_this.sessions));
}

@override
String toString() {
  final _this = this as ActiveCall;
  return 'ActiveCall(id: ${_this.id}, startAt: ${_this.startAt}, threadId: ${_this.threadId}, postId: ${_this.postId}, ownerId: ${_this.ownerId}, hostId: ${_this.hostId}, screenSharingSessionId: ${_this.screenSharingSessionId}, sessions: ${_this.sessions})';
}


}

/// @nodoc
abstract mixin class $ActiveCallCopyWith<$Res>  {
  factory $ActiveCallCopyWith(ActiveCall value, $Res Function(ActiveCall) _then) = _$ActiveCallCopyWithImpl;
@useResult
$Res call({
 String id, DateTime? startAt, String? threadId, String? postId, String? ownerId, String? hostId, String? screenSharingSessionId, Map<String, CallSession> sessions
});




}
/// @nodoc
class _$ActiveCallCopyWithImpl<$Res>
    implements $ActiveCallCopyWith<$Res> {
  _$ActiveCallCopyWithImpl(this._self, this._then);

  final ActiveCall _self;
  final $Res Function(ActiveCall) _then;

/// Create a copy of ActiveCall
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? startAt = freezed,Object? threadId = freezed,Object? postId = freezed,Object? ownerId = freezed,Object? hostId = freezed,Object? screenSharingSessionId = freezed,Object? sessions = null,}) {
  return _then(ActiveCall(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,startAt: freezed == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime?,threadId: freezed == threadId ? _self.threadId : threadId // ignore: cast_nullable_to_non_nullable
as String?,postId: freezed == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String?,ownerId: freezed == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String?,hostId: freezed == hostId ? _self.hostId : hostId // ignore: cast_nullable_to_non_nullable
as String?,screenSharingSessionId: freezed == screenSharingSessionId ? _self.screenSharingSessionId : screenSharingSessionId // ignore: cast_nullable_to_non_nullable
as String?,sessions: null == sessions ? _self.sessions : sessions // ignore: cast_nullable_to_non_nullable
as Map<String, CallSession>,
  ));
}

}


/// Adds pattern-matching-related methods to [ActiveCall].
extension ActiveCallPatterns on ActiveCall {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActiveCall value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActiveCall() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActiveCall value)  $default,){
final _that = this;
switch (_that) {
case _ActiveCall():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActiveCall value)?  $default,){
final _that = this;
switch (_that) {
case _ActiveCall() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime? startAt,  String? threadId,  String? postId,  String? ownerId,  String? hostId,  String? screenSharingSessionId,  Map<String, CallSession> sessions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActiveCall() when $default != null:
return $default(_that.id,_that.startAt,_that.threadId,_that.postId,_that.ownerId,_that.hostId,_that.screenSharingSessionId,_that.sessions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime? startAt,  String? threadId,  String? postId,  String? ownerId,  String? hostId,  String? screenSharingSessionId,  Map<String, CallSession> sessions)  $default,) {final _that = this;
switch (_that) {
case _ActiveCall():
return $default(_that.id,_that.startAt,_that.threadId,_that.postId,_that.ownerId,_that.hostId,_that.screenSharingSessionId,_that.sessions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime? startAt,  String? threadId,  String? postId,  String? ownerId,  String? hostId,  String? screenSharingSessionId,  Map<String, CallSession> sessions)?  $default,) {final _that = this;
switch (_that) {
case _ActiveCall() when $default != null:
return $default(_that.id,_that.startAt,_that.threadId,_that.postId,_that.ownerId,_that.hostId,_that.screenSharingSessionId,_that.sessions);case _:
  return null;

}
}

}

/// @nodoc


class _ActiveCall extends ActiveCall {
  const _ActiveCall({required this.id, this.startAt, this.threadId, this.postId, this.ownerId, this.hostId, this.screenSharingSessionId,  Map<String, CallSession> sessions = const <String, CallSession>{}}): _sessions = sessions,super._();
  

@override final  String id;
@override final  DateTime? startAt;
@override final  String? threadId;
@override final  String? postId;
@override final  String? ownerId;
@override final  String? hostId;
@override final  String? screenSharingSessionId;
 final  Map<String, CallSession> _sessions;
@override@JsonKey() Map<String, CallSession> get sessions {
  if (_sessions is EqualUnmodifiableMapView) return _sessions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_sessions);
}


/// Create a copy of ActiveCall
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActiveCallCopyWith<_ActiveCall> get copyWith => __$ActiveCallCopyWithImpl<_ActiveCall>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActiveCall&&(identical(other.id, id) || other.id == id)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.threadId, threadId) || other.threadId == threadId)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.hostId, hostId) || other.hostId == hostId)&&(identical(other.screenSharingSessionId, screenSharingSessionId) || other.screenSharingSessionId == screenSharingSessionId)&&const DeepCollectionEquality().equals(other.sessions, _sessions));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,startAt,threadId,postId,ownerId,hostId,screenSharingSessionId,const DeepCollectionEquality().hash(_sessions));
}

@override
String toString() {
    return 'ActiveCall(id: $id, startAt: $startAt, threadId: $threadId, postId: $postId, ownerId: $ownerId, hostId: $hostId, screenSharingSessionId: $screenSharingSessionId, sessions: $sessions)';
}


}

/// @nodoc
abstract mixin class _$ActiveCallCopyWith<$Res> implements $ActiveCallCopyWith<$Res> {
  factory _$ActiveCallCopyWith(_ActiveCall value, $Res Function(_ActiveCall) _then) = __$ActiveCallCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime? startAt, String? threadId, String? postId, String? ownerId, String? hostId, String? screenSharingSessionId, Map<String, CallSession> sessions
});




}
/// @nodoc
class __$ActiveCallCopyWithImpl<$Res>
    implements _$ActiveCallCopyWith<$Res> {
  __$ActiveCallCopyWithImpl(this._self, this._then);

  final _ActiveCall _self;
  final $Res Function(_ActiveCall) _then;

/// Create a copy of ActiveCall
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? startAt = freezed,Object? threadId = freezed,Object? postId = freezed,Object? ownerId = freezed,Object? hostId = freezed,Object? screenSharingSessionId = freezed,Object? sessions = null,}) {
  return _then(_ActiveCall(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,startAt: freezed == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime?,threadId: freezed == threadId ? _self.threadId : threadId // ignore: cast_nullable_to_non_nullable
as String?,postId: freezed == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String?,ownerId: freezed == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String?,hostId: freezed == hostId ? _self.hostId : hostId // ignore: cast_nullable_to_non_nullable
as String?,screenSharingSessionId: freezed == screenSharingSessionId ? _self.screenSharingSessionId : screenSharingSessionId // ignore: cast_nullable_to_non_nullable
as String?,sessions: null == sessions ? _self._sessions : sessions // ignore: cast_nullable_to_non_nullable
as Map<String, CallSession>,
  ));
}


}

/// @nodoc
mixin _$CallsState {

 Map<String, ActiveCall> get calls; Map<String, bool> get enabled;
/// Create a copy of CallsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CallsStateCopyWith<CallsState> get copyWith => _$CallsStateCopyWithImpl<CallsState>(this as CallsState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CallsState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CallsState&&const DeepCollectionEquality().equals(other.calls, _this.calls)&&const DeepCollectionEquality().equals(other.enabled, _this.enabled));
}


@override
int get hashCode {
  final _this = this as CallsState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.calls),const DeepCollectionEquality().hash(_this.enabled));
}

@override
String toString() {
  final _this = this as CallsState;
  return 'CallsState(calls: ${_this.calls}, enabled: ${_this.enabled})';
}


}

/// @nodoc
abstract mixin class $CallsStateCopyWith<$Res>  {
  factory $CallsStateCopyWith(CallsState value, $Res Function(CallsState) _then) = _$CallsStateCopyWithImpl;
@useResult
$Res call({
 Map<String, ActiveCall> calls, Map<String, bool> enabled
});




}
/// @nodoc
class _$CallsStateCopyWithImpl<$Res>
    implements $CallsStateCopyWith<$Res> {
  _$CallsStateCopyWithImpl(this._self, this._then);

  final CallsState _self;
  final $Res Function(CallsState) _then;

/// Create a copy of CallsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? calls = null,Object? enabled = null,}) {
  return _then(CallsState(
calls: null == calls ? _self.calls : calls // ignore: cast_nullable_to_non_nullable
as Map<String, ActiveCall>,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,
  ));
}

}


/// Adds pattern-matching-related methods to [CallsState].
extension CallsStatePatterns on CallsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CallsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CallsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CallsState value)  $default,){
final _that = this;
switch (_that) {
case _CallsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CallsState value)?  $default,){
final _that = this;
switch (_that) {
case _CallsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, ActiveCall> calls,  Map<String, bool> enabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CallsState() when $default != null:
return $default(_that.calls,_that.enabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, ActiveCall> calls,  Map<String, bool> enabled)  $default,) {final _that = this;
switch (_that) {
case _CallsState():
return $default(_that.calls,_that.enabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, ActiveCall> calls,  Map<String, bool> enabled)?  $default,) {final _that = this;
switch (_that) {
case _CallsState() when $default != null:
return $default(_that.calls,_that.enabled);case _:
  return null;

}
}

}

/// @nodoc


class _CallsState implements CallsState {
  const _CallsState({ Map<String, ActiveCall> calls = const <String, ActiveCall>{},  Map<String, bool> enabled = const <String, bool>{}}): _calls = calls,_enabled = enabled;
  

 final  Map<String, ActiveCall> _calls;
@override@JsonKey() Map<String, ActiveCall> get calls {
  if (_calls is EqualUnmodifiableMapView) return _calls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_calls);
}

 final  Map<String, bool> _enabled;
@override@JsonKey() Map<String, bool> get enabled {
  if (_enabled is EqualUnmodifiableMapView) return _enabled;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_enabled);
}


/// Create a copy of CallsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CallsStateCopyWith<_CallsState> get copyWith => __$CallsStateCopyWithImpl<_CallsState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CallsState&&const DeepCollectionEquality().equals(other.calls, _calls)&&const DeepCollectionEquality().equals(other.enabled, _enabled));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_calls),const DeepCollectionEquality().hash(_enabled));
}

@override
String toString() {
    return 'CallsState(calls: $calls, enabled: $enabled)';
}


}

/// @nodoc
abstract mixin class _$CallsStateCopyWith<$Res> implements $CallsStateCopyWith<$Res> {
  factory _$CallsStateCopyWith(_CallsState value, $Res Function(_CallsState) _then) = __$CallsStateCopyWithImpl;
@override @useResult
$Res call({
 Map<String, ActiveCall> calls, Map<String, bool> enabled
});




}
/// @nodoc
class __$CallsStateCopyWithImpl<$Res>
    implements _$CallsStateCopyWith<$Res> {
  __$CallsStateCopyWithImpl(this._self, this._then);

  final _CallsState _self;
  final $Res Function(_CallsState) _then;

/// Create a copy of CallsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? calls = null,Object? enabled = null,}) {
  return _then(_CallsState(
calls: null == calls ? _self._calls : calls // ignore: cast_nullable_to_non_nullable
as Map<String, ActiveCall>,enabled: null == enabled ? _self._enabled : enabled // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,
  ));
}


}

// dart format on
