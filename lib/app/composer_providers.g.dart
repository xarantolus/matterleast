// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'composer_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Kept while the app runs, like the session it wraps.

@ProviderFor(composerActions)
final composerActionsProvider = ComposerActionsFamily._();

/// Kept while the app runs, like the session it wraps.

final class ComposerActionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<ComposerActions>,
          ComposerActions,
          FutureOr<ComposerActions>
        >
    with $FutureModifier<ComposerActions>, $FutureProvider<ComposerActions> {
  /// Kept while the app runs, like the session it wraps.
  ComposerActionsProvider._({
    required ComposerActionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'composerActionsProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$composerActionsHash();

  @override
  String toString() {
    return r'composerActionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ComposerActions> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ComposerActions> create(Ref ref) {
    final argument = this.argument as String;
    return composerActions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ComposerActionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$composerActionsHash() => r'b74481a3701d8b111439742bf9a92a73c7a0cf0a';

/// Kept while the app runs, like the session it wraps.

final class ComposerActionsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ComposerActions>, String> {
  ComposerActionsFamily._()
    : super(
        retry: null,
        name: r'composerActionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Kept while the app runs, like the session it wraps.

  ComposerActionsProvider call(String url) =>
      ComposerActionsProvider._(argument: url, from: this);

  @override
  String toString() => r'composerActionsProvider';
}

/// Posts the server refused for good, as they happen, to tell the user.

@ProviderFor(rejectedPosts)
final rejectedPostsProvider = RejectedPostsFamily._();

/// Posts the server refused for good, as they happen, to tell the user.

final class RejectedPostsProvider
    extends
        $FunctionalProvider<
          AsyncValue<PostRejected>,
          PostRejected,
          Stream<PostRejected>
        >
    with $FutureModifier<PostRejected>, $StreamProvider<PostRejected> {
  /// Posts the server refused for good, as they happen, to tell the user.
  RejectedPostsProvider._({
    required RejectedPostsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'rejectedPostsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$rejectedPostsHash();

  @override
  String toString() {
    return r'rejectedPostsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<PostRejected> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<PostRejected> create(Ref ref) {
    final argument = this.argument as String;
    return rejectedPosts(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RejectedPostsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$rejectedPostsHash() => r'c5efac81b8e382db8d90dce6b45f4e417985599f';

/// Posts the server refused for good, as they happen, to tell the user.

final class RejectedPostsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<PostRejected>, String> {
  RejectedPostsFamily._()
    : super(
        retry: null,
        name: r'rejectedPostsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Posts the server refused for good, as they happen, to tell the user.

  RejectedPostsProvider call(String url) =>
      RejectedPostsProvider._(argument: url, from: this);

  @override
  String toString() => r'rejectedPostsProvider';
}
