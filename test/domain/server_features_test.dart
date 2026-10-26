import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/api/json/client_config.dart';
import 'package:matterleast/domain/server_features.dart';

ServerFeatures features(
  Map<String, Object?> config, {
  Map<String, Object?> license = const {},
  List<PluginVersion> plugins = const [],
  Set<OptionalFeature> turnedOff = const {},
}) => serverFeatures(
  config: ClientConfig.fromJson(config),
  license: ClientLicense.fromJson(license),
  plugins: plugins,
  turnedOff: turnedOff,
);

void main() {
  test('a server that names no post limit gets the safe default', () {
    expect(features({}).maxPostSize, 4000);
    expect(features({'MaxPostSize': '16383'}).maxPostSize, 16383);
    expect(features({'MaxPostSize': 'lots'}).maxPostSize, 4000);
  });

  test('the file size limit applies only when set', () {
    expect(features({'MaxFileSize': '52428800'}).maxFileSize, 52428800);
    expect(features({}).maxFileSize, isNull);
    expect(features({'MaxFileSize': '0'}).maxFileSize, isNull);
  });

  test('the licence alone can lock how people are named', () {
    final config = {'TeammateNameDisplay': 'full_name'};
    expect(features(config).nameDisplayLocked, isFalse);
    expect(
      features(
        config,
        license: {'IsLicensed': 'true', 'LockTeammateNameDisplay': 'true'},
      ).nameDisplayLocked,
      isTrue,
    );
    expect(
      features({...config, 'LockTeammateNameDisplay': 'true'})
          .nameDisplayLocked,
      isTrue,
    );
  });

  test('images go through the proxy when the server has one', () {
    expect(features({'HasImageProxy': 'true'}).imageProxy, isTrue);
    expect(features({'ImageProxyType': 'local'}).imageProxy, isTrue);
    expect(features({'HasImageProxy': 'false'}).imageProxy, isFalse);
    expect(features({}).imageProxy, isFalse);
  });

  test('typing follows the server, with its interval', () {
    final quiet = features({
      'EnableUserTypingMessages': 'false',
      'TimeBetweenUserTypingUpdatesMilliseconds': '2000',
    });
    expect(quiet.typing, isFalse);
    expect(quiet.typingInterval, const Duration(seconds: 2));
    expect(features({}).typing, isTrue);
    expect(features({}).typingInterval, const Duration(seconds: 5));
  });

  test('archived channels hide only when the server says false', () {
    expect(features({}).archivedChannels, isTrue);
    expect(
      features({'ExperimentalViewArchivedChannels': 'false'}).archivedChannels,
      isFalse,
    );
  });

  test('a feature the server answered as unavailable stays off', () {
    final config = {
      'EnableCustomEmoji': 'true',
      'EnableCustomUserStatuses': 'true',
      'PostAcknowledgements': 'true',
    };
    final on = features(config);
    expect([
      on.customEmoji,
      on.customStatus,
      on.acknowledgements,
    ], everyElement(isTrue));
    final off = features(config, turnedOff: OptionalFeature.values.toSet());
    expect([
      off.customEmoji,
      off.customStatus,
      off.acknowledgements,
      off.fileSearch,
      off.commandSuggestions,
    ], everyElement(isFalse));
  });

  test('a flag removed in a later version is on from that version', () {
    const removedIn = (11, 10, 0);
    final older = features({
      'Version': '11.9.2',
      'FeatureFlagChannelBookmarks': 'false',
    });
    expect(older.flag('ChannelBookmarks', removedIn: removedIn), isFalse);
    expect(
      features({'Version': '11.9.2', 'FeatureFlagChannelBookmarks': 'true'})
          .flag('ChannelBookmarks', removedIn: removedIn),
      isTrue,
    );
    expect(
      features({'Version': '12.0.1'})
          .flag('ChannelBookmarks', removedIn: removedIn),
      isTrue,
    );
    expect(features({'Version': '12.0.1'}).flag('ChannelBookmarks'), isFalse);
  });

  test('plugins count by id and version, and not when plugins are off', () {
    const plugins = [(id: 'mattermost-ai', version: '1.4.0')];
    final on = features({'PluginsEnabled': 'true'}, plugins: plugins);
    expect(on.hasPlugin('mattermost-ai'), isTrue);
    expect(on.hasPlugin('mattermost-ai', minVersion: (1, 4, 0)), isTrue);
    expect(on.hasPlugin('mattermost-ai', minVersion: (1, 5, 0)), isFalse);
    expect(on.hasPlugin('playbooks'), isFalse);
    final off = features({'PluginsEnabled': 'false'}, plugins: plugins);
    expect(off.hasPlugin('mattermost-ai'), isFalse);
    expect(off.pluginsAllowed, isFalse);
  });

  test('versions compare by number, with suffixes and missing parts', () {
    expect(compareVersions('12.0.1', (12, 0, 0)), greaterThan(0));
    expect(compareVersions('10.11.0-rc1', (10, 11, 0)), 0);
    expect(compareVersions('9.11', (10, 0, 0)), lessThan(0));
    expect(compareVersions('10.2.0', (10, 11, 0)), lessThan(0));
    expect(compareVersions('', (1, 0, 0)), isNull);
    expect(features({'Version': '12.0.1'}).atLeast(12, 0), isTrue);
    expect(features({}).atLeast(1, 0), isFalse);
  });

  test(
    'only an answer that the endpoint is unavailable turns a feature off',
    () {
      const notImplemented = ServerError(statusCode: 501);
      const forbidden = ServerError(statusCode: 403);
      const notFound = ServerError(statusCode: 404);
      expect(endpointUnavailable(notImplemented), isTrue);
      expect(endpointUnavailable(forbidden), isFalse);
      expect(endpointUnavailable(notFound), isFalse);
      expect(endpointUnavailable(forbidden, refusalMeansAbsent: true), isTrue);
      expect(endpointUnavailable(notFound, refusalMeansAbsent: true), isTrue);
      expect(endpointUnavailable(const ServerError(statusCode: 500)), isFalse);
      expect(endpointUnavailable(const Unreachable()), isFalse);
    },
  );

  test('uploads follow the attachment switch and, under compliance, the '
      'mobile switch', () {
    expect(features({}).fileUploads, isTrue);
    expect(features({'EnableFileAttachments': 'false'}).fileUploads, isFalse);
    final mobileOff = {'EnableMobileFileUpload': 'false'};
    expect(features(mobileOff).fileUploads, isTrue);
    expect(
      features(
        mobileOff,
        license: {'IsLicensed': 'true', 'Compliance': 'true'},
      ).fileUploads,
      isFalse,
    );
    expect(
      features({}, turnedOff: {OptionalFeature.fileUploads}).fileUploads,
      isFalse,
    );
  });

  test('downloads stop under compliance or secure preview', () {
    expect(features({}).fileDownloads, isTrue);
    expect(
      features(
        {'EnableMobileFileDownload': 'false'},
        license: {'IsLicensed': 'true', 'Compliance': 'true'},
      ).fileDownloads,
      isFalse,
    );
    final secure = {'MobileEnableSecureFilePreview': 'true'};
    expect(features(secure).fileDownloads, isTrue);
    expect(
      features(
        secure,
        license: {'IsLicensed': 'true', 'SkuShortName': 'advanced'},
      ).fileDownloads,
      isFalse,
    );
  });

  test('previews, overrides and cross-team search only when switched on', () {
    final none = features({});
    expect(none.linkPreviews, isFalse);
    expect(none.usernameOverride, isFalse);
    expect(none.iconOverride, isFalse);
    expect(none.crossTeamSearch, isFalse);
    final all = features({
      'EnableLinkPreviews': 'true',
      'EnablePostUsernameOverride': 'true',
      'EnablePostIconOverride': 'true',
      'EnableCrossTeamSearch': 'true',
    });
    expect(all.linkPreviews, isTrue);
    expect(all.usernameOverride, isTrue);
    expect(all.iconOverride, isTrue);
    expect(all.crossTeamSearch, isTrue);
  });

  test('the edit window is the server limit, none at -1', () {
    expect(features({'PostEditTimeLimit': '-1'}).editTimeLimit, isNull);
    expect(
      features({'PostEditTimeLimit': '300'}).editTimeLimit,
      const Duration(minutes: 5),
    );
  });

  test('the read-only default channel needs a licence', () {
    final config = {'ExperimentalTownSquareIsReadOnly': 'true'};
    expect(features(config).townSquareReadOnly, isFalse);
    expect(
      features(config, license: {'IsLicensed': 'true'}).townSquareReadOnly,
      isTrue,
    );
  });
}
