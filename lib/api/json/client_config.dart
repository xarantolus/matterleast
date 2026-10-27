import 'package:json_annotation/json_annotation.dart';
import 'package:matterleast/api/json/lenient.dart';

part 'client_config.g.dart';

// `GET /config/client?format=old` and `GET /license/client?format=old`,
// which the OpenAPI spec leaves untyped. Every value arrives as a string;
// keys follow the server's `config/client.go` and `utils/license.go`. Only
// the keys the app reads are here.

@JsonSerializable(createToJson: false, fieldRename: FieldRename.pascal)
class ClientConfig {
  const ClientConfig({
    this.version,
    this.buildNumber,
    this.sendEmailNotifications,
    this.experimentalEnableAutomaticReplies,
    this.siteName,
    this.siteUrl,
    this.diagnosticId,
    this.enableSignInWithEmail,
    this.enableSignInWithUsername,
    this.enableLdap,
    this.ldapLoginFieldName,
    this.passwordEnableForgotLink,
    this.forgotPasswordLink,
    this.enableSignUpWithGitLab,
    this.gitLabButtonText,
    this.enableSignUpWithGoogle,
    this.enableSignUpWithOffice365,
    this.enableSignUpWithOpenId,
    this.openIdButtonText,
    this.enableSaml,
    this.samlLoginButtonText,
    this.enableMultifactorAuthentication,
    this.enforceMultifactorAuthentication,
    this.mobileExternalBrowser,
    this.collapsedThreads,
    this.teammateNameDisplay,
    this.lockTeammateNameDisplay,
    this.enableCustomEmoji,
    this.enableCustomUserStatuses,
    this.postPriority,
    this.postAcknowledgements,
    this.maxPostSize,
    this.maxFileSize,
    this.enableUserTypingMessages,
    this.timeBetweenUserTypingUpdatesMilliseconds,
    this.maxNotificationsPerChannel,
    this.hasImageProxy,
    this.imageProxyType,
    this.enableLatex,
    this.enableInlineLatex,
    this.minimumHashtagLength,
    this.maxMarkdownNodes,
    this.restrictDirectMessage,
    this.experimentalViewArchivedChannels,
    this.pluginsEnabled,
    this.enableFileAttachments,
    this.enableMobileFileUpload,
    this.enableMobileFileDownload,
    this.mobileEnableSecureFilePreview,
    this.enableLinkPreviews,
    this.enablePermalinkPreviews,
    this.enablePostUsernameOverride,
    this.enablePostIconOverride,
    this.enableCrossTeamSearch,
    this.postEditTimeLimit,
    this.enableConfirmNotificationsToChannel,
    this.experimentalTownSquareIsReadOnly,
    this.ldapFirstNameAttributeSet,
    this.ldapLastNameAttributeSet,
    this.ldapNicknameAttributeSet,
    this.ldapPositionAttributeSet,
    this.ldapPictureAttributeSet,
    this.samlFirstNameAttributeSet,
    this.samlLastNameAttributeSet,
    this.samlNicknameAttributeSet,
    this.samlPositionAttributeSet,
    this.buildEnterpriseReady,
    this.scheduledPosts,
    this.allowSyncedDrafts,
    this.enableBurnOnRead,
    this.burnOnReadDurationSeconds,
    this.burnOnReadMaximumTimeToLiveSeconds,
    this.featureFlags = const {},
  });

  factory ClientConfig.fromJson(Map<String, Object?> json) =>
      _$ClientConfigFromJson(json);

  @LenientString()
  final String? version;
  @LenientString()
  final String? buildNumber;
  @LenientBool()
  final bool? sendEmailNotifications;
  @LenientBool()
  final bool? experimentalEnableAutomaticReplies;
  @LenientString()
  final String? siteName;
  @JsonKey(name: 'SiteURL')
  @LenientString()
  final String? siteUrl;
  @LenientString()
  final String? diagnosticId;

  @LenientBool()
  final bool? enableSignInWithEmail;
  @LenientBool()
  final bool? enableSignInWithUsername;
  @LenientBool()
  final bool? enableLdap;
  @LenientString()
  final String? ldapLoginFieldName;
  @LenientBool()
  final bool? passwordEnableForgotLink;
  @LenientString()
  final String? forgotPasswordLink;
  @LenientBool()
  @JsonKey(name: 'EnableSignUpWithGitLab')
  final bool? enableSignUpWithGitLab;
  @LenientString()
  @JsonKey(name: 'GitLabButtonText')
  final String? gitLabButtonText;
  @LenientBool()
  final bool? enableSignUpWithGoogle;
  @LenientBool()
  final bool? enableSignUpWithOffice365;
  @LenientBool()
  final bool? enableSignUpWithOpenId;
  @LenientString()
  final String? openIdButtonText;
  @LenientBool()
  final bool? enableSaml;
  @LenientString()
  final String? samlLoginButtonText;
  @LenientBool()
  final bool? enableMultifactorAuthentication;
  @LenientBool()
  final bool? enforceMultifactorAuthentication;
  @LenientBool()
  final bool? mobileExternalBrowser;

  /// `disabled`, `default_on`, `default_off` or `always_on`.
  @LenientString()
  final String? collapsedThreads;
  @LenientString()
  final String? teammateNameDisplay;
  @LenientBool()
  final bool? lockTeammateNameDisplay;
  @LenientBool()
  final bool? enableCustomEmoji;
  @LenientBool()
  final bool? enableCustomUserStatuses;
  @LenientBool()
  final bool? postPriority;
  @LenientBool()
  final bool? postAcknowledgements;
  @LenientInt()
  final int? maxPostSize;
  @LenientInt()
  final int? maxFileSize;
  @LenientBool()
  final bool? enableUserTypingMessages;
  @LenientInt()
  final int? timeBetweenUserTypingUpdatesMilliseconds;
  @LenientInt()
  final int? maxNotificationsPerChannel;
  @LenientBool()
  final bool? hasImageProxy;
  @LenientString()
  final String? imageProxyType;
  @LenientBool()
  final bool? enableLatex;
  @LenientBool()
  final bool? enableInlineLatex;
  @LenientInt()
  final int? minimumHashtagLength;
  @LenientInt()
  final int? maxMarkdownNodes;

  /// `any` or `team`.
  @LenientString()
  final String? restrictDirectMessage;

  /// Sent only up to 10.11; later servers always show archived channels.
  @LenientBool()
  final bool? experimentalViewArchivedChannels;
  @LenientBool()
  final bool? pluginsEnabled;
  @LenientBool()
  final bool? enableFileAttachments;
  @LenientBool()
  final bool? enableMobileFileUpload;
  @LenientBool()
  final bool? enableMobileFileDownload;
  @LenientBool()
  final bool? mobileEnableSecureFilePreview;
  @LenientBool()
  final bool? enableLinkPreviews;
  @LenientBool()
  final bool? enablePermalinkPreviews;
  @LenientBool()
  final bool? enablePostUsernameOverride;
  @LenientBool()
  final bool? enablePostIconOverride;
  @LenientBool()
  final bool? enableCrossTeamSearch;

  /// Seconds after posting that a message can still be edited; -1 for no
  /// limit.
  @LenientInt()
  final int? postEditTimeLimit;
  @LenientBool()
  final bool? enableConfirmNotificationsToChannel;
  @LenientBool()
  final bool? experimentalTownSquareIsReadOnly;
  @LenientBool()
  final bool? ldapFirstNameAttributeSet;
  @LenientBool()
  final bool? ldapLastNameAttributeSet;
  @LenientBool()
  final bool? ldapNicknameAttributeSet;
  @LenientBool()
  final bool? ldapPositionAttributeSet;
  @LenientBool()
  final bool? ldapPictureAttributeSet;
  @LenientBool()
  final bool? samlFirstNameAttributeSet;
  @LenientBool()
  final bool? samlLastNameAttributeSet;
  @LenientBool()
  final bool? samlNicknameAttributeSet;
  @LenientBool()
  final bool? samlPositionAttributeSet;
  @LenientBool()
  final bool? buildEnterpriseReady;

  /// Sent only to licensed servers' signed-in users.
  @LenientBool()
  final bool? scheduledPosts;
  @LenientBool()
  final bool? allowSyncedDrafts;
  @LenientBool()
  final bool? enableBurnOnRead;
  @LenientInt()
  final int? burnOnReadDurationSeconds;
  @LenientInt()
  final int? burnOnReadMaximumTimeToLiveSeconds;

  /// Every `FeatureFlag…` key, without the prefix.
  @JsonKey(readValue: _featureFlags)
  @_StringMap()
  final Map<String, String> featureFlags;
}

const _flagPrefix = 'FeatureFlag';

Object? _featureFlags(Map<dynamic, dynamic> json, String _) => {
  for (final MapEntry(:key, :value) in json.entries)
    if (key is String && key.startsWith(_flagPrefix) && value is String)
      key.substring(_flagPrefix.length): value,
};

class _StringMap implements JsonConverter<Map<String, String>, Object?> {
  const _StringMap();
  @override
  Map<String, String> fromJson(Object? json) => {
    if (json is Map<String, Object?>)
      for (final MapEntry(:key, :value) in json.entries)
        if (value is String) key: value,
  };
  @override
  Object? toJson(Map<String, String> object) => object;
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.pascal)
class ClientLicense {
  const ClientLicense({
    this.isLicensed,
    this.skuShortName,
    this.ldap,
    this.saml,
    this.lockTeammateNameDisplay,
    this.compliance,
  });

  factory ClientLicense.fromJson(Map<String, Object?> json) =>
      _$ClientLicenseFromJson(json);

  @LenientBool()
  final bool? isLicensed;
  @LenientString()
  @JsonKey(name: 'SkuShortName')
  final String? skuShortName;
  @LenientBool()
  @JsonKey(name: 'LDAP')
  final bool? ldap;
  @LenientBool()
  @JsonKey(name: 'SAML')
  final bool? saml;
  @LenientBool()
  final bool? lockTeammateNameDisplay;
  @LenientBool()
  final bool? compliance;
}
