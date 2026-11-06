// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'magic_link.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MagicLink {

 Uri get server; String get token;
/// Create a copy of MagicLink
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MagicLinkCopyWith<MagicLink> get copyWith => _$MagicLinkCopyWithImpl<MagicLink>(this as MagicLink, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MagicLink;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MagicLink&&(identical(other.server, _this.server) || other.server == _this.server)&&(identical(other.token, _this.token) || other.token == _this.token));
}


@override
int get hashCode {
  final _this = this as MagicLink;
  return Object.hash(runtimeType,_this.server,_this.token);
}

@override
String toString() {
  final _this = this as MagicLink;
  return 'MagicLink(server: ${_this.server}, token: ${_this.token})';
}


}

/// @nodoc
abstract mixin class $MagicLinkCopyWith<$Res>  {
  factory $MagicLinkCopyWith(MagicLink value, $Res Function(MagicLink) _then) = _$MagicLinkCopyWithImpl;
@useResult
$Res call({
 Uri server, String token
});




}
/// @nodoc
class _$MagicLinkCopyWithImpl<$Res>
    implements $MagicLinkCopyWith<$Res> {
  _$MagicLinkCopyWithImpl(this._self, this._then);

  final MagicLink _self;
  final $Res Function(MagicLink) _then;

/// Create a copy of MagicLink
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? server = null,Object? token = null,}) {
  return _then(MagicLink(
server: null == server ? _self.server : server // ignore: cast_nullable_to_non_nullable
as Uri,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MagicLink].
extension MagicLinkPatterns on MagicLink {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MagicLink value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MagicLink() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MagicLink value)  $default,){
final _that = this;
switch (_that) {
case _MagicLink():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MagicLink value)?  $default,){
final _that = this;
switch (_that) {
case _MagicLink() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Uri server,  String token)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MagicLink() when $default != null:
return $default(_that.server,_that.token);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Uri server,  String token)  $default,) {final _that = this;
switch (_that) {
case _MagicLink():
return $default(_that.server,_that.token);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Uri server,  String token)?  $default,) {final _that = this;
switch (_that) {
case _MagicLink() when $default != null:
return $default(_that.server,_that.token);case _:
  return null;

}
}

}

/// @nodoc


class _MagicLink implements MagicLink {
  const _MagicLink({required this.server, required this.token});
  

@override final  Uri server;
@override final  String token;

/// Create a copy of MagicLink
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MagicLinkCopyWith<_MagicLink> get copyWith => __$MagicLinkCopyWithImpl<_MagicLink>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MagicLink&&(identical(other.server, server) || other.server == server)&&(identical(other.token, token) || other.token == token));
}


@override
int get hashCode {
    return Object.hash(runtimeType,server,token);
}

@override
String toString() {
    return 'MagicLink(server: $server, token: $token)';
}


}

/// @nodoc
abstract mixin class _$MagicLinkCopyWith<$Res> implements $MagicLinkCopyWith<$Res> {
  factory _$MagicLinkCopyWith(_MagicLink value, $Res Function(_MagicLink) _then) = __$MagicLinkCopyWithImpl;
@override @useResult
$Res call({
 Uri server, String token
});




}
/// @nodoc
class __$MagicLinkCopyWithImpl<$Res>
    implements _$MagicLinkCopyWith<$Res> {
  __$MagicLinkCopyWithImpl(this._self, this._then);

  final _MagicLink _self;
  final $Res Function(_MagicLink) _then;

/// Create a copy of MagicLink
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? server = null,Object? token = null,}) {
  return _then(_MagicLink(
server: null == server ? _self.server : server // ignore: cast_nullable_to_non_nullable
as Uri,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
