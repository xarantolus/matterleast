// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the user follows the thread; null without collapsed threads,
/// where there is nothing to follow.

@ProviderFor(threadFollowing)
final threadFollowingProvider = ThreadFollowingFamily._();

/// Whether the user follows the thread; null without collapsed threads,
/// where there is nothing to follow.

final class ThreadFollowingProvider
    extends $FunctionalProvider<AsyncValue<bool?>, bool?, Stream<bool?>>
    with $FutureModifier<bool?>, $StreamProvider<bool?> {
  /// Whether the user follows the thread; null without collapsed threads,
  /// where there is nothing to follow.
  ThreadFollowingProvider._({
    required ThreadFollowingFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'threadFollowingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$threadFollowingHash();

  @override
  String toString() {
    return r'threadFollowingProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<bool?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool?> create(Ref ref) {
    final argument = this.argument as (String, String);
    return threadFollowing(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ThreadFollowingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$threadFollowingHash() => r'59188333e379ce6b064f22a71560b14350be2e47';

/// Whether the user follows the thread; null without collapsed threads,
/// where there is nothing to follow.

final class ThreadFollowingFamily extends $Family
    with $FunctionalFamilyOverride<Stream<bool?>, (String, String)> {
  ThreadFollowingFamily._()
    : super(
        retry: null,
        name: r'threadFollowingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether the user follows the thread; null without collapsed threads,
  /// where there is nothing to follow.

  ThreadFollowingProvider call(String url, String rootId) =>
      ThreadFollowingProvider._(argument: (url, rootId), from: this);

  @override
  String toString() => r'threadFollowingProvider';
}
