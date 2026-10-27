// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_update.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$KnownRelease {

 String get tag; String get url;
/// Create a copy of KnownRelease
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KnownReleaseCopyWith<KnownRelease> get copyWith => _$KnownReleaseCopyWithImpl<KnownRelease>(this as KnownRelease, _$identity);

  /// Serializes this KnownRelease to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as KnownRelease;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KnownRelease&&(identical(other.tag, _this.tag) || other.tag == _this.tag)&&(identical(other.url, _this.url) || other.url == _this.url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as KnownRelease;
  return Object.hash(runtimeType,_this.tag,_this.url);
}

@override
String toString() {
  final _this = this as KnownRelease;
  return 'KnownRelease(tag: ${_this.tag}, url: ${_this.url})';
}


}

/// @nodoc
abstract mixin class $KnownReleaseCopyWith<$Res>  {
  factory $KnownReleaseCopyWith(KnownRelease value, $Res Function(KnownRelease) _then) = _$KnownReleaseCopyWithImpl;
@useResult
$Res call({
 String tag, String url
});




}
/// @nodoc
class _$KnownReleaseCopyWithImpl<$Res>
    implements $KnownReleaseCopyWith<$Res> {
  _$KnownReleaseCopyWithImpl(this._self, this._then);

  final KnownRelease _self;
  final $Res Function(KnownRelease) _then;

/// Create a copy of KnownRelease
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tag = null,Object? url = null,}) {
  return _then(KnownRelease(
tag: null == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [KnownRelease].
extension KnownReleasePatterns on KnownRelease {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KnownRelease value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KnownRelease() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KnownRelease value)  $default,){
final _that = this;
switch (_that) {
case _KnownRelease():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KnownRelease value)?  $default,){
final _that = this;
switch (_that) {
case _KnownRelease() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String tag,  String url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KnownRelease() when $default != null:
return $default(_that.tag,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String tag,  String url)  $default,) {final _that = this;
switch (_that) {
case _KnownRelease():
return $default(_that.tag,_that.url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String tag,  String url)?  $default,) {final _that = this;
switch (_that) {
case _KnownRelease() when $default != null:
return $default(_that.tag,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KnownRelease implements KnownRelease {
  const _KnownRelease({required this.tag, required this.url});
  factory _KnownRelease.fromJson(Map<String, dynamic> json) => _$KnownReleaseFromJson(json);

@override final  String tag;
@override final  String url;

/// Create a copy of KnownRelease
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KnownReleaseCopyWith<_KnownRelease> get copyWith => __$KnownReleaseCopyWithImpl<_KnownRelease>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KnownReleaseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _KnownRelease&&(identical(other.tag, tag) || other.tag == tag)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,tag,url);
}

@override
String toString() {
    return 'KnownRelease(tag: $tag, url: $url)';
}


}

/// @nodoc
abstract mixin class _$KnownReleaseCopyWith<$Res> implements $KnownReleaseCopyWith<$Res> {
  factory _$KnownReleaseCopyWith(_KnownRelease value, $Res Function(_KnownRelease) _then) = __$KnownReleaseCopyWithImpl;
@override @useResult
$Res call({
 String tag, String url
});




}
/// @nodoc
class __$KnownReleaseCopyWithImpl<$Res>
    implements _$KnownReleaseCopyWith<$Res> {
  __$KnownReleaseCopyWithImpl(this._self, this._then);

  final _KnownRelease _self;
  final $Res Function(_KnownRelease) _then;

/// Create a copy of KnownRelease
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tag = null,Object? url = null,}) {
  return _then(_KnownRelease(
tag: null == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
