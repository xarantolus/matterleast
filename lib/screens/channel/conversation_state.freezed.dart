// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conversation_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ConversationState {

/// Null until the database answered once.
 ConversationWindow? get window; List<ListRow> get rows;/// The refresh after opening is running.
 bool get refreshing; ApiError? get refreshFailure; bool get loadingOlder; ApiError? get olderFailure;/// Messages that arrived live while the screen was open, by key, with
/// when they arrived: they animate in and count towards "N new".
 Map<Object, DateTime> get arrived;/// Grows when the list moves to another stretch of history, so it
/// opens anew there.
 int get generation;/// How this [generation] opens, once its rows are there.
 OpenIntent get intent; SavedPlace? get saved; String? get highlightKey;
/// Create a copy of ConversationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConversationStateCopyWith<ConversationState> get copyWith => _$ConversationStateCopyWithImpl<ConversationState>(this as ConversationState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ConversationState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConversationState&&(identical(other.window, _this.window) || other.window == _this.window)&&const DeepCollectionEquality().equals(other.rows, _this.rows)&&(identical(other.refreshing, _this.refreshing) || other.refreshing == _this.refreshing)&&(identical(other.refreshFailure, _this.refreshFailure) || other.refreshFailure == _this.refreshFailure)&&(identical(other.loadingOlder, _this.loadingOlder) || other.loadingOlder == _this.loadingOlder)&&(identical(other.olderFailure, _this.olderFailure) || other.olderFailure == _this.olderFailure)&&const DeepCollectionEquality().equals(other.arrived, _this.arrived)&&(identical(other.generation, _this.generation) || other.generation == _this.generation)&&(identical(other.intent, _this.intent) || other.intent == _this.intent)&&(identical(other.saved, _this.saved) || other.saved == _this.saved)&&(identical(other.highlightKey, _this.highlightKey) || other.highlightKey == _this.highlightKey));
}


@override
int get hashCode {
  final _this = this as ConversationState;
  return Object.hash(runtimeType,_this.window,const DeepCollectionEquality().hash(_this.rows),_this.refreshing,_this.refreshFailure,_this.loadingOlder,_this.olderFailure,const DeepCollectionEquality().hash(_this.arrived),_this.generation,_this.intent,_this.saved,_this.highlightKey);
}

@override
String toString() {
  final _this = this as ConversationState;
  return 'ConversationState(window: ${_this.window}, rows: ${_this.rows}, refreshing: ${_this.refreshing}, refreshFailure: ${_this.refreshFailure}, loadingOlder: ${_this.loadingOlder}, olderFailure: ${_this.olderFailure}, arrived: ${_this.arrived}, generation: ${_this.generation}, intent: ${_this.intent}, saved: ${_this.saved}, highlightKey: ${_this.highlightKey})';
}


}

/// @nodoc
abstract mixin class $ConversationStateCopyWith<$Res>  {
  factory $ConversationStateCopyWith(ConversationState value, $Res Function(ConversationState) _then) = _$ConversationStateCopyWithImpl;
@useResult
$Res call({
 ConversationWindow? window, List<ListRow> rows, bool refreshing, ApiError? refreshFailure, bool loadingOlder, ApiError? olderFailure, Map<Object, DateTime> arrived, int generation, OpenIntent intent, SavedPlace? saved, String? highlightKey
});


$ConversationWindowCopyWith<$Res>? get window;

}
/// @nodoc
class _$ConversationStateCopyWithImpl<$Res>
    implements $ConversationStateCopyWith<$Res> {
  _$ConversationStateCopyWithImpl(this._self, this._then);

  final ConversationState _self;
  final $Res Function(ConversationState) _then;

/// Create a copy of ConversationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? window = freezed,Object? rows = null,Object? refreshing = null,Object? refreshFailure = freezed,Object? loadingOlder = null,Object? olderFailure = freezed,Object? arrived = null,Object? generation = null,Object? intent = null,Object? saved = freezed,Object? highlightKey = freezed,}) {
  return _then(ConversationState(
window: freezed == window ? _self.window : window // ignore: cast_nullable_to_non_nullable
as ConversationWindow?,rows: null == rows ? _self.rows : rows // ignore: cast_nullable_to_non_nullable
as List<ListRow>,refreshing: null == refreshing ? _self.refreshing : refreshing // ignore: cast_nullable_to_non_nullable
as bool,refreshFailure: freezed == refreshFailure ? _self.refreshFailure : refreshFailure // ignore: cast_nullable_to_non_nullable
as ApiError?,loadingOlder: null == loadingOlder ? _self.loadingOlder : loadingOlder // ignore: cast_nullable_to_non_nullable
as bool,olderFailure: freezed == olderFailure ? _self.olderFailure : olderFailure // ignore: cast_nullable_to_non_nullable
as ApiError?,arrived: null == arrived ? _self.arrived : arrived // ignore: cast_nullable_to_non_nullable
as Map<Object, DateTime>,generation: null == generation ? _self.generation : generation // ignore: cast_nullable_to_non_nullable
as int,intent: null == intent ? _self.intent : intent // ignore: cast_nullable_to_non_nullable
as OpenIntent,saved: freezed == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as SavedPlace?,highlightKey: freezed == highlightKey ? _self.highlightKey : highlightKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of ConversationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConversationWindowCopyWith<$Res>? get window {
    if (_self.window == null) {
    return null;
  }

  return $ConversationWindowCopyWith<$Res>(_self.window!, (value) {
    return _then(_self.copyWith(window: value));
  });
}
}


/// Adds pattern-matching-related methods to [ConversationState].
extension ConversationStatePatterns on ConversationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConversationState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConversationState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConversationState value)  $default,){
final _that = this;
switch (_that) {
case _ConversationState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConversationState value)?  $default,){
final _that = this;
switch (_that) {
case _ConversationState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ConversationWindow? window,  List<ListRow> rows,  bool refreshing,  ApiError? refreshFailure,  bool loadingOlder,  ApiError? olderFailure,  Map<Object, DateTime> arrived,  int generation,  OpenIntent intent,  SavedPlace? saved,  String? highlightKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConversationState() when $default != null:
return $default(_that.window,_that.rows,_that.refreshing,_that.refreshFailure,_that.loadingOlder,_that.olderFailure,_that.arrived,_that.generation,_that.intent,_that.saved,_that.highlightKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ConversationWindow? window,  List<ListRow> rows,  bool refreshing,  ApiError? refreshFailure,  bool loadingOlder,  ApiError? olderFailure,  Map<Object, DateTime> arrived,  int generation,  OpenIntent intent,  SavedPlace? saved,  String? highlightKey)  $default,) {final _that = this;
switch (_that) {
case _ConversationState():
return $default(_that.window,_that.rows,_that.refreshing,_that.refreshFailure,_that.loadingOlder,_that.olderFailure,_that.arrived,_that.generation,_that.intent,_that.saved,_that.highlightKey);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ConversationWindow? window,  List<ListRow> rows,  bool refreshing,  ApiError? refreshFailure,  bool loadingOlder,  ApiError? olderFailure,  Map<Object, DateTime> arrived,  int generation,  OpenIntent intent,  SavedPlace? saved,  String? highlightKey)?  $default,) {final _that = this;
switch (_that) {
case _ConversationState() when $default != null:
return $default(_that.window,_that.rows,_that.refreshing,_that.refreshFailure,_that.loadingOlder,_that.olderFailure,_that.arrived,_that.generation,_that.intent,_that.saved,_that.highlightKey);case _:
  return null;

}
}

}

/// @nodoc


class _ConversationState implements ConversationState {
  const _ConversationState({this.window,  List<ListRow> rows = const <ListRow>[], this.refreshing = false, this.refreshFailure, this.loadingOlder = false, this.olderFailure,  Map<Object, DateTime> arrived = const <Object, DateTime>{}, this.generation = 0, this.intent = OpenIntent.usual, this.saved, this.highlightKey}): _rows = rows,_arrived = arrived;
  

/// Null until the database answered once.
@override final  ConversationWindow? window;
 final  List<ListRow> _rows;
@override@JsonKey() List<ListRow> get rows {
  if (_rows is EqualUnmodifiableListView) return _rows;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rows);
}

/// The refresh after opening is running.
@override@JsonKey() final  bool refreshing;
@override final  ApiError? refreshFailure;
@override@JsonKey() final  bool loadingOlder;
@override final  ApiError? olderFailure;
/// Messages that arrived live while the screen was open, by key, with
/// when they arrived: they animate in and count towards "N new".
 final  Map<Object, DateTime> _arrived;
/// Messages that arrived live while the screen was open, by key, with
/// when they arrived: they animate in and count towards "N new".
@override@JsonKey() Map<Object, DateTime> get arrived {
  if (_arrived is EqualUnmodifiableMapView) return _arrived;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_arrived);
}

/// Grows when the list moves to another stretch of history, so it
/// opens anew there.
@override@JsonKey() final  int generation;
/// How this [generation] opens, once its rows are there.
@override@JsonKey() final  OpenIntent intent;
@override final  SavedPlace? saved;
@override final  String? highlightKey;

/// Create a copy of ConversationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConversationStateCopyWith<_ConversationState> get copyWith => __$ConversationStateCopyWithImpl<_ConversationState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConversationState&&(identical(other.window, window) || other.window == window)&&const DeepCollectionEquality().equals(other.rows, _rows)&&(identical(other.refreshing, refreshing) || other.refreshing == refreshing)&&(identical(other.refreshFailure, refreshFailure) || other.refreshFailure == refreshFailure)&&(identical(other.loadingOlder, loadingOlder) || other.loadingOlder == loadingOlder)&&(identical(other.olderFailure, olderFailure) || other.olderFailure == olderFailure)&&const DeepCollectionEquality().equals(other.arrived, _arrived)&&(identical(other.generation, generation) || other.generation == generation)&&(identical(other.intent, intent) || other.intent == intent)&&(identical(other.saved, saved) || other.saved == saved)&&(identical(other.highlightKey, highlightKey) || other.highlightKey == highlightKey));
}


@override
int get hashCode {
    return Object.hash(runtimeType,window,const DeepCollectionEquality().hash(_rows),refreshing,refreshFailure,loadingOlder,olderFailure,const DeepCollectionEquality().hash(_arrived),generation,intent,saved,highlightKey);
}

@override
String toString() {
    return 'ConversationState(window: $window, rows: $rows, refreshing: $refreshing, refreshFailure: $refreshFailure, loadingOlder: $loadingOlder, olderFailure: $olderFailure, arrived: $arrived, generation: $generation, intent: $intent, saved: $saved, highlightKey: $highlightKey)';
}


}

/// @nodoc
abstract mixin class _$ConversationStateCopyWith<$Res> implements $ConversationStateCopyWith<$Res> {
  factory _$ConversationStateCopyWith(_ConversationState value, $Res Function(_ConversationState) _then) = __$ConversationStateCopyWithImpl;
@override @useResult
$Res call({
 ConversationWindow? window, List<ListRow> rows, bool refreshing, ApiError? refreshFailure, bool loadingOlder, ApiError? olderFailure, Map<Object, DateTime> arrived, int generation, OpenIntent intent, SavedPlace? saved, String? highlightKey
});


@override $ConversationWindowCopyWith<$Res>? get window;

}
/// @nodoc
class __$ConversationStateCopyWithImpl<$Res>
    implements _$ConversationStateCopyWith<$Res> {
  __$ConversationStateCopyWithImpl(this._self, this._then);

  final _ConversationState _self;
  final $Res Function(_ConversationState) _then;

/// Create a copy of ConversationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? window = freezed,Object? rows = null,Object? refreshing = null,Object? refreshFailure = freezed,Object? loadingOlder = null,Object? olderFailure = freezed,Object? arrived = null,Object? generation = null,Object? intent = null,Object? saved = freezed,Object? highlightKey = freezed,}) {
  return _then(_ConversationState(
window: freezed == window ? _self.window : window // ignore: cast_nullable_to_non_nullable
as ConversationWindow?,rows: null == rows ? _self._rows : rows // ignore: cast_nullable_to_non_nullable
as List<ListRow>,refreshing: null == refreshing ? _self.refreshing : refreshing // ignore: cast_nullable_to_non_nullable
as bool,refreshFailure: freezed == refreshFailure ? _self.refreshFailure : refreshFailure // ignore: cast_nullable_to_non_nullable
as ApiError?,loadingOlder: null == loadingOlder ? _self.loadingOlder : loadingOlder // ignore: cast_nullable_to_non_nullable
as bool,olderFailure: freezed == olderFailure ? _self.olderFailure : olderFailure // ignore: cast_nullable_to_non_nullable
as ApiError?,arrived: null == arrived ? _self._arrived : arrived // ignore: cast_nullable_to_non_nullable
as Map<Object, DateTime>,generation: null == generation ? _self.generation : generation // ignore: cast_nullable_to_non_nullable
as int,intent: null == intent ? _self.intent : intent // ignore: cast_nullable_to_non_nullable
as OpenIntent,saved: freezed == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as SavedPlace?,highlightKey: freezed == highlightKey ? _self.highlightKey : highlightKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ConversationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConversationWindowCopyWith<$Res>? get window {
    if (_self.window == null) {
    return null;
  }

  return $ConversationWindowCopyWith<$Res>(_self.window!, (value) {
    return _then(_self.copyWith(window: value));
  });
}
}

// dart format on
