// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permission_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What the user may do in one channel, as their roles and the channel
/// change.

@ProviderFor(channelRights)
final channelRightsProvider = ChannelRightsFamily._();

/// What the user may do in one channel, as their roles and the channel
/// change.

final class ChannelRightsProvider
    extends
        $FunctionalProvider<
          AsyncValue<ChannelPermissions>,
          ChannelPermissions,
          Stream<ChannelPermissions>
        >
    with
        $FutureModifier<ChannelPermissions>,
        $StreamProvider<ChannelPermissions> {
  /// What the user may do in one channel, as their roles and the channel
  /// change.
  ChannelRightsProvider._({
    required ChannelRightsFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'channelRightsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$channelRightsHash();

  @override
  String toString() {
    return r'channelRightsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<ChannelPermissions> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ChannelPermissions> create(Ref ref) {
    final argument = this.argument as (String, String);
    return channelRights(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ChannelRightsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$channelRightsHash() => r'b482ee5861468b6926220b9814cfb3b329bc6de4';

/// What the user may do in one channel, as their roles and the channel
/// change.

final class ChannelRightsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<ChannelPermissions>,
          (String, String)
        > {
  ChannelRightsFamily._()
    : super(
        retry: null,
        name: r'channelRightsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// What the user may do in one channel, as their roles and the channel
  /// change.

  ChannelRightsProvider call(String url, String channelId) =>
      ChannelRightsProvider._(argument: (url, channelId), from: this);

  @override
  String toString() => r'channelRightsProvider';
}
