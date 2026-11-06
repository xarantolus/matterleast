// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'in_app_notifications.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(noticeRouter)
final noticeRouterProvider = NoticeRouterProvider._();

final class NoticeRouterProvider
    extends $FunctionalProvider<NoticeRouter, NoticeRouter, NoticeRouter>
    with $Provider<NoticeRouter> {
  NoticeRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'noticeRouterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$noticeRouterHash();

  @$internal
  @override
  $ProviderElement<NoticeRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NoticeRouter create(Ref ref) {
    return noticeRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NoticeRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NoticeRouter>(value),
    );
  }
}

String _$noticeRouterHash() => r'19f25be7f39c7bc26aea1e42484163caaae648c8';

@ProviderFor(inAppNotifications)
final inAppNotificationsProvider = InAppNotificationsProvider._();

final class InAppNotificationsProvider
    extends
        $FunctionalProvider<
          InAppNotifications,
          InAppNotifications,
          InAppNotifications
        >
    with $Provider<InAppNotifications> {
  InAppNotificationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inAppNotificationsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inAppNotificationsHash();

  @$internal
  @override
  $ProviderElement<InAppNotifications> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  InAppNotifications create(Ref ref) {
    return inAppNotifications(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InAppNotifications value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InAppNotifications>(value),
    );
  }
}

String _$inAppNotificationsHash() =>
    r'e46b8fcb6f06e50274059e1082d9681e1be0d6ea';
