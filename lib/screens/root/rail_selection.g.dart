// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rail_selection.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The server picked in the rail; null is Home.

@ProviderFor(RailSelection)
final railSelectionProvider = RailSelectionProvider._();

/// The server picked in the rail; null is Home.
final class RailSelectionProvider
    extends $NotifierProvider<RailSelection, String?> {
  /// The server picked in the rail; null is Home.
  RailSelectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'railSelectionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$railSelectionHash();

  @$internal
  @override
  RailSelection create() => RailSelection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$railSelectionHash() => r'5bfb2ca1f29e086faf6d8872573f70b18f2524b6';

/// The server picked in the rail; null is Home.

abstract class _$RailSelection extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
