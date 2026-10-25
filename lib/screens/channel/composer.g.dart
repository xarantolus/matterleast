// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'composer.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The longest message the server takes.

@ProviderFor(maxPostSize)
final maxPostSizeProvider = MaxPostSizeFamily._();

/// The longest message the server takes.

final class MaxPostSizeProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  /// The longest message the server takes.
  MaxPostSizeProvider._({
    required MaxPostSizeFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'maxPostSizeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$maxPostSizeHash();

  @override
  String toString() {
    return r'maxPostSizeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    final argument = this.argument as String;
    return maxPostSize(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MaxPostSizeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$maxPostSizeHash() => r'd56d3a5fc398b9407ac37f7c86848fdb7f4bcacd';

/// The longest message the server takes.

final class MaxPostSizeFamily extends $Family
    with $FunctionalFamilyOverride<Stream<int>, String> {
  MaxPostSizeFamily._()
    : super(
        retry: null,
        name: r'maxPostSizeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The longest message the server takes.

  MaxPostSizeProvider call(String url) =>
      MaxPostSizeProvider._(argument: url, from: this);

  @override
  String toString() => r'maxPostSizeProvider';
}
