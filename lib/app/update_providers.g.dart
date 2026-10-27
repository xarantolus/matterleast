// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(updateHttp)
final updateHttpProvider = UpdateHttpProvider._();

final class UpdateHttpProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  UpdateHttpProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateHttpProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateHttpHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return updateHttp(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$updateHttpHash() => r'f79f4468ed9ec9037e65ae3639be290bc5af1da0';

@ProviderFor(updateCheck)
final updateCheckProvider = UpdateCheckProvider._();

final class UpdateCheckProvider
    extends $FunctionalProvider<UpdateCheck, UpdateCheck, UpdateCheck>
    with $Provider<UpdateCheck> {
  UpdateCheckProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateCheckProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateCheckHash();

  @$internal
  @override
  $ProviderElement<UpdateCheck> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UpdateCheck create(Ref ref) {
    return updateCheck(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateCheck value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateCheck>(value),
    );
  }
}

String _$updateCheckHash() => r'0659926f73e6ff2dfb427dd8a9f336cb146eab3f';

@ProviderFor(latestRelease)
final latestReleaseProvider = LatestReleaseProvider._();

final class LatestReleaseProvider
    extends
        $FunctionalProvider<
          AsyncValue<KnownRelease?>,
          KnownRelease?,
          Stream<KnownRelease?>
        >
    with $FutureModifier<KnownRelease?>, $StreamProvider<KnownRelease?> {
  LatestReleaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'latestReleaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$latestReleaseHash();

  @$internal
  @override
  $StreamProviderElement<KnownRelease?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<KnownRelease?> create(Ref ref) {
    return latestRelease(ref);
  }
}

String _$latestReleaseHash() => r'c5756462676fa4391cbccc1ac242850f789cca72';

@ProviderFor(dismissedRelease)
final dismissedReleaseProvider = DismissedReleaseProvider._();

final class DismissedReleaseProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, Stream<String?>>
    with $FutureModifier<String?>, $StreamProvider<String?> {
  DismissedReleaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dismissedReleaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dismissedReleaseHash();

  @$internal
  @override
  $StreamProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<String?> create(Ref ref) {
    return dismissedRelease(ref);
  }
}

String _$dismissedReleaseHash() => r'3f1355ad7ff213ea12673057fa3286acb35c40e3';

/// The release the desktop update indicator points out, or null. Watching
/// it on desktop starts the daily check; phones update through their store
/// and never ask.

@ProviderFor(availableUpdate)
final availableUpdateProvider = AvailableUpdateProvider._();

/// The release the desktop update indicator points out, or null. Watching
/// it on desktop starts the daily check; phones update through their store
/// and never ask.

final class AvailableUpdateProvider
    extends $FunctionalProvider<KnownRelease?, KnownRelease?, KnownRelease?>
    with $Provider<KnownRelease?> {
  /// The release the desktop update indicator points out, or null. Watching
  /// it on desktop starts the daily check; phones update through their store
  /// and never ask.
  AvailableUpdateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'availableUpdateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$availableUpdateHash();

  @$internal
  @override
  $ProviderElement<KnownRelease?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  KnownRelease? create(Ref ref) {
    return availableUpdate(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KnownRelease? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KnownRelease?>(value),
    );
  }
}

String _$availableUpdateHash() => r'065c096971dd259b4b9efc0babe6dc9825b20517';
