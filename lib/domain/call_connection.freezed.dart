// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'call_connection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CallConnection {

 CallPhase get phase;/// The call this is about: its server and channel; empty while idle.
 String get url; String get channelId;/// The user's session in the call; empty until the server accepted.
 String get sessionId; bool get muted;/// The microphone is not available: the user hears but isn't heard.
 bool get listenOnly; AudioRoute? get route; List<AudioRoute> get routes; CallFailure? get failure; CallEnd? get endedBy;
/// Create a copy of CallConnection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CallConnectionCopyWith<CallConnection> get copyWith => _$CallConnectionCopyWithImpl<CallConnection>(this as CallConnection, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CallConnection;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CallConnection&&(identical(other.phase, _this.phase) || other.phase == _this.phase)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.channelId, _this.channelId) || other.channelId == _this.channelId)&&(identical(other.sessionId, _this.sessionId) || other.sessionId == _this.sessionId)&&(identical(other.muted, _this.muted) || other.muted == _this.muted)&&(identical(other.listenOnly, _this.listenOnly) || other.listenOnly == _this.listenOnly)&&(identical(other.route, _this.route) || other.route == _this.route)&&const DeepCollectionEquality().equals(other.routes, _this.routes)&&(identical(other.failure, _this.failure) || other.failure == _this.failure)&&(identical(other.endedBy, _this.endedBy) || other.endedBy == _this.endedBy));
}


@override
int get hashCode {
  final _this = this as CallConnection;
  return Object.hash(runtimeType,_this.phase,_this.url,_this.channelId,_this.sessionId,_this.muted,_this.listenOnly,_this.route,const DeepCollectionEquality().hash(_this.routes),_this.failure,_this.endedBy);
}

@override
String toString() {
  final _this = this as CallConnection;
  return 'CallConnection(phase: ${_this.phase}, url: ${_this.url}, channelId: ${_this.channelId}, sessionId: ${_this.sessionId}, muted: ${_this.muted}, listenOnly: ${_this.listenOnly}, route: ${_this.route}, routes: ${_this.routes}, failure: ${_this.failure}, endedBy: ${_this.endedBy})';
}


}

/// @nodoc
abstract mixin class $CallConnectionCopyWith<$Res>  {
  factory $CallConnectionCopyWith(CallConnection value, $Res Function(CallConnection) _then) = _$CallConnectionCopyWithImpl;
@useResult
$Res call({
 CallPhase phase, String url, String channelId, String sessionId, bool muted, bool listenOnly, AudioRoute? route, List<AudioRoute> routes, CallFailure? failure, CallEnd? endedBy
});




}
/// @nodoc
class _$CallConnectionCopyWithImpl<$Res>
    implements $CallConnectionCopyWith<$Res> {
  _$CallConnectionCopyWithImpl(this._self, this._then);

  final CallConnection _self;
  final $Res Function(CallConnection) _then;

/// Create a copy of CallConnection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phase = null,Object? url = null,Object? channelId = null,Object? sessionId = null,Object? muted = null,Object? listenOnly = null,Object? route = freezed,Object? routes = null,Object? failure = freezed,Object? endedBy = freezed,}) {
  return _then(CallConnection(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as CallPhase,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,muted: null == muted ? _self.muted : muted // ignore: cast_nullable_to_non_nullable
as bool,listenOnly: null == listenOnly ? _self.listenOnly : listenOnly // ignore: cast_nullable_to_non_nullable
as bool,route: freezed == route ? _self.route : route // ignore: cast_nullable_to_non_nullable
as AudioRoute?,routes: null == routes ? _self.routes : routes // ignore: cast_nullable_to_non_nullable
as List<AudioRoute>,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as CallFailure?,endedBy: freezed == endedBy ? _self.endedBy : endedBy // ignore: cast_nullable_to_non_nullable
as CallEnd?,
  ));
}

}


/// Adds pattern-matching-related methods to [CallConnection].
extension CallConnectionPatterns on CallConnection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CallConnection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CallConnection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CallConnection value)  $default,){
final _that = this;
switch (_that) {
case _CallConnection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CallConnection value)?  $default,){
final _that = this;
switch (_that) {
case _CallConnection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CallPhase phase,  String url,  String channelId,  String sessionId,  bool muted,  bool listenOnly,  AudioRoute? route,  List<AudioRoute> routes,  CallFailure? failure,  CallEnd? endedBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CallConnection() when $default != null:
return $default(_that.phase,_that.url,_that.channelId,_that.sessionId,_that.muted,_that.listenOnly,_that.route,_that.routes,_that.failure,_that.endedBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CallPhase phase,  String url,  String channelId,  String sessionId,  bool muted,  bool listenOnly,  AudioRoute? route,  List<AudioRoute> routes,  CallFailure? failure,  CallEnd? endedBy)  $default,) {final _that = this;
switch (_that) {
case _CallConnection():
return $default(_that.phase,_that.url,_that.channelId,_that.sessionId,_that.muted,_that.listenOnly,_that.route,_that.routes,_that.failure,_that.endedBy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CallPhase phase,  String url,  String channelId,  String sessionId,  bool muted,  bool listenOnly,  AudioRoute? route,  List<AudioRoute> routes,  CallFailure? failure,  CallEnd? endedBy)?  $default,) {final _that = this;
switch (_that) {
case _CallConnection() when $default != null:
return $default(_that.phase,_that.url,_that.channelId,_that.sessionId,_that.muted,_that.listenOnly,_that.route,_that.routes,_that.failure,_that.endedBy);case _:
  return null;

}
}

}

/// @nodoc


class _CallConnection extends CallConnection {
  const _CallConnection({this.phase = CallPhase.idle, this.url = '', this.channelId = '', this.sessionId = '', this.muted = true, this.listenOnly = false, this.route,  List<AudioRoute> routes = const <AudioRoute>[], this.failure, this.endedBy}): _routes = routes,super._();
  

@override@JsonKey() final  CallPhase phase;
/// The call this is about: its server and channel; empty while idle.
@override@JsonKey() final  String url;
@override@JsonKey() final  String channelId;
/// The user's session in the call; empty until the server accepted.
@override@JsonKey() final  String sessionId;
@override@JsonKey() final  bool muted;
/// The microphone is not available: the user hears but isn't heard.
@override@JsonKey() final  bool listenOnly;
@override final  AudioRoute? route;
 final  List<AudioRoute> _routes;
@override@JsonKey() List<AudioRoute> get routes {
  if (_routes is EqualUnmodifiableListView) return _routes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_routes);
}

@override final  CallFailure? failure;
@override final  CallEnd? endedBy;

/// Create a copy of CallConnection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CallConnectionCopyWith<_CallConnection> get copyWith => __$CallConnectionCopyWithImpl<_CallConnection>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CallConnection&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.url, url) || other.url == url)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.muted, muted) || other.muted == muted)&&(identical(other.listenOnly, listenOnly) || other.listenOnly == listenOnly)&&(identical(other.route, route) || other.route == route)&&const DeepCollectionEquality().equals(other.routes, _routes)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.endedBy, endedBy) || other.endedBy == endedBy));
}


@override
int get hashCode {
    return Object.hash(runtimeType,phase,url,channelId,sessionId,muted,listenOnly,route,const DeepCollectionEquality().hash(_routes),failure,endedBy);
}

@override
String toString() {
    return 'CallConnection(phase: $phase, url: $url, channelId: $channelId, sessionId: $sessionId, muted: $muted, listenOnly: $listenOnly, route: $route, routes: $routes, failure: $failure, endedBy: $endedBy)';
}


}

/// @nodoc
abstract mixin class _$CallConnectionCopyWith<$Res> implements $CallConnectionCopyWith<$Res> {
  factory _$CallConnectionCopyWith(_CallConnection value, $Res Function(_CallConnection) _then) = __$CallConnectionCopyWithImpl;
@override @useResult
$Res call({
 CallPhase phase, String url, String channelId, String sessionId, bool muted, bool listenOnly, AudioRoute? route, List<AudioRoute> routes, CallFailure? failure, CallEnd? endedBy
});




}
/// @nodoc
class __$CallConnectionCopyWithImpl<$Res>
    implements _$CallConnectionCopyWith<$Res> {
  __$CallConnectionCopyWithImpl(this._self, this._then);

  final _CallConnection _self;
  final $Res Function(_CallConnection) _then;

/// Create a copy of CallConnection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? phase = null,Object? url = null,Object? channelId = null,Object? sessionId = null,Object? muted = null,Object? listenOnly = null,Object? route = freezed,Object? routes = null,Object? failure = freezed,Object? endedBy = freezed,}) {
  return _then(_CallConnection(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as CallPhase,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,muted: null == muted ? _self.muted : muted // ignore: cast_nullable_to_non_nullable
as bool,listenOnly: null == listenOnly ? _self.listenOnly : listenOnly // ignore: cast_nullable_to_non_nullable
as bool,route: freezed == route ? _self.route : route // ignore: cast_nullable_to_non_nullable
as AudioRoute?,routes: null == routes ? _self._routes : routes // ignore: cast_nullable_to_non_nullable
as List<AudioRoute>,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as CallFailure?,endedBy: freezed == endedBy ? _self.endedBy : endedBy // ignore: cast_nullable_to_non_nullable
as CallEnd?,
  ));
}


}

// dart format on
