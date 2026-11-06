// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notice_banner.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// How long a banner shows.

@ProviderFor(noticeBannerDuration)
final noticeBannerDurationProvider = NoticeBannerDurationProvider._();

/// How long a banner shows.

final class NoticeBannerDurationProvider
    extends $FunctionalProvider<Duration, Duration, Duration>
    with $Provider<Duration> {
  /// How long a banner shows.
  NoticeBannerDurationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'noticeBannerDurationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$noticeBannerDurationHash();

  @$internal
  @override
  $ProviderElement<Duration> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Duration create(Ref ref) {
    return noticeBannerDuration(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Duration value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Duration>(value),
    );
  }
}

String _$noticeBannerDurationHash() =>
    r'a6868eaf18dc00d88db78fe11968735ea3a5d043';

/// The one banner on screen, if any; a newer notice replaces it.

@ProviderFor(NoticeBanners)
final noticeBannersProvider = NoticeBannersProvider._();

/// The one banner on screen, if any; a newer notice replaces it.
final class NoticeBannersProvider
    extends $NotifierProvider<NoticeBanners, BannerNotice?> {
  /// The one banner on screen, if any; a newer notice replaces it.
  NoticeBannersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'noticeBannersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$noticeBannersHash();

  @$internal
  @override
  NoticeBanners create() => NoticeBanners();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BannerNotice? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BannerNotice?>(value),
    );
  }
}

String _$noticeBannersHash() => r'87b7f3d09ac06b4566cd67651f1165b359339619';

/// The one banner on screen, if any; a newer notice replaces it.

abstract class _$NoticeBanners extends $Notifier<BannerNotice?> {
  BannerNotice? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<BannerNotice?, BannerNotice?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BannerNotice?, BannerNotice?>,
              BannerNotice?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
