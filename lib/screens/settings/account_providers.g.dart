// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(accountActions)
final accountActionsProvider = AccountActionsFamily._();

final class AccountActionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<AccountActions>,
          AccountActions,
          FutureOr<AccountActions>
        >
    with $FutureModifier<AccountActions>, $FutureProvider<AccountActions> {
  AccountActionsProvider._({
    required AccountActionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'accountActionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$accountActionsHash();

  @override
  String toString() {
    return r'accountActionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<AccountActions> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AccountActions> create(Ref ref) {
    final argument = this.argument as String;
    return accountActions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AccountActionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountActionsHash() => r'b9072ad311bb4cd4627b65f7ab13abc414d45b7e';

final class AccountActionsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<AccountActions>, String> {
  AccountActionsFamily._()
    : super(
        retry: null,
        name: r'accountActionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AccountActionsProvider call(String url) =>
      AccountActionsProvider._(argument: url, from: this);

  @override
  String toString() => r'accountActionsProvider';
}

/// The account as the server has it now, for what the stored copy lacks.

@ProviderFor(accountMe)
final accountMeProvider = AccountMeFamily._();

/// The account as the server has it now, for what the stored copy lacks.

final class AccountMeProvider
    extends
        $FunctionalProvider<AsyncValue<api.User>, api.User, FutureOr<api.User>>
    with $FutureModifier<api.User>, $FutureProvider<api.User> {
  /// The account as the server has it now, for what the stored copy lacks.
  AccountMeProvider._({
    required AccountMeFamily super.from,
    required String super.argument,
  }) : super(
         retry: noRetry,
         name: r'accountMeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$accountMeHash();

  @override
  String toString() {
    return r'accountMeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<api.User> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<api.User> create(Ref ref) {
    final argument = this.argument as String;
    return accountMe(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AccountMeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountMeHash() => r'514014f145248d17310277fb80604ac095bc56f4';

/// The account as the server has it now, for what the stored copy lacks.

final class AccountMeFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<api.User>, String> {
  AccountMeFamily._()
    : super(
        retry: noRetry,
        name: r'accountMeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The account as the server has it now, for what the stored copy lacks.

  AccountMeProvider call(String url) =>
      AccountMeProvider._(argument: url, from: this);

  @override
  String toString() => r'accountMeProvider';
}

/// Whether the account can manage two-factor authentication here.

@ProviderFor(mfaAvailable)
final mfaAvailableProvider = MfaAvailableFamily._();

/// Whether the account can manage two-factor authentication here.

final class MfaAvailableProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether the account can manage two-factor authentication here.
  MfaAvailableProvider._({
    required MfaAvailableFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'mfaAvailableProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$mfaAvailableHash();

  @override
  String toString() {
    return r'mfaAvailableProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as String;
    return mfaAvailable(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MfaAvailableProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$mfaAvailableHash() => r'bdda8bbff79b1535d8cc0c2a11614b2784303eaf';

/// Whether the account can manage two-factor authentication here.

final class MfaAvailableFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  MfaAvailableFamily._()
    : super(
        retry: null,
        name: r'mfaAvailableProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether the account can manage two-factor authentication here.

  MfaAvailableProvider call(String url) =>
      MfaAvailableProvider._(argument: url, from: this);

  @override
  String toString() => r'mfaAvailableProvider';
}

/// The terms to show the user, or null when none are due. Looks again when
/// the server's config arrives or changes.

@ProviderFor(termsToAccept)
final termsToAcceptProvider = TermsToAcceptFamily._();

/// The terms to show the user, or null when none are due. Looks again when
/// the server's config arrives or changes.

final class TermsToAcceptProvider
    extends
        $FunctionalProvider<
          AsyncValue<api.TermsOfService?>,
          api.TermsOfService?,
          FutureOr<api.TermsOfService?>
        >
    with
        $FutureModifier<api.TermsOfService?>,
        $FutureProvider<api.TermsOfService?> {
  /// The terms to show the user, or null when none are due. Looks again when
  /// the server's config arrives or changes.
  TermsToAcceptProvider._({
    required TermsToAcceptFamily super.from,
    required String super.argument,
  }) : super(
         retry: noRetry,
         name: r'termsToAcceptProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$termsToAcceptHash();

  @override
  String toString() {
    return r'termsToAcceptProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<api.TermsOfService?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<api.TermsOfService?> create(Ref ref) {
    final argument = this.argument as String;
    return termsToAccept(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TermsToAcceptProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$termsToAcceptHash() => r'939de8fc9626735581d2ff29ed38e430a2b27740';

/// The terms to show the user, or null when none are due. Looks again when
/// the server's config arrives or changes.

final class TermsToAcceptFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<api.TermsOfService?>, String> {
  TermsToAcceptFamily._()
    : super(
        retry: noRetry,
        name: r'termsToAcceptProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The terms to show the user, or null when none are due. Looks again when
  /// the server's config arrives or changes.

  TermsToAcceptProvider call(String url) =>
      TermsToAcceptProvider._(argument: url, from: this);

  @override
  String toString() => r'termsToAcceptProvider';
}

/// The account's sessions, newest activity first.

@ProviderFor(ActiveSessions)
final activeSessionsProvider = ActiveSessionsFamily._();

/// The account's sessions, newest activity first.
final class ActiveSessionsProvider
    extends $AsyncNotifierProvider<ActiveSessions, List<SessionRow>> {
  /// The account's sessions, newest activity first.
  ActiveSessionsProvider._({
    required ActiveSessionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: noRetry,
         name: r'activeSessionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$activeSessionsHash();

  @override
  String toString() {
    return r'activeSessionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ActiveSessions create() => ActiveSessions();

  @override
  bool operator ==(Object other) {
    return other is ActiveSessionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$activeSessionsHash() => r'9e6745a2d03621530fc768c8c1e87c8d7151ed32';

/// The account's sessions, newest activity first.

final class ActiveSessionsFamily extends $Family
    with
        $ClassFamilyOverride<
          ActiveSessions,
          AsyncValue<List<SessionRow>>,
          List<SessionRow>,
          FutureOr<List<SessionRow>>,
          String
        > {
  ActiveSessionsFamily._()
    : super(
        retry: noRetry,
        name: r'activeSessionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The account's sessions, newest activity first.

  ActiveSessionsProvider call(String url) =>
      ActiveSessionsProvider._(argument: url, from: this);

  @override
  String toString() => r'activeSessionsProvider';
}

/// The account's sessions, newest activity first.

abstract class _$ActiveSessions extends $AsyncNotifier<List<SessionRow>> {
  late final _$args = ref.$arg as String;
  String get url => _$args;

  FutureOr<List<SessionRow>> build(String url);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<SessionRow>>, List<SessionRow>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<SessionRow>>, List<SessionRow>>,
              AsyncValue<List<SessionRow>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
