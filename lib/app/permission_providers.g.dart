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

/// Whether the user is a system admin on [url]'s server.

@ProviderFor(systemAdmin)
final systemAdminProvider = SystemAdminFamily._();

/// Whether the user is a system admin on [url]'s server.

final class SystemAdminProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Whether the user is a system admin on [url]'s server.
  SystemAdminProvider._({
    required SystemAdminFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'systemAdminProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$systemAdminHash();

  @override
  String toString() {
    return r'systemAdminProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    final argument = this.argument as String;
    return systemAdmin(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SystemAdminProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$systemAdminHash() => r'4f583a09e82ab10e11232a5285f2252045037b6f';

/// Whether the user is a system admin on [url]'s server.

final class SystemAdminFamily extends $Family
    with $FunctionalFamilyOverride<Stream<bool>, String> {
  SystemAdminFamily._()
    : super(
        retry: null,
        name: r'systemAdminProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether the user is a system admin on [url]'s server.

  SystemAdminProvider call(String url) =>
      SystemAdminProvider._(argument: url, from: this);

  @override
  String toString() => r'systemAdminProvider';
}
