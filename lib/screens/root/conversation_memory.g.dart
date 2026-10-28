// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_memory.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Writes the conversation on top, for the place the rail shows, to the
/// settings whenever the open ones change, in routes on a narrow window or
/// in panes on a wide one, so switching back to that place and the next
/// launch can open it again. Read it once the launch has restored.

@ProviderFor(conversationMemory)
final conversationMemoryProvider = ConversationMemoryProvider._();

/// Writes the conversation on top, for the place the rail shows, to the
/// settings whenever the open ones change, in routes on a narrow window or
/// in panes on a wide one, so switching back to that place and the next
/// launch can open it again. Read it once the launch has restored.

final class ConversationMemoryProvider
    extends
        $FunctionalProvider<
          ConversationMemory,
          ConversationMemory,
          ConversationMemory
        >
    with $Provider<ConversationMemory> {
  /// Writes the conversation on top, for the place the rail shows, to the
  /// settings whenever the open ones change, in routes on a narrow window or
  /// in panes on a wide one, so switching back to that place and the next
  /// launch can open it again. Read it once the launch has restored.
  ConversationMemoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conversationMemoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conversationMemoryHash();

  @$internal
  @override
  $ProviderElement<ConversationMemory> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConversationMemory create(Ref ref) {
    return conversationMemory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConversationMemory value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConversationMemory>(value),
    );
  }
}

String _$conversationMemoryHash() =>
    r'0f117584bfcbeaba4b17dede7b6de30f6c359500';
