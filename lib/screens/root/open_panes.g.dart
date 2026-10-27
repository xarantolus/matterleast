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

String _$openPanesHash() => r'd074beda4624a992c15dcb5a4e7cdb554083a474';

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

/// The conversation the user last closed on a narrow screen; a left swipe
/// on the channel list or Home brings it back.

@ProviderFor(LastClosed)
final lastClosedProvider = LastClosedProvider._();

/// The conversation the user last closed on a narrow screen; a left swipe
/// on the channel list or Home brings it back.
final class LastClosedProvider
    extends $NotifierProvider<LastClosed, ConversationTarget?> {
  /// The conversation the user last closed on a narrow screen; a left swipe
  /// on the channel list or Home brings it back.
  LastClosedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lastClosedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lastClosedHash();

  @$internal
  @override
  LastClosed create() => LastClosed();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConversationTarget? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConversationTarget?>(value),
    );
  }
}

String _$lastClosedHash() => r'429d8b9f35d97b3461ad0a963d79af26938d921d';

/// The conversation the user last closed on a narrow screen; a left swipe
/// on the channel list or Home brings it back.

abstract class _$LastClosed extends $Notifier<ConversationTarget?> {
  ConversationTarget? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ConversationTarget?, ConversationTarget?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ConversationTarget?, ConversationTarget?>,
              ConversationTarget?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The conversation routes on the app's navigator, oldest first.

@ProviderFor(conversationRoutes)
final conversationRoutesProvider = ConversationRoutesProvider._();

/// The conversation routes on the app's navigator, oldest first.

final class ConversationRoutesProvider
    extends
        $FunctionalProvider<
          ConversationRoutes,
          ConversationRoutes,
          ConversationRoutes
        >
    with $Provider<ConversationRoutes> {
  /// The conversation routes on the app's navigator, oldest first.
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
    r'8f3527ad344721e4c3461b7a90ac8a1f1a788564';
