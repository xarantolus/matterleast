// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'open_history.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What the user opened, across teams and servers, for the mouse's Back
/// and Forward buttons and Alt+Left and Alt+Right.

@ProviderFor(openHistory)
final openHistoryProvider = OpenHistoryProvider._();

/// What the user opened, across teams and servers, for the mouse's Back
/// and Forward buttons and Alt+Left and Alt+Right.

final class OpenHistoryProvider
    extends
        $FunctionalProvider<
          OpenHistory<SavedConversation>,
          OpenHistory<SavedConversation>,
          OpenHistory<SavedConversation>
        >
    with $Provider<OpenHistory<SavedConversation>> {
  /// What the user opened, across teams and servers, for the mouse's Back
  /// and Forward buttons and Alt+Left and Alt+Right.
  OpenHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'openHistoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$openHistoryHash();

  @$internal
  @override
  $ProviderElement<OpenHistory<SavedConversation>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OpenHistory<SavedConversation> create(Ref ref) {
    return openHistory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OpenHistory<SavedConversation> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OpenHistory<SavedConversation>>(
        value,
      ),
    );
  }
}

String _$openHistoryHash() => r'5d52f49bc30b99111229c6e1341fcfab492e74dd';
