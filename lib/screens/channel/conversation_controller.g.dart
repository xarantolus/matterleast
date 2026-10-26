// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// An open channel, or the thread of [rootId] in it: watches the stored
/// window, refreshes it once on open, loads older history as the reader
/// scrolls, and marks the conversation read.

@ProviderFor(Conversation)
final conversationProvider = ConversationFamily._();

/// An open channel, or the thread of [rootId] in it: watches the stored
/// window, refreshes it once on open, loads older history as the reader
/// scrolls, and marks the conversation read.
final class ConversationProvider
    extends $NotifierProvider<Conversation, ConversationState> {
  /// An open channel, or the thread of [rootId] in it: watches the stored
  /// window, refreshes it once on open, loads older history as the reader
  /// scrolls, and marks the conversation read.
  ConversationProvider._({
    required ConversationFamily super.from,
    required (String, String, {String? rootId, String? highlightPostId})
    super.argument,
  }) : super(
         retry: null,
         name: r'conversationProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$conversationHash();

  @override
  String toString() {
    return r'conversationProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  Conversation create() => Conversation();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConversationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConversationState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ConversationProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$conversationHash() => r'da221c7c49005d15e3616339c5c2ea346e2ab2ab';

/// An open channel, or the thread of [rootId] in it: watches the stored
/// window, refreshes it once on open, loads older history as the reader
/// scrolls, and marks the conversation read.

final class ConversationFamily extends $Family
    with
        $ClassFamilyOverride<
          Conversation,
          ConversationState,
          ConversationState,
          ConversationState,
          (String, String, {String? rootId, String? highlightPostId})
        > {
  ConversationFamily._()
    : super(
        retry: null,
        name: r'conversationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// An open channel, or the thread of [rootId] in it: watches the stored
  /// window, refreshes it once on open, loads older history as the reader
  /// scrolls, and marks the conversation read.

  ConversationProvider call(
    String url,
    String channelId, {
    String? rootId,
    String? highlightPostId,
  }) => ConversationProvider._(
    argument: (
      url,
      channelId,
      rootId: rootId,
      highlightPostId: highlightPostId,
    ),
    from: this,
  );

  @override
  String toString() => r'conversationProvider';
}

/// An open channel, or the thread of [rootId] in it: watches the stored
/// window, refreshes it once on open, loads older history as the reader
/// scrolls, and marks the conversation read.

abstract class _$Conversation extends $Notifier<ConversationState> {
  late final _$args =
      ref.$arg as (String, String, {String? rootId, String? highlightPostId});
  String get url => _$args.$1;
  String get channelId => _$args.$2;
  String? get rootId => _$args.rootId;
  String? get highlightPostId => _$args.highlightPostId;

  ConversationState build(
    String url,
    String channelId, {
    String? rootId,
    String? highlightPostId,
  });
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ConversationState, ConversationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ConversationState, ConversationState>,
              ConversationState,
              Object?,
              Object?
            >;
    return element.handleCreate(
      ref,
      () => build(
        _$args.$1,
        _$args.$2,
        rootId: _$args.rootId,
        highlightPostId: _$args.highlightPostId,
      ),
    );
  }
}
