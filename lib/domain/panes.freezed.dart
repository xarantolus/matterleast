// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'panes.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ConversationTarget {

 String get url; String get channelId; String? get teamId; String? get highlightPostId;/// The composer takes the keyboard when it shows, as after Reply.
 bool get focusComposer;
/// Create a copy of ConversationTarget
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConversationTargetCopyWith<ConversationTarget> get copyWith => _$ConversationTargetCopyWithImpl<ConversationTarget>(this as ConversationTarget, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ConversationTarget;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConversationTarget&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.channelId, _this.channelId) || other.channelId == _this.channelId)&&(identical(other.teamId, _this.teamId) || other.teamId == _this.teamId)&&(identical(other.highlightPostId, _this.highlightPostId) || other.highlightPostId == _this.highlightPostId)&&(identical(other.focusComposer, _this.focusComposer) || other.focusComposer == _this.focusComposer));
}


@override
int get hashCode {
  final _this = this as ConversationTarget;
  return Object.hash(runtimeType,_this.url,_this.channelId,_this.teamId,_this.highlightPostId,_this.focusComposer);
}

@override
String toString() {
  final _this = this as ConversationTarget;
  return 'ConversationTarget(url: ${_this.url}, channelId: ${_this.channelId}, teamId: ${_this.teamId}, highlightPostId: ${_this.highlightPostId}, focusComposer: ${_this.focusComposer})';
}


}

/// @nodoc
abstract mixin class $ConversationTargetCopyWith<$Res>  {
  factory $ConversationTargetCopyWith(ConversationTarget value, $Res Function(ConversationTarget) _then) = _$ConversationTargetCopyWithImpl;
@useResult
$Res call({
 String url, String channelId, String? teamId, String? highlightPostId, bool focusComposer
});




}
/// @nodoc
class _$ConversationTargetCopyWithImpl<$Res>
    implements $ConversationTargetCopyWith<$Res> {
  _$ConversationTargetCopyWithImpl(this._self, this._then);

  final ConversationTarget _self;
  final $Res Function(ConversationTarget) _then;

/// Create a copy of ConversationTarget
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? channelId = null,Object? teamId = freezed,Object? highlightPostId = freezed,Object? focusComposer = null,}) {
  return _then(_self.copyWith(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,teamId: freezed == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String?,highlightPostId: freezed == highlightPostId ? _self.highlightPostId : highlightPostId // ignore: cast_nullable_to_non_nullable
as String?,focusComposer: null == focusComposer ? _self.focusComposer : focusComposer // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ConversationTarget].
extension ConversationTargetPatterns on ConversationTarget {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ChannelTarget value)?  channel,TResult Function( ThreadTarget value)?  thread,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ChannelTarget() when channel != null:
return channel(_that);case ThreadTarget() when thread != null:
return thread(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ChannelTarget value)  channel,required TResult Function( ThreadTarget value)  thread,}){
final _that = this;
switch (_that) {
case ChannelTarget():
return channel(_that);case ThreadTarget():
return thread(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ChannelTarget value)?  channel,TResult? Function( ThreadTarget value)?  thread,}){
final _that = this;
switch (_that) {
case ChannelTarget() when channel != null:
return channel(_that);case ThreadTarget() when thread != null:
return thread(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String url,  String channelId,  String title,  String? teamId,  String? highlightPostId,  bool focusComposer)?  channel,TResult Function( String url,  String channelId,  String rootId,  String channelName,  String? teamId,  String? highlightPostId,  bool focusComposer)?  thread,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ChannelTarget() when channel != null:
return channel(_that.url,_that.channelId,_that.title,_that.teamId,_that.highlightPostId,_that.focusComposer);case ThreadTarget() when thread != null:
return thread(_that.url,_that.channelId,_that.rootId,_that.channelName,_that.teamId,_that.highlightPostId,_that.focusComposer);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String url,  String channelId,  String title,  String? teamId,  String? highlightPostId,  bool focusComposer)  channel,required TResult Function( String url,  String channelId,  String rootId,  String channelName,  String? teamId,  String? highlightPostId,  bool focusComposer)  thread,}) {final _that = this;
switch (_that) {
case ChannelTarget():
return channel(_that.url,_that.channelId,_that.title,_that.teamId,_that.highlightPostId,_that.focusComposer);case ThreadTarget():
return thread(_that.url,_that.channelId,_that.rootId,_that.channelName,_that.teamId,_that.highlightPostId,_that.focusComposer);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String url,  String channelId,  String title,  String? teamId,  String? highlightPostId,  bool focusComposer)?  channel,TResult? Function( String url,  String channelId,  String rootId,  String channelName,  String? teamId,  String? highlightPostId,  bool focusComposer)?  thread,}) {final _that = this;
switch (_that) {
case ChannelTarget() when channel != null:
return channel(_that.url,_that.channelId,_that.title,_that.teamId,_that.highlightPostId,_that.focusComposer);case ThreadTarget() when thread != null:
return thread(_that.url,_that.channelId,_that.rootId,_that.channelName,_that.teamId,_that.highlightPostId,_that.focusComposer);case _:
  return null;

}
}

}

/// @nodoc


class ChannelTarget implements ConversationTarget {
  const ChannelTarget({required this.url, required this.channelId, required this.title, this.teamId, this.highlightPostId, this.focusComposer = false});
  

@override final  String url;
@override final  String channelId;
 final  String title;
@override final  String? teamId;
@override final  String? highlightPostId;
/// The composer takes the keyboard when it shows, as after Reply.
@override@JsonKey() final  bool focusComposer;

/// Create a copy of ConversationTarget
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChannelTargetCopyWith<ChannelTarget> get copyWith => _$ChannelTargetCopyWithImpl<ChannelTarget>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ChannelTarget&&(identical(other.url, url) || other.url == url)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.title, title) || other.title == title)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.highlightPostId, highlightPostId) || other.highlightPostId == highlightPostId)&&(identical(other.focusComposer, focusComposer) || other.focusComposer == focusComposer));
}


@override
int get hashCode {
    return Object.hash(runtimeType,url,channelId,title,teamId,highlightPostId,focusComposer);
}

@override
String toString() {
    return 'ConversationTarget.channel(url: $url, channelId: $channelId, title: $title, teamId: $teamId, highlightPostId: $highlightPostId, focusComposer: $focusComposer)';
}


}

/// @nodoc
abstract mixin class $ChannelTargetCopyWith<$Res> implements $ConversationTargetCopyWith<$Res> {
  factory $ChannelTargetCopyWith(ChannelTarget value, $Res Function(ChannelTarget) _then) = _$ChannelTargetCopyWithImpl;
@override @useResult
$Res call({
 String url, String channelId, String title, String? teamId, String? highlightPostId, bool focusComposer
});




}
/// @nodoc
class _$ChannelTargetCopyWithImpl<$Res>
    implements $ChannelTargetCopyWith<$Res> {
  _$ChannelTargetCopyWithImpl(this._self, this._then);

  final ChannelTarget _self;
  final $Res Function(ChannelTarget) _then;

/// Create a copy of ConversationTarget
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? channelId = null,Object? title = null,Object? teamId = freezed,Object? highlightPostId = freezed,Object? focusComposer = null,}) {
  return _then(ChannelTarget(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,teamId: freezed == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String?,highlightPostId: freezed == highlightPostId ? _self.highlightPostId : highlightPostId // ignore: cast_nullable_to_non_nullable
as String?,focusComposer: null == focusComposer ? _self.focusComposer : focusComposer // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class ThreadTarget implements ConversationTarget {
  const ThreadTarget({required this.url, required this.channelId, required this.rootId, required this.channelName, this.teamId, this.highlightPostId, this.focusComposer = false});
  

@override final  String url;
@override final  String channelId;
 final  String rootId;
 final  String channelName;
@override final  String? teamId;
@override final  String? highlightPostId;
@override@JsonKey() final  bool focusComposer;

/// Create a copy of ConversationTarget
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThreadTargetCopyWith<ThreadTarget> get copyWith => _$ThreadTargetCopyWithImpl<ThreadTarget>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ThreadTarget&&(identical(other.url, url) || other.url == url)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.rootId, rootId) || other.rootId == rootId)&&(identical(other.channelName, channelName) || other.channelName == channelName)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.highlightPostId, highlightPostId) || other.highlightPostId == highlightPostId)&&(identical(other.focusComposer, focusComposer) || other.focusComposer == focusComposer));
}


@override
int get hashCode {
    return Object.hash(runtimeType,url,channelId,rootId,channelName,teamId,highlightPostId,focusComposer);
}

@override
String toString() {
    return 'ConversationTarget.thread(url: $url, channelId: $channelId, rootId: $rootId, channelName: $channelName, teamId: $teamId, highlightPostId: $highlightPostId, focusComposer: $focusComposer)';
}


}

/// @nodoc
abstract mixin class $ThreadTargetCopyWith<$Res> implements $ConversationTargetCopyWith<$Res> {
  factory $ThreadTargetCopyWith(ThreadTarget value, $Res Function(ThreadTarget) _then) = _$ThreadTargetCopyWithImpl;
@override @useResult
$Res call({
 String url, String channelId, String rootId, String channelName, String? teamId, String? highlightPostId, bool focusComposer
});




}
/// @nodoc
class _$ThreadTargetCopyWithImpl<$Res>
    implements $ThreadTargetCopyWith<$Res> {
  _$ThreadTargetCopyWithImpl(this._self, this._then);

  final ThreadTarget _self;
  final $Res Function(ThreadTarget) _then;

/// Create a copy of ConversationTarget
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? channelId = null,Object? rootId = null,Object? channelName = null,Object? teamId = freezed,Object? highlightPostId = freezed,Object? focusComposer = null,}) {
  return _then(ThreadTarget(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,rootId: null == rootId ? _self.rootId : rootId // ignore: cast_nullable_to_non_nullable
as String,channelName: null == channelName ? _self.channelName : channelName // ignore: cast_nullable_to_non_nullable
as String,teamId: freezed == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String?,highlightPostId: freezed == highlightPostId ? _self.highlightPostId : highlightPostId // ignore: cast_nullable_to_non_nullable
as String?,focusComposer: null == focusComposer ? _self.focusComposer : focusComposer // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$Panes {

 ChannelTarget? get channel; ThreadTarget? get thread;
/// Create a copy of Panes
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PanesCopyWith<Panes> get copyWith => _$PanesCopyWithImpl<Panes>(this as Panes, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Panes;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Panes&&const DeepCollectionEquality().equals(other.channel, _this.channel)&&const DeepCollectionEquality().equals(other.thread, _this.thread));
}


@override
int get hashCode {
  final _this = this as Panes;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.channel),const DeepCollectionEquality().hash(_this.thread));
}

@override
String toString() {
  final _this = this as Panes;
  return 'Panes(channel: ${_this.channel}, thread: ${_this.thread})';
}


}

/// @nodoc
abstract mixin class $PanesCopyWith<$Res>  {
  factory $PanesCopyWith(Panes value, $Res Function(Panes) _then) = _$PanesCopyWithImpl;
@useResult
$Res call({
 ChannelTarget? channel, ThreadTarget? thread
});




}
/// @nodoc
class _$PanesCopyWithImpl<$Res>
    implements $PanesCopyWith<$Res> {
  _$PanesCopyWithImpl(this._self, this._then);

  final Panes _self;
  final $Res Function(Panes) _then;

/// Create a copy of Panes
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? channel = freezed,Object? thread = freezed,}) {
  return _then(Panes(
channel: freezed == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as ChannelTarget?,thread: freezed == thread ? _self.thread : thread // ignore: cast_nullable_to_non_nullable
as ThreadTarget?,
  ));
}

}


/// Adds pattern-matching-related methods to [Panes].
extension PanesPatterns on Panes {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Panes value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Panes() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Panes value)  $default,){
final _that = this;
switch (_that) {
case _Panes():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Panes value)?  $default,){
final _that = this;
switch (_that) {
case _Panes() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ChannelTarget? channel,  ThreadTarget? thread)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Panes() when $default != null:
return $default(_that.channel,_that.thread);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ChannelTarget? channel,  ThreadTarget? thread)  $default,) {final _that = this;
switch (_that) {
case _Panes():
return $default(_that.channel,_that.thread);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ChannelTarget? channel,  ThreadTarget? thread)?  $default,) {final _that = this;
switch (_that) {
case _Panes() when $default != null:
return $default(_that.channel,_that.thread);case _:
  return null;

}
}

}

/// @nodoc


class _Panes extends Panes {
  const _Panes({this.channel, this.thread}): super._();
  

@override final  ChannelTarget? channel;
@override final  ThreadTarget? thread;

/// Create a copy of Panes
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PanesCopyWith<_Panes> get copyWith => __$PanesCopyWithImpl<_Panes>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Panes&&const DeepCollectionEquality().equals(other.channel, channel)&&const DeepCollectionEquality().equals(other.thread, thread));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(channel),const DeepCollectionEquality().hash(thread));
}

@override
String toString() {
    return 'Panes(channel: $channel, thread: $thread)';
}


}

/// @nodoc
abstract mixin class _$PanesCopyWith<$Res> implements $PanesCopyWith<$Res> {
  factory _$PanesCopyWith(_Panes value, $Res Function(_Panes) _then) = __$PanesCopyWithImpl;
@override @useResult
$Res call({
 ChannelTarget? channel, ThreadTarget? thread
});




}
/// @nodoc
class __$PanesCopyWithImpl<$Res>
    implements _$PanesCopyWith<$Res> {
  __$PanesCopyWithImpl(this._self, this._then);

  final _Panes _self;
  final $Res Function(_Panes) _then;

/// Create a copy of Panes
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? channel = freezed,Object? thread = freezed,}) {
  return _then(_Panes(
channel: freezed == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as ChannelTarget?,thread: freezed == thread ? _self.thread : thread // ignore: cast_nullable_to_non_nullable
as ThreadTarget?,
  ));
}


}

// dart format on
