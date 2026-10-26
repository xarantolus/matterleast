// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The largest file the server takes, null when it doesn't say.

@ProviderFor(shareSizeLimit)
final shareSizeLimitProvider = ShareSizeLimitFamily._();

/// The largest file the server takes, null when it doesn't say.

final class ShareSizeLimitProvider
    extends $FunctionalProvider<AsyncValue<int?>, int?, FutureOr<int?>>
    with $FutureModifier<int?>, $FutureProvider<int?> {
  /// The largest file the server takes, null when it doesn't say.
  ShareSizeLimitProvider._({
    required ShareSizeLimitFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'shareSizeLimitProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$shareSizeLimitHash();

  @override
  String toString() {
    return r'shareSizeLimitProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<int?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int?> create(Ref ref) {
    final argument = this.argument as String;
    return shareSizeLimit(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ShareSizeLimitProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$shareSizeLimitHash() => r'10698137072e0ef8289c8b4eb60aac5ee5038658';

/// The largest file the server takes, null when it doesn't say.

final class ShareSizeLimitFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<int?>, String> {
  ShareSizeLimitFamily._()
    : super(
        retry: null,
        name: r'shareSizeLimitProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The largest file the server takes, null when it doesn't say.

  ShareSizeLimitProvider call(String url) =>
      ShareSizeLimitProvider._(argument: url, from: this);

  @override
  String toString() => r'shareSizeLimitProvider';
}
