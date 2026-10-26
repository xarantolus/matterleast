// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(profileActions)
final profileActionsProvider = ProfileActionsFamily._();

final class ProfileActionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<ProfileActions>,
          ProfileActions,
          FutureOr<ProfileActions>
        >
    with $FutureModifier<ProfileActions>, $FutureProvider<ProfileActions> {
  ProfileActionsProvider._({
    required ProfileActionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'profileActionsProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$profileActionsHash();

  @override
  String toString() {
    return r'profileActionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ProfileActions> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ProfileActions> create(Ref ref) {
    final argument = this.argument as String;
    return profileActions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileActionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profileActionsHash() => r'217262eef5ff874c5135ffdbccf0ad3bcf0f5cbf';

final class ProfileActionsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ProfileActions>, String> {
  ProfileActionsFamily._()
    : super(
        retry: null,
        name: r'profileActionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  ProfileActionsProvider call(String url) =>
      ProfileActionsProvider._(argument: url, from: this);

  @override
  String toString() => r'profileActionsProvider';
}

@ProviderFor(userProfile)
final userProfileProvider = UserProfileFamily._();

final class UserProfileProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserProfile?>,
          UserProfile?,
          Stream<UserProfile?>
        >
    with $FutureModifier<UserProfile?>, $StreamProvider<UserProfile?> {
  UserProfileProvider._({
    required UserProfileFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'userProfileProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userProfileHash();

  @override
  String toString() {
    return r'userProfileProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<UserProfile?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<UserProfile?> create(Ref ref) {
    final argument = this.argument as (String, String);
    return userProfile(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is UserProfileProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userProfileHash() => r'6284acaee052ea5efeb34e6dc98f6566f93af7ac';

final class UserProfileFamily extends $Family
    with $FunctionalFamilyOverride<Stream<UserProfile?>, (String, String)> {
  UserProfileFamily._()
    : super(
        retry: null,
        name: r'userProfileProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UserProfileProvider call(String url, String userId) =>
      UserProfileProvider._(argument: (url, userId), from: this);

  @override
  String toString() => r'userProfileProvider';
}

/// The profile fields the signed-in user can't change on [url].

@ProviderFor(myProfileLocks)
final myProfileLocksProvider = MyProfileLocksFamily._();

/// The profile fields the signed-in user can't change on [url].

final class MyProfileLocksProvider
    extends
        $FunctionalProvider<
          AsyncValue<ProfileLocks>,
          ProfileLocks,
          Stream<ProfileLocks>
        >
    with $FutureModifier<ProfileLocks>, $StreamProvider<ProfileLocks> {
  /// The profile fields the signed-in user can't change on [url].
  MyProfileLocksProvider._({
    required MyProfileLocksFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'myProfileLocksProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$myProfileLocksHash();

  @override
  String toString() {
    return r'myProfileLocksProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<ProfileLocks> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ProfileLocks> create(Ref ref) {
    final argument = this.argument as String;
    return myProfileLocks(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MyProfileLocksProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$myProfileLocksHash() => r'1200b437b359687f20666b711a60550c48551290';

/// The profile fields the signed-in user can't change on [url].

final class MyProfileLocksFamily extends $Family
    with $FunctionalFamilyOverride<Stream<ProfileLocks>, String> {
  MyProfileLocksFamily._()
    : super(
        retry: null,
        name: r'myProfileLocksProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The profile fields the signed-in user can't change on [url].

  MyProfileLocksProvider call(String url) =>
      MyProfileLocksProvider._(argument: url, from: this);

  @override
  String toString() => r'myProfileLocksProvider';
}

/// The custom statuses the user set lately on [url], newest first.

@ProviderFor(recentCustomStatuses)
final recentCustomStatusesProvider = RecentCustomStatusesFamily._();

/// The custom statuses the user set lately on [url], newest first.

final class RecentCustomStatusesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CustomStatus>>,
          List<CustomStatus>,
          Stream<List<CustomStatus>>
        >
    with
        $FutureModifier<List<CustomStatus>>,
        $StreamProvider<List<CustomStatus>> {
  /// The custom statuses the user set lately on [url], newest first.
  RecentCustomStatusesProvider._({
    required RecentCustomStatusesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'recentCustomStatusesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recentCustomStatusesHash();

  @override
  String toString() {
    return r'recentCustomStatusesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<CustomStatus>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<CustomStatus>> create(Ref ref) {
    final argument = this.argument as String;
    return recentCustomStatuses(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RecentCustomStatusesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recentCustomStatusesHash() =>
    r'ce54b8fba191f9cd8daf71b2c2d0cc09eba52d83';

/// The custom statuses the user set lately on [url], newest first.

final class RecentCustomStatusesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<CustomStatus>>, String> {
  RecentCustomStatusesFamily._()
    : super(
        retry: null,
        name: r'recentCustomStatusesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The custom statuses the user set lately on [url], newest first.

  RecentCustomStatusesProvider call(String url) =>
      RecentCustomStatusesProvider._(argument: url, from: this);

  @override
  String toString() => r'recentCustomStatusesProvider';
}

/// Fetched when a profile opens, so it shows fresh details.

@ProviderFor(profileRefresh)
final profileRefreshProvider = ProfileRefreshFamily._();

/// Fetched when a profile opens, so it shows fresh details.

final class ProfileRefreshProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Fetched when a profile opens, so it shows fresh details.
  ProfileRefreshProvider._({
    required ProfileRefreshFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: noRetry,
         name: r'profileRefreshProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$profileRefreshHash();

  @override
  String toString() {
    return r'profileRefreshProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as (String, String);
    return profileRefresh(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileRefreshProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profileRefreshHash() => r'b33335bfca71b381526825cab903b229b253093e';

/// Fetched when a profile opens, so it shows fresh details.

final class ProfileRefreshFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, (String, String)> {
  ProfileRefreshFamily._()
    : super(
        retry: noRetry,
        name: r'profileRefreshProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Fetched when a profile opens, so it shows fresh details.

  ProfileRefreshProvider call(String url, String userId) =>
      ProfileRefreshProvider._(argument: (url, userId), from: this);

  @override
  String toString() => r'profileRefreshProvider';
}
