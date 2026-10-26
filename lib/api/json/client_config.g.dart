// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClientConfig _$ClientConfigFromJson(Map<String, dynamic> json) => ClientConfig(
  version: const LenientString().fromJson(json['Version']),
  siteName: const LenientString().fromJson(json['SiteName']),
  diagnosticId: const LenientString().fromJson(json['DiagnosticId']),
  enableSignInWithEmail: const LenientBool().fromJson(
    json['EnableSignInWithEmail'],
  ),
  enableSignInWithUsername: const LenientBool().fromJson(
    json['EnableSignInWithUsername'],
  ),
  enableLdap: const LenientBool().fromJson(json['EnableLdap']),
  ldapLoginFieldName: const LenientString().fromJson(
    json['LdapLoginFieldName'],
  ),
  passwordEnableForgotLink: const LenientBool().fromJson(
    json['PasswordEnableForgotLink'],
  ),
  forgotPasswordLink: const LenientString().fromJson(
    json['ForgotPasswordLink'],
  ),
  enableSignUpWithGitLab: const LenientBool().fromJson(
    json['EnableSignUpWithGitLab'],
  ),
  gitLabButtonText: const LenientString().fromJson(json['GitLabButtonText']),
  enableSignUpWithGoogle: const LenientBool().fromJson(
    json['EnableSignUpWithGoogle'],
  ),
  enableSignUpWithOffice365: const LenientBool().fromJson(
    json['EnableSignUpWithOffice365'],
  ),
  enableSignUpWithOpenId: const LenientBool().fromJson(
    json['EnableSignUpWithOpenId'],
  ),
  openIdButtonText: const LenientString().fromJson(json['OpenIdButtonText']),
  enableSaml: const LenientBool().fromJson(json['EnableSaml']),
  samlLoginButtonText: const LenientString().fromJson(
    json['SamlLoginButtonText'],
  ),
  enableMultifactorAuthentication: const LenientBool().fromJson(
    json['EnableMultifactorAuthentication'],
  ),
  enforceMultifactorAuthentication: const LenientBool().fromJson(
    json['EnforceMultifactorAuthentication'],
  ),
  mobileExternalBrowser: const LenientBool().fromJson(
    json['MobileExternalBrowser'],
  ),
  collapsedThreads: const LenientString().fromJson(json['CollapsedThreads']),
  teammateNameDisplay: const LenientString().fromJson(
    json['TeammateNameDisplay'],
  ),
  lockTeammateNameDisplay: const LenientBool().fromJson(
    json['LockTeammateNameDisplay'],
  ),
  enableCustomEmoji: const LenientBool().fromJson(json['EnableCustomEmoji']),
  enableCustomUserStatuses: const LenientBool().fromJson(
    json['EnableCustomUserStatuses'],
  ),
  postPriority: const LenientBool().fromJson(json['PostPriority']),
  postAcknowledgements: const LenientBool().fromJson(
    json['PostAcknowledgements'],
  ),
  maxPostSize: const LenientInt().fromJson(json['MaxPostSize']),
  maxFileSize: const LenientInt().fromJson(json['MaxFileSize']),
  enableUserTypingMessages: const LenientBool().fromJson(
    json['EnableUserTypingMessages'],
  ),
  timeBetweenUserTypingUpdatesMilliseconds: const LenientInt().fromJson(
    json['TimeBetweenUserTypingUpdatesMilliseconds'],
  ),
  maxNotificationsPerChannel: const LenientInt().fromJson(
    json['MaxNotificationsPerChannel'],
  ),
  hasImageProxy: const LenientBool().fromJson(json['HasImageProxy']),
  imageProxyType: const LenientString().fromJson(json['ImageProxyType']),
  enableLatex: const LenientBool().fromJson(json['EnableLatex']),
  enableInlineLatex: const LenientBool().fromJson(json['EnableInlineLatex']),
  minimumHashtagLength: const LenientInt().fromJson(
    json['MinimumHashtagLength'],
  ),
  maxMarkdownNodes: const LenientInt().fromJson(json['MaxMarkdownNodes']),
  restrictDirectMessage: const LenientString().fromJson(
    json['RestrictDirectMessage'],
  ),
  experimentalViewArchivedChannels: const LenientBool().fromJson(
    json['ExperimentalViewArchivedChannels'],
  ),
  pluginsEnabled: const LenientBool().fromJson(json['PluginsEnabled']),
  enableFileAttachments: const LenientBool().fromJson(
    json['EnableFileAttachments'],
  ),
  enableMobileFileUpload: const LenientBool().fromJson(
    json['EnableMobileFileUpload'],
  ),
  enableMobileFileDownload: const LenientBool().fromJson(
    json['EnableMobileFileDownload'],
  ),
  mobileEnableSecureFilePreview: const LenientBool().fromJson(
    json['MobileEnableSecureFilePreview'],
  ),
  enableLinkPreviews: const LenientBool().fromJson(json['EnableLinkPreviews']),
  enablePermalinkPreviews: const LenientBool().fromJson(
    json['EnablePermalinkPreviews'],
  ),
  enablePostUsernameOverride: const LenientBool().fromJson(
    json['EnablePostUsernameOverride'],
  ),
  enablePostIconOverride: const LenientBool().fromJson(
    json['EnablePostIconOverride'],
  ),
  enableCrossTeamSearch: const LenientBool().fromJson(
    json['EnableCrossTeamSearch'],
  ),
  postEditTimeLimit: const LenientInt().fromJson(json['PostEditTimeLimit']),
  enableConfirmNotificationsToChannel: const LenientBool().fromJson(
    json['EnableConfirmNotificationsToChannel'],
  ),
  experimentalTownSquareIsReadOnly: const LenientBool().fromJson(
    json['ExperimentalTownSquareIsReadOnly'],
  ),
  ldapFirstNameAttributeSet: const LenientBool().fromJson(
    json['LdapFirstNameAttributeSet'],
  ),
  ldapLastNameAttributeSet: const LenientBool().fromJson(
    json['LdapLastNameAttributeSet'],
  ),
  ldapNicknameAttributeSet: const LenientBool().fromJson(
    json['LdapNicknameAttributeSet'],
  ),
  ldapPositionAttributeSet: const LenientBool().fromJson(
    json['LdapPositionAttributeSet'],
  ),
  ldapPictureAttributeSet: const LenientBool().fromJson(
    json['LdapPictureAttributeSet'],
  ),
  samlFirstNameAttributeSet: const LenientBool().fromJson(
    json['SamlFirstNameAttributeSet'],
  ),
  samlLastNameAttributeSet: const LenientBool().fromJson(
    json['SamlLastNameAttributeSet'],
  ),
  samlNicknameAttributeSet: const LenientBool().fromJson(
    json['SamlNicknameAttributeSet'],
  ),
  samlPositionAttributeSet: const LenientBool().fromJson(
    json['SamlPositionAttributeSet'],
  ),
  buildEnterpriseReady: const LenientBool().fromJson(
    json['BuildEnterpriseReady'],
  ),
  scheduledPosts: const LenientBool().fromJson(json['ScheduledPosts']),
  allowSyncedDrafts: const LenientBool().fromJson(json['AllowSyncedDrafts']),
  enableBurnOnRead: const LenientBool().fromJson(json['EnableBurnOnRead']),
  burnOnReadDurationSeconds: const LenientInt().fromJson(
    json['BurnOnReadDurationSeconds'],
  ),
  burnOnReadMaximumTimeToLiveSeconds: const LenientInt().fromJson(
    json['BurnOnReadMaximumTimeToLiveSeconds'],
  ),
  featureFlags: _featureFlags(json, 'FeatureFlags') == null
      ? const {}
      : const _StringMap().fromJson(_featureFlags(json, 'FeatureFlags')),
);

ClientLicense _$ClientLicenseFromJson(Map<String, dynamic> json) =>
    ClientLicense(
      isLicensed: const LenientBool().fromJson(json['IsLicensed']),
      skuShortName: const LenientString().fromJson(json['SkuShortName']),
      ldap: const LenientBool().fromJson(json['LDAP']),
      saml: const LenientBool().fromJson(json['SAML']),
      lockTeammateNameDisplay: const LenientBool().fromJson(
        json['LockTeammateNameDisplay'],
      ),
      compliance: const LenientBool().fromJson(json['Compliance']),
    );
