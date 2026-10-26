// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_places.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Hands the reading position of a conversation on to the next view of it
/// when a window change moves the conversation between a pane and a route,
/// so the reader stays where they were.

@ProviderFor(readingPlaces)
final readingPlacesProvider = ReadingPlacesProvider._();

/// Hands the reading position of a conversation on to the next view of it
/// when a window change moves the conversation between a pane and a route,
/// so the reader stays where they were.

final class ReadingPlacesProvider
    extends $FunctionalProvider<ReadingPlaces, ReadingPlaces, ReadingPlaces>
    with $Provider<ReadingPlaces> {
  /// Hands the reading position of a conversation on to the next view of it
  /// when a window change moves the conversation between a pane and a route,
  /// so the reader stays where they were.
  ReadingPlacesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readingPlacesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readingPlacesHash();

  @$internal
  @override
  $ProviderElement<ReadingPlaces> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReadingPlaces create(Ref ref) {
    return readingPlaces(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReadingPlaces value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReadingPlaces>(value),
    );
  }
}

String _$readingPlacesHash() => r'1f3ede1ec426b3cf355f6679463db82d83eff413';
