// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'add_server_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AddServerState {

 bool get checking; String? get urlError; String? get nameError;
/// Create a copy of AddServerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddServerStateCopyWith<AddServerState> get copyWith => _$AddServerStateCopyWithImpl<AddServerState>(this as AddServerState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AddServerState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddServerState&&(identical(other.checking, _this.checking) || other.checking == _this.checking)&&(identical(other.urlError, _this.urlError) || other.urlError == _this.urlError)&&(identical(other.nameError, _this.nameError) || other.nameError == _this.nameError));
}


@override
int get hashCode {
  final _this = this as AddServerState;
  return Object.hash(runtimeType,_this.checking,_this.urlError,_this.nameError);
}

@override
String toString() {
  final _this = this as AddServerState;
  return 'AddServerState(checking: ${_this.checking}, urlError: ${_this.urlError}, nameError: ${_this.nameError})';
}


}

/// @nodoc
abstract mixin class $AddServerStateCopyWith<$Res>  {
  factory $AddServerStateCopyWith(AddServerState value, $Res Function(AddServerState) _then) = _$AddServerStateCopyWithImpl;
@useResult
$Res call({
 bool checking, String? urlError, String? nameError
});




}
/// @nodoc
class _$AddServerStateCopyWithImpl<$Res>
    implements $AddServerStateCopyWith<$Res> {
  _$AddServerStateCopyWithImpl(this._self, this._then);

  final AddServerState _self;
  final $Res Function(AddServerState) _then;

/// Create a copy of AddServerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? checking = null,Object? urlError = freezed,Object? nameError = freezed,}) {
  return _then(AddServerState(
checking: null == checking ? _self.checking : checking // ignore: cast_nullable_to_non_nullable
as bool,urlError: freezed == urlError ? _self.urlError : urlError // ignore: cast_nullable_to_non_nullable
as String?,nameError: freezed == nameError ? _self.nameError : nameError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AddServerState].
extension AddServerStatePatterns on AddServerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AddServerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AddServerState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AddServerState value)  $default,){
final _that = this;
switch (_that) {
case _AddServerState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AddServerState value)?  $default,){
final _that = this;
switch (_that) {
case _AddServerState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool checking,  String? urlError,  String? nameError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AddServerState() when $default != null:
return $default(_that.checking,_that.urlError,_that.nameError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool checking,  String? urlError,  String? nameError)  $default,) {final _that = this;
switch (_that) {
case _AddServerState():
return $default(_that.checking,_that.urlError,_that.nameError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool checking,  String? urlError,  String? nameError)?  $default,) {final _that = this;
switch (_that) {
case _AddServerState() when $default != null:
return $default(_that.checking,_that.urlError,_that.nameError);case _:
  return null;

}
}

}

/// @nodoc


class _AddServerState implements AddServerState {
  const _AddServerState({this.checking = false, this.urlError, this.nameError});
  

@override@JsonKey() final  bool checking;
@override final  String? urlError;
@override final  String? nameError;

/// Create a copy of AddServerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddServerStateCopyWith<_AddServerState> get copyWith => __$AddServerStateCopyWithImpl<_AddServerState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddServerState&&(identical(other.checking, checking) || other.checking == checking)&&(identical(other.urlError, urlError) || other.urlError == urlError)&&(identical(other.nameError, nameError) || other.nameError == nameError));
}


@override
int get hashCode {
    return Object.hash(runtimeType,checking,urlError,nameError);
}

@override
String toString() {
    return 'AddServerState(checking: $checking, urlError: $urlError, nameError: $nameError)';
}


}

/// @nodoc
abstract mixin class _$AddServerStateCopyWith<$Res> implements $AddServerStateCopyWith<$Res> {
  factory _$AddServerStateCopyWith(_AddServerState value, $Res Function(_AddServerState) _then) = __$AddServerStateCopyWithImpl;
@override @useResult
$Res call({
 bool checking, String? urlError, String? nameError
});




}
/// @nodoc
class __$AddServerStateCopyWithImpl<$Res>
    implements _$AddServerStateCopyWith<$Res> {
  __$AddServerStateCopyWithImpl(this._self, this._then);

  final _AddServerState _self;
  final $Res Function(_AddServerState) _then;

/// Create a copy of AddServerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? checking = null,Object? urlError = freezed,Object? nameError = freezed,}) {
  return _then(_AddServerState(
checking: null == checking ? _self.checking : checking // ignore: cast_nullable_to_non_nullable
as bool,urlError: freezed == urlError ? _self.urlError : urlError // ignore: cast_nullable_to_non_nullable
as String?,nameError: freezed == nameError ? _self.nameError : nameError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
