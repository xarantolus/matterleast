// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'composer_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Kept while the app runs, like the session it wraps, so a draft save
/// outlives the screen that started it. Waiting drafts are written when the
/// app is hidden.

@ProviderFor(composerActions)
final composerActionsProvider = ComposerActionsFamily._();

/// Kept while the app runs, like the session it wraps, so a draft save
/// outlives the screen that started it. Waiting drafts are written when the
/// app is hidden.

final class ComposerActionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<ComposerActions>,
          ComposerActions,
          FutureOr<ComposerActions>
        >
    with $FutureModifier<ComposerActions>, $FutureProvider<ComposerActions> {
  /// Kept while the app runs, like the session it wraps, so a draft save
  /// outlives the screen that started it. Waiting drafts are written when the
  /// app is hidden.
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

String _$composerActionsHash() => r'ce5e21d5eaef594af23a5802a2fb651044228c57';

/// Kept while the app runs, like the session it wraps, so a draft save
/// outlives the screen that started it. Waiting drafts are written when the
/// app is hidden.

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

  /// Kept while the app runs, like the session it wraps, so a draft save
  /// outlives the screen that started it. Waiting drafts are written when the
  /// app is hidden.

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

/// The names of the people writing in a channel (empty [rootId]) or thread,
/// first to start first.

@ProviderFor(typingNames)
final typingNamesProvider = TypingNamesFamily._();

/// The names of the people writing in a channel (empty [rootId]) or thread,
/// first to start first.

final class TypingNamesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          Stream<List<String>>
        >
    with $FutureModifier<List<String>>, $StreamProvider<List<String>> {
  /// The names of the people writing in a channel (empty [rootId]) or thread,
  /// first to start first.
  TypingNamesProvider._({
    required TypingNamesFamily super.from,
    required (String, String, String) super.argument,
  }) : super(
         retry: null,
         name: r'typingNamesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$typingNamesHash();

  @override
  String toString() {
    return r'typingNamesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<String>> create(Ref ref) {
    final argument = this.argument as (String, String, String);
    return typingNames(ref, argument.$1, argument.$2, argument.$3);
  }

  @override
  bool operator ==(Object other) {
    return other is TypingNamesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$typingNamesHash() => r'22f5b975d29d5729760249d0744e7b5e5caed567';

/// The names of the people writing in a channel (empty [rootId]) or thread,
/// first to start first.

final class TypingNamesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<String>>,
          (String, String, String)
        > {
  TypingNamesFamily._()
    : super(
        retry: null,
        name: r'typingNamesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The names of the people writing in a channel (empty [rootId]) or thread,
  /// first to start first.

  TypingNamesProvider call(String url, String channelId, String rootId) =>
      TypingNamesProvider._(argument: (url, channelId, rootId), from: this);

  @override
  String toString() => r'typingNamesProvider';
}

/// Dialogs integrations open in answer to this device's commands, to show
/// as they come.

@ProviderFor(openDialogs)
final openDialogsProvider = OpenDialogsFamily._();

/// Dialogs integrations open in answer to this device's commands, to show
/// as they come.

final class OpenDialogsProvider
    extends
        $FunctionalProvider<
          AsyncValue<OpenDialog>,
          OpenDialog,
          Stream<OpenDialog>
        >
    with $FutureModifier<OpenDialog>, $StreamProvider<OpenDialog> {
  /// Dialogs integrations open in answer to this device's commands, to show
  /// as they come.
  OpenDialogsProvider._({
    required OpenDialogsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'openDialogsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$openDialogsHash();

  @override
  String toString() {
    return r'openDialogsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<OpenDialog> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<OpenDialog> create(Ref ref) {
    final argument = this.argument as String;
    return openDialogs(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is OpenDialogsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$openDialogsHash() => r'7ed0fad121af84f2089b8ffc6ad9245ca3b38496';

/// Dialogs integrations open in answer to this device's commands, to show
/// as they come.

final class OpenDialogsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<OpenDialog>, String> {
  OpenDialogsFamily._()
    : super(
        retry: null,
        name: r'openDialogsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Dialogs integrations open in answer to this device's commands, to show
  /// as they come.

  OpenDialogsProvider call(String url) =>
      OpenDialogsProvider._(argument: url, from: this);

  @override
  String toString() => r'openDialogsProvider';
}

/// What the message menu does to a post.

@ProviderFor(postActions)
final postActionsProvider = PostActionsFamily._();

/// What the message menu does to a post.

final class PostActionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<PostActions>,
          PostActions,
          FutureOr<PostActions>
        >
    with $FutureModifier<PostActions>, $FutureProvider<PostActions> {
  /// What the message menu does to a post.
  PostActionsProvider._({
    required PostActionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'postActionsProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$postActionsHash();

  @override
  String toString() {
    return r'postActionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<PostActions> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PostActions> create(Ref ref) {
    final argument = this.argument as String;
    return postActions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PostActionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$postActionsHash() => r'5fcdb6425d59d018c1526b18502091b51b148e64';

/// What the message menu does to a post.

final class PostActionsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<PostActions>, String> {
  PostActionsFamily._()
    : super(
        retry: null,
        name: r'postActionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// What the message menu does to a post.

  PostActionsProvider call(String url) =>
      PostActionsProvider._(argument: url, from: this);

  @override
  String toString() => r'postActionsProvider';
}
