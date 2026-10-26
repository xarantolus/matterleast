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
 String get version;/// The build the server reports; often the same as [version].
 String get buildNumber;/// `disabled`, `default_on`, `default_off` or `always_on`.
 String? get collapsedThreads; String? get nameDisplay; bool get nameDisplayLocked; bool get customEmoji; bool get customStatus; bool get postPriority; bool get acknowledgements; int get maxPostSize; int? get maxFileSize; bool get typing; Duration get typingInterval; int? get maxNotificationsPerChannel; bool get imageProxy; bool get latex; bool get inlineLatex; int get minimumHashtagLength; int? get maxMarkdownNodes; bool get directMessagesRestricted; bool get archivedChannels; bool get fileSearch; bool get commandSuggestions;/// Files can be attached to messages from this app.
 bool get fileUploads;/// Files can be saved, shared and opened in other apps; without it
/// they are only shown here.
 bool get fileDownloads; bool get linkPreviews;/// Links to messages show a card of the linked message.
 bool get permalinkPreviews;/// Integrations may post under another name or picture.
 bool get usernameOverride; bool get iconOverride; bool get crossTeamSearch;/// The system bot can remind the user of a message later.
 bool get postReminders;/// User groups (custom or synced from a directory) can be @mentioned;
/// each channel's permissions decide who may.
 bool get groupMentions;/// Channels can have a bar of bookmarked links and files.
 bool get bookmarks;/// People have custom profile attributes the server defines.
 bool get profileAttributes;/// How long after posting a message can be edited; null for always.
 Duration? get editTimeLimit;/// Ask before @all, @channel or @here notify a larger channel.
 bool get confirmChannelMentions;/// The default channel takes posts from admins only.
 bool get townSquareReadOnly;/// The server sends notification emails.
 bool get emailNotifications;/// People can set an automatic reply to direct messages.
 bool get automaticReplies;/// Messages can be scheduled to send later.
 bool get scheduledPosts;/// Drafts are kept on the server too, so other devices see them; the
/// user's own setting can still turn it off.
 bool get syncedDrafts;/// Messages can be sent that burn after the recipient read them.
 bool get burnOnRead;/// How long a revealed burn-on-read message stays.
 Duration get burnOnReadDuration;/// Fields that sign-in through LDAP or SAML fills in.
 Set<ProfileField> get ldapFields; Set<ProfileField> get samlFields;/// Whether the server runs plugins at all.
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerFeatures&&(identical(other.version, _this.version) || other.version == _this.version)&&(identical(other.buildNumber, _this.buildNumber) || other.buildNumber == _this.buildNumber)&&(identical(other.collapsedThreads, _this.collapsedThreads) || other.collapsedThreads == _this.collapsedThreads)&&(identical(other.nameDisplay, _this.nameDisplay) || other.nameDisplay == _this.nameDisplay)&&(identical(other.nameDisplayLocked, _this.nameDisplayLocked) || other.nameDisplayLocked == _this.nameDisplayLocked)&&(identical(other.customEmoji, _this.customEmoji) || other.customEmoji == _this.customEmoji)&&(identical(other.customStatus, _this.customStatus) || other.customStatus == _this.customStatus)&&(identical(other.postPriority, _this.postPriority) || other.postPriority == _this.postPriority)&&(identical(other.acknowledgements, _this.acknowledgements) || other.acknowledgements == _this.acknowledgements)&&(identical(other.maxPostSize, _this.maxPostSize) || other.maxPostSize == _this.maxPostSize)&&(identical(other.maxFileSize, _this.maxFileSize) || other.maxFileSize == _this.maxFileSize)&&(identical(other.typing, _this.typing) || other.typing == _this.typing)&&(identical(other.typingInterval, _this.typingInterval) || other.typingInterval == _this.typingInterval)&&(identical(other.maxNotificationsPerChannel, _this.maxNotificationsPerChannel) || other.maxNotificationsPerChannel == _this.maxNotificationsPerChannel)&&(identical(other.imageProxy, _this.imageProxy) || other.imageProxy == _this.imageProxy)&&(identical(other.latex, _this.latex) || other.latex == _this.latex)&&(identical(other.inlineLatex, _this.inlineLatex) || other.inlineLatex == _this.inlineLatex)&&(identical(other.minimumHashtagLength, _this.minimumHashtagLength) || other.minimumHashtagLength == _this.minimumHashtagLength)&&(identical(other.maxMarkdownNodes, _this.maxMarkdownNodes) || other.maxMarkdownNodes == _this.maxMarkdownNodes)&&(identical(other.directMessagesRestricted, _this.directMessagesRestricted) || other.directMessagesRestricted == _this.directMessagesRestricted)&&(identical(other.archivedChannels, _this.archivedChannels) || other.archivedChannels == _this.archivedChannels)&&(identical(other.fileSearch, _this.fileSearch) || other.fileSearch == _this.fileSearch)&&(identical(other.commandSuggestions, _this.commandSuggestions) || other.commandSuggestions == _this.commandSuggestions)&&(identical(other.fileUploads, _this.fileUploads) || other.fileUploads == _this.fileUploads)&&(identical(other.fileDownloads, _this.fileDownloads) || other.fileDownloads == _this.fileDownloads)&&(identical(other.linkPreviews, _this.linkPreviews) || other.linkPreviews == _this.linkPreviews)&&(identical(other.permalinkPreviews, _this.permalinkPreviews) || other.permalinkPreviews == _this.permalinkPreviews)&&(identical(other.usernameOverride, _this.usernameOverride) || other.usernameOverride == _this.usernameOverride)&&(identical(other.iconOverride, _this.iconOverride) || other.iconOverride == _this.iconOverride)&&(identical(other.crossTeamSearch, _this.crossTeamSearch) || other.crossTeamSearch == _this.crossTeamSearch)&&(identical(other.postReminders, _this.postReminders) || other.postReminders == _this.postReminders)&&(identical(other.groupMentions, _this.groupMentions) || other.groupMentions == _this.groupMentions)&&(identical(other.bookmarks, _this.bookmarks) || other.bookmarks == _this.bookmarks)&&(identical(other.profileAttributes, _this.profileAttributes) || other.profileAttributes == _this.profileAttributes)&&(identical(other.editTimeLimit, _this.editTimeLimit) || other.editTimeLimit == _this.editTimeLimit)&&(identical(other.confirmChannelMentions, _this.confirmChannelMentions) || other.confirmChannelMentions == _this.confirmChannelMentions)&&(identical(other.townSquareReadOnly, _this.townSquareReadOnly) || other.townSquareReadOnly == _this.townSquareReadOnly)&&(identical(other.emailNotifications, _this.emailNotifications) || other.emailNotifications == _this.emailNotifications)&&(identical(other.automaticReplies, _this.automaticReplies) || other.automaticReplies == _this.automaticReplies)&&(identical(other.scheduledPosts, _this.scheduledPosts) || other.scheduledPosts == _this.scheduledPosts)&&(identical(other.syncedDrafts, _this.syncedDrafts) || other.syncedDrafts == _this.syncedDrafts)&&(identical(other.burnOnRead, _this.burnOnRead) || other.burnOnRead == _this.burnOnRead)&&(identical(other.burnOnReadDuration, _this.burnOnReadDuration) || other.burnOnReadDuration == _this.burnOnReadDuration)&&const DeepCollectionEquality().equals(other.ldapFields, _this.ldapFields)&&const DeepCollectionEquality().equals(other.samlFields, _this.samlFields)&&(identical(other.pluginsAllowed, _this.pluginsAllowed) || other.pluginsAllowed == _this.pluginsAllowed)&&const DeepCollectionEquality().equals(other.featureFlags, _this.featureFlags)&&const DeepCollectionEquality().equals(other.plugins, _this.plugins));
}


@override
int get hashCode {
  final _this = this as ServerFeatures;
  return Object.hashAll([runtimeType,_this.version,_this.buildNumber,_this.collapsedThreads,_this.nameDisplay,_this.nameDisplayLocked,_this.customEmoji,_this.customStatus,_this.postPriority,_this.acknowledgements,_this.maxPostSize,_this.maxFileSize,_this.typing,_this.typingInterval,_this.maxNotificationsPerChannel,_this.imageProxy,_this.latex,_this.inlineLatex,_this.minimumHashtagLength,_this.maxMarkdownNodes,_this.directMessagesRestricted,_this.archivedChannels,_this.fileSearch,_this.commandSuggestions,_this.fileUploads,_this.fileDownloads,_this.linkPreviews,_this.permalinkPreviews,_this.usernameOverride,_this.iconOverride,_this.crossTeamSearch,_this.postReminders,_this.groupMentions,_this.bookmarks,_this.profileAttributes,_this.editTimeLimit,_this.confirmChannelMentions,_this.townSquareReadOnly,_this.emailNotifications,_this.automaticReplies,_this.scheduledPosts,_this.syncedDrafts,_this.burnOnRead,_this.burnOnReadDuration,const DeepCollectionEquality().hash(_this.ldapFields),const DeepCollectionEquality().hash(_this.samlFields),_this.pluginsAllowed,const DeepCollectionEquality().hash(_this.featureFlags),const DeepCollectionEquality().hash(_this.plugins)]);
}

@override
String toString() {
  final _this = this as ServerFeatures;
  return 'ServerFeatures(version: ${_this.version}, buildNumber: ${_this.buildNumber}, collapsedThreads: ${_this.collapsedThreads}, nameDisplay: ${_this.nameDisplay}, nameDisplayLocked: ${_this.nameDisplayLocked}, customEmoji: ${_this.customEmoji}, customStatus: ${_this.customStatus}, postPriority: ${_this.postPriority}, acknowledgements: ${_this.acknowledgements}, maxPostSize: ${_this.maxPostSize}, maxFileSize: ${_this.maxFileSize}, typing: ${_this.typing}, typingInterval: ${_this.typingInterval}, maxNotificationsPerChannel: ${_this.maxNotificationsPerChannel}, imageProxy: ${_this.imageProxy}, latex: ${_this.latex}, inlineLatex: ${_this.inlineLatex}, minimumHashtagLength: ${_this.minimumHashtagLength}, maxMarkdownNodes: ${_this.maxMarkdownNodes}, directMessagesRestricted: ${_this.directMessagesRestricted}, archivedChannels: ${_this.archivedChannels}, fileSearch: ${_this.fileSearch}, commandSuggestions: ${_this.commandSuggestions}, fileUploads: ${_this.fileUploads}, fileDownloads: ${_this.fileDownloads}, linkPreviews: ${_this.linkPreviews}, permalinkPreviews: ${_this.permalinkPreviews}, usernameOverride: ${_this.usernameOverride}, iconOverride: ${_this.iconOverride}, crossTeamSearch: ${_this.crossTeamSearch}, postReminders: ${_this.postReminders}, groupMentions: ${_this.groupMentions}, bookmarks: ${_this.bookmarks}, profileAttributes: ${_this.profileAttributes}, editTimeLimit: ${_this.editTimeLimit}, confirmChannelMentions: ${_this.confirmChannelMentions}, townSquareReadOnly: ${_this.townSquareReadOnly}, emailNotifications: ${_this.emailNotifications}, automaticReplies: ${_this.automaticReplies}, scheduledPosts: ${_this.scheduledPosts}, syncedDrafts: ${_this.syncedDrafts}, burnOnRead: ${_this.burnOnRead}, burnOnReadDuration: ${_this.burnOnReadDuration}, ldapFields: ${_this.ldapFields}, samlFields: ${_this.samlFields}, pluginsAllowed: ${_this.pluginsAllowed}, featureFlags: ${_this.featureFlags}, plugins: ${_this.plugins})';
}


}

/// @nodoc
abstract mixin class $ServerFeaturesCopyWith<$Res>  {
  factory $ServerFeaturesCopyWith(ServerFeatures value, $Res Function(ServerFeatures) _then) = _$ServerFeaturesCopyWithImpl;
@useResult
$Res call({
 String version, String buildNumber, String? collapsedThreads, String? nameDisplay, bool nameDisplayLocked, bool customEmoji, bool customStatus, bool postPriority, bool acknowledgements, int maxPostSize, int? maxFileSize, bool typing, Duration typingInterval, int? maxNotificationsPerChannel, bool imageProxy, bool latex, bool inlineLatex, int minimumHashtagLength, int? maxMarkdownNodes, bool directMessagesRestricted, bool archivedChannels, bool fileSearch, bool commandSuggestions, bool fileUploads, bool fileDownloads, bool linkPreviews, bool permalinkPreviews, bool usernameOverride, bool iconOverride, bool crossTeamSearch, bool postReminders, bool groupMentions, bool bookmarks, bool profileAttributes, Duration? editTimeLimit, bool confirmChannelMentions, bool townSquareReadOnly, bool emailNotifications, bool automaticReplies, bool scheduledPosts, bool syncedDrafts, bool burnOnRead, Duration burnOnReadDuration, Set<ProfileField> ldapFields, Set<ProfileField> samlFields, bool pluginsAllowed, Map<String, String> featureFlags, Map<String, String> plugins
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
@pragma('vm:prefer-inline') @override $Res call({Object? version = null,Object? buildNumber = null,Object? collapsedThreads = freezed,Object? nameDisplay = freezed,Object? nameDisplayLocked = null,Object? customEmoji = null,Object? customStatus = null,Object? postPriority = null,Object? acknowledgements = null,Object? maxPostSize = null,Object? maxFileSize = freezed,Object? typing = null,Object? typingInterval = null,Object? maxNotificationsPerChannel = freezed,Object? imageProxy = null,Object? latex = null,Object? inlineLatex = null,Object? minimumHashtagLength = null,Object? maxMarkdownNodes = freezed,Object? directMessagesRestricted = null,Object? archivedChannels = null,Object? fileSearch = null,Object? commandSuggestions = null,Object? fileUploads = null,Object? fileDownloads = null,Object? linkPreviews = null,Object? permalinkPreviews = null,Object? usernameOverride = null,Object? iconOverride = null,Object? crossTeamSearch = null,Object? postReminders = null,Object? groupMentions = null,Object? bookmarks = null,Object? profileAttributes = null,Object? editTimeLimit = freezed,Object? confirmChannelMentions = null,Object? townSquareReadOnly = null,Object? emailNotifications = null,Object? automaticReplies = null,Object? scheduledPosts = null,Object? syncedDrafts = null,Object? burnOnRead = null,Object? burnOnReadDuration = null,Object? ldapFields = null,Object? samlFields = null,Object? pluginsAllowed = null,Object? featureFlags = null,Object? plugins = null,}) {
  return _then(ServerFeatures(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,buildNumber: null == buildNumber ? _self.buildNumber : buildNumber // ignore: cast_nullable_to_non_nullable
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
as bool,fileUploads: null == fileUploads ? _self.fileUploads : fileUploads // ignore: cast_nullable_to_non_nullable
as bool,fileDownloads: null == fileDownloads ? _self.fileDownloads : fileDownloads // ignore: cast_nullable_to_non_nullable
as bool,linkPreviews: null == linkPreviews ? _self.linkPreviews : linkPreviews // ignore: cast_nullable_to_non_nullable
as bool,permalinkPreviews: null == permalinkPreviews ? _self.permalinkPreviews : permalinkPreviews // ignore: cast_nullable_to_non_nullable
as bool,usernameOverride: null == usernameOverride ? _self.usernameOverride : usernameOverride // ignore: cast_nullable_to_non_nullable
as bool,iconOverride: null == iconOverride ? _self.iconOverride : iconOverride // ignore: cast_nullable_to_non_nullable
as bool,crossTeamSearch: null == crossTeamSearch ? _self.crossTeamSearch : crossTeamSearch // ignore: cast_nullable_to_non_nullable
as bool,postReminders: null == postReminders ? _self.postReminders : postReminders // ignore: cast_nullable_to_non_nullable
as bool,groupMentions: null == groupMentions ? _self.groupMentions : groupMentions // ignore: cast_nullable_to_non_nullable
as bool,bookmarks: null == bookmarks ? _self.bookmarks : bookmarks // ignore: cast_nullable_to_non_nullable
as bool,profileAttributes: null == profileAttributes ? _self.profileAttributes : profileAttributes // ignore: cast_nullable_to_non_nullable
as bool,editTimeLimit: freezed == editTimeLimit ? _self.editTimeLimit : editTimeLimit // ignore: cast_nullable_to_non_nullable
as Duration?,confirmChannelMentions: null == confirmChannelMentions ? _self.confirmChannelMentions : confirmChannelMentions // ignore: cast_nullable_to_non_nullable
as bool,townSquareReadOnly: null == townSquareReadOnly ? _self.townSquareReadOnly : townSquareReadOnly // ignore: cast_nullable_to_non_nullable
as bool,emailNotifications: null == emailNotifications ? _self.emailNotifications : emailNotifications // ignore: cast_nullable_to_non_nullable
as bool,automaticReplies: null == automaticReplies ? _self.automaticReplies : automaticReplies // ignore: cast_nullable_to_non_nullable
as bool,scheduledPosts: null == scheduledPosts ? _self.scheduledPosts : scheduledPosts // ignore: cast_nullable_to_non_nullable
as bool,syncedDrafts: null == syncedDrafts ? _self.syncedDrafts : syncedDrafts // ignore: cast_nullable_to_non_nullable
as bool,burnOnRead: null == burnOnRead ? _self.burnOnRead : burnOnRead // ignore: cast_nullable_to_non_nullable
as bool,burnOnReadDuration: null == burnOnReadDuration ? _self.burnOnReadDuration : burnOnReadDuration // ignore: cast_nullable_to_non_nullable
as Duration,ldapFields: null == ldapFields ? _self.ldapFields : ldapFields // ignore: cast_nullable_to_non_nullable
as Set<ProfileField>,samlFields: null == samlFields ? _self.samlFields : samlFields // ignore: cast_nullable_to_non_nullable
as Set<ProfileField>,pluginsAllowed: null == pluginsAllowed ? _self.pluginsAllowed : pluginsAllowed // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String version,  String buildNumber,  String? collapsedThreads,  String? nameDisplay,  bool nameDisplayLocked,  bool customEmoji,  bool customStatus,  bool postPriority,  bool acknowledgements,  int maxPostSize,  int? maxFileSize,  bool typing,  Duration typingInterval,  int? maxNotificationsPerChannel,  bool imageProxy,  bool latex,  bool inlineLatex,  int minimumHashtagLength,  int? maxMarkdownNodes,  bool directMessagesRestricted,  bool archivedChannels,  bool fileSearch,  bool commandSuggestions,  bool fileUploads,  bool fileDownloads,  bool linkPreviews,  bool permalinkPreviews,  bool usernameOverride,  bool iconOverride,  bool crossTeamSearch,  bool postReminders,  bool groupMentions,  bool bookmarks,  bool profileAttributes,  Duration? editTimeLimit,  bool confirmChannelMentions,  bool townSquareReadOnly,  bool emailNotifications,  bool automaticReplies,  bool scheduledPosts,  bool syncedDrafts,  bool burnOnRead,  Duration burnOnReadDuration,  Set<ProfileField> ldapFields,  Set<ProfileField> samlFields,  bool pluginsAllowed,  Map<String, String> featureFlags,  Map<String, String> plugins)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServerFeatures() when $default != null:
return $default(_that.version,_that.buildNumber,_that.collapsedThreads,_that.nameDisplay,_that.nameDisplayLocked,_that.customEmoji,_that.customStatus,_that.postPriority,_that.acknowledgements,_that.maxPostSize,_that.maxFileSize,_that.typing,_that.typingInterval,_that.maxNotificationsPerChannel,_that.imageProxy,_that.latex,_that.inlineLatex,_that.minimumHashtagLength,_that.maxMarkdownNodes,_that.directMessagesRestricted,_that.archivedChannels,_that.fileSearch,_that.commandSuggestions,_that.fileUploads,_that.fileDownloads,_that.linkPreviews,_that.permalinkPreviews,_that.usernameOverride,_that.iconOverride,_that.crossTeamSearch,_that.postReminders,_that.groupMentions,_that.bookmarks,_that.profileAttributes,_that.editTimeLimit,_that.confirmChannelMentions,_that.townSquareReadOnly,_that.emailNotifications,_that.automaticReplies,_that.scheduledPosts,_that.syncedDrafts,_that.burnOnRead,_that.burnOnReadDuration,_that.ldapFields,_that.samlFields,_that.pluginsAllowed,_that.featureFlags,_that.plugins);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String version,  String buildNumber,  String? collapsedThreads,  String? nameDisplay,  bool nameDisplayLocked,  bool customEmoji,  bool customStatus,  bool postPriority,  bool acknowledgements,  int maxPostSize,  int? maxFileSize,  bool typing,  Duration typingInterval,  int? maxNotificationsPerChannel,  bool imageProxy,  bool latex,  bool inlineLatex,  int minimumHashtagLength,  int? maxMarkdownNodes,  bool directMessagesRestricted,  bool archivedChannels,  bool fileSearch,  bool commandSuggestions,  bool fileUploads,  bool fileDownloads,  bool linkPreviews,  bool permalinkPreviews,  bool usernameOverride,  bool iconOverride,  bool crossTeamSearch,  bool postReminders,  bool groupMentions,  bool bookmarks,  bool profileAttributes,  Duration? editTimeLimit,  bool confirmChannelMentions,  bool townSquareReadOnly,  bool emailNotifications,  bool automaticReplies,  bool scheduledPosts,  bool syncedDrafts,  bool burnOnRead,  Duration burnOnReadDuration,  Set<ProfileField> ldapFields,  Set<ProfileField> samlFields,  bool pluginsAllowed,  Map<String, String> featureFlags,  Map<String, String> plugins)  $default,) {final _that = this;
switch (_that) {
case _ServerFeatures():
return $default(_that.version,_that.buildNumber,_that.collapsedThreads,_that.nameDisplay,_that.nameDisplayLocked,_that.customEmoji,_that.customStatus,_that.postPriority,_that.acknowledgements,_that.maxPostSize,_that.maxFileSize,_that.typing,_that.typingInterval,_that.maxNotificationsPerChannel,_that.imageProxy,_that.latex,_that.inlineLatex,_that.minimumHashtagLength,_that.maxMarkdownNodes,_that.directMessagesRestricted,_that.archivedChannels,_that.fileSearch,_that.commandSuggestions,_that.fileUploads,_that.fileDownloads,_that.linkPreviews,_that.permalinkPreviews,_that.usernameOverride,_that.iconOverride,_that.crossTeamSearch,_that.postReminders,_that.groupMentions,_that.bookmarks,_that.profileAttributes,_that.editTimeLimit,_that.confirmChannelMentions,_that.townSquareReadOnly,_that.emailNotifications,_that.automaticReplies,_that.scheduledPosts,_that.syncedDrafts,_that.burnOnRead,_that.burnOnReadDuration,_that.ldapFields,_that.samlFields,_that.pluginsAllowed,_that.featureFlags,_that.plugins);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String version,  String buildNumber,  String? collapsedThreads,  String? nameDisplay,  bool nameDisplayLocked,  bool customEmoji,  bool customStatus,  bool postPriority,  bool acknowledgements,  int maxPostSize,  int? maxFileSize,  bool typing,  Duration typingInterval,  int? maxNotificationsPerChannel,  bool imageProxy,  bool latex,  bool inlineLatex,  int minimumHashtagLength,  int? maxMarkdownNodes,  bool directMessagesRestricted,  bool archivedChannels,  bool fileSearch,  bool commandSuggestions,  bool fileUploads,  bool fileDownloads,  bool linkPreviews,  bool permalinkPreviews,  bool usernameOverride,  bool iconOverride,  bool crossTeamSearch,  bool postReminders,  bool groupMentions,  bool bookmarks,  bool profileAttributes,  Duration? editTimeLimit,  bool confirmChannelMentions,  bool townSquareReadOnly,  bool emailNotifications,  bool automaticReplies,  bool scheduledPosts,  bool syncedDrafts,  bool burnOnRead,  Duration burnOnReadDuration,  Set<ProfileField> ldapFields,  Set<ProfileField> samlFields,  bool pluginsAllowed,  Map<String, String> featureFlags,  Map<String, String> plugins)?  $default,) {final _that = this;
switch (_that) {
case _ServerFeatures() when $default != null:
return $default(_that.version,_that.buildNumber,_that.collapsedThreads,_that.nameDisplay,_that.nameDisplayLocked,_that.customEmoji,_that.customStatus,_that.postPriority,_that.acknowledgements,_that.maxPostSize,_that.maxFileSize,_that.typing,_that.typingInterval,_that.maxNotificationsPerChannel,_that.imageProxy,_that.latex,_that.inlineLatex,_that.minimumHashtagLength,_that.maxMarkdownNodes,_that.directMessagesRestricted,_that.archivedChannels,_that.fileSearch,_that.commandSuggestions,_that.fileUploads,_that.fileDownloads,_that.linkPreviews,_that.permalinkPreviews,_that.usernameOverride,_that.iconOverride,_that.crossTeamSearch,_that.postReminders,_that.groupMentions,_that.bookmarks,_that.profileAttributes,_that.editTimeLimit,_that.confirmChannelMentions,_that.townSquareReadOnly,_that.emailNotifications,_that.automaticReplies,_that.scheduledPosts,_that.syncedDrafts,_that.burnOnRead,_that.burnOnReadDuration,_that.ldapFields,_that.samlFields,_that.pluginsAllowed,_that.featureFlags,_that.plugins);case _:
  return null;

}
}

}

/// @nodoc


class _ServerFeatures extends ServerFeatures {
  const _ServerFeatures({this.version = '', this.buildNumber = '', this.collapsedThreads, this.nameDisplay, this.nameDisplayLocked = false, this.customEmoji = false, this.customStatus = false, this.postPriority = false, this.acknowledgements = false, this.maxPostSize = ServerFeatures.defaultMaxPostSize, this.maxFileSize, this.typing = true, this.typingInterval = ServerFeatures.defaultTypingInterval, this.maxNotificationsPerChannel, this.imageProxy = false, this.latex = false, this.inlineLatex = false, this.minimumHashtagLength = 3, this.maxMarkdownNodes, this.directMessagesRestricted = false, this.archivedChannels = true, this.fileSearch = true, this.commandSuggestions = true, this.fileUploads = true, this.fileDownloads = true, this.linkPreviews = true, this.permalinkPreviews = false, this.usernameOverride = false, this.iconOverride = false, this.crossTeamSearch = false, this.postReminders = false, this.groupMentions = false, this.bookmarks = false, this.profileAttributes = false, this.editTimeLimit, this.confirmChannelMentions = false, this.townSquareReadOnly = false, this.emailNotifications = false, this.automaticReplies = false, this.scheduledPosts = false, this.syncedDrafts = false, this.burnOnRead = false, this.burnOnReadDuration = ServerFeatures.defaultBurnOnReadDuration,  Set<ProfileField> ldapFields = const {},  Set<ProfileField> samlFields = const {}, this.pluginsAllowed = true,  Map<String, String> featureFlags = const {},  Map<String, String> plugins = const {}}): _ldapFields = ldapFields,_samlFields = samlFields,_featureFlags = featureFlags,_plugins = plugins,super._();
  

/// Such as `12.0.1`; empty when the server didn't say.
@override@JsonKey() final  String version;
/// The build the server reports; often the same as [version].
@override@JsonKey() final  String buildNumber;
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
/// Files can be attached to messages from this app.
@override@JsonKey() final  bool fileUploads;
/// Files can be saved, shared and opened in other apps; without it
/// they are only shown here.
@override@JsonKey() final  bool fileDownloads;
@override@JsonKey() final  bool linkPreviews;
/// Links to messages show a card of the linked message.
@override@JsonKey() final  bool permalinkPreviews;
/// Integrations may post under another name or picture.
@override@JsonKey() final  bool usernameOverride;
@override@JsonKey() final  bool iconOverride;
@override@JsonKey() final  bool crossTeamSearch;
/// The system bot can remind the user of a message later.
@override@JsonKey() final  bool postReminders;
/// User groups (custom or synced from a directory) can be @mentioned;
/// each channel's permissions decide who may.
@override@JsonKey() final  bool groupMentions;
/// Channels can have a bar of bookmarked links and files.
@override@JsonKey() final  bool bookmarks;
/// People have custom profile attributes the server defines.
@override@JsonKey() final  bool profileAttributes;
/// How long after posting a message can be edited; null for always.
@override final  Duration? editTimeLimit;
/// Ask before @all, @channel or @here notify a larger channel.
@override@JsonKey() final  bool confirmChannelMentions;
/// The default channel takes posts from admins only.
@override@JsonKey() final  bool townSquareReadOnly;
/// The server sends notification emails.
@override@JsonKey() final  bool emailNotifications;
/// People can set an automatic reply to direct messages.
@override@JsonKey() final  bool automaticReplies;
/// Messages can be scheduled to send later.
@override@JsonKey() final  bool scheduledPosts;
/// Drafts are kept on the server too, so other devices see them; the
/// user's own setting can still turn it off.
@override@JsonKey() final  bool syncedDrafts;
/// Messages can be sent that burn after the recipient read them.
@override@JsonKey() final  bool burnOnRead;
/// How long a revealed burn-on-read message stays.
@override@JsonKey() final  Duration burnOnReadDuration;
/// Fields that sign-in through LDAP or SAML fills in.
 final  Set<ProfileField> _ldapFields;
/// Fields that sign-in through LDAP or SAML fills in.
@override@JsonKey() Set<ProfileField> get ldapFields {
  if (_ldapFields is EqualUnmodifiableSetView) return _ldapFields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_ldapFields);
}

 final  Set<ProfileField> _samlFields;
@override@JsonKey() Set<ProfileField> get samlFields {
  if (_samlFields is EqualUnmodifiableSetView) return _samlFields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_samlFields);
}

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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServerFeatures&&(identical(other.version, version) || other.version == version)&&(identical(other.buildNumber, buildNumber) || other.buildNumber == buildNumber)&&(identical(other.collapsedThreads, collapsedThreads) || other.collapsedThreads == collapsedThreads)&&(identical(other.nameDisplay, nameDisplay) || other.nameDisplay == nameDisplay)&&(identical(other.nameDisplayLocked, nameDisplayLocked) || other.nameDisplayLocked == nameDisplayLocked)&&(identical(other.customEmoji, customEmoji) || other.customEmoji == customEmoji)&&(identical(other.customStatus, customStatus) || other.customStatus == customStatus)&&(identical(other.postPriority, postPriority) || other.postPriority == postPriority)&&(identical(other.acknowledgements, acknowledgements) || other.acknowledgements == acknowledgements)&&(identical(other.maxPostSize, maxPostSize) || other.maxPostSize == maxPostSize)&&(identical(other.maxFileSize, maxFileSize) || other.maxFileSize == maxFileSize)&&(identical(other.typing, typing) || other.typing == typing)&&(identical(other.typingInterval, typingInterval) || other.typingInterval == typingInterval)&&(identical(other.maxNotificationsPerChannel, maxNotificationsPerChannel) || other.maxNotificationsPerChannel == maxNotificationsPerChannel)&&(identical(other.imageProxy, imageProxy) || other.imageProxy == imageProxy)&&(identical(other.latex, latex) || other.latex == latex)&&(identical(other.inlineLatex, inlineLatex) || other.inlineLatex == inlineLatex)&&(identical(other.minimumHashtagLength, minimumHashtagLength) || other.minimumHashtagLength == minimumHashtagLength)&&(identical(other.maxMarkdownNodes, maxMarkdownNodes) || other.maxMarkdownNodes == maxMarkdownNodes)&&(identical(other.directMessagesRestricted, directMessagesRestricted) || other.directMessagesRestricted == directMessagesRestricted)&&(identical(other.archivedChannels, archivedChannels) || other.archivedChannels == archivedChannels)&&(identical(other.fileSearch, fileSearch) || other.fileSearch == fileSearch)&&(identical(other.commandSuggestions, commandSuggestions) || other.commandSuggestions == commandSuggestions)&&(identical(other.fileUploads, fileUploads) || other.fileUploads == fileUploads)&&(identical(other.fileDownloads, fileDownloads) || other.fileDownloads == fileDownloads)&&(identical(other.linkPreviews, linkPreviews) || other.linkPreviews == linkPreviews)&&(identical(other.permalinkPreviews, permalinkPreviews) || other.permalinkPreviews == permalinkPreviews)&&(identical(other.usernameOverride, usernameOverride) || other.usernameOverride == usernameOverride)&&(identical(other.iconOverride, iconOverride) || other.iconOverride == iconOverride)&&(identical(other.crossTeamSearch, crossTeamSearch) || other.crossTeamSearch == crossTeamSearch)&&(identical(other.postReminders, postReminders) || other.postReminders == postReminders)&&(identical(other.groupMentions, groupMentions) || other.groupMentions == groupMentions)&&(identical(other.bookmarks, bookmarks) || other.bookmarks == bookmarks)&&(identical(other.profileAttributes, profileAttributes) || other.profileAttributes == profileAttributes)&&(identical(other.editTimeLimit, editTimeLimit) || other.editTimeLimit == editTimeLimit)&&(identical(other.confirmChannelMentions, confirmChannelMentions) || other.confirmChannelMentions == confirmChannelMentions)&&(identical(other.townSquareReadOnly, townSquareReadOnly) || other.townSquareReadOnly == townSquareReadOnly)&&(identical(other.emailNotifications, emailNotifications) || other.emailNotifications == emailNotifications)&&(identical(other.automaticReplies, automaticReplies) || other.automaticReplies == automaticReplies)&&(identical(other.scheduledPosts, scheduledPosts) || other.scheduledPosts == scheduledPosts)&&(identical(other.syncedDrafts, syncedDrafts) || other.syncedDrafts == syncedDrafts)&&(identical(other.burnOnRead, burnOnRead) || other.burnOnRead == burnOnRead)&&(identical(other.burnOnReadDuration, burnOnReadDuration) || other.burnOnReadDuration == burnOnReadDuration)&&const DeepCollectionEquality().equals(other.ldapFields, _ldapFields)&&const DeepCollectionEquality().equals(other.samlFields, _samlFields)&&(identical(other.pluginsAllowed, pluginsAllowed) || other.pluginsAllowed == pluginsAllowed)&&const DeepCollectionEquality().equals(other.featureFlags, _featureFlags)&&const DeepCollectionEquality().equals(other.plugins, _plugins));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,version,buildNumber,collapsedThreads,nameDisplay,nameDisplayLocked,customEmoji,customStatus,postPriority,acknowledgements,maxPostSize,maxFileSize,typing,typingInterval,maxNotificationsPerChannel,imageProxy,latex,inlineLatex,minimumHashtagLength,maxMarkdownNodes,directMessagesRestricted,archivedChannels,fileSearch,commandSuggestions,fileUploads,fileDownloads,linkPreviews,permalinkPreviews,usernameOverride,iconOverride,crossTeamSearch,postReminders,groupMentions,bookmarks,profileAttributes,editTimeLimit,confirmChannelMentions,townSquareReadOnly,emailNotifications,automaticReplies,scheduledPosts,syncedDrafts,burnOnRead,burnOnReadDuration,const DeepCollectionEquality().hash(_ldapFields),const DeepCollectionEquality().hash(_samlFields),pluginsAllowed,const DeepCollectionEquality().hash(_featureFlags),const DeepCollectionEquality().hash(_plugins)]);
}

@override
String toString() {
    return 'ServerFeatures(version: $version, buildNumber: $buildNumber, collapsedThreads: $collapsedThreads, nameDisplay: $nameDisplay, nameDisplayLocked: $nameDisplayLocked, customEmoji: $customEmoji, customStatus: $customStatus, postPriority: $postPriority, acknowledgements: $acknowledgements, maxPostSize: $maxPostSize, maxFileSize: $maxFileSize, typing: $typing, typingInterval: $typingInterval, maxNotificationsPerChannel: $maxNotificationsPerChannel, imageProxy: $imageProxy, latex: $latex, inlineLatex: $inlineLatex, minimumHashtagLength: $minimumHashtagLength, maxMarkdownNodes: $maxMarkdownNodes, directMessagesRestricted: $directMessagesRestricted, archivedChannels: $archivedChannels, fileSearch: $fileSearch, commandSuggestions: $commandSuggestions, fileUploads: $fileUploads, fileDownloads: $fileDownloads, linkPreviews: $linkPreviews, permalinkPreviews: $permalinkPreviews, usernameOverride: $usernameOverride, iconOverride: $iconOverride, crossTeamSearch: $crossTeamSearch, postReminders: $postReminders, groupMentions: $groupMentions, bookmarks: $bookmarks, profileAttributes: $profileAttributes, editTimeLimit: $editTimeLimit, confirmChannelMentions: $confirmChannelMentions, townSquareReadOnly: $townSquareReadOnly, emailNotifications: $emailNotifications, automaticReplies: $automaticReplies, scheduledPosts: $scheduledPosts, syncedDrafts: $syncedDrafts, burnOnRead: $burnOnRead, burnOnReadDuration: $burnOnReadDuration, ldapFields: $ldapFields, samlFields: $samlFields, pluginsAllowed: $pluginsAllowed, featureFlags: $featureFlags, plugins: $plugins)';
}


}

/// @nodoc
abstract mixin class _$ServerFeaturesCopyWith<$Res> implements $ServerFeaturesCopyWith<$Res> {
  factory _$ServerFeaturesCopyWith(_ServerFeatures value, $Res Function(_ServerFeatures) _then) = __$ServerFeaturesCopyWithImpl;
@override @useResult
$Res call({
 String version, String buildNumber, String? collapsedThreads, String? nameDisplay, bool nameDisplayLocked, bool customEmoji, bool customStatus, bool postPriority, bool acknowledgements, int maxPostSize, int? maxFileSize, bool typing, Duration typingInterval, int? maxNotificationsPerChannel, bool imageProxy, bool latex, bool inlineLatex, int minimumHashtagLength, int? maxMarkdownNodes, bool directMessagesRestricted, bool archivedChannels, bool fileSearch, bool commandSuggestions, bool fileUploads, bool fileDownloads, bool linkPreviews, bool permalinkPreviews, bool usernameOverride, bool iconOverride, bool crossTeamSearch, bool postReminders, bool groupMentions, bool bookmarks, bool profileAttributes, Duration? editTimeLimit, bool confirmChannelMentions, bool townSquareReadOnly, bool emailNotifications, bool automaticReplies, bool scheduledPosts, bool syncedDrafts, bool burnOnRead, Duration burnOnReadDuration, Set<ProfileField> ldapFields, Set<ProfileField> samlFields, bool pluginsAllowed, Map<String, String> featureFlags, Map<String, String> plugins
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
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,Object? buildNumber = null,Object? collapsedThreads = freezed,Object? nameDisplay = freezed,Object? nameDisplayLocked = null,Object? customEmoji = null,Object? customStatus = null,Object? postPriority = null,Object? acknowledgements = null,Object? maxPostSize = null,Object? maxFileSize = freezed,Object? typing = null,Object? typingInterval = null,Object? maxNotificationsPerChannel = freezed,Object? imageProxy = null,Object? latex = null,Object? inlineLatex = null,Object? minimumHashtagLength = null,Object? maxMarkdownNodes = freezed,Object? directMessagesRestricted = null,Object? archivedChannels = null,Object? fileSearch = null,Object? commandSuggestions = null,Object? fileUploads = null,Object? fileDownloads = null,Object? linkPreviews = null,Object? permalinkPreviews = null,Object? usernameOverride = null,Object? iconOverride = null,Object? crossTeamSearch = null,Object? postReminders = null,Object? groupMentions = null,Object? bookmarks = null,Object? profileAttributes = null,Object? editTimeLimit = freezed,Object? confirmChannelMentions = null,Object? townSquareReadOnly = null,Object? emailNotifications = null,Object? automaticReplies = null,Object? scheduledPosts = null,Object? syncedDrafts = null,Object? burnOnRead = null,Object? burnOnReadDuration = null,Object? ldapFields = null,Object? samlFields = null,Object? pluginsAllowed = null,Object? featureFlags = null,Object? plugins = null,}) {
  return _then(_ServerFeatures(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,buildNumber: null == buildNumber ? _self.buildNumber : buildNumber // ignore: cast_nullable_to_non_nullable
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
as bool,fileUploads: null == fileUploads ? _self.fileUploads : fileUploads // ignore: cast_nullable_to_non_nullable
as bool,fileDownloads: null == fileDownloads ? _self.fileDownloads : fileDownloads // ignore: cast_nullable_to_non_nullable
as bool,linkPreviews: null == linkPreviews ? _self.linkPreviews : linkPreviews // ignore: cast_nullable_to_non_nullable
as bool,permalinkPreviews: null == permalinkPreviews ? _self.permalinkPreviews : permalinkPreviews // ignore: cast_nullable_to_non_nullable
as bool,usernameOverride: null == usernameOverride ? _self.usernameOverride : usernameOverride // ignore: cast_nullable_to_non_nullable
as bool,iconOverride: null == iconOverride ? _self.iconOverride : iconOverride // ignore: cast_nullable_to_non_nullable
as bool,crossTeamSearch: null == crossTeamSearch ? _self.crossTeamSearch : crossTeamSearch // ignore: cast_nullable_to_non_nullable
as bool,postReminders: null == postReminders ? _self.postReminders : postReminders // ignore: cast_nullable_to_non_nullable
as bool,groupMentions: null == groupMentions ? _self.groupMentions : groupMentions // ignore: cast_nullable_to_non_nullable
as bool,bookmarks: null == bookmarks ? _self.bookmarks : bookmarks // ignore: cast_nullable_to_non_nullable
as bool,profileAttributes: null == profileAttributes ? _self.profileAttributes : profileAttributes // ignore: cast_nullable_to_non_nullable
as bool,editTimeLimit: freezed == editTimeLimit ? _self.editTimeLimit : editTimeLimit // ignore: cast_nullable_to_non_nullable
as Duration?,confirmChannelMentions: null == confirmChannelMentions ? _self.confirmChannelMentions : confirmChannelMentions // ignore: cast_nullable_to_non_nullable
as bool,townSquareReadOnly: null == townSquareReadOnly ? _self.townSquareReadOnly : townSquareReadOnly // ignore: cast_nullable_to_non_nullable
as bool,emailNotifications: null == emailNotifications ? _self.emailNotifications : emailNotifications // ignore: cast_nullable_to_non_nullable
as bool,automaticReplies: null == automaticReplies ? _self.automaticReplies : automaticReplies // ignore: cast_nullable_to_non_nullable
as bool,scheduledPosts: null == scheduledPosts ? _self.scheduledPosts : scheduledPosts // ignore: cast_nullable_to_non_nullable
as bool,syncedDrafts: null == syncedDrafts ? _self.syncedDrafts : syncedDrafts // ignore: cast_nullable_to_non_nullable
as bool,burnOnRead: null == burnOnRead ? _self.burnOnRead : burnOnRead // ignore: cast_nullable_to_non_nullable
as bool,burnOnReadDuration: null == burnOnReadDuration ? _self.burnOnReadDuration : burnOnReadDuration // ignore: cast_nullable_to_non_nullable
as Duration,ldapFields: null == ldapFields ? _self._ldapFields : ldapFields // ignore: cast_nullable_to_non_nullable
as Set<ProfileField>,samlFields: null == samlFields ? _self._samlFields : samlFields // ignore: cast_nullable_to_non_nullable
as Set<ProfileField>,pluginsAllowed: null == pluginsAllowed ? _self.pluginsAllowed : pluginsAllowed // ignore: cast_nullable_to_non_nullable
as bool,featureFlags: null == featureFlags ? _self._featureFlags : featureFlags // ignore: cast_nullable_to_non_nullable
as Map<String, String>,plugins: null == plugins ? _self._plugins : plugins // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

// dart format on
