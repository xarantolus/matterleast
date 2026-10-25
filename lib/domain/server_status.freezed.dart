// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'server_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ServerStatusView {

 String get connection; String get sync;/// The sync line reports a failure.
 bool get problem; String get stored; String get size;
/// Create a copy of ServerStatusView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerStatusViewCopyWith<ServerStatusView> get copyWith => _$ServerStatusViewCopyWithImpl<ServerStatusView>(this as ServerStatusView, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ServerStatusView;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerStatusView&&(identical(other.connection, _this.connection) || other.connection == _this.connection)&&(identical(other.sync, _this.sync) || other.sync == _this.sync)&&(identical(other.problem, _this.problem) || other.problem == _this.problem)&&(identical(other.stored, _this.stored) || other.stored == _this.stored)&&(identical(other.size, _this.size) || other.size == _this.size));
}


@override
int get hashCode {
  final _this = this as ServerStatusView;
  return Object.hash(runtimeType,_this.connection,_this.sync,_this.problem,_this.stored,_this.size);
}

@override
String toString() {
  final _this = this as ServerStatusView;
  return 'ServerStatusView(connection: ${_this.connection}, sync: ${_this.sync}, problem: ${_this.problem}, stored: ${_this.stored}, size: ${_this.size})';
}


}

/// @nodoc
abstract mixin class $ServerStatusViewCopyWith<$Res>  {
  factory $ServerStatusViewCopyWith(ServerStatusView value, $Res Function(ServerStatusView) _then) = _$ServerStatusViewCopyWithImpl;
@useResult
$Res call({
 String connection, String sync, bool problem, String stored, String size
});




}
/// @nodoc
class _$ServerStatusViewCopyWithImpl<$Res>
    implements $ServerStatusViewCopyWith<$Res> {
  _$ServerStatusViewCopyWithImpl(this._self, this._then);

  final ServerStatusView _self;
  final $Res Function(ServerStatusView) _then;

/// Create a copy of ServerStatusView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? connection = null,Object? sync = null,Object? problem = null,Object? stored = null,Object? size = null,}) {
  return _then(ServerStatusView(
connection: null == connection ? _self.connection : connection // ignore: cast_nullable_to_non_nullable
as String,sync: null == sync ? _self.sync : sync // ignore: cast_nullable_to_non_nullable
as String,problem: null == problem ? _self.problem : problem // ignore: cast_nullable_to_non_nullable
as bool,stored: null == stored ? _self.stored : stored // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ServerStatusView].
extension ServerStatusViewPatterns on ServerStatusView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ServerStatusView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ServerStatusView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ServerStatusView value)  $default,){
final _that = this;
switch (_that) {
case _ServerStatusView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ServerStatusView value)?  $default,){
final _that = this;
switch (_that) {
case _ServerStatusView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String connection,  String sync,  bool problem,  String stored,  String size)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServerStatusView() when $default != null:
return $default(_that.connection,_that.sync,_that.problem,_that.stored,_that.size);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String connection,  String sync,  bool problem,  String stored,  String size)  $default,) {final _that = this;
switch (_that) {
case _ServerStatusView():
return $default(_that.connection,_that.sync,_that.problem,_that.stored,_that.size);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String connection,  String sync,  bool problem,  String stored,  String size)?  $default,) {final _that = this;
switch (_that) {
case _ServerStatusView() when $default != null:
return $default(_that.connection,_that.sync,_that.problem,_that.stored,_that.size);case _:
  return null;

}
}

}

/// @nodoc


class _ServerStatusView implements ServerStatusView {
  const _ServerStatusView({required this.connection, required this.sync, required this.problem, required this.stored, required this.size});
  

@override final  String connection;
@override final  String sync;
/// The sync line reports a failure.
@override final  bool problem;
@override final  String stored;
@override final  String size;

/// Create a copy of ServerStatusView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServerStatusViewCopyWith<_ServerStatusView> get copyWith => __$ServerStatusViewCopyWithImpl<_ServerStatusView>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServerStatusView&&(identical(other.connection, connection) || other.connection == connection)&&(identical(other.sync, sync) || other.sync == sync)&&(identical(other.problem, problem) || other.problem == problem)&&(identical(other.stored, stored) || other.stored == stored)&&(identical(other.size, size) || other.size == size));
}


@override
int get hashCode {
    return Object.hash(runtimeType,connection,sync,problem,stored,size);
}

@override
String toString() {
    return 'ServerStatusView(connection: $connection, sync: $sync, problem: $problem, stored: $stored, size: $size)';
}


}

/// @nodoc
abstract mixin class _$ServerStatusViewCopyWith<$Res> implements $ServerStatusViewCopyWith<$Res> {
  factory _$ServerStatusViewCopyWith(_ServerStatusView value, $Res Function(_ServerStatusView) _then) = __$ServerStatusViewCopyWithImpl;
@override @useResult
$Res call({
 String connection, String sync, bool problem, String stored, String size
});




}
/// @nodoc
class __$ServerStatusViewCopyWithImpl<$Res>
    implements _$ServerStatusViewCopyWith<$Res> {
  __$ServerStatusViewCopyWithImpl(this._self, this._then);

  final _ServerStatusView _self;
  final $Res Function(_ServerStatusView) _then;

/// Create a copy of ServerStatusView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? connection = null,Object? sync = null,Object? problem = null,Object? stored = null,Object? size = null,}) {
  return _then(_ServerStatusView(
connection: null == connection ? _self.connection : connection // ignore: cast_nullable_to_non_nullable
as String,sync: null == sync ? _self.sync : sync // ignore: cast_nullable_to_non_nullable
as String,problem: null == problem ? _self.problem : problem // ignore: cast_nullable_to_non_nullable
as bool,stored: null == stored ? _self.stored : stored // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
