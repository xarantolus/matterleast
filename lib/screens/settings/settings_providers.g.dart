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

String _$settingsActionsHash() => r'6b5249ee682e7c44cc37a00efdb6039ab80f1131';

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

/// The account's notification settings, fetched from the server when the
/// page opens, since the server is the only place they live.

@ProviderFor(NotifySettings)
final notifySettingsProvider = NotifySettingsFamily._();

/// The account's notification settings, fetched from the server when the
/// page opens, since the server is the only place they live.
final class NotifySettingsProvider
    extends $AsyncNotifierProvider<NotifySettings, NotifyProps> {
  /// The account's notification settings, fetched from the server when the
  /// page opens, since the server is the only place they live.
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
  NotifySettings create() => NotifySettings();

  @override
  bool operator ==(Object other) {
    return other is NotifySettingsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$notifySettingsHash() => r'e5d0f7b641b8245ec11edecdbff9562907bb01a8';

/// The account's notification settings, fetched from the server when the
/// page opens, since the server is the only place they live.

final class NotifySettingsFamily extends $Family
    with
        $ClassFamilyOverride<
          NotifySettings,
          AsyncValue<NotifyProps>,
          NotifyProps,
          FutureOr<NotifyProps>,
          String
        > {
  NotifySettingsFamily._()
    : super(
        retry: null,
        name: r'notifySettingsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The account's notification settings, fetched from the server when the
  /// page opens, since the server is the only place they live.

  NotifySettingsProvider call(String url) =>
      NotifySettingsProvider._(argument: url, from: this);

  @override
  String toString() => r'notifySettingsProvider';
}

/// The account's notification settings, fetched from the server when the
/// page opens, since the server is the only place they live.

abstract class _$NotifySettings extends $AsyncNotifier<NotifyProps> {
  late final _$args = ref.$arg as String;
  String get url => _$args;

  FutureOr<NotifyProps> build(String url);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<NotifyProps>, NotifyProps>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<NotifyProps>, NotifyProps>,
              AsyncValue<NotifyProps>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
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

String _$displayPrefsHash() => r'517766472bb6e00859f83c5945314340fd4f65ea';

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

/// `brand` or `server`.

@ProviderFor(themeMode)
final themeModeProvider = ThemeModeFamily._();

/// `brand` or `server`.

final class ThemeModeProvider
    extends $FunctionalProvider<AsyncValue<String>, String, Stream<String>>
    with $FutureModifier<String>, $StreamProvider<String> {
  /// `brand` or `server`.
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
  $StreamProviderElement<String> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<String> create(Ref ref) {
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

String _$themeModeHash() => r'ae605ea22339af0d811dac3da21414442d10736a';

/// `brand` or `server`.

final class ThemeModeFamily extends $Family
    with $FunctionalFamilyOverride<Stream<String>, String> {
  ThemeModeFamily._()
    : super(
        retry: null,
        name: r'themeModeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// `brand` or `server`.

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
