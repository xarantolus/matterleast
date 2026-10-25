// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sso_callback.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SsoResult {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SsoResult);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'SsoResult()';
}


}

/// @nodoc
class $SsoResultCopyWith<$Res>  {
$SsoResultCopyWith(SsoResult _, $Res Function(SsoResult) __);
}


/// Adds pattern-matching-related methods to [SsoResult].
extension SsoResultPatterns on SsoResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SsoToken value)?  token,TResult Function( SsoRejected value)?  rejected,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SsoToken() when token != null:
return token(_that);case SsoRejected() when rejected != null:
return rejected(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SsoToken value)  token,required TResult Function( SsoRejected value)  rejected,}){
final _that = this;
switch (_that) {
case SsoToken():
return token(_that);case SsoRejected():
return rejected(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SsoToken value)?  token,TResult? Function( SsoRejected value)?  rejected,}){
final _that = this;
switch (_that) {
case SsoToken() when token != null:
return token(_that);case SsoRejected() when rejected != null:
return rejected(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String token)?  token,TResult Function( String reason)?  rejected,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SsoToken() when token != null:
return token(_that.token);case SsoRejected() when rejected != null:
return rejected(_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String token)  token,required TResult Function( String reason)  rejected,}) {final _that = this;
switch (_that) {
case SsoToken():
return token(_that.token);case SsoRejected():
return rejected(_that.reason);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String token)?  token,TResult? Function( String reason)?  rejected,}) {final _that = this;
switch (_that) {
case SsoToken() when token != null:
return token(_that.token);case SsoRejected() when rejected != null:
return rejected(_that.reason);case _:
  return null;

}
}

}

/// @nodoc


class SsoToken implements SsoResult {
  const SsoToken(this.token);
  

 final  String token;

/// Create a copy of SsoResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SsoTokenCopyWith<SsoToken> get copyWith => _$SsoTokenCopyWithImpl<SsoToken>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SsoToken&&(identical(other.token, token) || other.token == token));
}


@override
int get hashCode {
    return Object.hash(runtimeType,token);
}

@override
String toString() {
    return 'SsoResult.token(token: $token)';
}


}

/// @nodoc
abstract mixin class $SsoTokenCopyWith<$Res> implements $SsoResultCopyWith<$Res> {
  factory $SsoTokenCopyWith(SsoToken value, $Res Function(SsoToken) _then) = _$SsoTokenCopyWithImpl;
@useResult
$Res call({
 String token
});




}
/// @nodoc
class _$SsoTokenCopyWithImpl<$Res>
    implements $SsoTokenCopyWith<$Res> {
  _$SsoTokenCopyWithImpl(this._self, this._then);

  final SsoToken _self;
  final $Res Function(SsoToken) _then;

/// Create a copy of SsoResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? token = null,}) {
  return _then(SsoToken(
null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SsoRejected implements SsoResult {
  const SsoRejected(this.reason);
  

 final  String reason;

/// Create a copy of SsoResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SsoRejectedCopyWith<SsoRejected> get copyWith => _$SsoRejectedCopyWithImpl<SsoRejected>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SsoRejected&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode {
    return Object.hash(runtimeType,reason);
}

@override
String toString() {
    return 'SsoResult.rejected(reason: $reason)';
}


}

/// @nodoc
abstract mixin class $SsoRejectedCopyWith<$Res> implements $SsoResultCopyWith<$Res> {
  factory $SsoRejectedCopyWith(SsoRejected value, $Res Function(SsoRejected) _then) = _$SsoRejectedCopyWithImpl;
@useResult
$Res call({
 String reason
});




}
/// @nodoc
class _$SsoRejectedCopyWithImpl<$Res>
    implements $SsoRejectedCopyWith<$Res> {
  _$SsoRejectedCopyWithImpl(this._self, this._then);

  final SsoRejected _self;
  final $Res Function(SsoRejected) _then;

/// Create a copy of SsoResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reason = null,}) {
  return _then(SsoRejected(
null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
