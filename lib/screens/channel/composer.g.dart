// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'composer.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether messages can be marked important or urgent, and whether they
/// can ask for acknowledgement.

@ProviderFor(postPriorityOptions)
final postPriorityOptionsProvider = PostPriorityOptionsFamily._();

/// Whether messages can be marked important or urgent, and whether they
/// can ask for acknowledgement.

final class PostPriorityOptionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<({bool acknowledgements, bool priority})>,
          ({bool acknowledgements, bool priority}),
          Stream<({bool acknowledgements, bool priority})>
        >
    with
        $FutureModifier<({bool acknowledgements, bool priority})>,
        $StreamProvider<({bool acknowledgements, bool priority})> {
  /// Whether messages can be marked important or urgent, and whether they
  /// can ask for acknowledgement.
  PostPriorityOptionsProvider._({
    required PostPriorityOptionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'postPriorityOptionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$postPriorityOptionsHash();

  @override
  String toString() {
    return r'postPriorityOptionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<({bool acknowledgements, bool priority})>
  $createElement($ProviderPointer pointer) => $StreamProviderElement(pointer);

  @override
  Stream<({bool acknowledgements, bool priority})> create(Ref ref) {
    final argument = this.argument as String;
    return postPriorityOptions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PostPriorityOptionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$postPriorityOptionsHash() =>
    r'43d89998088f6aeb6b0382e65a2b16b801685a47';

/// Whether messages can be marked important or urgent, and whether they
/// can ask for acknowledgement.

final class PostPriorityOptionsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<({bool acknowledgements, bool priority})>,
          String
        > {
  PostPriorityOptionsFamily._()
    : super(
        retry: null,
        name: r'postPriorityOptionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether messages can be marked important or urgent, and whether they
  /// can ask for acknowledgement.

  PostPriorityOptionsProvider call(String url) =>
      PostPriorityOptionsProvider._(argument: url, from: this);

  @override
  String toString() => r'postPriorityOptionsProvider';
}

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

String _$maxPostSizeHash() => r'1ca3512f18a66121b501ff320a84930e9a1a13ce';

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
