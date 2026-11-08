// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_environment.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(messageLinks)
final messageLinksProvider = MessageLinksFamily._();

final class MessageLinksProvider
    extends
        $FunctionalProvider<
          AsyncValue<MessageLinks>,
          MessageLinks,
          FutureOr<MessageLinks>
        >
    with $FutureModifier<MessageLinks>, $FutureProvider<MessageLinks> {
  MessageLinksProvider._({
    required MessageLinksFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'messageLinksProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$messageLinksHash();

  @override
  String toString() {
    return r'messageLinksProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<MessageLinks> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MessageLinks> create(Ref ref) {
    final argument = this.argument as String;
    return messageLinks(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MessageLinksProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$messageLinksHash() => r'1b18652b27d91b6c6dfebb15e7030b202989b620';

final class MessageLinksFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<MessageLinks>, String> {
  MessageLinksFamily._()
    : super(
        retry: null,
        name: r'messageLinksProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MessageLinksProvider call(String url) =>
      MessageLinksProvider._(argument: url, from: this);

  @override
  String toString() => r'messageLinksProvider';
}

/// Kept while the app runs, so a second tap joins an action still running.

@ProviderFor(integrationActions)
final integrationActionsProvider = IntegrationActionsFamily._();

/// Kept while the app runs, so a second tap joins an action still running.

final class IntegrationActionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<IntegrationActions>,
          IntegrationActions,
          FutureOr<IntegrationActions>
        >
    with
        $FutureModifier<IntegrationActions>,
        $FutureProvider<IntegrationActions> {
  /// Kept while the app runs, so a second tap joins an action still running.
  IntegrationActionsProvider._({
    required IntegrationActionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'integrationActionsProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$integrationActionsHash();

  @override
  String toString() {
    return r'integrationActionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<IntegrationActions> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<IntegrationActions> create(Ref ref) {
    final argument = this.argument as String;
    return integrationActions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is IntegrationActionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$integrationActionsHash() =>
    r'da21f60897f6a589a2d6bf870e1e02b80a763186';

/// Kept while the app runs, so a second tap joins an action still running.

final class IntegrationActionsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<IntegrationActions>, String> {
  IntegrationActionsFamily._()
    : super(
        retry: null,
        name: r'integrationActionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Kept while the app runs, so a second tap joins an action still running.

  IntegrationActionsProvider call(String url) =>
      IntegrationActionsProvider._(argument: url, from: this);

  @override
  String toString() => r'integrationActionsProvider';
}

@ProviderFor(parseOptions)
final parseOptionsProvider = ParseOptionsFamily._();

final class ParseOptionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<ParseOptions>,
          ParseOptions,
          Stream<ParseOptions>
        >
    with $FutureModifier<ParseOptions>, $StreamProvider<ParseOptions> {
  ParseOptionsProvider._({
    required ParseOptionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'parseOptionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$parseOptionsHash();

  @override
  String toString() {
    return r'parseOptionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<ParseOptions> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ParseOptions> create(Ref ref) {
    final argument = this.argument as String;
    return parseOptions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ParseOptionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$parseOptionsHash() => r'27139a880fa10cf718f243511059433df467cd4d';

final class ParseOptionsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<ParseOptions>, String> {
  ParseOptionsFamily._()
    : super(
        retry: null,
        name: r'parseOptionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ParseOptionsProvider call(String url) =>
      ParseOptionsProvider._(argument: url, from: this);

  @override
  String toString() => r'parseOptionsProvider';
}

/// The reader's mention and highlight words, from their notification
/// settings as they change.

@ProviderFor(mentionKeys)
final mentionKeysProvider = MentionKeysFamily._();

/// The reader's mention and highlight words, from their notification
/// settings as they change.

final class MentionKeysProvider
    extends
        $FunctionalProvider<
          AsyncValue<MentionKeys>,
          MentionKeys,
          Stream<MentionKeys>
        >
    with $FutureModifier<MentionKeys>, $StreamProvider<MentionKeys> {
  /// The reader's mention and highlight words, from their notification
  /// settings as they change.
  MentionKeysProvider._({
    required MentionKeysFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'mentionKeysProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$mentionKeysHash();

  @override
  String toString() {
    return r'mentionKeysProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<MentionKeys> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<MentionKeys> create(Ref ref) {
    final argument = this.argument as String;
    return mentionKeys(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MentionKeysProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$mentionKeysHash() => r'9a6354a3e7a817ae6f54ea5da930717628139191';

/// The reader's mention and highlight words, from their notification
/// settings as they change.

final class MentionKeysFamily extends $Family
    with $FunctionalFamilyOverride<Stream<MentionKeys>, String> {
  MentionKeysFamily._()
    : super(
        retry: null,
        name: r'mentionKeysProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The reader's mention and highlight words, from their notification
  /// settings as they change.

  MentionKeysProvider call(String url) =>
      MentionKeysProvider._(argument: url, from: this);

  @override
  String toString() => r'mentionKeysProvider';
}

/// Whether the user turned off `@channel`, `@all` and `@here` for a channel.

@ProviderFor(ignoresChannelMentions)
final ignoresChannelMentionsProvider = IgnoresChannelMentionsFamily._();

/// Whether the user turned off `@channel`, `@all` and `@here` for a channel.

final class IgnoresChannelMentionsProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Whether the user turned off `@channel`, `@all` and `@here` for a channel.
  IgnoresChannelMentionsProvider._({
    required IgnoresChannelMentionsFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'ignoresChannelMentionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$ignoresChannelMentionsHash();

  @override
  String toString() {
    return r'ignoresChannelMentionsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    final argument = this.argument as (String, String);
    return ignoresChannelMentions(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is IgnoresChannelMentionsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$ignoresChannelMentionsHash() =>
    r'38b94075c61604b56bf6a54c568175220e061984';

/// Whether the user turned off `@channel`, `@all` and `@here` for a channel.

final class IgnoresChannelMentionsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<bool>, (String, String)> {
  IgnoresChannelMentionsFamily._()
    : super(
        retry: null,
        name: r'ignoresChannelMentionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether the user turned off `@channel`, `@all` and `@here` for a channel.

  IgnoresChannelMentionsProvider call(String url, String channelId) =>
      IgnoresChannelMentionsProvider._(argument: (url, channelId), from: this);

  @override
  String toString() => r'ignoresChannelMentionsProvider';
}

@ProviderFor(postDisplay)
final postDisplayProvider = PostDisplayFamily._();

final class PostDisplayProvider
    extends
        $FunctionalProvider<
          AsyncValue<PostDisplay>,
          PostDisplay,
          Stream<PostDisplay>
        >
    with $FutureModifier<PostDisplay>, $StreamProvider<PostDisplay> {
  PostDisplayProvider._({
    required PostDisplayFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'postDisplayProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$postDisplayHash();

  @override
  String toString() {
    return r'postDisplayProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<PostDisplay> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<PostDisplay> create(Ref ref) {
    final argument = this.argument as String;
    return postDisplay(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PostDisplayProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$postDisplayHash() => r'0e43b1629a7a9a570364c727234f257b65b6197d';

final class PostDisplayFamily extends $Family
    with $FunctionalFamilyOverride<Stream<PostDisplay>, String> {
  PostDisplayFamily._()
    : super(
        retry: null,
        name: r'postDisplayProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PostDisplayProvider call(String url) =>
      PostDisplayProvider._(argument: url, from: this);

  @override
  String toString() => r'postDisplayProvider';
}
