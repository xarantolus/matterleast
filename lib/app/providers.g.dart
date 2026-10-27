// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'365ef3f215d780c29a21b6328f0b547a8363c6a6';

@ProviderFor(settingsStore)
final settingsStoreProvider = SettingsStoreProvider._();

final class SettingsStoreProvider
    extends $FunctionalProvider<SettingsStore, SettingsStore, SettingsStore>
    with $Provider<SettingsStore> {
  SettingsStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsStoreHash();

  @$internal
  @override
  $ProviderElement<SettingsStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SettingsStore create(Ref ref) {
    return settingsStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsStore>(value),
    );
  }
}

String _$settingsStoreHash() => r'03752f8d2b575da19bd6c088058cb24c46c6fa19';

/// The rail item shown when the app was last used, read once at launch.

@ProviderFor(savedRailTarget)
final savedRailTargetProvider = SavedRailTargetProvider._();

/// The rail item shown when the app was last used, read once at launch.

final class SavedRailTargetProvider
    extends
        $FunctionalProvider<
          AsyncValue<RailTarget?>,
          RailTarget?,
          FutureOr<RailTarget?>
        >
    with $FutureModifier<RailTarget?>, $FutureProvider<RailTarget?> {
  /// The rail item shown when the app was last used, read once at launch.
  SavedRailTargetProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedRailTargetProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedRailTargetHash();

  @$internal
  @override
  $FutureProviderElement<RailTarget?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<RailTarget?> create(Ref ref) {
    return savedRailTarget(ref);
  }
}

String _$savedRailTargetHash() => r'c26301a9a7afcec0e711f081f5ed181429a71a31';

@ProviderFor(tokenStore)
final tokenStoreProvider = TokenStoreProvider._();

final class TokenStoreProvider
    extends $FunctionalProvider<TokenStore, TokenStore, TokenStore>
    with $Provider<TokenStore> {
  TokenStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tokenStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tokenStoreHash();

  @$internal
  @override
  $ProviderElement<TokenStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TokenStore create(Ref ref) {
    return tokenStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TokenStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TokenStore>(value),
    );
  }
}

String _$tokenStoreHash() => r'1a3723cb9c87a80308bd518f02c3e17b42cdd4e8';

/// Whether the token storage stopped answering (a locked or missing
/// keyring), as it changes.

@ProviderFor(keyringUnavailable)
final keyringUnavailableProvider = KeyringUnavailableProvider._();

/// Whether the token storage stopped answering (a locked or missing
/// keyring), as it changes.

final class KeyringUnavailableProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Whether the token storage stopped answering (a locked or missing
  /// keyring), as it changes.
  KeyringUnavailableProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'keyringUnavailableProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$keyringUnavailableHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return keyringUnavailable(ref);
  }
}

String _$keyringUnavailableHash() =>
    r'27d1522cf15cfb0e24e4fd50849e60b94954d245';

@ProviderFor(networkState)
final networkStateProvider = NetworkStateProvider._();

final class NetworkStateProvider
    extends $FunctionalProvider<NetworkState, NetworkState, NetworkState>
    with $Provider<NetworkState> {
  NetworkStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'networkStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$networkStateHash();

  @$internal
  @override
  $ProviderElement<NetworkState> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NetworkState create(Ref ref) {
    return networkState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NetworkState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NetworkState>(value),
    );
  }
}

String _$networkStateHash() => r'd94b31057357d41faff4af0531da6185cf15dbf0';

/// True while the device has no network, so nothing shows as loading.

@ProviderFor(offline)
final offlineProvider = OfflineProvider._();

/// True while the device has no network, so nothing shows as loading.

final class OfflineProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// True while the device has no network, so nothing shows as loading.
  OfflineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'offlineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$offlineHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return offline(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$offlineHash() => r'469732fd3047a6abeeb4bf7ae90a145e1ecdfaf9';

@ProviderFor(serverManager)
final serverManagerProvider = ServerManagerProvider._();

final class ServerManagerProvider
    extends $FunctionalProvider<ServerManager, ServerManager, ServerManager>
    with $Provider<ServerManager> {
  ServerManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serverManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serverManagerHash();

  @$internal
  @override
  $ProviderElement<ServerManager> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ServerManager create(Ref ref) {
    return serverManager(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ServerManager value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ServerManager>(value),
    );
  }
}

String _$serverManagerHash() => r'079c701e06279794fd4b74446a0f74507ed11754';

/// Message notifications of this isolate; [Notifier.init] runs at launch.

@ProviderFor(notifier)
final notifierProvider = NotifierProvider._();

/// Message notifications of this isolate; [Notifier.init] runs at launch.

final class NotifierProvider
    extends $FunctionalProvider<Notifier, Notifier, Notifier>
    with $Provider<Notifier> {
  /// Message notifications of this isolate; [Notifier.init] runs at launch.
  NotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notifierProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notifierHash();

  @$internal
  @override
  $ProviderElement<Notifier> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Notifier create(Ref ref) {
    return notifier(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Notifier value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Notifier>(value),
    );
  }
}

String _$notifierHash() => r'eed641cbe646fd089cd186f801d90ef18cb4aec8';

@ProviderFor(serverProbe)
final serverProbeProvider = ServerProbeProvider._();

final class ServerProbeProvider
    extends $FunctionalProvider<ServerProbe, ServerProbe, ServerProbe>
    with $Provider<ServerProbe> {
  ServerProbeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serverProbeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serverProbeHash();

  @$internal
  @override
  $ProviderElement<ServerProbe> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ServerProbe create(Ref ref) {
    return serverProbe(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ServerProbe value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ServerProbe>(value),
    );
  }
}

String _$serverProbeHash() => r'ee7b1e15a5fbd0aeaa4c0d524f1584e448f8b41e';

/// The desktop SSO sign-in waiting for the browser; callback links that
/// reach the app go to it.

@ProviderFor(browserAuthSession)
final browserAuthSessionProvider = BrowserAuthSessionProvider._();

/// The desktop SSO sign-in waiting for the browser; callback links that
/// reach the app go to it.

final class BrowserAuthSessionProvider
    extends
        $FunctionalProvider<
          BrowserAuthSession,
          BrowserAuthSession,
          BrowserAuthSession
        >
    with $Provider<BrowserAuthSession> {
  /// The desktop SSO sign-in waiting for the browser; callback links that
  /// reach the app go to it.
  BrowserAuthSessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'browserAuthSessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$browserAuthSessionHash();

  @$internal
  @override
  $ProviderElement<BrowserAuthSession> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BrowserAuthSession create(Ref ref) {
    return browserAuthSession(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BrowserAuthSession value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BrowserAuthSession>(value),
    );
  }
}

String _$browserAuthSessionHash() =>
    r'5d2a45f9a687b1ad12029f424db8a1a45add9852';

@ProviderFor(signIn)
final signInProvider = SignInProvider._();

final class SignInProvider extends $FunctionalProvider<SignIn, SignIn, SignIn>
    with $Provider<SignIn> {
  SignInProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signInProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signInHash();

  @$internal
  @override
  $ProviderElement<SignIn> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SignIn create(Ref ref) {
    return signIn(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignIn value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignIn>(value),
    );
  }
}

String _$signInHash() => r'a5dea4347eae281c9fb2b1e96fd0bda214082bcb';

/// Every added server, signed in or not, in rail order.

@ProviderFor(servers)
final serversProvider = ServersProvider._();

/// Every added server, signed in or not, in rail order.

final class ServersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ServerEntry>>,
          List<ServerEntry>,
          Stream<List<ServerEntry>>
        >
    with
        $FutureModifier<List<ServerEntry>>,
        $StreamProvider<List<ServerEntry>> {
  /// Every added server, signed in or not, in rail order.
  ServersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serversProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serversHash();

  @$internal
  @override
  $StreamProviderElement<List<ServerEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ServerEntry>> create(Ref ref) {
    return servers(ref);
  }
}

String _$serversHash() => r'b2b2352d668cfc70d867251be59cde7c97512d11';

@ProviderFor(serverSession)
final serverSessionProvider = ServerSessionFamily._();

final class ServerSessionProvider
    extends
        $FunctionalProvider<
          AsyncValue<ServerSession>,
          ServerSession,
          FutureOr<ServerSession>
        >
    with $FutureModifier<ServerSession>, $FutureProvider<ServerSession> {
  ServerSessionProvider._({
    required ServerSessionFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'serverSessionProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$serverSessionHash();

  @override
  String toString() {
    return r'serverSessionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ServerSession> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ServerSession> create(Ref ref) {
    final argument = this.argument as String;
    return serverSession(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ServerSessionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$serverSessionHash() => r'fcbaeaa10d7b4b6c987069270a111a68fc702953';

final class ServerSessionFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ServerSession>, String> {
  ServerSessionFamily._()
    : super(
        retry: null,
        name: r'serverSessionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  ServerSessionProvider call(String url) =>
      ServerSessionProvider._(argument: url, from: this);

  @override
  String toString() => r'serverSessionProvider';
}

/// The signed-in user of one server, from its database.

@ProviderFor(currentUser)
final currentUserProvider = CurrentUserFamily._();

/// The signed-in user of one server, from its database.

final class CurrentUserProvider
    extends $FunctionalProvider<AsyncValue<Me?>, Me?, Stream<Me?>>
    with $FutureModifier<Me?>, $StreamProvider<Me?> {
  /// The signed-in user of one server, from its database.
  CurrentUserProvider._({
    required CurrentUserFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'currentUserProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$currentUserHash();

  @override
  String toString() {
    return r'currentUserProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Me?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Me?> create(Ref ref) {
    final argument = this.argument as String;
    return currentUser(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CurrentUserProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$currentUserHash() => r'163de35fb58e4fe727cf677ed562d7d0ee64dddb';

/// The signed-in user of one server, from its database.

final class CurrentUserFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Me?>, String> {
  CurrentUserFamily._()
    : super(
        retry: null,
        name: r'currentUserProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The signed-in user of one server, from its database.

  CurrentUserProvider call(String url) =>
      CurrentUserProvider._(argument: url, from: this);

  @override
  String toString() => r'currentUserProvider';
}

/// What one server offers, as it changes.

@ProviderFor(features)
final featuresProvider = FeaturesFamily._();

/// What one server offers, as it changes.

final class FeaturesProvider
    extends
        $FunctionalProvider<
          AsyncValue<ServerFeatures>,
          ServerFeatures,
          Stream<ServerFeatures>
        >
    with $FutureModifier<ServerFeatures>, $StreamProvider<ServerFeatures> {
  /// What one server offers, as it changes.
  FeaturesProvider._({
    required FeaturesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'featuresProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$featuresHash();

  @override
  String toString() {
    return r'featuresProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<ServerFeatures> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ServerFeatures> create(Ref ref) {
    final argument = this.argument as String;
    return features(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FeaturesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$featuresHash() => r'ef2ad933d1ed66c3e27967412967dff5ca544f91';

/// What one server offers, as it changes.

final class FeaturesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<ServerFeatures>, String> {
  FeaturesFamily._()
    : super(
        retry: null,
        name: r'featuresProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// What one server offers, as it changes.

  FeaturesProvider call(String url) =>
      FeaturesProvider._(argument: url, from: this);

  @override
  String toString() => r'featuresProvider';
}

/// Servers that ended their session, as they happen.

@ProviderFor(sessionEnded)
final sessionEndedProvider = SessionEndedProvider._();

/// Servers that ended their session, as they happen.

final class SessionEndedProvider
    extends
        $FunctionalProvider<
          AsyncValue<ServerEntry>,
          ServerEntry,
          Stream<ServerEntry>
        >
    with $FutureModifier<ServerEntry>, $StreamProvider<ServerEntry> {
  /// Servers that ended their session, as they happen.
  SessionEndedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionEndedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionEndedHash();

  @$internal
  @override
  $StreamProviderElement<ServerEntry> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ServerEntry> create(Ref ref) {
    return sessionEnded(ref);
  }
}

String _$sessionEndedHash() => r'd80df2fcddfad88635aedca5adc964c6914b95a8';

/// The running version alone, such as `0.11.1`.

@ProviderFor(runningVersion)
final runningVersionProvider = RunningVersionProvider._();

/// The running version alone, such as `0.11.1`.

final class RunningVersionProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// The running version alone, such as `0.11.1`.
  RunningVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'runningVersionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$runningVersionHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return runningVersion(ref);
  }
}

String _$runningVersionHash() => r'713b152f5f1bf7eeabe3caf80b6fd7a814c75831';

/// The app's version as people read it, such as `0.1.0 (1)`.

@ProviderFor(appVersion)
final appVersionProvider = AppVersionProvider._();

/// The app's version as people read it, such as `0.1.0 (1)`.

final class AppVersionProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// The app's version as people read it, such as `0.1.0 (1)`.
  AppVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appVersionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appVersionHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return appVersion(ref);
  }
}

String _$appVersionHash() => r'ff1eb5d2af994c051622516f93f238f401bb6abc';

/// The clock the user picked; null follows the phone.

@ProviderFor(use24HourClock)
final use24HourClockProvider = Use24HourClockProvider._();

/// The clock the user picked; null follows the phone.

final class Use24HourClockProvider
    extends $FunctionalProvider<AsyncValue<bool?>, bool?, Stream<bool?>>
    with $FutureModifier<bool?>, $StreamProvider<bool?> {
  /// The clock the user picked; null follows the phone.
  Use24HourClockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'use24HourClockProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$use24HourClockHash();

  @$internal
  @override
  $StreamProviderElement<bool?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool?> create(Ref ref) {
    return use24HourClock(ref);
  }
}

String _$use24HourClockHash() => r'd0e8794540e17a29e7e55ed38f0e58708ec67672';

@ProviderFor(messageTextSize)
final messageTextSizeProvider = MessageTextSizeProvider._();

final class MessageTextSizeProvider
    extends
        $FunctionalProvider<
          AsyncValue<MessageTextSize>,
          MessageTextSize,
          Stream<MessageTextSize>
        >
    with $FutureModifier<MessageTextSize>, $StreamProvider<MessageTextSize> {
  MessageTextSizeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'messageTextSizeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$messageTextSizeHash();

  @$internal
  @override
  $StreamProviderElement<MessageTextSize> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<MessageTextSize> create(Ref ref) {
    return messageTextSize(ref);
  }
}

String _$messageTextSizeHash() => r'64f057ba1364d163a27b735e0b9cda6f2d4954b4';

@ProviderFor(wrapCode)
final wrapCodeProvider = WrapCodeProvider._();

final class WrapCodeProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  WrapCodeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wrapCodeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wrapCodeHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return wrapCode(ref);
  }
}

String _$wrapCodeHash() => r'29d6ee002f5e077605648ad91b2d08edd0583605';

@ProviderFor(closeToTray)
final closeToTrayProvider = CloseToTrayProvider._();

final class CloseToTrayProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  CloseToTrayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'closeToTrayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$closeToTrayHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return closeToTray(ref);
  }
}

String _$closeToTrayHash() => r'4389da6bfd94950822cdbf5ac27f20460f0af4c9';
