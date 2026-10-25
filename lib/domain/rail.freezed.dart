// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RailTeam {

 String get id; String get displayName; bool get unread; int get mentions;
/// Create a copy of RailTeam
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RailTeamCopyWith<RailTeam> get copyWith => _$RailTeamCopyWithImpl<RailTeam>(this as RailTeam, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RailTeam;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RailTeam&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.displayName, _this.displayName) || other.displayName == _this.displayName)&&(identical(other.unread, _this.unread) || other.unread == _this.unread)&&(identical(other.mentions, _this.mentions) || other.mentions == _this.mentions));
}


@override
int get hashCode {
  final _this = this as RailTeam;
  return Object.hash(runtimeType,_this.id,_this.displayName,_this.unread,_this.mentions);
}

@override
String toString() {
  final _this = this as RailTeam;
  return 'RailTeam(id: ${_this.id}, displayName: ${_this.displayName}, unread: ${_this.unread}, mentions: ${_this.mentions})';
}


}

/// @nodoc
abstract mixin class $RailTeamCopyWith<$Res>  {
  factory $RailTeamCopyWith(RailTeam value, $Res Function(RailTeam) _then) = _$RailTeamCopyWithImpl;
@useResult
$Res call({
 String id, String displayName, bool unread, int mentions
});




}
/// @nodoc
class _$RailTeamCopyWithImpl<$Res>
    implements $RailTeamCopyWith<$Res> {
  _$RailTeamCopyWithImpl(this._self, this._then);

  final RailTeam _self;
  final $Res Function(RailTeam) _then;

/// Create a copy of RailTeam
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? displayName = null,Object? unread = null,Object? mentions = null,}) {
  return _then(RailTeam(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,unread: null == unread ? _self.unread : unread // ignore: cast_nullable_to_non_nullable
as bool,mentions: null == mentions ? _self.mentions : mentions // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RailTeam].
extension RailTeamPatterns on RailTeam {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RailTeam value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RailTeam() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RailTeam value)  $default,){
final _that = this;
switch (_that) {
case _RailTeam():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RailTeam value)?  $default,){
final _that = this;
switch (_that) {
case _RailTeam() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String displayName,  bool unread,  int mentions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RailTeam() when $default != null:
return $default(_that.id,_that.displayName,_that.unread,_that.mentions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String displayName,  bool unread,  int mentions)  $default,) {final _that = this;
switch (_that) {
case _RailTeam():
return $default(_that.id,_that.displayName,_that.unread,_that.mentions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String displayName,  bool unread,  int mentions)?  $default,) {final _that = this;
switch (_that) {
case _RailTeam() when $default != null:
return $default(_that.id,_that.displayName,_that.unread,_that.mentions);case _:
  return null;

}
}

}

/// @nodoc


class _RailTeam implements RailTeam {
  const _RailTeam({required this.id, required this.displayName, required this.unread, required this.mentions});
  

@override final  String id;
@override final  String displayName;
@override final  bool unread;
@override final  int mentions;

/// Create a copy of RailTeam
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RailTeamCopyWith<_RailTeam> get copyWith => __$RailTeamCopyWithImpl<_RailTeam>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RailTeam&&(identical(other.id, id) || other.id == id)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.unread, unread) || other.unread == unread)&&(identical(other.mentions, mentions) || other.mentions == mentions));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,displayName,unread,mentions);
}

@override
String toString() {
    return 'RailTeam(id: $id, displayName: $displayName, unread: $unread, mentions: $mentions)';
}


}

/// @nodoc
abstract mixin class _$RailTeamCopyWith<$Res> implements $RailTeamCopyWith<$Res> {
  factory _$RailTeamCopyWith(_RailTeam value, $Res Function(_RailTeam) _then) = __$RailTeamCopyWithImpl;
@override @useResult
$Res call({
 String id, String displayName, bool unread, int mentions
});




}
/// @nodoc
class __$RailTeamCopyWithImpl<$Res>
    implements _$RailTeamCopyWith<$Res> {
  __$RailTeamCopyWithImpl(this._self, this._then);

  final _RailTeam _self;
  final $Res Function(_RailTeam) _then;

/// Create a copy of RailTeam
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? displayName = null,Object? unread = null,Object? mentions = null,}) {
  return _then(_RailTeam(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,unread: null == unread ? _self.unread : unread // ignore: cast_nullable_to_non_nullable
as bool,mentions: null == mentions ? _self.mentions : mentions // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$RailTarget {

 String get url; String? get teamId;
/// Create a copy of RailTarget
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RailTargetCopyWith<RailTarget> get copyWith => _$RailTargetCopyWithImpl<RailTarget>(this as RailTarget, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RailTarget;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RailTarget&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.teamId, _this.teamId) || other.teamId == _this.teamId));
}


@override
int get hashCode {
  final _this = this as RailTarget;
  return Object.hash(runtimeType,_this.url,_this.teamId);
}

@override
String toString() {
  final _this = this as RailTarget;
  return 'RailTarget(url: ${_this.url}, teamId: ${_this.teamId})';
}


}

/// @nodoc
abstract mixin class $RailTargetCopyWith<$Res>  {
  factory $RailTargetCopyWith(RailTarget value, $Res Function(RailTarget) _then) = _$RailTargetCopyWithImpl;
@useResult
$Res call({
 String url, String? teamId
});




}
/// @nodoc
class _$RailTargetCopyWithImpl<$Res>
    implements $RailTargetCopyWith<$Res> {
  _$RailTargetCopyWithImpl(this._self, this._then);

  final RailTarget _self;
  final $Res Function(RailTarget) _then;

/// Create a copy of RailTarget
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? teamId = freezed,}) {
  return _then(RailTarget(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,teamId: freezed == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RailTarget].
extension RailTargetPatterns on RailTarget {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RailTarget value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RailTarget() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RailTarget value)  $default,){
final _that = this;
switch (_that) {
case _RailTarget():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RailTarget value)?  $default,){
final _that = this;
switch (_that) {
case _RailTarget() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url,  String? teamId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RailTarget() when $default != null:
return $default(_that.url,_that.teamId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url,  String? teamId)  $default,) {final _that = this;
switch (_that) {
case _RailTarget():
return $default(_that.url,_that.teamId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url,  String? teamId)?  $default,) {final _that = this;
switch (_that) {
case _RailTarget() when $default != null:
return $default(_that.url,_that.teamId);case _:
  return null;

}
}

}

/// @nodoc


class _RailTarget implements RailTarget {
  const _RailTarget({required this.url, this.teamId});
  

@override final  String url;
@override final  String? teamId;

/// Create a copy of RailTarget
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RailTargetCopyWith<_RailTarget> get copyWith => __$RailTargetCopyWithImpl<_RailTarget>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RailTarget&&(identical(other.url, url) || other.url == url)&&(identical(other.teamId, teamId) || other.teamId == teamId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,url,teamId);
}

@override
String toString() {
    return 'RailTarget(url: $url, teamId: $teamId)';
}


}

/// @nodoc
abstract mixin class _$RailTargetCopyWith<$Res> implements $RailTargetCopyWith<$Res> {
  factory _$RailTargetCopyWith(_RailTarget value, $Res Function(_RailTarget) _then) = __$RailTargetCopyWithImpl;
@override @useResult
$Res call({
 String url, String? teamId
});




}
/// @nodoc
class __$RailTargetCopyWithImpl<$Res>
    implements _$RailTargetCopyWith<$Res> {
  __$RailTargetCopyWithImpl(this._self, this._then);

  final _RailTarget _self;
  final $Res Function(_RailTarget) _then;

/// Create a copy of RailTarget
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? teamId = freezed,}) {
  return _then(_RailTarget(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,teamId: freezed == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
