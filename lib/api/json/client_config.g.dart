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
    );
