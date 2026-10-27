// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'desktop_notifications.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(desktopNotifications)
final desktopNotificationsProvider = DesktopNotificationsProvider._();

final class DesktopNotificationsProvider
    extends
        $FunctionalProvider<
          DesktopNotifications,
          DesktopNotifications,
          DesktopNotifications
        >
    with $Provider<DesktopNotifications> {
  DesktopNotificationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'desktopNotificationsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$desktopNotificationsHash();

  @$internal
  @override
  $ProviderElement<DesktopNotifications> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DesktopNotifications create(Ref ref) {
    return desktopNotifications(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DesktopNotifications value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DesktopNotifications>(value),
    );
  }
}

String _$desktopNotificationsHash() =>
    r'c8da633cccc41bf174420e40b7e6af0bd897ba09';
