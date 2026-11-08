// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_saver.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether Android's Data Saver or iOS Low Data Mode restricts this app;
/// never on desktop. The phone reports every change.

@ProviderFor(dataSaver)
final dataSaverProvider = DataSaverProvider._();

/// Whether Android's Data Saver or iOS Low Data Mode restricts this app;
/// never on desktop. The phone reports every change.

final class DataSaverProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Whether Android's Data Saver or iOS Low Data Mode restricts this app;
  /// never on desktop. The phone reports every change.
  DataSaverProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dataSaverProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dataSaverHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return dataSaver(ref);
  }
}

String _$dataSaverHash() => r'ed8d4b4dc75a0cdcc36d9d563be95e422fa239b5';
