// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LoginController)
final loginControllerProvider = LoginControllerFamily._();

final class LoginControllerProvider
    extends $NotifierProvider<LoginController, LoginState> {
  LoginControllerProvider._({
    required LoginControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'loginControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$loginControllerHash();

  @override
  String toString() {
    return r'loginControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  LoginController create() => LoginController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoginState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoginState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LoginControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$loginControllerHash() => r'930af9f03cfda35844c4afa85b3622153459b5a1';

final class LoginControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          LoginController,
          LoginState,
          LoginState,
          LoginState,
          String
        > {
  LoginControllerFamily._()
    : super(
        retry: null,
        name: r'loginControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LoginControllerProvider call(String url) =>
      LoginControllerProvider._(argument: url, from: this);

  @override
  String toString() => r'loginControllerProvider';
}

abstract class _$LoginController extends $Notifier<LoginState> {
  late final _$args = ref.$arg as String;
  String get url => _$args;

  LoginState build(String url);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<LoginState, LoginState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LoginState, LoginState>,
              LoginState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
