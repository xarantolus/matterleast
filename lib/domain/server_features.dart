import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/api/json/client_config.dart';

part 'server_features.freezed.dart';

/// Optional capabilities the server can lack even when its config says
/// otherwise; an answer that the endpoint is unavailable turns one off for
/// the rest of the session.
enum OptionalFeature {
  customEmoji,
  customStatus,
  acknowledgements,
  fileSearch,
  commandSuggestions,
  fileUploads,
  postReminders,
  groupMentions,
  scheduledPosts,
  syncedDrafts,
  burnOnRead,
}

/// Profile fields a directory (LDAP or SAML) can fill in, which the user
/// then can't change.
enum ProfileField { firstName, lastName, nickname, position, picture }

/// What one server offers, from its client config, licence, version,
/// feature flags and plugins. The one place the app asks.
@freezed
abstract class ServerFeatures with _$ServerFeatures {
  const factory ServerFeatures({
    /// Such as `12.0.1`; empty when the server didn't say.
    @Default('') String version,

    /// `disabled`, `default_on`, `default_off` or `always_on`.
    String? collapsedThreads,
    String? nameDisplay,
    @Default(false) bool nameDisplayLocked,
    @Default(false) bool customEmoji,
    @Default(false) bool customStatus,
    @Default(false) bool postPriority,
    @Default(false) bool acknowledgements,
    @Default(ServerFeatures.defaultMaxPostSize) int maxPostSize,
    int? maxFileSize,
    @Default(true) bool typing,
    @Default(ServerFeatures.defaultTypingInterval) Duration typingInterval,
    int? maxNotificationsPerChannel,
    @Default(false) bool imageProxy,
    @Default(false) bool latex,
    @Default(false) bool inlineLatex,
    @Default(3) int minimumHashtagLength,
    int? maxMarkdownNodes,
    @Default(false) bool directMessagesRestricted,
    @Default(true) bool archivedChannels,
    @Default(true) bool fileSearch,
    @Default(true) bool commandSuggestions,

    /// Files can be attached to messages from this app.
    @Default(true) bool fileUploads,

    /// Files can be saved, shared and opened in other apps; without it
    /// they are only shown here.
    @Default(true) bool fileDownloads,
    @Default(true) bool linkPreviews,

    /// Links to messages show a card of the linked message.
    @Default(false) bool permalinkPreviews,

    /// Integrations may post under another name or picture.
    @Default(false) bool usernameOverride,
    @Default(false) bool iconOverride,
    @Default(false) bool crossTeamSearch,

    /// The system bot can remind the user of a message later.
    @Default(false) bool postReminders,

    /// User groups (custom or synced from a directory) can be @mentioned;
    /// each channel's permissions decide who may.
    @Default(false) bool groupMentions,

    /// How long after posting a message can be edited; null for always.
    Duration? editTimeLimit,

    /// Ask before @all, @channel or @here notify a larger channel.
    @Default(false) bool confirmChannelMentions,

    /// The default channel takes posts from admins only.
    @Default(false) bool townSquareReadOnly,

    /// Messages can be scheduled to send later.
    @Default(false) bool scheduledPosts,

    /// Drafts are kept on the server too, so other devices see them; the
    /// user's own setting can still turn it off.
    @Default(false) bool syncedDrafts,

    /// Messages can be sent that burn after the recipient read them.
    @Default(false) bool burnOnRead,

    /// How long a revealed burn-on-read message stays.
    @Default(ServerFeatures.defaultBurnOnReadDuration)
    Duration burnOnReadDuration,

    /// Fields that sign-in through LDAP or SAML fills in.
    @Default({}) Set<ProfileField> ldapFields,
    @Default({}) Set<ProfileField> samlFields,

    /// Whether the server runs plugins at all.
    @Default(true) bool pluginsAllowed,

    /// Feature flags without their `FeatureFlag` prefix.
    @Default({}) Map<String, String> featureFlags,

    /// Enabled webapp plugins by id, with their versions.
    @Default({}) Map<String, String> plugins,
  }) = _ServerFeatures;

  const ServerFeatures._();

  /// What the client may assume before the server has answered.
  static const defaultMaxPostSize = 4000;
  static const defaultTypingInterval = Duration(seconds: 5);
  static const defaultBurnOnReadDuration = Duration(minutes: 10);

  /// Whether the server runs [major].[minor].[patch] or newer; false when
  /// the version is unknown.
  bool atLeast(int major, int minor, [int patch = 0]) =>
      (compareVersions(version, (major, minor, patch)) ?? -1) >= 0;

  /// A feature flag that later versions removed because the feature is
  /// always on from then: on from [removedIn], else as the flag says.
  bool flag(String name, {(int, int, int)? removedIn}) {
    if (removedIn case (final major, final minor, final patch)
        when atLeast(major, minor, patch)) {
      return true;
    }
    return featureFlags[name] == 'true';
  }

  /// Whether the plugin [id] is enabled, at [minVersion] or newer if given.
  bool hasPlugin(String id, {(int, int, int)? minVersion}) {
    final version = plugins[id];
    if (version == null) return false;
    if (minVersion == null) return true;
    return (compareVersions(version, minVersion) ?? -1) >= 0;
  }
}

/// A webapp plugin as `GET /plugins/webapp` lists it.
typedef PluginVersion = ({String id, String version});

/// Pure: the features of a server from what it reported, minus those that
/// answered as unavailable this session.
ServerFeatures serverFeatures({
  required ClientConfig config,
  required ClientLicense license,
  List<PluginVersion> plugins = const [],
  Set<OptionalFeature> turnedOff = const {},
}) {
  bool on(OptionalFeature f, bool? value) =>
      value == true && !turnedOff.contains(f);
  final licensed = license.isLicensed == true;
  final compliance = licensed && license.compliance == true;
  final advanced =
      licensed &&
      config.buildEnterpriseReady != false &&
      const {'advanced', 'entry'}.contains(license.skuShortName);
  final editLimit = config.postEditTimeLimit;
  final proxyType = config.imageProxyType;
  final maxFileSize = config.maxFileSize;
  final typingMs = config.timeBetweenUserTypingUpdatesMilliseconds;
  final burnSeconds = config.burnOnReadDurationSeconds;
  return ServerFeatures(
    version: config.version?.trim() ?? '',
    collapsedThreads: config.collapsedThreads,
    nameDisplay: config.teammateNameDisplay,
    nameDisplayLocked:
        config.lockTeammateNameDisplay == true ||
        license.lockTeammateNameDisplay == true,
    customEmoji: on(OptionalFeature.customEmoji, config.enableCustomEmoji),
    customStatus: on(
      OptionalFeature.customStatus,
      config.enableCustomUserStatuses,
    ),
    postPriority: config.postPriority == true,
    acknowledgements: on(
      OptionalFeature.acknowledgements,
      config.postAcknowledgements,
    ),
    maxPostSize: switch (config.maxPostSize) {
      final size? when size > 0 => size,
      _ => ServerFeatures.defaultMaxPostSize,
    },
    maxFileSize: maxFileSize != null && maxFileSize > 0 ? maxFileSize : null,
    typing: config.enableUserTypingMessages != false,
    typingInterval: typingMs != null && typingMs > 0
        ? Duration(milliseconds: typingMs)
        : ServerFeatures.defaultTypingInterval,
    maxNotificationsPerChannel: config.maxNotificationsPerChannel,
    imageProxy:
        config.hasImageProxy == true ||
        (proxyType != null && proxyType.isNotEmpty),
    latex: config.enableLatex == true,
    inlineLatex: config.enableLatex == true && config.enableInlineLatex == true,
    minimumHashtagLength: config.minimumHashtagLength ?? 3,
    maxMarkdownNodes: config.maxMarkdownNodes,
    directMessagesRestricted: (config.restrictDirectMessage ?? 'any') != 'any',
    archivedChannels: config.experimentalViewArchivedChannels != false,
    fileSearch: !turnedOff.contains(OptionalFeature.fileSearch),
    commandSuggestions: !turnedOff.contains(OptionalFeature.commandSuggestions),
    fileUploads:
        config.enableFileAttachments != false &&
        (!compliance || config.enableMobileFileUpload != false) &&
        !turnedOff.contains(OptionalFeature.fileUploads),
    fileDownloads:
        (!compliance || config.enableMobileFileDownload != false) &&
        !(advanced && config.mobileEnableSecureFilePreview == true),
    linkPreviews: config.enableLinkPreviews == true,
    permalinkPreviews: config.enablePermalinkPreviews == true,
    usernameOverride: config.enablePostUsernameOverride == true,
    iconOverride: config.enablePostIconOverride == true,
    crossTeamSearch: config.enableCrossTeamSearch == true,
    postReminders:
        (compareVersions(config.version ?? '', (7, 2, 0)) ?? -1) >= 0 &&
        !turnedOff.contains(OptionalFeature.postReminders),
    groupMentions:
        licensed && !turnedOff.contains(OptionalFeature.groupMentions),
    editTimeLimit: editLimit != null && editLimit >= 0
        ? Duration(seconds: editLimit)
        : null,
    confirmChannelMentions: config.enableConfirmNotificationsToChannel == true,
    scheduledPosts:
        licensed &&
        config.scheduledPosts == true &&
        !turnedOff.contains(OptionalFeature.scheduledPosts),
    syncedDrafts: on(OptionalFeature.syncedDrafts, config.allowSyncedDrafts),
    burnOnRead:
        advanced && on(OptionalFeature.burnOnRead, config.enableBurnOnRead),
    burnOnReadDuration: burnSeconds != null && burnSeconds > 0
        ? Duration(seconds: burnSeconds)
        : ServerFeatures.defaultBurnOnReadDuration,
    townSquareReadOnly:
        licensed && config.experimentalTownSquareIsReadOnly == true,
    ldapFields: {
      if (config.ldapFirstNameAttributeSet == true) ProfileField.firstName,
      if (config.ldapLastNameAttributeSet == true) ProfileField.lastName,
      if (config.ldapNicknameAttributeSet == true) ProfileField.nickname,
      if (config.ldapPositionAttributeSet == true) ProfileField.position,
      if (config.ldapPictureAttributeSet == true) ProfileField.picture,
    },
    samlFields: {
      if (config.samlFirstNameAttributeSet == true) ProfileField.firstName,
      if (config.samlLastNameAttributeSet == true) ProfileField.lastName,
      if (config.samlNicknameAttributeSet == true) ProfileField.nickname,
      if (config.samlPositionAttributeSet == true) ProfileField.position,
    },
    featureFlags: config.featureFlags,
    pluginsAllowed: config.pluginsEnabled != false,
    plugins: {
      if (config.pluginsEnabled != false)
        for (final p in plugins) p.id: p.version,
    },
  );
}

/// Pure: whether an optional endpoint's failure says the feature isn't
/// there (switched off, not licensed, or not built into this server), as
/// opposed to a failure of this one request. [refusalMeansAbsent] is for
/// endpoints whose 403 or 404 can only mean that.
bool endpointUnavailable(Object error, {bool refusalMeansAbsent = false}) =>
    switch (error) {
      ServerError(statusCode: 501) => true,
      ServerError(statusCode: 403 || 404) => refusalMeansAbsent,
      _ => false,
    };

/// Pure: [version] (such as `12.0.1` or `10.11.0-rc1`) compared with
/// [other]: negative when older, 0 when equal, positive when newer; null
/// when it can't be read.
int? compareVersions(String version, (int, int, int) other) {
  final match = RegExp(r'^v?(\d+)\.(\d+)(?:\.(\d+))?')
      .firstMatch(version.trim());
  if (match == null) return null;
  final mine = [
    int.parse(match.group(1)!),
    int.parse(match.group(2)!),
    int.tryParse(match.group(3) ?? '') ?? 0,
  ];
  final (major, minor, patch) = other;
  for (final (a, b) in [(mine[0], major), (mine[1], minor), (mine[2], patch)]) {
    if (a != b) return a.compareTo(b);
  }
  return 0;
}
