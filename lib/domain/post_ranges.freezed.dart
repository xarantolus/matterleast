// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_ranges.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PostRange {

 DateTime get earliest; DateTime get latest; bool get reachesStart;
/// Create a copy of PostRange
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostRangeCopyWith<PostRange> get copyWith => _$PostRangeCopyWithImpl<PostRange>(this as PostRange, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PostRange;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostRange&&(identical(other.earliest, _this.earliest) || other.earliest == _this.earliest)&&(identical(other.latest, _this.latest) || other.latest == _this.latest)&&(identical(other.reachesStart, _this.reachesStart) || other.reachesStart == _this.reachesStart));
}


@override
int get hashCode {
  final _this = this as PostRange;
  return Object.hash(runtimeType,_this.earliest,_this.latest,_this.reachesStart);
}

@override
String toString() {
  final _this = this as PostRange;
  return 'PostRange(earliest: ${_this.earliest}, latest: ${_this.latest}, reachesStart: ${_this.reachesStart})';
}


}

/// @nodoc
abstract mixin class $PostRangeCopyWith<$Res>  {
  factory $PostRangeCopyWith(PostRange value, $Res Function(PostRange) _then) = _$PostRangeCopyWithImpl;
@useResult
$Res call({
 DateTime earliest, DateTime latest, bool reachesStart
});




}
/// @nodoc
class _$PostRangeCopyWithImpl<$Res>
    implements $PostRangeCopyWith<$Res> {
  _$PostRangeCopyWithImpl(this._self, this._then);

  final PostRange _self;
  final $Res Function(PostRange) _then;

/// Create a copy of PostRange
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? earliest = null,Object? latest = null,Object? reachesStart = null,}) {
  return _then(PostRange(
earliest: null == earliest ? _self.earliest : earliest // ignore: cast_nullable_to_non_nullable
as DateTime,latest: null == latest ? _self.latest : latest // ignore: cast_nullable_to_non_nullable
as DateTime,reachesStart: null == reachesStart ? _self.reachesStart : reachesStart // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PostRange].
extension PostRangePatterns on PostRange {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostRange value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostRange() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostRange value)  $default,){
final _that = this;
switch (_that) {
case _PostRange():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostRange value)?  $default,){
final _that = this;
switch (_that) {
case _PostRange() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime earliest,  DateTime latest,  bool reachesStart)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostRange() when $default != null:
return $default(_that.earliest,_that.latest,_that.reachesStart);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime earliest,  DateTime latest,  bool reachesStart)  $default,) {final _that = this;
switch (_that) {
case _PostRange():
return $default(_that.earliest,_that.latest,_that.reachesStart);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime earliest,  DateTime latest,  bool reachesStart)?  $default,) {final _that = this;
switch (_that) {
case _PostRange() when $default != null:
return $default(_that.earliest,_that.latest,_that.reachesStart);case _:
  return null;

}
}

}

/// @nodoc


class _PostRange extends PostRange {
  const _PostRange({required this.earliest, required this.latest, this.reachesStart = false}): super._();
  

@override final  DateTime earliest;
@override final  DateTime latest;
@override@JsonKey() final  bool reachesStart;

/// Create a copy of PostRange
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostRangeCopyWith<_PostRange> get copyWith => __$PostRangeCopyWithImpl<_PostRange>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostRange&&(identical(other.earliest, earliest) || other.earliest == earliest)&&(identical(other.latest, latest) || other.latest == latest)&&(identical(other.reachesStart, reachesStart) || other.reachesStart == reachesStart));
}


@override
int get hashCode {
    return Object.hash(runtimeType,earliest,latest,reachesStart);
}

@override
String toString() {
    return 'PostRange(earliest: $earliest, latest: $latest, reachesStart: $reachesStart)';
}


}

/// @nodoc
abstract mixin class _$PostRangeCopyWith<$Res> implements $PostRangeCopyWith<$Res> {
  factory _$PostRangeCopyWith(_PostRange value, $Res Function(_PostRange) _then) = __$PostRangeCopyWithImpl;
@override @useResult
$Res call({
 DateTime earliest, DateTime latest, bool reachesStart
});




}
/// @nodoc
class __$PostRangeCopyWithImpl<$Res>
    implements _$PostRangeCopyWith<$Res> {
  __$PostRangeCopyWithImpl(this._self, this._then);

  final _PostRange _self;
  final $Res Function(_PostRange) _then;

/// Create a copy of PostRange
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? earliest = null,Object? latest = null,Object? reachesStart = null,}) {
  return _then(_PostRange(
earliest: null == earliest ? _self.earliest : earliest // ignore: cast_nullable_to_non_nullable
as DateTime,latest: null == latest ? _self.latest : latest // ignore: cast_nullable_to_non_nullable
as DateTime,reachesStart: null == reachesStart ? _self.reachesStart : reachesStart // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
