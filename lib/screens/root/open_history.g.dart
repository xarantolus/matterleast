// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'open_history.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Where the user went, across teams and servers, for Back and Forward.

@ProviderFor(openHistory)
final openHistoryProvider = OpenHistoryProvider._();

/// Where the user went, across teams and servers, for Back and Forward.

final class OpenHistoryProvider
    extends
        $FunctionalProvider<
          OpenHistory<Location>,
          OpenHistory<Location>,
          OpenHistory<Location>
        >
    with $Provider<OpenHistory<Location>> {
  /// Where the user went, across teams and servers, for Back and Forward.
  OpenHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'openHistoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$openHistoryHash();

  @$internal
  @override
  $ProviderElement<OpenHistory<Location>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OpenHistory<Location> create(Ref ref) {
    return openHistory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OpenHistory<Location> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OpenHistory<Location>>(value),
    );
  }
}

String _$openHistoryHash() => r'd686a20dedadaca1ab8c80b6c7bfd919e2ce48c1';
