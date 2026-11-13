// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'composer_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The conversation's stored draft, each time it changes.

@ProviderFor(storedDraft)
final storedDraftProvider = StoredDraftFamily._();

/// The conversation's stored draft, each time it changes.

final class StoredDraftProvider
    extends $FunctionalProvider<AsyncValue<Draft?>, Draft?, Stream<Draft?>>
    with $FutureModifier<Draft?>, $StreamProvider<Draft?> {
  /// The conversation's stored draft, each time it changes.
  StoredDraftProvider._({
    required StoredDraftFamily super.from,
    required (String, String, String) super.argument,
  }) : super(
         retry: null,
         name: r'storedDraftProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$storedDraftHash();

  @override
  String toString() {
    return r'storedDraftProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<Draft?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Draft?> create(Ref ref) {
    final argument = this.argument as (String, String, String);
    return storedDraft(ref, argument.$1, argument.$2, argument.$3);
  }

  @override
  bool operator ==(Object other) {
    return other is StoredDraftProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$storedDraftHash() => r'953c64b948e078f5d043103f5b107b3499264701';

/// The conversation's stored draft, each time it changes.

final class StoredDraftFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Draft?>, (String, String, String)> {
  StoredDraftFamily._()
    : super(
        retry: null,
        name: r'storedDraftProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The conversation's stored draft, each time it changes.

  StoredDraftProvider call(String url, String channelId, String rootId) =>
      StoredDraftProvider._(argument: (url, channelId, rootId), from: this);

  @override
  String toString() => r'storedDraftProvider';
}

/// The composer of one conversation. Lives as long as the conversation is
/// on screen, so rebuilds and the drawer keep what was typed; the draft
/// keeps it after that. With a [forward] link it writes the comment for
/// forwarding that message instead: no draft, commands, files or typing
/// signal, and sending posts the comment and the link.

@ProviderFor(ComposerDraft)
final composerDraftProvider = ComposerDraftFamily._();

/// The composer of one conversation. Lives as long as the conversation is
/// on screen, so rebuilds and the drawer keep what was typed; the draft
/// keeps it after that. With a [forward] link it writes the comment for
/// forwarding that message instead: no draft, commands, files or typing
/// signal, and sending posts the comment and the link.
final class ComposerDraftProvider
    extends $NotifierProvider<ComposerDraft, ComposerValue> {
  /// The composer of one conversation. Lives as long as the conversation is
  /// on screen, so rebuilds and the drawer keep what was typed; the draft
  /// keeps it after that. With a [forward] link it writes the comment for
  /// forwarding that message instead: no draft, commands, files or typing
  /// signal, and sending posts the comment and the link.
  ComposerDraftProvider._({
    required ComposerDraftFamily super.from,
    required (String, String, String, {String forward}) super.argument,
  }) : super(
         retry: null,
         name: r'composerDraftProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$composerDraftHash();

  @override
  String toString() {
    return r'composerDraftProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  ComposerDraft create() => ComposerDraft();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ComposerValue value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ComposerValue>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ComposerDraftProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$composerDraftHash() => r'00dbd2041fb696b4e513790f33b55f38159e2fb8';

/// The composer of one conversation. Lives as long as the conversation is
/// on screen, so rebuilds and the drawer keep what was typed; the draft
/// keeps it after that. With a [forward] link it writes the comment for
/// forwarding that message instead: no draft, commands, files or typing
/// signal, and sending posts the comment and the link.

final class ComposerDraftFamily extends $Family
    with
        $ClassFamilyOverride<
          ComposerDraft,
          ComposerValue,
          ComposerValue,
          ComposerValue,
          (String, String, String, {String forward})
        > {
  ComposerDraftFamily._()
    : super(
        retry: null,
        name: r'composerDraftProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The composer of one conversation. Lives as long as the conversation is
  /// on screen, so rebuilds and the drawer keep what was typed; the draft
  /// keeps it after that. With a [forward] link it writes the comment for
  /// forwarding that message instead: no draft, commands, files or typing
  /// signal, and sending posts the comment and the link.

  ComposerDraftProvider call(
    String url,
    String channelId,
    String rootId, {
    String forward = '',
  }) => ComposerDraftProvider._(
    argument: (url, channelId, rootId, forward: forward),
    from: this,
  );

  @override
  String toString() => r'composerDraftProvider';
}

/// The composer of one conversation. Lives as long as the conversation is
/// on screen, so rebuilds and the drawer keep what was typed; the draft
/// keeps it after that. With a [forward] link it writes the comment for
/// forwarding that message instead: no draft, commands, files or typing
/// signal, and sending posts the comment and the link.

abstract class _$ComposerDraft extends $Notifier<ComposerValue> {
  late final _$args = ref.$arg as (String, String, String, {String forward});
  String get url => _$args.$1;
  String get channelId => _$args.$2;
  String get rootId => _$args.$3;
  String get forward => _$args.forward;

  ComposerValue build(
    String url,
    String channelId,
    String rootId, {
    String forward = '',
  });
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ComposerValue, ComposerValue>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ComposerValue, ComposerValue>,
              ComposerValue,
              Object?,
              Object?
            >;
    return element.handleCreate(
      ref,
      () => build(_$args.$1, _$args.$2, _$args.$3, forward: _$args.forward),
    );
  }
}
