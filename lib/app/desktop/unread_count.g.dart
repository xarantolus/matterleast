// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unread_count.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Unread mentions and direct messages over every signed-in server, from
/// the same lists the rail badges and Home show; null until all of them
/// were read once.

@ProviderFor(unreadCount)
final unreadCountProvider = UnreadCountProvider._();

/// Unread mentions and direct messages over every signed-in server, from
/// the same lists the rail badges and Home show; null until all of them
/// were read once.

final class UnreadCountProvider extends $FunctionalProvider<int?, int?, int?>
    with $Provider<int?> {
  /// Unread mentions and direct messages over every signed-in server, from
  /// the same lists the rail badges and Home show; null until all of them
  /// were read once.
  UnreadCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unreadCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unreadCountHash();

  @$internal
  @override
  $ProviderElement<int?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int? create(Ref ref) {
    return unreadCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int?>(value),
    );
  }
}

String _$unreadCountHash() => r'e61ba40b109566a49dad76b447f85869136b7f36';
