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

String _$parseOptionsHash() => r'a8487d7429a29fefd85aef6b3314b012efeb68b4';

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

String _$postDisplayHash() => r'55a5d7c0430feec47f58081b2c208e0cc0686d21';

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
