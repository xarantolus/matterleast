// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'desktop_window.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WindowPlacement {

 double? get x; double? get y; double get width; double get height; bool get maximized;
/// Create a copy of WindowPlacement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WindowPlacementCopyWith<WindowPlacement> get copyWith => _$WindowPlacementCopyWithImpl<WindowPlacement>(this as WindowPlacement, _$identity);

  /// Serializes this WindowPlacement to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as WindowPlacement;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WindowPlacement&&(identical(other.x, _this.x) || other.x == _this.x)&&(identical(other.y, _this.y) || other.y == _this.y)&&(identical(other.width, _this.width) || other.width == _this.width)&&(identical(other.height, _this.height) || other.height == _this.height)&&(identical(other.maximized, _this.maximized) || other.maximized == _this.maximized));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WindowPlacement;
  return Object.hash(runtimeType,_this.x,_this.y,_this.width,_this.height,_this.maximized);
}

@override
String toString() {
  final _this = this as WindowPlacement;
  return 'WindowPlacement(x: ${_this.x}, y: ${_this.y}, width: ${_this.width}, height: ${_this.height}, maximized: ${_this.maximized})';
}


}

/// @nodoc
abstract mixin class $WindowPlacementCopyWith<$Res>  {
  factory $WindowPlacementCopyWith(WindowPlacement value, $Res Function(WindowPlacement) _then) = _$WindowPlacementCopyWithImpl;
@useResult
$Res call({
 double? x, double? y, double width, double height, bool maximized
});




}
/// @nodoc
class _$WindowPlacementCopyWithImpl<$Res>
    implements $WindowPlacementCopyWith<$Res> {
  _$WindowPlacementCopyWithImpl(this._self, this._then);

  final WindowPlacement _self;
  final $Res Function(WindowPlacement) _then;

/// Create a copy of WindowPlacement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? x = freezed,Object? y = freezed,Object? width = null,Object? height = null,Object? maximized = null,}) {
  return _then(WindowPlacement(
x: freezed == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double?,y: freezed == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double?,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,maximized: null == maximized ? _self.maximized : maximized // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [WindowPlacement].
extension WindowPlacementPatterns on WindowPlacement {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WindowPlacement value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WindowPlacement() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WindowPlacement value)  $default,){
final _that = this;
switch (_that) {
case _WindowPlacement():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WindowPlacement value)?  $default,){
final _that = this;
switch (_that) {
case _WindowPlacement() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double? x,  double? y,  double width,  double height,  bool maximized)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WindowPlacement() when $default != null:
return $default(_that.x,_that.y,_that.width,_that.height,_that.maximized);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double? x,  double? y,  double width,  double height,  bool maximized)  $default,) {final _that = this;
switch (_that) {
case _WindowPlacement():
return $default(_that.x,_that.y,_that.width,_that.height,_that.maximized);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double? x,  double? y,  double width,  double height,  bool maximized)?  $default,) {final _that = this;
switch (_that) {
case _WindowPlacement() when $default != null:
return $default(_that.x,_that.y,_that.width,_that.height,_that.maximized);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WindowPlacement implements WindowPlacement {
  const _WindowPlacement({this.x, this.y, required this.width, required this.height, this.maximized = false});
  factory _WindowPlacement.fromJson(Map<String, dynamic> json) => _$WindowPlacementFromJson(json);

@override final  double? x;
@override final  double? y;
@override final  double width;
@override final  double height;
@override@JsonKey() final  bool maximized;

/// Create a copy of WindowPlacement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WindowPlacementCopyWith<_WindowPlacement> get copyWith => __$WindowPlacementCopyWithImpl<_WindowPlacement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WindowPlacementToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WindowPlacement&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.maximized, maximized) || other.maximized == maximized));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,x,y,width,height,maximized);
}

@override
String toString() {
    return 'WindowPlacement(x: $x, y: $y, width: $width, height: $height, maximized: $maximized)';
}


}

/// @nodoc
abstract mixin class _$WindowPlacementCopyWith<$Res> implements $WindowPlacementCopyWith<$Res> {
  factory _$WindowPlacementCopyWith(_WindowPlacement value, $Res Function(_WindowPlacement) _then) = __$WindowPlacementCopyWithImpl;
@override @useResult
$Res call({
 double? x, double? y, double width, double height, bool maximized
});




}
/// @nodoc
class __$WindowPlacementCopyWithImpl<$Res>
    implements _$WindowPlacementCopyWith<$Res> {
  __$WindowPlacementCopyWithImpl(this._self, this._then);

  final _WindowPlacement _self;
  final $Res Function(_WindowPlacement) _then;

/// Create a copy of WindowPlacement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? x = freezed,Object? y = freezed,Object? width = null,Object? height = null,Object? maximized = null,}) {
  return _then(_WindowPlacement(
x: freezed == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double?,y: freezed == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double?,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,maximized: null == maximized ? _self.maximized : maximized // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
