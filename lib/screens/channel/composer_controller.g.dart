// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'composer_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The composer of one conversation. Lives as long as the conversation is
/// on screen, so rebuilds and the drawer keep what was typed; the draft
/// keeps it after that.

@ProviderFor(ComposerDraft)
final composerDraftProvider = ComposerDraftFamily._();

/// The composer of one conversation. Lives as long as the conversation is
/// on screen, so rebuilds and the drawer keep what was typed; the draft
/// keeps it after that.
final class ComposerDraftProvider
    extends $NotifierProvider<ComposerDraft, ComposerValue> {
  /// The composer of one conversation. Lives as long as the conversation is
  /// on screen, so rebuilds and the drawer keep what was typed; the draft
  /// keeps it after that.
  ComposerDraftProvider._({
    required ComposerDraftFamily super.from,
    required (String, String, String) super.argument,
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

String _$composerDraftHash() => r'1e477d6224a4ac7979fa0fb674e95fe535bae61c';

/// The composer of one conversation. Lives as long as the conversation is
/// on screen, so rebuilds and the drawer keep what was typed; the draft
/// keeps it after that.

final class ComposerDraftFamily extends $Family
    with
        $ClassFamilyOverride<
          ComposerDraft,
          ComposerValue,
          ComposerValue,
          ComposerValue,
          (String, String, String)
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
  /// keeps it after that.

  ComposerDraftProvider call(String url, String channelId, String rootId) =>
      ComposerDraftProvider._(argument: (url, channelId, rootId), from: this);

  @override
  String toString() => r'composerDraftProvider';
}

/// The composer of one conversation. Lives as long as the conversation is
/// on screen, so rebuilds and the drawer keep what was typed; the draft
/// keeps it after that.

abstract class _$ComposerDraft extends $Notifier<ComposerValue> {
  late final _$args = ref.$arg as (String, String, String);
  String get url => _$args.$1;
  String get channelId => _$args.$2;
  String get rootId => _$args.$3;

  ComposerValue build(String url, String channelId, String rootId);
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
      () => build(_$args.$1, _$args.$2, _$args.$3),
    );
  }
}
