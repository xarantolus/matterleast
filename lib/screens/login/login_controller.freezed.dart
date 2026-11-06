// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LoginState {

 bool get busy; bool get mfaNeeded;/// Waiting for the sign-in to finish in the browser.
 bool get inBrowser; String? get error; String? get mfaError;/// With magic links on: what the server said about the login id. Null
/// until asked, empty when a password is the way in.
 String? get loginType;/// The server emailed a sign-in link.
 bool get linkSent;
/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginStateCopyWith<LoginState> get copyWith => _$LoginStateCopyWithImpl<LoginState>(this as LoginState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LoginState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginState&&(identical(other.busy, _this.busy) || other.busy == _this.busy)&&(identical(other.mfaNeeded, _this.mfaNeeded) || other.mfaNeeded == _this.mfaNeeded)&&(identical(other.inBrowser, _this.inBrowser) || other.inBrowser == _this.inBrowser)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.mfaError, _this.mfaError) || other.mfaError == _this.mfaError)&&(identical(other.loginType, _this.loginType) || other.loginType == _this.loginType)&&(identical(other.linkSent, _this.linkSent) || other.linkSent == _this.linkSent));
}


@override
int get hashCode {
  final _this = this as LoginState;
  return Object.hash(runtimeType,_this.busy,_this.mfaNeeded,_this.inBrowser,_this.error,_this.mfaError,_this.loginType,_this.linkSent);
}

@override
String toString() {
  final _this = this as LoginState;
  return 'LoginState(busy: ${_this.busy}, mfaNeeded: ${_this.mfaNeeded}, inBrowser: ${_this.inBrowser}, error: ${_this.error}, mfaError: ${_this.mfaError}, loginType: ${_this.loginType}, linkSent: ${_this.linkSent})';
}


}

/// @nodoc
abstract mixin class $LoginStateCopyWith<$Res>  {
  factory $LoginStateCopyWith(LoginState value, $Res Function(LoginState) _then) = _$LoginStateCopyWithImpl;
@useResult
$Res call({
 bool busy, bool mfaNeeded, bool inBrowser, String? error, String? mfaError, String? loginType, bool linkSent
});




}
/// @nodoc
class _$LoginStateCopyWithImpl<$Res>
    implements $LoginStateCopyWith<$Res> {
  _$LoginStateCopyWithImpl(this._self, this._then);

  final LoginState _self;
  final $Res Function(LoginState) _then;

/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? busy = null,Object? mfaNeeded = null,Object? inBrowser = null,Object? error = freezed,Object? mfaError = freezed,Object? loginType = freezed,Object? linkSent = null,}) {
  return _then(LoginState(
busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,mfaNeeded: null == mfaNeeded ? _self.mfaNeeded : mfaNeeded // ignore: cast_nullable_to_non_nullable
as bool,inBrowser: null == inBrowser ? _self.inBrowser : inBrowser // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,mfaError: freezed == mfaError ? _self.mfaError : mfaError // ignore: cast_nullable_to_non_nullable
as String?,loginType: freezed == loginType ? _self.loginType : loginType // ignore: cast_nullable_to_non_nullable
as String?,linkSent: null == linkSent ? _self.linkSent : linkSent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LoginState].
extension LoginStatePatterns on LoginState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoginState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoginState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoginState value)  $default,){
final _that = this;
switch (_that) {
case _LoginState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoginState value)?  $default,){
final _that = this;
switch (_that) {
case _LoginState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool busy,  bool mfaNeeded,  bool inBrowser,  String? error,  String? mfaError,  String? loginType,  bool linkSent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoginState() when $default != null:
return $default(_that.busy,_that.mfaNeeded,_that.inBrowser,_that.error,_that.mfaError,_that.loginType,_that.linkSent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool busy,  bool mfaNeeded,  bool inBrowser,  String? error,  String? mfaError,  String? loginType,  bool linkSent)  $default,) {final _that = this;
switch (_that) {
case _LoginState():
return $default(_that.busy,_that.mfaNeeded,_that.inBrowser,_that.error,_that.mfaError,_that.loginType,_that.linkSent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool busy,  bool mfaNeeded,  bool inBrowser,  String? error,  String? mfaError,  String? loginType,  bool linkSent)?  $default,) {final _that = this;
switch (_that) {
case _LoginState() when $default != null:
return $default(_that.busy,_that.mfaNeeded,_that.inBrowser,_that.error,_that.mfaError,_that.loginType,_that.linkSent);case _:
  return null;

}
}

}

/// @nodoc


class _LoginState implements LoginState {
  const _LoginState({this.busy = false, this.mfaNeeded = false, this.inBrowser = false, this.error, this.mfaError, this.loginType, this.linkSent = false});
  

@override@JsonKey() final  bool busy;
@override@JsonKey() final  bool mfaNeeded;
/// Waiting for the sign-in to finish in the browser.
@override@JsonKey() final  bool inBrowser;
@override final  String? error;
@override final  String? mfaError;
/// With magic links on: what the server said about the login id. Null
/// until asked, empty when a password is the way in.
@override final  String? loginType;
/// The server emailed a sign-in link.
@override@JsonKey() final  bool linkSent;

/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoginStateCopyWith<_LoginState> get copyWith => __$LoginStateCopyWithImpl<_LoginState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoginState&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.mfaNeeded, mfaNeeded) || other.mfaNeeded == mfaNeeded)&&(identical(other.inBrowser, inBrowser) || other.inBrowser == inBrowser)&&(identical(other.error, error) || other.error == error)&&(identical(other.mfaError, mfaError) || other.mfaError == mfaError)&&(identical(other.loginType, loginType) || other.loginType == loginType)&&(identical(other.linkSent, linkSent) || other.linkSent == linkSent));
}


@override
int get hashCode {
    return Object.hash(runtimeType,busy,mfaNeeded,inBrowser,error,mfaError,loginType,linkSent);
}

@override
String toString() {
    return 'LoginState(busy: $busy, mfaNeeded: $mfaNeeded, inBrowser: $inBrowser, error: $error, mfaError: $mfaError, loginType: $loginType, linkSent: $linkSent)';
}


}

/// @nodoc
abstract mixin class _$LoginStateCopyWith<$Res> implements $LoginStateCopyWith<$Res> {
  factory _$LoginStateCopyWith(_LoginState value, $Res Function(_LoginState) _then) = __$LoginStateCopyWithImpl;
@override @useResult
$Res call({
 bool busy, bool mfaNeeded, bool inBrowser, String? error, String? mfaError, String? loginType, bool linkSent
});




}
/// @nodoc
class __$LoginStateCopyWithImpl<$Res>
    implements _$LoginStateCopyWith<$Res> {
  __$LoginStateCopyWithImpl(this._self, this._then);

  final _LoginState _self;
  final $Res Function(_LoginState) _then;

/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? busy = null,Object? mfaNeeded = null,Object? inBrowser = null,Object? error = freezed,Object? mfaError = freezed,Object? loginType = freezed,Object? linkSent = null,}) {
  return _then(_LoginState(
busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,mfaNeeded: null == mfaNeeded ? _self.mfaNeeded : mfaNeeded // ignore: cast_nullable_to_non_nullable
as bool,inBrowser: null == inBrowser ? _self.inBrowser : inBrowser // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,mfaError: freezed == mfaError ? _self.mfaError : mfaError // ignore: cast_nullable_to_non_nullable
as String?,loginType: freezed == loginType ? _self.loginType : loginType // ignore: cast_nullable_to_non_nullable
as String?,linkSent: null == linkSent ? _self.linkSent : linkSent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
