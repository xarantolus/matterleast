// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_server_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AddServerController)
final addServerControllerProvider = AddServerControllerProvider._();

final class AddServerControllerProvider
    extends $NotifierProvider<AddServerController, AddServerState> {
  AddServerControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addServerControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addServerControllerHash();

  @$internal
  @override
  AddServerController create() => AddServerController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AddServerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AddServerState>(value),
    );
  }
}

String _$addServerControllerHash() =>
    r'1c0f5ef02ebfddfbf74054596d9f01d4c0e6b530';

abstract class _$AddServerController extends $Notifier<AddServerState> {
  AddServerState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AddServerState, AddServerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AddServerState, AddServerState>,
              AddServerState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
