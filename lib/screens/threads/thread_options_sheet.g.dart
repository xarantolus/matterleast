// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_options_sheet.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the thread's first post is saved, and the team name its link
/// needs.

@ProviderFor(threadOptionFacts)
final threadOptionFactsProvider = ThreadOptionFactsFamily._();

/// Whether the thread's first post is saved, and the team name its link
/// needs.

final class ThreadOptionFactsProvider
    extends
        $FunctionalProvider<
          AsyncValue<({bool saved, String teamName})>,
          ({bool saved, String teamName}),
          FutureOr<({bool saved, String teamName})>
        >
    with
        $FutureModifier<({bool saved, String teamName})>,
        $FutureProvider<({bool saved, String teamName})> {
  /// Whether the thread's first post is saved, and the team name its link
  /// needs.
  ThreadOptionFactsProvider._({
    required ThreadOptionFactsFamily super.from,
    required (String, String, String?) super.argument,
  }) : super(
         retry: null,
         name: r'threadOptionFactsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$threadOptionFactsHash();

  @override
  String toString() {
    return r'threadOptionFactsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<({bool saved, String teamName})> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<({bool saved, String teamName})> create(Ref ref) {
    final argument = this.argument as (String, String, String?);
    return threadOptionFacts(ref, argument.$1, argument.$2, argument.$3);
  }

  @override
  bool operator ==(Object other) {
    return other is ThreadOptionFactsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$threadOptionFactsHash() => r'e1c655929008e4572acc8f2b7a423d4fecb0c879';

/// Whether the thread's first post is saved, and the team name its link
/// needs.

final class ThreadOptionFactsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<({bool saved, String teamName})>,
          (String, String, String?)
        > {
  ThreadOptionFactsFamily._()
    : super(
        retry: null,
        name: r'threadOptionFactsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether the thread's first post is saved, and the team name its link
  /// needs.

  ThreadOptionFactsProvider call(String url, String rootId, String? teamId) =>
      ThreadOptionFactsProvider._(argument: (url, rootId, teamId), from: this);

  @override
  String toString() => r'threadOptionFactsProvider';
}
