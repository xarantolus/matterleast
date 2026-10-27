// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_memory.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Writes the conversation on top to the settings whenever the open ones
/// change, in routes on a narrow window or in panes on a wide one, so the
/// next launch can open it again. Read it once the launch has restored.

@ProviderFor(conversationMemory)
final conversationMemoryProvider = ConversationMemoryFamily._();

/// Writes the conversation on top to the settings whenever the open ones
/// change, in routes on a narrow window or in panes on a wide one, so the
/// next launch can open it again. Read it once the launch has restored.

final class ConversationMemoryProvider
    extends
        $FunctionalProvider<
          ConversationMemory,
          ConversationMemory,
          ConversationMemory
        >
    with $Provider<ConversationMemory> {
  /// Writes the conversation on top to the settings whenever the open ones
  /// change, in routes on a narrow window or in panes on a wide one, so the
  /// next launch can open it again. Read it once the launch has restored.
  ConversationMemoryProvider._({
    required ConversationMemoryFamily super.from,
    required SavedConversation? super.argument,
  }) : super(
         retry: null,
         name: r'conversationMemoryProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$conversationMemoryHash();

  @override
  String toString() {
    return r'conversationMemoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<ConversationMemory> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConversationMemory create(Ref ref) {
    final argument = this.argument as SavedConversation?;
    return conversationMemory(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConversationMemory value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConversationMemory>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ConversationMemoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$conversationMemoryHash() =>
    r'b3405d96aed73d69453e42cc3a8122ef4d4bae9b';

/// Writes the conversation on top to the settings whenever the open ones
/// change, in routes on a narrow window or in panes on a wide one, so the
/// next launch can open it again. Read it once the launch has restored.

final class ConversationMemoryFamily extends $Family
    with $FunctionalFamilyOverride<ConversationMemory, SavedConversation?> {
  ConversationMemoryFamily._()
    : super(
        retry: null,
        name: r'conversationMemoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Writes the conversation on top to the settings whenever the open ones
  /// change, in routes on a narrow window or in panes on a wide one, so the
  /// next launch can open it again. Read it once the launch has restored.

  ConversationMemoryProvider call(SavedConversation? saved) =>
      ConversationMemoryProvider._(argument: saved, from: this);

  @override
  String toString() => r'conversationMemoryProvider';
}
