// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'channel_list_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChannelListState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ChannelListState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ChannelListState()';
}


}

/// @nodoc
class $ChannelListStateCopyWith<$Res>  {
$ChannelListStateCopyWith(ChannelListState _, $Res Function(ChannelListState) __);
}


/// Adds pattern-matching-related methods to [ChannelListState].
extension ChannelListStatePatterns on ChannelListState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ChannelListLoading value)?  loading,TResult Function( ChannelListFailed value)?  failed,TResult Function( ChannelListReady value)?  ready,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ChannelListLoading() when loading != null:
return loading(_that);case ChannelListFailed() when failed != null:
return failed(_that);case ChannelListReady() when ready != null:
return ready(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ChannelListLoading value)  loading,required TResult Function( ChannelListFailed value)  failed,required TResult Function( ChannelListReady value)  ready,}){
final _that = this;
switch (_that) {
case ChannelListLoading():
return loading(_that);case ChannelListFailed():
return failed(_that);case ChannelListReady():
return ready(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ChannelListLoading value)?  loading,TResult? Function( ChannelListFailed value)?  failed,TResult? Function( ChannelListReady value)?  ready,}){
final _that = this;
switch (_that) {
case ChannelListLoading() when loading != null:
return loading(_that);case ChannelListFailed() when failed != null:
return failed(_that);case ChannelListReady() when ready != null:
return ready(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( String title,  String detail)?  failed,TResult Function( ChannelList list,  bool refreshing,  String? notice)?  ready,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ChannelListLoading() when loading != null:
return loading();case ChannelListFailed() when failed != null:
return failed(_that.title,_that.detail);case ChannelListReady() when ready != null:
return ready(_that.list,_that.refreshing,_that.notice);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( String title,  String detail)  failed,required TResult Function( ChannelList list,  bool refreshing,  String? notice)  ready,}) {final _that = this;
switch (_that) {
case ChannelListLoading():
return loading();case ChannelListFailed():
return failed(_that.title,_that.detail);case ChannelListReady():
return ready(_that.list,_that.refreshing,_that.notice);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( String title,  String detail)?  failed,TResult? Function( ChannelList list,  bool refreshing,  String? notice)?  ready,}) {final _that = this;
switch (_that) {
case ChannelListLoading() when loading != null:
return loading();case ChannelListFailed() when failed != null:
return failed(_that.title,_that.detail);case ChannelListReady() when ready != null:
return ready(_that.list,_that.refreshing,_that.notice);case _:
  return null;

}
}

}

/// @nodoc


class ChannelListLoading implements ChannelListState {
  const ChannelListLoading();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ChannelListLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ChannelListState.loading()';
}


}




/// @nodoc


class ChannelListFailed implements ChannelListState {
  const ChannelListFailed({required this.title, required this.detail});
  

 final  String title;
 final  String detail;

/// Create a copy of ChannelListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChannelListFailedCopyWith<ChannelListFailed> get copyWith => _$ChannelListFailedCopyWithImpl<ChannelListFailed>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ChannelListFailed&&(identical(other.title, title) || other.title == title)&&(identical(other.detail, detail) || other.detail == detail));
}


@override
int get hashCode {
    return Object.hash(runtimeType,title,detail);
}

@override
String toString() {
    return 'ChannelListState.failed(title: $title, detail: $detail)';
}


}

/// @nodoc
abstract mixin class $ChannelListFailedCopyWith<$Res> implements $ChannelListStateCopyWith<$Res> {
  factory $ChannelListFailedCopyWith(ChannelListFailed value, $Res Function(ChannelListFailed) _then) = _$ChannelListFailedCopyWithImpl;
@useResult
$Res call({
 String title, String detail
});




}
/// @nodoc
class _$ChannelListFailedCopyWithImpl<$Res>
    implements $ChannelListFailedCopyWith<$Res> {
  _$ChannelListFailedCopyWithImpl(this._self, this._then);

  final ChannelListFailed _self;
  final $Res Function(ChannelListFailed) _then;

/// Create a copy of ChannelListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? title = null,Object? detail = null,}) {
  return _then(ChannelListFailed(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,detail: null == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ChannelListReady implements ChannelListState {
  const ChannelListReady(this.list, {required this.refreshing, this.notice});
  

 final  ChannelList list;
 final  bool refreshing;
 final  String? notice;

/// Create a copy of ChannelListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChannelListReadyCopyWith<ChannelListReady> get copyWith => _$ChannelListReadyCopyWithImpl<ChannelListReady>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ChannelListReady&&(identical(other.list, list) || other.list == list)&&(identical(other.refreshing, refreshing) || other.refreshing == refreshing)&&(identical(other.notice, notice) || other.notice == notice));
}


@override
int get hashCode {
    return Object.hash(runtimeType,list,refreshing,notice);
}

@override
String toString() {
    return 'ChannelListState.ready(list: $list, refreshing: $refreshing, notice: $notice)';
}


}

/// @nodoc
abstract mixin class $ChannelListReadyCopyWith<$Res> implements $ChannelListStateCopyWith<$Res> {
  factory $ChannelListReadyCopyWith(ChannelListReady value, $Res Function(ChannelListReady) _then) = _$ChannelListReadyCopyWithImpl;
@useResult
$Res call({
 ChannelList list, bool refreshing, String? notice
});


$ChannelListCopyWith<$Res> get list;

}
/// @nodoc
class _$ChannelListReadyCopyWithImpl<$Res>
    implements $ChannelListReadyCopyWith<$Res> {
  _$ChannelListReadyCopyWithImpl(this._self, this._then);

  final ChannelListReady _self;
  final $Res Function(ChannelListReady) _then;

/// Create a copy of ChannelListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? list = null,Object? refreshing = null,Object? notice = freezed,}) {
  return _then(ChannelListReady(
null == list ? _self.list : list // ignore: cast_nullable_to_non_nullable
as ChannelList,refreshing: null == refreshing ? _self.refreshing : refreshing // ignore: cast_nullable_to_non_nullable
as bool,notice: freezed == notice ? _self.notice : notice // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ChannelListState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChannelListCopyWith<$Res> get list {
  
  return $ChannelListCopyWith<$Res>(_self.list, (value) {
    return _then(_self.copyWith(list: value));
  });
}
}

// dart format on
