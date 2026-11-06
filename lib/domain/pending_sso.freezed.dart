// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pending_sso.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PendingSso {

 String get serverUrl; String get displayName; String get state; String get verifier; DateTime get startedAt; String? get ssoScheme; String? get replaces;
/// Create a copy of PendingSso
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PendingSsoCopyWith<PendingSso> get copyWith => _$PendingSsoCopyWithImpl<PendingSso>(this as PendingSso, _$identity);

  /// Serializes this PendingSso to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PendingSso;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PendingSso&&(identical(other.serverUrl, _this.serverUrl) || other.serverUrl == _this.serverUrl)&&(identical(other.displayName, _this.displayName) || other.displayName == _this.displayName)&&(identical(other.state, _this.state) || other.state == _this.state)&&(identical(other.verifier, _this.verifier) || other.verifier == _this.verifier)&&(identical(other.startedAt, _this.startedAt) || other.startedAt == _this.startedAt)&&(identical(other.ssoScheme, _this.ssoScheme) || other.ssoScheme == _this.ssoScheme)&&(identical(other.replaces, _this.replaces) || other.replaces == _this.replaces));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PendingSso;
  return Object.hash(runtimeType,_this.serverUrl,_this.displayName,_this.state,_this.verifier,_this.startedAt,_this.ssoScheme,_this.replaces);
}

@override
String toString() {
  final _this = this as PendingSso;
  return 'PendingSso(serverUrl: ${_this.serverUrl}, displayName: ${_this.displayName}, state: ${_this.state}, verifier: ${_this.verifier}, startedAt: ${_this.startedAt}, ssoScheme: ${_this.ssoScheme}, replaces: ${_this.replaces})';
}


}

/// @nodoc
abstract mixin class $PendingSsoCopyWith<$Res>  {
  factory $PendingSsoCopyWith(PendingSso value, $Res Function(PendingSso) _then) = _$PendingSsoCopyWithImpl;
@useResult
$Res call({
 String serverUrl, String displayName, String state, String verifier, DateTime startedAt, String? ssoScheme, String? replaces
});




}
/// @nodoc
class _$PendingSsoCopyWithImpl<$Res>
    implements $PendingSsoCopyWith<$Res> {
  _$PendingSsoCopyWithImpl(this._self, this._then);

  final PendingSso _self;
  final $Res Function(PendingSso) _then;

/// Create a copy of PendingSso
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? serverUrl = null,Object? displayName = null,Object? state = null,Object? verifier = null,Object? startedAt = null,Object? ssoScheme = freezed,Object? replaces = freezed,}) {
  return _then(PendingSso(
serverUrl: null == serverUrl ? _self.serverUrl : serverUrl // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,verifier: null == verifier ? _self.verifier : verifier // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,ssoScheme: freezed == ssoScheme ? _self.ssoScheme : ssoScheme // ignore: cast_nullable_to_non_nullable
as String?,replaces: freezed == replaces ? _self.replaces : replaces // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PendingSso].
extension PendingSsoPatterns on PendingSso {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PendingSso value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PendingSso() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PendingSso value)  $default,){
final _that = this;
switch (_that) {
case _PendingSso():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PendingSso value)?  $default,){
final _that = this;
switch (_that) {
case _PendingSso() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String serverUrl,  String displayName,  String state,  String verifier,  DateTime startedAt,  String? ssoScheme,  String? replaces)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PendingSso() when $default != null:
return $default(_that.serverUrl,_that.displayName,_that.state,_that.verifier,_that.startedAt,_that.ssoScheme,_that.replaces);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String serverUrl,  String displayName,  String state,  String verifier,  DateTime startedAt,  String? ssoScheme,  String? replaces)  $default,) {final _that = this;
switch (_that) {
case _PendingSso():
return $default(_that.serverUrl,_that.displayName,_that.state,_that.verifier,_that.startedAt,_that.ssoScheme,_that.replaces);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String serverUrl,  String displayName,  String state,  String verifier,  DateTime startedAt,  String? ssoScheme,  String? replaces)?  $default,) {final _that = this;
switch (_that) {
case _PendingSso() when $default != null:
return $default(_that.serverUrl,_that.displayName,_that.state,_that.verifier,_that.startedAt,_that.ssoScheme,_that.replaces);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PendingSso extends PendingSso {
  const _PendingSso({required this.serverUrl, required this.displayName, required this.state, required this.verifier, required this.startedAt, this.ssoScheme, this.replaces}): super._();
  factory _PendingSso.fromJson(Map<String, dynamic> json) => _$PendingSsoFromJson(json);

@override final  String serverUrl;
@override final  String displayName;
@override final  String state;
@override final  String verifier;
@override final  DateTime startedAt;
@override final  String? ssoScheme;
@override final  String? replaces;

/// Create a copy of PendingSso
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PendingSsoCopyWith<_PendingSso> get copyWith => __$PendingSsoCopyWithImpl<_PendingSso>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PendingSsoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PendingSso&&(identical(other.serverUrl, serverUrl) || other.serverUrl == serverUrl)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.state, state) || other.state == state)&&(identical(other.verifier, verifier) || other.verifier == verifier)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.ssoScheme, ssoScheme) || other.ssoScheme == ssoScheme)&&(identical(other.replaces, replaces) || other.replaces == replaces));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,serverUrl,displayName,state,verifier,startedAt,ssoScheme,replaces);
}

@override
String toString() {
    return 'PendingSso(serverUrl: $serverUrl, displayName: $displayName, state: $state, verifier: $verifier, startedAt: $startedAt, ssoScheme: $ssoScheme, replaces: $replaces)';
}


}

/// @nodoc
abstract mixin class _$PendingSsoCopyWith<$Res> implements $PendingSsoCopyWith<$Res> {
  factory _$PendingSsoCopyWith(_PendingSso value, $Res Function(_PendingSso) _then) = __$PendingSsoCopyWithImpl;
@override @useResult
$Res call({
 String serverUrl, String displayName, String state, String verifier, DateTime startedAt, String? ssoScheme, String? replaces
});




}
/// @nodoc
class __$PendingSsoCopyWithImpl<$Res>
    implements _$PendingSsoCopyWith<$Res> {
  __$PendingSsoCopyWithImpl(this._self, this._then);

  final _PendingSso _self;
  final $Res Function(_PendingSso) _then;

/// Create a copy of PendingSso
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? serverUrl = null,Object? displayName = null,Object? state = null,Object? verifier = null,Object? startedAt = null,Object? ssoScheme = freezed,Object? replaces = freezed,}) {
  return _then(_PendingSso(
serverUrl: null == serverUrl ? _self.serverUrl : serverUrl // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,verifier: null == verifier ? _self.verifier : verifier // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,ssoScheme: freezed == ssoScheme ? _self.ssoScheme : ssoScheme // ignore: cast_nullable_to_non_nullable
as String?,replaces: freezed == replaces ? _self.replaces : replaces // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
