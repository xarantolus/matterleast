// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dismissedAnnouncements)
final dismissedAnnouncementsProvider = DismissedAnnouncementsProvider._();

final class DismissedAnnouncementsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, String>>,
          Map<String, String>,
          Stream<Map<String, String>>
        >
    with
        $FutureModifier<Map<String, String>>,
        $StreamProvider<Map<String, String>> {
  DismissedAnnouncementsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dismissedAnnouncementsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dismissedAnnouncementsHash();

  @$internal
  @override
  $StreamProviderElement<Map<String, String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, String>> create(Ref ref) {
    return dismissedAnnouncements(ref);
  }
}

String _$dismissedAnnouncementsHash() =>
    r'91fc0697c48c146dc755c461ecc277b05fa8599d';

/// The server's announcement to show now, or null.

@ProviderFor(announcementBanner)
final announcementBannerProvider = AnnouncementBannerFamily._();

/// The server's announcement to show now, or null.

final class AnnouncementBannerProvider
    extends $FunctionalProvider<Announcement?, Announcement?, Announcement?>
    with $Provider<Announcement?> {
  /// The server's announcement to show now, or null.
  AnnouncementBannerProvider._({
    required AnnouncementBannerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'announcementBannerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$announcementBannerHash();

  @override
  String toString() {
    return r'announcementBannerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Announcement?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Announcement? create(Ref ref) {
    final argument = this.argument as String;
    return announcementBanner(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Announcement? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Announcement?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AnnouncementBannerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$announcementBannerHash() =>
    r'78e2473dd318a9ae7a17abbcb9c486793774430e';

/// The server's announcement to show now, or null.

final class AnnouncementBannerFamily extends $Family
    with $FunctionalFamilyOverride<Announcement?, String> {
  AnnouncementBannerFamily._()
    : super(
        retry: null,
        name: r'announcementBannerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The server's announcement to show now, or null.

  AnnouncementBannerProvider call(String url) =>
      AnnouncementBannerProvider._(argument: url, from: this);

  @override
  String toString() => r'announcementBannerProvider';
}
