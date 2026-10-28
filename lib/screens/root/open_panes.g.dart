// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'open_panes.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The conversations shown beside the channel list on a wide screen. On a
/// narrow one the [ConversationRoute]s on the navigator are the truth.

@ProviderFor(OpenPanes)
final openPanesProvider = OpenPanesProvider._();

/// The conversations shown beside the channel list on a wide screen. On a
/// narrow one the [ConversationRoute]s on the navigator are the truth.
final class OpenPanesProvider extends $NotifierProvider<OpenPanes, Panes> {
  /// The conversations shown beside the channel list on a wide screen. On a
  /// narrow one the [ConversationRoute]s on the navigator are the truth.
  OpenPanesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'openPanesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$openPanesHash();

  @$internal
  @override
  OpenPanes create() => OpenPanes();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Panes value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Panes>(value),
    );
  }
}

String _$openPanesHash() => r'e52e20436e631e5866f765964a6e416b3ef68b84';

/// The conversations shown beside the channel list on a wide screen. On a
/// narrow one the [ConversationRoute]s on the navigator are the truth.

abstract class _$OpenPanes extends $Notifier<Panes> {
  Panes build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Panes, Panes>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Panes, Panes>,
              Panes,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The conversation routes and content views on the app's navigator,
/// oldest first.

@ProviderFor(conversationRoutes)
final conversationRoutesProvider = ConversationRoutesProvider._();

/// The conversation routes and content views on the app's navigator,
/// oldest first.

final class ConversationRoutesProvider
    extends
        $FunctionalProvider<
          ConversationRoutes,
          ConversationRoutes,
          ConversationRoutes
        >
    with $Provider<ConversationRoutes> {
  /// The conversation routes and content views on the app's navigator,
  /// oldest first.
  ConversationRoutesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conversationRoutesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conversationRoutesHash();

  @$internal
  @override
  $ProviderElement<ConversationRoutes> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConversationRoutes create(Ref ref) {
    return conversationRoutes(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConversationRoutes value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConversationRoutes>(value),
    );
  }
}

String _$conversationRoutesHash() =>
    r'00ab83a1402ae9069bf1d3a7a0b74b7796fe1eec';

/// The content views open in the conversation pane of a wide window, over
/// the conversation; their navigator is there only while the window is
/// wide.

@ProviderFor(paneRoutes)
final paneRoutesProvider = PaneRoutesProvider._();

/// The content views open in the conversation pane of a wide window, over
/// the conversation; their navigator is there only while the window is
/// wide.

final class PaneRoutesProvider
    extends
        $FunctionalProvider<
          ConversationRoutes,
          ConversationRoutes,
          ConversationRoutes
        >
    with $Provider<ConversationRoutes> {
  /// The content views open in the conversation pane of a wide window, over
  /// the conversation; their navigator is there only while the window is
  /// wide.
  PaneRoutesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paneRoutesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paneRoutesHash();

  @$internal
  @override
  $ProviderElement<ConversationRoutes> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConversationRoutes create(Ref ref) {
    return paneRoutes(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConversationRoutes value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConversationRoutes>(value),
    );
  }
}

String _$paneRoutesHash() => r'4380ebec024df0e6c4d0bb37b2de8d51b7a72ad7';

/// What Back closed, most recent last, for Forward to open again. Opening
/// anything else forgets it, as a browser does.

@ProviderFor(forwardHistory)
final forwardHistoryProvider = ForwardHistoryProvider._();

/// What Back closed, most recent last, for Forward to open again. Opening
/// anything else forgets it, as a browser does.

final class ForwardHistoryProvider
    extends $FunctionalProvider<ForwardHistory, ForwardHistory, ForwardHistory>
    with $Provider<ForwardHistory> {
  /// What Back closed, most recent last, for Forward to open again. Opening
  /// anything else forgets it, as a browser does.
  ForwardHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'forwardHistoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$forwardHistoryHash();

  @$internal
  @override
  $ProviderElement<ForwardHistory> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ForwardHistory create(Ref ref) {
    return forwardHistory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ForwardHistory value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ForwardHistory>(value),
    );
  }
}

String _$forwardHistoryHash() => r'3d4b8860ba78a2de44b37168ea7ae7430f6ea1c9';
