// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The server whose account settings are shown: the one picked in the
/// rail, else the one used last.

@ProviderFor(settingsServer)
final settingsServerProvider = SettingsServerProvider._();

/// The server whose account settings are shown: the one picked in the
/// rail, else the one used last.

final class SettingsServerProvider
    extends $FunctionalProvider<ServerEntry?, ServerEntry?, ServerEntry?>
    with $Provider<ServerEntry?> {
  /// The server whose account settings are shown: the one picked in the
  /// rail, else the one used last.
  SettingsServerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsServerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsServerHash();

  @$internal
  @override
  $ProviderElement<ServerEntry?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ServerEntry? create(Ref ref) {
    return settingsServer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ServerEntry? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ServerEntry?>(value),
    );
  }
}

String _$settingsServerHash() => r'a7faa4fdb26944e6a9650b01ac618c3d3f86456e';

@ProviderFor(settingsActions)
final settingsActionsProvider = SettingsActionsFamily._();

final class SettingsActionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<SettingsActions>,
          SettingsActions,
          FutureOr<SettingsActions>
        >
    with $FutureModifier<SettingsActions>, $FutureProvider<SettingsActions> {
  SettingsActionsProvider._({
    required SettingsActionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'settingsActionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$settingsActionsHash();

  @override
  String toString() {
    return r'settingsActionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SettingsActions> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SettingsActions> create(Ref ref) {
    final argument = this.argument as String;
    return settingsActions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SettingsActionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$settingsActionsHash() => r'2b0f7b29a527ef90aff223f025f29a3153d88c06';

final class SettingsActionsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SettingsActions>, String> {
  SettingsActionsFamily._()
    : super(
        retry: null,
        name: r'settingsActionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SettingsActionsProvider call(String url) =>
      SettingsActionsProvider._(argument: url, from: this);

  @override
  String toString() => r'settingsActionsProvider';
}

/// The account's notification settings as stored; empty until the first
/// sign-in data arrived.

@ProviderFor(notifySettings)
final notifySettingsProvider = NotifySettingsFamily._();

/// The account's notification settings as stored; empty until the first
/// sign-in data arrived.

final class NotifySettingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<NotifyProps>,
          NotifyProps,
          Stream<NotifyProps>
        >
    with $FutureModifier<NotifyProps>, $StreamProvider<NotifyProps> {
  /// The account's notification settings as stored; empty until the first
  /// sign-in data arrived.
  NotifySettingsProvider._({
    required NotifySettingsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'notifySettingsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$notifySettingsHash();

  @override
  String toString() {
    return r'notifySettingsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<NotifyProps> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<NotifyProps> create(Ref ref) {
    final argument = this.argument as String;
    return notifySettings(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is NotifySettingsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$notifySettingsHash() => r'd6f664deec3151730d92cff85628b1f4dc946406';

/// The account's notification settings as stored; empty until the first
/// sign-in data arrived.

final class NotifySettingsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<NotifyProps>, String> {
  NotifySettingsFamily._()
    : super(
        retry: null,
        name: r'notifySettingsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The account's notification settings as stored; empty until the first
  /// sign-in data arrived.

  NotifySettingsProvider call(String url) =>
      NotifySettingsProvider._(argument: url, from: this);

  @override
  String toString() => r'notifySettingsProvider';
}

/// Fetched when the notification settings open, so they show every key.

@ProviderFor(notifySettingsRefresh)
final notifySettingsRefreshProvider = NotifySettingsRefreshFamily._();

/// Fetched when the notification settings open, so they show every key.

final class NotifySettingsRefreshProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Fetched when the notification settings open, so they show every key.
  NotifySettingsRefreshProvider._({
    required NotifySettingsRefreshFamily super.from,
    required String super.argument,
  }) : super(
         retry: noRetry,
         name: r'notifySettingsRefreshProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$notifySettingsRefreshHash();

  @override
  String toString() {
    return r'notifySettingsRefreshProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as String;
    return notifySettingsRefresh(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is NotifySettingsRefreshProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$notifySettingsRefreshHash() =>
    r'9980fe67f2a14b2195362eb1c4a186b1a6407ab8';

/// Fetched when the notification settings open, so they show every key.

final class NotifySettingsRefreshFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, String> {
  NotifySettingsRefreshFamily._()
    : super(
        retry: noRetry,
        name: r'notifySettingsRefreshProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Fetched when the notification settings open, so they show every key.

  NotifySettingsRefreshProvider call(String url) =>
      NotifySettingsRefreshProvider._(argument: url, from: this);

  @override
  String toString() => r'notifySettingsRefreshProvider';
}

@ProviderFor(displayPrefs)
final displayPrefsProvider = DisplayPrefsFamily._();

final class DisplayPrefsProvider
    extends
        $FunctionalProvider<
          AsyncValue<DisplayPrefs>,
          DisplayPrefs,
          Stream<DisplayPrefs>
        >
    with $FutureModifier<DisplayPrefs>, $StreamProvider<DisplayPrefs> {
  DisplayPrefsProvider._({
    required DisplayPrefsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'displayPrefsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$displayPrefsHash();

  @override
  String toString() {
    return r'displayPrefsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<DisplayPrefs> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<DisplayPrefs> create(Ref ref) {
    final argument = this.argument as String;
    return displayPrefs(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DisplayPrefsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$displayPrefsHash() => r'ae2bda35992b457bf419838d0304698b81620f90';

final class DisplayPrefsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<DisplayPrefs>, String> {
  DisplayPrefsFamily._()
    : super(
        retry: null,
        name: r'displayPrefsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DisplayPrefsProvider call(String url) =>
      DisplayPrefsProvider._(argument: url, from: this);

  @override
  String toString() => r'displayPrefsProvider';
}

@ProviderFor(themeMode)
final themeModeProvider = ThemeModeFamily._();

final class ThemeModeProvider
    extends
        $FunctionalProvider<
          AsyncValue<ThemeSource>,
          ThemeSource,
          Stream<ThemeSource>
        >
    with $FutureModifier<ThemeSource>, $StreamProvider<ThemeSource> {
  ThemeModeProvider._({
    required ThemeModeFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'themeModeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$themeModeHash();

  @override
  String toString() {
    return r'themeModeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<ThemeSource> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ThemeSource> create(Ref ref) {
    final argument = this.argument as String;
    return themeMode(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ThemeModeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$themeModeHash() => r'68ae4b51ab0b4a2f6bf0ebfb185261e3b5a57fc5';

final class ThemeModeFamily extends $Family
    with $FunctionalFamilyOverride<Stream<ThemeSource>, String> {
  ThemeModeFamily._()
    : super(
        retry: null,
        name: r'themeModeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ThemeModeProvider call(String url) =>
      ThemeModeProvider._(argument: url, from: this);

  @override
  String toString() => r'themeModeProvider';
}

@ProviderFor(mediaCacheBudget)
final mediaCacheBudgetProvider = MediaCacheBudgetProvider._();

final class MediaCacheBudgetProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  MediaCacheBudgetProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mediaCacheBudgetProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mediaCacheBudgetHash();

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return mediaCacheBudget(ref);
  }
}

String _$mediaCacheBudgetHash() => r'8d427eb075ad0c5e12576e61f6ae84ba19e0e0ae';

@ProviderFor(filesCacheBudget)
final filesCacheBudgetProvider = FilesCacheBudgetProvider._();

final class FilesCacheBudgetProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  FilesCacheBudgetProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filesCacheBudgetProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filesCacheBudgetHash();

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return filesCacheBudget(ref);
  }
}

String _$filesCacheBudgetHash() => r'dc5590c2741e6fb8b79e38577f806a35c0a9af59';

/// Bytes of each cache kind across every signed-in server.

@ProviderFor(CacheUsage)
final cacheUsageProvider = CacheUsageProvider._();

/// Bytes of each cache kind across every signed-in server.
final class CacheUsageProvider
    extends $AsyncNotifierProvider<CacheUsage, Map<CacheKind, int>> {
  /// Bytes of each cache kind across every signed-in server.
  CacheUsageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cacheUsageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cacheUsageHash();

  @$internal
  @override
  CacheUsage create() => CacheUsage();
}

String _$cacheUsageHash() => r'd8c329b8812169942fb0fc2a3f12c45d13caae0f';

/// Bytes of each cache kind across every signed-in server.

abstract class _$CacheUsage extends $AsyncNotifier<Map<CacheKind, int>> {
  FutureOr<Map<CacheKind, int>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<Map<CacheKind, int>>, Map<CacheKind, int>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Map<CacheKind, int>>, Map<CacheKind, int>>,
              AsyncValue<Map<CacheKind, int>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
