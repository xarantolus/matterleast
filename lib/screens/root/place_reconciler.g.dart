// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_reconciler.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Closes what is open whenever the place the rail shows changes, for any reason.

@ProviderFor(placeReconciler)
final placeReconcilerProvider = PlaceReconcilerProvider._();

/// Closes what is open whenever the place the rail shows changes, for any reason.

final class PlaceReconcilerProvider
    extends
        $FunctionalProvider<PlaceReconciler, PlaceReconciler, PlaceReconciler>
    with $Provider<PlaceReconciler> {
  /// Closes what is open whenever the place the rail shows changes, for any reason.
  PlaceReconcilerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'placeReconcilerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$placeReconcilerHash();

  @$internal
  @override
  $ProviderElement<PlaceReconciler> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PlaceReconciler create(Ref ref) {
    return placeReconciler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlaceReconciler value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlaceReconciler>(value),
    );
  }
}

String _$placeReconcilerHash() => r'0bb5d402084971946f6ff2764469b4adbb1385cc';
