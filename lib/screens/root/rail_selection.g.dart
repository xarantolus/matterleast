// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rail_selection.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The team (or server) picked in the rail; null is Home.

@ProviderFor(RailSelection)
final railSelectionProvider = RailSelectionProvider._();

/// The team (or server) picked in the rail; null is Home.
final class RailSelectionProvider
    extends $NotifierProvider<RailSelection, RailTarget?> {
  /// The team (or server) picked in the rail; null is Home.
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
  Override overrideWithValue(RailTarget? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RailTarget?>(value),
    );
  }
}

String _$railSelectionHash() => r'7af18cec5ae838e3c3d2b95fbf884cd996c8728d';

/// The team (or server) picked in the rail; null is Home.

abstract class _$RailSelection extends $Notifier<RailTarget?> {
  RailTarget? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<RailTarget?, RailTarget?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RailTarget?, RailTarget?>,
              RailTarget?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
