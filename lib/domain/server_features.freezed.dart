// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'server_features.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ServerFeatures {

/// Such as `12.0.1`; empty when the server didn't say.
 String get version;/// `disabled`, `default_on`, `default_off` or `always_on`.
 String? get collapsedThreads; String? get nameDisplay; bool get nameDisplayLocked; bool get customEmoji; bool get customStatus; bool get postPriority; bool get acknowledgements; int get maxPostSize; int? get maxFileSize; bool get typing; Duration get typingInterval; int? get maxNotificationsPerChannel; bool get imageProxy; bool get latex; bool get inlineLatex; int get minimumHashtagLength; int? get maxMarkdownNodes; bool get directMessagesRestricted; bool get archivedChannels; bool get fileSearch; bool get commandSuggestions;/// Whether the server runs plugins at all.
 bool get pluginsAllowed;/// Feature flags without their `FeatureFlag` prefix.
 Map<String, String> get featureFlags;/// Enabled webapp plugins by id, with their versions.
 Map<String, String> get plugins;
/// Create a copy of ServerFeatures
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerFeaturesCopyWith<ServerFeatures> get copyWith => _$ServerFeaturesCopyWithImpl<ServerFeatures>(this as ServerFeatures, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ServerFeatures;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerFeatures&&(identical(other.version, _this.version) || other.version == _this.version)&&(identical(other.collapsedThreads, _this.collapsedThreads) || other.collapsedThreads == _this.collapsedThreads)&&(identical(other.nameDisplay, _this.nameDisplay) || other.nameDisplay == _this.nameDisplay)&&(identical(other.nameDisplayLocked, _this.nameDisplayLocked) || other.nameDisplayLocked == _this.nameDisplayLocked)&&(identical(other.customEmoji, _this.customEmoji) || other.customEmoji == _this.customEmoji)&&(identical(other.customStatus, _this.customStatus) || other.customStatus == _this.customStatus)&&(identical(other.postPriority, _this.postPriority) || other.postPriority == _this.postPriority)&&(identical(other.acknowledgements, _this.acknowledgements) || other.acknowledgements == _this.acknowledgements)&&(identical(other.maxPostSize, _this.maxPostSize) || other.maxPostSize == _this.maxPostSize)&&(identical(other.maxFileSize, _this.maxFileSize) || other.maxFileSize == _this.maxFileSize)&&(identical(other.typing, _this.typing) || other.typing == _this.typing)&&(identical(other.typingInterval, _this.typingInterval) || other.typingInterval == _this.typingInterval)&&(identical(other.maxNotificationsPerChannel, _this.maxNotificationsPerChannel) || other.maxNotificationsPerChannel == _this.maxNotificationsPerChannel)&&(identical(other.imageProxy, _this.imageProxy) || other.imageProxy == _this.imageProxy)&&(identical(other.latex, _this.latex) || other.latex == _this.latex)&&(identical(other.inlineLatex, _this.inlineLatex) || other.inlineLatex == _this.inlineLatex)&&(identical(other.minimumHashtagLength, _this.minimumHashtagLength) || other.minimumHashtagLength == _this.minimumHashtagLength)&&(identical(other.maxMarkdownNodes, _this.maxMarkdownNodes) || other.maxMarkdownNodes == _this.maxMarkdownNodes)&&(identical(other.directMessagesRestricted, _this.directMessagesRestricted) || other.directMessagesRestricted == _this.directMessagesRestricted)&&(identical(other.archivedChannels, _this.archivedChannels) || other.archivedChannels == _this.archivedChannels)&&(identical(other.fileSearch, _this.fileSearch) || other.fileSearch == _this.fileSearch)&&(identical(other.commandSuggestions, _this.commandSuggestions) || other.commandSuggestions == _this.commandSuggestions)&&(identical(other.pluginsAllowed, _this.pluginsAllowed) || other.pluginsAllowed == _this.pluginsAllowed)&&const DeepCollectionEquality().equals(other.featureFlags, _this.featureFlags)&&const DeepCollectionEquality().equals(other.plugins, _this.plugins));
}


@override
int get hashCode {
  final _this = this as ServerFeatures;
  return Object.hashAll([runtimeType,_this.version,_this.collapsedThreads,_this.nameDisplay,_this.nameDisplayLocked,_this.customEmoji,_this.customStatus,_this.postPriority,_this.acknowledgements,_this.maxPostSize,_this.maxFileSize,_this.typing,_this.typingInterval,_this.maxNotificationsPerChannel,_this.imageProxy,_this.latex,_this.inlineLatex,_this.minimumHashtagLength,_this.maxMarkdownNodes,_this.directMessagesRestricted,_this.archivedChannels,_this.fileSearch,_this.commandSuggestions,_this.pluginsAllowed,const DeepCollectionEquality().hash(_this.featureFlags),const DeepCollectionEquality().hash(_this.plugins)]);
}

@override
String toString() {
  final _this = this as ServerFeatures;
  return 'ServerFeatures(version: ${_this.version}, collapsedThreads: ${_this.collapsedThreads}, nameDisplay: ${_this.nameDisplay}, nameDisplayLocked: ${_this.nameDisplayLocked}, customEmoji: ${_this.customEmoji}, customStatus: ${_this.customStatus}, postPriority: ${_this.postPriority}, acknowledgements: ${_this.acknowledgements}, maxPostSize: ${_this.maxPostSize}, maxFileSize: ${_this.maxFileSize}, typing: ${_this.typing}, typingInterval: ${_this.typingInterval}, maxNotificationsPerChannel: ${_this.maxNotificationsPerChannel}, imageProxy: ${_this.imageProxy}, latex: ${_this.latex}, inlineLatex: ${_this.inlineLatex}, minimumHashtagLength: ${_this.minimumHashtagLength}, maxMarkdownNodes: ${_this.maxMarkdownNodes}, directMessagesRestricted: ${_this.directMessagesRestricted}, archivedChannels: ${_this.archivedChannels}, fileSearch: ${_this.fileSearch}, commandSuggestions: ${_this.commandSuggestions}, pluginsAllowed: ${_this.pluginsAllowed}, featureFlags: ${_this.featureFlags}, plugins: ${_this.plugins})';
}


}

/// @nodoc
abstract mixin class $ServerFeaturesCopyWith<$Res>  {
  factory $ServerFeaturesCopyWith(ServerFeatures value, $Res Function(ServerFeatures) _then) = _$ServerFeaturesCopyWithImpl;
@useResult
$Res call({
 String version, String? collapsedThreads, String? nameDisplay, bool nameDisplayLocked, bool customEmoji, bool customStatus, bool postPriority, bool acknowledgements, int maxPostSize, int? maxFileSize, bool typing, Duration typingInterval, int? maxNotificationsPerChannel, bool imageProxy, bool latex, bool inlineLatex, int minimumHashtagLength, int? maxMarkdownNodes, bool directMessagesRestricted, bool archivedChannels, bool fileSearch, bool commandSuggestions, bool pluginsAllowed, Map<String, String> featureFlags, Map<String, String> plugins
});




}
/// @nodoc
class _$ServerFeaturesCopyWithImpl<$Res>
    implements $ServerFeaturesCopyWith<$Res> {
  _$ServerFeaturesCopyWithImpl(this._self, this._then);

  final ServerFeatures _self;
  final $Res Function(ServerFeatures) _then;

/// Create a copy of ServerFeatures
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? version = null,Object? collapsedThreads = freezed,Object? nameDisplay = freezed,Object? nameDisplayLocked = null,Object? customEmoji = null,Object? customStatus = null,Object? postPriority = null,Object? acknowledgements = null,Object? maxPostSize = null,Object? maxFileSize = freezed,Object? typing = null,Object? typingInterval = null,Object? maxNotificationsPerChannel = freezed,Object? imageProxy = null,Object? latex = null,Object? inlineLatex = null,Object? minimumHashtagLength = null,Object? maxMarkdownNodes = freezed,Object? directMessagesRestricted = null,Object? archivedChannels = null,Object? fileSearch = null,Object? commandSuggestions = null,Object? pluginsAllowed = null,Object? featureFlags = null,Object? plugins = null,}) {
  return _then(ServerFeatures(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,collapsedThreads: freezed == collapsedThreads ? _self.collapsedThreads : collapsedThreads // ignore: cast_nullable_to_non_nullable
as String?,nameDisplay: freezed == nameDisplay ? _self.nameDisplay : nameDisplay // ignore: cast_nullable_to_non_nullable
as String?,nameDisplayLocked: null == nameDisplayLocked ? _self.nameDisplayLocked : nameDisplayLocked // ignore: cast_nullable_to_non_nullable
as bool,customEmoji: null == customEmoji ? _self.customEmoji : customEmoji // ignore: cast_nullable_to_non_nullable
as bool,customStatus: null == customStatus ? _self.customStatus : customStatus // ignore: cast_nullable_to_non_nullable
as bool,postPriority: null == postPriority ? _self.postPriority : postPriority // ignore: cast_nullable_to_non_nullable
as bool,acknowledgements: null == acknowledgements ? _self.acknowledgements : acknowledgements // ignore: cast_nullable_to_non_nullable
as bool,maxPostSize: null == maxPostSize ? _self.maxPostSize : maxPostSize // ignore: cast_nullable_to_non_nullable
as int,maxFileSize: freezed == maxFileSize ? _self.maxFileSize : maxFileSize // ignore: cast_nullable_to_non_nullable
as int?,typing: null == typing ? _self.typing : typing // ignore: cast_nullable_to_non_nullable
as bool,typingInterval: null == typingInterval ? _self.typingInterval : typingInterval // ignore: cast_nullable_to_non_nullable
as Duration,maxNotificationsPerChannel: freezed == maxNotificationsPerChannel ? _self.maxNotificationsPerChannel : maxNotificationsPerChannel // ignore: cast_nullable_to_non_nullable
as int?,imageProxy: null == imageProxy ? _self.imageProxy : imageProxy // ignore: cast_nullable_to_non_nullable
as bool,latex: null == latex ? _self.latex : latex // ignore: cast_nullable_to_non_nullable
as bool,inlineLatex: null == inlineLatex ? _self.inlineLatex : inlineLatex // ignore: cast_nullable_to_non_nullable
as bool,minimumHashtagLength: null == minimumHashtagLength ? _self.minimumHashtagLength : minimumHashtagLength // ignore: cast_nullable_to_non_nullable
as int,maxMarkdownNodes: freezed == maxMarkdownNodes ? _self.maxMarkdownNodes : maxMarkdownNodes // ignore: cast_nullable_to_non_nullable
as int?,directMessagesRestricted: null == directMessagesRestricted ? _self.directMessagesRestricted : directMessagesRestricted // ignore: cast_nullable_to_non_nullable
as bool,archivedChannels: null == archivedChannels ? _self.archivedChannels : archivedChannels // ignore: cast_nullable_to_non_nullable
as bool,fileSearch: null == fileSearch ? _self.fileSearch : fileSearch // ignore: cast_nullable_to_non_nullable
as bool,commandSuggestions: null == commandSuggestions ? _self.commandSuggestions : commandSuggestions // ignore: cast_nullable_to_non_nullable
as bool,pluginsAllowed: null == pluginsAllowed ? _self.pluginsAllowed : pluginsAllowed // ignore: cast_nullable_to_non_nullable
as bool,featureFlags: null == featureFlags ? _self.featureFlags : featureFlags // ignore: cast_nullable_to_non_nullable
as Map<String, String>,plugins: null == plugins ? _self.plugins : plugins // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ServerFeatures].
extension ServerFeaturesPatterns on ServerFeatures {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ServerFeatures value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ServerFeatures() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ServerFeatures value)  $default,){
final _that = this;
switch (_that) {
case _ServerFeatures():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ServerFeatures value)?  $default,){
final _that = this;
switch (_that) {
case _ServerFeatures() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String version,  String? collapsedThreads,  String? nameDisplay,  bool nameDisplayLocked,  bool customEmoji,  bool customStatus,  bool postPriority,  bool acknowledgements,  int maxPostSize,  int? maxFileSize,  bool typing,  Duration typingInterval,  int? maxNotificationsPerChannel,  bool imageProxy,  bool latex,  bool inlineLatex,  int minimumHashtagLength,  int? maxMarkdownNodes,  bool directMessagesRestricted,  bool archivedChannels,  bool fileSearch,  bool commandSuggestions,  bool pluginsAllowed,  Map<String, String> featureFlags,  Map<String, String> plugins)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServerFeatures() when $default != null:
return $default(_that.version,_that.collapsedThreads,_that.nameDisplay,_that.nameDisplayLocked,_that.customEmoji,_that.customStatus,_that.postPriority,_that.acknowledgements,_that.maxPostSize,_that.maxFileSize,_that.typing,_that.typingInterval,_that.maxNotificationsPerChannel,_that.imageProxy,_that.latex,_that.inlineLatex,_that.minimumHashtagLength,_that.maxMarkdownNodes,_that.directMessagesRestricted,_that.archivedChannels,_that.fileSearch,_that.commandSuggestions,_that.pluginsAllowed,_that.featureFlags,_that.plugins);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String version,  String? collapsedThreads,  String? nameDisplay,  bool nameDisplayLocked,  bool customEmoji,  bool customStatus,  bool postPriority,  bool acknowledgements,  int maxPostSize,  int? maxFileSize,  bool typing,  Duration typingInterval,  int? maxNotificationsPerChannel,  bool imageProxy,  bool latex,  bool inlineLatex,  int minimumHashtagLength,  int? maxMarkdownNodes,  bool directMessagesRestricted,  bool archivedChannels,  bool fileSearch,  bool commandSuggestions,  bool pluginsAllowed,  Map<String, String> featureFlags,  Map<String, String> plugins)  $default,) {final _that = this;
switch (_that) {
case _ServerFeatures():
return $default(_that.version,_that.collapsedThreads,_that.nameDisplay,_that.nameDisplayLocked,_that.customEmoji,_that.customStatus,_that.postPriority,_that.acknowledgements,_that.maxPostSize,_that.maxFileSize,_that.typing,_that.typingInterval,_that.maxNotificationsPerChannel,_that.imageProxy,_that.latex,_that.inlineLatex,_that.minimumHashtagLength,_that.maxMarkdownNodes,_that.directMessagesRestricted,_that.archivedChannels,_that.fileSearch,_that.commandSuggestions,_that.pluginsAllowed,_that.featureFlags,_that.plugins);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String version,  String? collapsedThreads,  String? nameDisplay,  bool nameDisplayLocked,  bool customEmoji,  bool customStatus,  bool postPriority,  bool acknowledgements,  int maxPostSize,  int? maxFileSize,  bool typing,  Duration typingInterval,  int? maxNotificationsPerChannel,  bool imageProxy,  bool latex,  bool inlineLatex,  int minimumHashtagLength,  int? maxMarkdownNodes,  bool directMessagesRestricted,  bool archivedChannels,  bool fileSearch,  bool commandSuggestions,  bool pluginsAllowed,  Map<String, String> featureFlags,  Map<String, String> plugins)?  $default,) {final _that = this;
switch (_that) {
case _ServerFeatures() when $default != null:
return $default(_that.version,_that.collapsedThreads,_that.nameDisplay,_that.nameDisplayLocked,_that.customEmoji,_that.customStatus,_that.postPriority,_that.acknowledgements,_that.maxPostSize,_that.maxFileSize,_that.typing,_that.typingInterval,_that.maxNotificationsPerChannel,_that.imageProxy,_that.latex,_that.inlineLatex,_that.minimumHashtagLength,_that.maxMarkdownNodes,_that.directMessagesRestricted,_that.archivedChannels,_that.fileSearch,_that.commandSuggestions,_that.pluginsAllowed,_that.featureFlags,_that.plugins);case _:
  return null;

}
}

}

/// @nodoc


class _ServerFeatures extends ServerFeatures {
  const _ServerFeatures({this.version = '', this.collapsedThreads, this.nameDisplay, this.nameDisplayLocked = false, this.customEmoji = false, this.customStatus = false, this.postPriority = false, this.acknowledgements = false, this.maxPostSize = ServerFeatures.defaultMaxPostSize, this.maxFileSize, this.typing = true, this.typingInterval = ServerFeatures.defaultTypingInterval, this.maxNotificationsPerChannel, this.imageProxy = false, this.latex = false, this.inlineLatex = false, this.minimumHashtagLength = 3, this.maxMarkdownNodes, this.directMessagesRestricted = false, this.archivedChannels = true, this.fileSearch = true, this.commandSuggestions = true, this.pluginsAllowed = true,  Map<String, String> featureFlags = const {},  Map<String, String> plugins = const {}}): _featureFlags = featureFlags,_plugins = plugins,super._();
  

/// Such as `12.0.1`; empty when the server didn't say.
@override@JsonKey() final  String version;
/// `disabled`, `default_on`, `default_off` or `always_on`.
@override final  String? collapsedThreads;
@override final  String? nameDisplay;
@override@JsonKey() final  bool nameDisplayLocked;
@override@JsonKey() final  bool customEmoji;
@override@JsonKey() final  bool customStatus;
@override@JsonKey() final  bool postPriority;
@override@JsonKey() final  bool acknowledgements;
@override@JsonKey() final  int maxPostSize;
@override final  int? maxFileSize;
@override@JsonKey() final  bool typing;
@override@JsonKey() final  Duration typingInterval;
@override final  int? maxNotificationsPerChannel;
@override@JsonKey() final  bool imageProxy;
@override@JsonKey() final  bool latex;
@override@JsonKey() final  bool inlineLatex;
@override@JsonKey() final  int minimumHashtagLength;
@override final  int? maxMarkdownNodes;
@override@JsonKey() final  bool directMessagesRestricted;
@override@JsonKey() final  bool archivedChannels;
@override@JsonKey() final  bool fileSearch;
@override@JsonKey() final  bool commandSuggestions;
/// Whether the server runs plugins at all.
@override@JsonKey() final  bool pluginsAllowed;
/// Feature flags without their `FeatureFlag` prefix.
 final  Map<String, String> _featureFlags;
/// Feature flags without their `FeatureFlag` prefix.
@override@JsonKey() Map<String, String> get featureFlags {
  if (_featureFlags is EqualUnmodifiableMapView) return _featureFlags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_featureFlags);
}

/// Enabled webapp plugins by id, with their versions.
 final  Map<String, String> _plugins;
/// Enabled webapp plugins by id, with their versions.
@override@JsonKey() Map<String, String> get plugins {
  if (_plugins is EqualUnmodifiableMapView) return _plugins;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_plugins);
}


/// Create a copy of ServerFeatures
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServerFeaturesCopyWith<_ServerFeatures> get copyWith => __$ServerFeaturesCopyWithImpl<_ServerFeatures>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServerFeatures&&(identical(other.version, version) || other.version == version)&&(identical(other.collapsedThreads, collapsedThreads) || other.collapsedThreads == collapsedThreads)&&(identical(other.nameDisplay, nameDisplay) || other.nameDisplay == nameDisplay)&&(identical(other.nameDisplayLocked, nameDisplayLocked) || other.nameDisplayLocked == nameDisplayLocked)&&(identical(other.customEmoji, customEmoji) || other.customEmoji == customEmoji)&&(identical(other.customStatus, customStatus) || other.customStatus == customStatus)&&(identical(other.postPriority, postPriority) || other.postPriority == postPriority)&&(identical(other.acknowledgements, acknowledgements) || other.acknowledgements == acknowledgements)&&(identical(other.maxPostSize, maxPostSize) || other.maxPostSize == maxPostSize)&&(identical(other.maxFileSize, maxFileSize) || other.maxFileSize == maxFileSize)&&(identical(other.typing, typing) || other.typing == typing)&&(identical(other.typingInterval, typingInterval) || other.typingInterval == typingInterval)&&(identical(other.maxNotificationsPerChannel, maxNotificationsPerChannel) || other.maxNotificationsPerChannel == maxNotificationsPerChannel)&&(identical(other.imageProxy, imageProxy) || other.imageProxy == imageProxy)&&(identical(other.latex, latex) || other.latex == latex)&&(identical(other.inlineLatex, inlineLatex) || other.inlineLatex == inlineLatex)&&(identical(other.minimumHashtagLength, minimumHashtagLength) || other.minimumHashtagLength == minimumHashtagLength)&&(identical(other.maxMarkdownNodes, maxMarkdownNodes) || other.maxMarkdownNodes == maxMarkdownNodes)&&(identical(other.directMessagesRestricted, directMessagesRestricted) || other.directMessagesRestricted == directMessagesRestricted)&&(identical(other.archivedChannels, archivedChannels) || other.archivedChannels == archivedChannels)&&(identical(other.fileSearch, fileSearch) || other.fileSearch == fileSearch)&&(identical(other.commandSuggestions, commandSuggestions) || other.commandSuggestions == commandSuggestions)&&(identical(other.pluginsAllowed, pluginsAllowed) || other.pluginsAllowed == pluginsAllowed)&&const DeepCollectionEquality().equals(other.featureFlags, _featureFlags)&&const DeepCollectionEquality().equals(other.plugins, _plugins));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,version,collapsedThreads,nameDisplay,nameDisplayLocked,customEmoji,customStatus,postPriority,acknowledgements,maxPostSize,maxFileSize,typing,typingInterval,maxNotificationsPerChannel,imageProxy,latex,inlineLatex,minimumHashtagLength,maxMarkdownNodes,directMessagesRestricted,archivedChannels,fileSearch,commandSuggestions,pluginsAllowed,const DeepCollectionEquality().hash(_featureFlags),const DeepCollectionEquality().hash(_plugins)]);
}

@override
String toString() {
    return 'ServerFeatures(version: $version, collapsedThreads: $collapsedThreads, nameDisplay: $nameDisplay, nameDisplayLocked: $nameDisplayLocked, customEmoji: $customEmoji, customStatus: $customStatus, postPriority: $postPriority, acknowledgements: $acknowledgements, maxPostSize: $maxPostSize, maxFileSize: $maxFileSize, typing: $typing, typingInterval: $typingInterval, maxNotificationsPerChannel: $maxNotificationsPerChannel, imageProxy: $imageProxy, latex: $latex, inlineLatex: $inlineLatex, minimumHashtagLength: $minimumHashtagLength, maxMarkdownNodes: $maxMarkdownNodes, directMessagesRestricted: $directMessagesRestricted, archivedChannels: $archivedChannels, fileSearch: $fileSearch, commandSuggestions: $commandSuggestions, pluginsAllowed: $pluginsAllowed, featureFlags: $featureFlags, plugins: $plugins)';
}


}

/// @nodoc
abstract mixin class _$ServerFeaturesCopyWith<$Res> implements $ServerFeaturesCopyWith<$Res> {
  factory _$ServerFeaturesCopyWith(_ServerFeatures value, $Res Function(_ServerFeatures) _then) = __$ServerFeaturesCopyWithImpl;
@override @useResult
$Res call({
 String version, String? collapsedThreads, String? nameDisplay, bool nameDisplayLocked, bool customEmoji, bool customStatus, bool postPriority, bool acknowledgements, int maxPostSize, int? maxFileSize, bool typing, Duration typingInterval, int? maxNotificationsPerChannel, bool imageProxy, bool latex, bool inlineLatex, int minimumHashtagLength, int? maxMarkdownNodes, bool directMessagesRestricted, bool archivedChannels, bool fileSearch, bool commandSuggestions, bool pluginsAllowed, Map<String, String> featureFlags, Map<String, String> plugins
});




}
/// @nodoc
class __$ServerFeaturesCopyWithImpl<$Res>
    implements _$ServerFeaturesCopyWith<$Res> {
  __$ServerFeaturesCopyWithImpl(this._self, this._then);

  final _ServerFeatures _self;
  final $Res Function(_ServerFeatures) _then;

/// Create a copy of ServerFeatures
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,Object? collapsedThreads = freezed,Object? nameDisplay = freezed,Object? nameDisplayLocked = null,Object? customEmoji = null,Object? customStatus = null,Object? postPriority = null,Object? acknowledgements = null,Object? maxPostSize = null,Object? maxFileSize = freezed,Object? typing = null,Object? typingInterval = null,Object? maxNotificationsPerChannel = freezed,Object? imageProxy = null,Object? latex = null,Object? inlineLatex = null,Object? minimumHashtagLength = null,Object? maxMarkdownNodes = freezed,Object? directMessagesRestricted = null,Object? archivedChannels = null,Object? fileSearch = null,Object? commandSuggestions = null,Object? pluginsAllowed = null,Object? featureFlags = null,Object? plugins = null,}) {
  return _then(_ServerFeatures(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,collapsedThreads: freezed == collapsedThreads ? _self.collapsedThreads : collapsedThreads // ignore: cast_nullable_to_non_nullable
as String?,nameDisplay: freezed == nameDisplay ? _self.nameDisplay : nameDisplay // ignore: cast_nullable_to_non_nullable
as String?,nameDisplayLocked: null == nameDisplayLocked ? _self.nameDisplayLocked : nameDisplayLocked // ignore: cast_nullable_to_non_nullable
as bool,customEmoji: null == customEmoji ? _self.customEmoji : customEmoji // ignore: cast_nullable_to_non_nullable
as bool,customStatus: null == customStatus ? _self.customStatus : customStatus // ignore: cast_nullable_to_non_nullable
as bool,postPriority: null == postPriority ? _self.postPriority : postPriority // ignore: cast_nullable_to_non_nullable
as bool,acknowledgements: null == acknowledgements ? _self.acknowledgements : acknowledgements // ignore: cast_nullable_to_non_nullable
as bool,maxPostSize: null == maxPostSize ? _self.maxPostSize : maxPostSize // ignore: cast_nullable_to_non_nullable
as int,maxFileSize: freezed == maxFileSize ? _self.maxFileSize : maxFileSize // ignore: cast_nullable_to_non_nullable
as int?,typing: null == typing ? _self.typing : typing // ignore: cast_nullable_to_non_nullable
as bool,typingInterval: null == typingInterval ? _self.typingInterval : typingInterval // ignore: cast_nullable_to_non_nullable
as Duration,maxNotificationsPerChannel: freezed == maxNotificationsPerChannel ? _self.maxNotificationsPerChannel : maxNotificationsPerChannel // ignore: cast_nullable_to_non_nullable
as int?,imageProxy: null == imageProxy ? _self.imageProxy : imageProxy // ignore: cast_nullable_to_non_nullable
as bool,latex: null == latex ? _self.latex : latex // ignore: cast_nullable_to_non_nullable
as bool,inlineLatex: null == inlineLatex ? _self.inlineLatex : inlineLatex // ignore: cast_nullable_to_non_nullable
as bool,minimumHashtagLength: null == minimumHashtagLength ? _self.minimumHashtagLength : minimumHashtagLength // ignore: cast_nullable_to_non_nullable
as int,maxMarkdownNodes: freezed == maxMarkdownNodes ? _self.maxMarkdownNodes : maxMarkdownNodes // ignore: cast_nullable_to_non_nullable
as int?,directMessagesRestricted: null == directMessagesRestricted ? _self.directMessagesRestricted : directMessagesRestricted // ignore: cast_nullable_to_non_nullable
as bool,archivedChannels: null == archivedChannels ? _self.archivedChannels : archivedChannels // ignore: cast_nullable_to_non_nullable
as bool,fileSearch: null == fileSearch ? _self.fileSearch : fileSearch // ignore: cast_nullable_to_non_nullable
as bool,commandSuggestions: null == commandSuggestions ? _self.commandSuggestions : commandSuggestions // ignore: cast_nullable_to_non_nullable
as bool,pluginsAllowed: null == pluginsAllowed ? _self.pluginsAllowed : pluginsAllowed // ignore: cast_nullable_to_non_nullable
as bool,featureFlags: null == featureFlags ? _self._featureFlags : featureFlags // ignore: cast_nullable_to_non_nullable
as Map<String, String>,plugins: null == plugins ? _self._plugins : plugins // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

// dart format on
