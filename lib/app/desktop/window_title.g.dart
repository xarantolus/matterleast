// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'window_title.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The conversation on top, or null while a channel list shows; set by
/// the conversation memory.

@ProviderFor(OpenConversation)
final openConversationProvider = OpenConversationProvider._();

/// The conversation on top, or null while a channel list shows; set by
/// the conversation memory.
final class OpenConversationProvider
    extends $NotifierProvider<OpenConversation, SavedConversation?> {
  /// The conversation on top, or null while a channel list shows; set by
  /// the conversation memory.
  OpenConversationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'openConversationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$openConversationHash();

  @$internal
  @override
  OpenConversation create() => OpenConversation();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SavedConversation? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SavedConversation?>(value),
    );
  }
}

String _$openConversationHash() => r'a9372a4e702a6dfe503ed5324f3be27ac5d2ef58';

/// The conversation on top, or null while a channel list shows; set by
/// the conversation memory.

abstract class _$OpenConversation extends $Notifier<SavedConversation?> {
  SavedConversation? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SavedConversation?, SavedConversation?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SavedConversation?, SavedConversation?>,
              SavedConversation?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// What the OS shows for the window: the open conversation and the unread
/// count.

@ProviderFor(windowTitleText)
final windowTitleTextProvider = WindowTitleTextProvider._();

/// What the OS shows for the window: the open conversation and the unread
/// count.

final class WindowTitleTextProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// What the OS shows for the window: the open conversation and the unread
  /// count.
  WindowTitleTextProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'windowTitleTextProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$windowTitleTextHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return windowTitleText(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$windowTitleTextHash() => r'01ab379e95a40cf61b0e32f48e1ac085405fb0fd';
