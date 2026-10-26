// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the server runs a supported Agents plugin; follows plugin
/// changes. False while unknown, so nothing shows that might vanish.

@ProviderFor(agentsAvailable)
final agentsAvailableProvider = AgentsAvailableFamily._();

/// Whether the server runs a supported Agents plugin; follows plugin
/// changes. False while unknown, so nothing shows that might vanish.

final class AgentsAvailableProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the server runs a supported Agents plugin; follows plugin
  /// changes. False while unknown, so nothing shows that might vanish.
  AgentsAvailableProvider._({
    required AgentsAvailableFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'agentsAvailableProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$agentsAvailableHash();

  @override
  String toString() {
    return r'agentsAvailableProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as String;
    return agentsAvailable(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AgentsAvailableProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$agentsAvailableHash() => r'bcd2eb4844615951389724d40c4eeb20fed74ff7';

/// Whether the server runs a supported Agents plugin; follows plugin
/// changes. False while unknown, so nothing shows that might vanish.

final class AgentsAvailableFamily extends $Family
    with $FunctionalFamilyOverride<bool, String> {
  AgentsAvailableFamily._()
    : super(
        retry: null,
        name: r'agentsAvailableProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether the server runs a supported Agents plugin; follows plugin
  /// changes. False while unknown, so nothing shows that might vanish.

  AgentsAvailableProvider call(String url) =>
      AgentsAvailableProvider._(argument: url, from: this);

  @override
  String toString() => r'agentsAvailableProvider';
}

@ProviderFor(agentActions)
final agentActionsProvider = AgentActionsFamily._();

final class AgentActionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<AgentActions>,
          AgentActions,
          FutureOr<AgentActions>
        >
    with $FutureModifier<AgentActions>, $FutureProvider<AgentActions> {
  AgentActionsProvider._({
    required AgentActionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'agentActionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$agentActionsHash();

  @override
  String toString() {
    return r'agentActionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<AgentActions> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AgentActions> create(Ref ref) {
    final argument = this.argument as String;
    return agentActions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AgentActionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$agentActionsHash() => r'634b42e6bc55efdb483a613d9075c3e42afa328f';

final class AgentActionsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<AgentActions>, String> {
  AgentActionsFamily._()
    : super(
        retry: null,
        name: r'agentActionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AgentActionsProvider call(String url) =>
      AgentActionsProvider._(argument: url, from: this);

  @override
  String toString() => r'agentActionsProvider';
}

/// The agents the user may talk to; none when the plugin is gone.

@ProviderFor(agentBots)
final agentBotsProvider = AgentBotsFamily._();

/// The agents the user may talk to; none when the plugin is gone.

final class AgentBotsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AgentBot>>,
          List<AgentBot>,
          FutureOr<List<AgentBot>>
        >
    with $FutureModifier<List<AgentBot>>, $FutureProvider<List<AgentBot>> {
  /// The agents the user may talk to; none when the plugin is gone.
  AgentBotsProvider._({
    required AgentBotsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'agentBotsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$agentBotsHash();

  @override
  String toString() {
    return r'agentBotsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<AgentBot>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AgentBot>> create(Ref ref) {
    final argument = this.argument as String;
    return agentBots(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AgentBotsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$agentBotsHash() => r'2dcfeb0d5a3fbdb2e1316b87a5eeb733032e54fa';

/// The agents the user may talk to; none when the plugin is gone.

final class AgentBotsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<AgentBot>>, String> {
  AgentBotsFamily._()
    : super(
        retry: null,
        name: r'agentBotsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The agents the user may talk to; none when the plugin is gone.

  AgentBotsProvider call(String url) =>
      AgentBotsProvider._(argument: url, from: this);

  @override
  String toString() => r'agentBotsProvider';
}

/// The user's conversations with agents, newest first.

@ProviderFor(agentThreads)
final agentThreadsProvider = AgentThreadsFamily._();

/// The user's conversations with agents, newest first.

final class AgentThreadsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AgentThread>>,
          List<AgentThread>,
          FutureOr<List<AgentThread>>
        >
    with
        $FutureModifier<List<AgentThread>>,
        $FutureProvider<List<AgentThread>> {
  /// The user's conversations with agents, newest first.
  AgentThreadsProvider._({
    required AgentThreadsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'agentThreadsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$agentThreadsHash();

  @override
  String toString() {
    return r'agentThreadsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<AgentThread>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AgentThread>> create(Ref ref) {
    final argument = this.argument as String;
    return agentThreads(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AgentThreadsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$agentThreadsHash() => r'8de522f359771a4048c279eb0395197ca292deab';

/// The user's conversations with agents, newest first.

final class AgentThreadsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<AgentThread>>, String> {
  AgentThreadsFamily._()
    : super(
        retry: null,
        name: r'agentThreadsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The user's conversations with agents, newest first.

  AgentThreadsProvider call(String url) =>
      AgentThreadsProvider._(argument: url, from: this);

  @override
  String toString() => r'agentThreadsProvider';
}

/// What is streaming into agent post [postId].

@ProviderFor(agentStream)
final agentStreamProvider = AgentStreamFamily._();

/// What is streaming into agent post [postId].

final class AgentStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<AgentStream?>,
          AgentStream?,
          Stream<AgentStream?>
        >
    with $FutureModifier<AgentStream?>, $StreamProvider<AgentStream?> {
  /// What is streaming into agent post [postId].
  AgentStreamProvider._({
    required AgentStreamFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'agentStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$agentStreamHash();

  @override
  String toString() {
    return r'agentStreamProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<AgentStream?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<AgentStream?> create(Ref ref) {
    final argument = this.argument as (String, String);
    return agentStream(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is AgentStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$agentStreamHash() => r'4b109c9f7d279e1326638b703fd139f6f9271753';

/// What is streaming into agent post [postId].

final class AgentStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<AgentStream?>, (String, String)> {
  AgentStreamFamily._()
    : super(
        retry: null,
        name: r'agentStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// What is streaming into agent post [postId].

  AgentStreamProvider call(String url, String postId) =>
      AgentStreamProvider._(argument: (url, postId), from: this);

  @override
  String toString() => r'agentStreamProvider';
}

/// The conversation of agent post [postId] (plugin 2.x).

@ProviderFor(agentConversation)
final agentConversationProvider = AgentConversationFamily._();

/// The conversation of agent post [postId] (plugin 2.x).

final class AgentConversationProvider
    extends
        $FunctionalProvider<
          AsyncValue<AgentConversationState>,
          AgentConversationState,
          Stream<AgentConversationState>
        >
    with
        $FutureModifier<AgentConversationState>,
        $StreamProvider<AgentConversationState> {
  /// The conversation of agent post [postId] (plugin 2.x).
  AgentConversationProvider._({
    required AgentConversationFamily super.from,
    required (String, String, String) super.argument,
  }) : super(
         retry: null,
         name: r'agentConversationProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$agentConversationHash();

  @override
  String toString() {
    return r'agentConversationProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<AgentConversationState> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<AgentConversationState> create(Ref ref) {
    final argument = this.argument as (String, String, String);
    return agentConversation(ref, argument.$1, argument.$2, argument.$3);
  }

  @override
  bool operator ==(Object other) {
    return other is AgentConversationProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$agentConversationHash() => r'fefb122b30dcc87bddef6d3bd6ae579d79766a95';

/// The conversation of agent post [postId] (plugin 2.x).

final class AgentConversationFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<AgentConversationState>,
          (String, String, String)
        > {
  AgentConversationFamily._()
    : super(
        retry: null,
        name: r'agentConversationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The conversation of agent post [postId] (plugin 2.x).

  AgentConversationProvider call(
    String url,
    String conversationId,
    String postId,
  ) => AgentConversationProvider._(
    argument: (url, conversationId, postId),
    from: this,
  );

  @override
  String toString() => r'agentConversationProvider';
}
