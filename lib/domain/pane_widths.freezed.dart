// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pane_widths.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PaneWidths {

 double? get list; double? get listBesideThread; double? get thread;
/// Create a copy of PaneWidths
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaneWidthsCopyWith<PaneWidths> get copyWith => _$PaneWidthsCopyWithImpl<PaneWidths>(this as PaneWidths, _$identity);

  /// Serializes this PaneWidths to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PaneWidths;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaneWidths&&(identical(other.list, _this.list) || other.list == _this.list)&&(identical(other.listBesideThread, _this.listBesideThread) || other.listBesideThread == _this.listBesideThread)&&(identical(other.thread, _this.thread) || other.thread == _this.thread));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PaneWidths;
  return Object.hash(runtimeType,_this.list,_this.listBesideThread,_this.thread);
}

@override
String toString() {
  final _this = this as PaneWidths;
  return 'PaneWidths(list: ${_this.list}, listBesideThread: ${_this.listBesideThread}, thread: ${_this.thread})';
}


}

/// @nodoc
abstract mixin class $PaneWidthsCopyWith<$Res>  {
  factory $PaneWidthsCopyWith(PaneWidths value, $Res Function(PaneWidths) _then) = _$PaneWidthsCopyWithImpl;
@useResult
$Res call({
 double? list, double? listBesideThread, double? thread
});




}
/// @nodoc
class _$PaneWidthsCopyWithImpl<$Res>
    implements $PaneWidthsCopyWith<$Res> {
  _$PaneWidthsCopyWithImpl(this._self, this._then);

  final PaneWidths _self;
  final $Res Function(PaneWidths) _then;

/// Create a copy of PaneWidths
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? list = freezed,Object? listBesideThread = freezed,Object? thread = freezed,}) {
  return _then(PaneWidths(
list: freezed == list ? _self.list : list // ignore: cast_nullable_to_non_nullable
as double?,listBesideThread: freezed == listBesideThread ? _self.listBesideThread : listBesideThread // ignore: cast_nullable_to_non_nullable
as double?,thread: freezed == thread ? _self.thread : thread // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [PaneWidths].
extension PaneWidthsPatterns on PaneWidths {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaneWidths value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaneWidths() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaneWidths value)  $default,){
final _that = this;
switch (_that) {
case _PaneWidths():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaneWidths value)?  $default,){
final _that = this;
switch (_that) {
case _PaneWidths() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double? list,  double? listBesideThread,  double? thread)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaneWidths() when $default != null:
return $default(_that.list,_that.listBesideThread,_that.thread);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double? list,  double? listBesideThread,  double? thread)  $default,) {final _that = this;
switch (_that) {
case _PaneWidths():
return $default(_that.list,_that.listBesideThread,_that.thread);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double? list,  double? listBesideThread,  double? thread)?  $default,) {final _that = this;
switch (_that) {
case _PaneWidths() when $default != null:
return $default(_that.list,_that.listBesideThread,_that.thread);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaneWidths implements PaneWidths {
  const _PaneWidths({this.list, this.listBesideThread, this.thread});
  factory _PaneWidths.fromJson(Map<String, dynamic> json) => _$PaneWidthsFromJson(json);

@override final  double? list;
@override final  double? listBesideThread;
@override final  double? thread;

/// Create a copy of PaneWidths
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaneWidthsCopyWith<_PaneWidths> get copyWith => __$PaneWidthsCopyWithImpl<_PaneWidths>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaneWidthsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaneWidths&&(identical(other.list, list) || other.list == list)&&(identical(other.listBesideThread, listBesideThread) || other.listBesideThread == listBesideThread)&&(identical(other.thread, thread) || other.thread == thread));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,list,listBesideThread,thread);
}

@override
String toString() {
    return 'PaneWidths(list: $list, listBesideThread: $listBesideThread, thread: $thread)';
}


}

/// @nodoc
abstract mixin class _$PaneWidthsCopyWith<$Res> implements $PaneWidthsCopyWith<$Res> {
  factory _$PaneWidthsCopyWith(_PaneWidths value, $Res Function(_PaneWidths) _then) = __$PaneWidthsCopyWithImpl;
@override @useResult
$Res call({
 double? list, double? listBesideThread, double? thread
});




}
/// @nodoc
class __$PaneWidthsCopyWithImpl<$Res>
    implements _$PaneWidthsCopyWith<$Res> {
  __$PaneWidthsCopyWithImpl(this._self, this._then);

  final _PaneWidths _self;
  final $Res Function(_PaneWidths) _then;

/// Create a copy of PaneWidths
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? list = freezed,Object? listBesideThread = freezed,Object? thread = freezed,}) {
  return _then(_PaneWidths(
list: freezed == list ? _self.list : list // ignore: cast_nullable_to_non_nullable
as double?,listBesideThread: freezed == listBesideThread ? _self.listBesideThread : listBesideThread // ignore: cast_nullable_to_non_nullable
as double?,thread: freezed == thread ? _self.thread : thread // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
