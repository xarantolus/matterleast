// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_options.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LoginOptions {

 bool get password; bool get ldap; String get ldapFieldLabel;/// "Email or username", with the LDAP field name when LDAP is on.
 String get loginIdLabel;/// Whether to offer a password reset, and the admin's own reset page if
/// one is configured (else the server's web page).
 bool get forgotPassword; String? get forgotPasswordLink; List<SsoButton> get sso; bool get mfaPossible; bool get mfaEnforced; String get siteName; String get serverVersion; String get diagnosticId; bool get externalBrowserForSso;/// The address the server knows itself by (`SiteURL`), which it names
/// in an SSO redirect; it may differ from the one the user entered.
 Uri? get siteUrl;
/// Create a copy of LoginOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginOptionsCopyWith<LoginOptions> get copyWith => _$LoginOptionsCopyWithImpl<LoginOptions>(this as LoginOptions, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LoginOptions;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginOptions&&(identical(other.password, _this.password) || other.password == _this.password)&&(identical(other.ldap, _this.ldap) || other.ldap == _this.ldap)&&(identical(other.ldapFieldLabel, _this.ldapFieldLabel) || other.ldapFieldLabel == _this.ldapFieldLabel)&&(identical(other.loginIdLabel, _this.loginIdLabel) || other.loginIdLabel == _this.loginIdLabel)&&(identical(other.forgotPassword, _this.forgotPassword) || other.forgotPassword == _this.forgotPassword)&&(identical(other.forgotPasswordLink, _this.forgotPasswordLink) || other.forgotPasswordLink == _this.forgotPasswordLink)&&const DeepCollectionEquality().equals(other.sso, _this.sso)&&(identical(other.mfaPossible, _this.mfaPossible) || other.mfaPossible == _this.mfaPossible)&&(identical(other.mfaEnforced, _this.mfaEnforced) || other.mfaEnforced == _this.mfaEnforced)&&(identical(other.siteName, _this.siteName) || other.siteName == _this.siteName)&&(identical(other.serverVersion, _this.serverVersion) || other.serverVersion == _this.serverVersion)&&(identical(other.diagnosticId, _this.diagnosticId) || other.diagnosticId == _this.diagnosticId)&&(identical(other.externalBrowserForSso, _this.externalBrowserForSso) || other.externalBrowserForSso == _this.externalBrowserForSso)&&(identical(other.siteUrl, _this.siteUrl) || other.siteUrl == _this.siteUrl));
}


@override
int get hashCode {
  final _this = this as LoginOptions;
  return Object.hash(runtimeType,_this.password,_this.ldap,_this.ldapFieldLabel,_this.loginIdLabel,_this.forgotPassword,_this.forgotPasswordLink,const DeepCollectionEquality().hash(_this.sso),_this.mfaPossible,_this.mfaEnforced,_this.siteName,_this.serverVersion,_this.diagnosticId,_this.externalBrowserForSso,_this.siteUrl);
}

@override
String toString() {
  final _this = this as LoginOptions;
  return 'LoginOptions(password: ${_this.password}, ldap: ${_this.ldap}, ldapFieldLabel: ${_this.ldapFieldLabel}, loginIdLabel: ${_this.loginIdLabel}, forgotPassword: ${_this.forgotPassword}, forgotPasswordLink: ${_this.forgotPasswordLink}, sso: ${_this.sso}, mfaPossible: ${_this.mfaPossible}, mfaEnforced: ${_this.mfaEnforced}, siteName: ${_this.siteName}, serverVersion: ${_this.serverVersion}, diagnosticId: ${_this.diagnosticId}, externalBrowserForSso: ${_this.externalBrowserForSso}, siteUrl: ${_this.siteUrl})';
}


}

/// @nodoc
abstract mixin class $LoginOptionsCopyWith<$Res>  {
  factory $LoginOptionsCopyWith(LoginOptions value, $Res Function(LoginOptions) _then) = _$LoginOptionsCopyWithImpl;
@useResult
$Res call({
 bool password, bool ldap, String ldapFieldLabel, String loginIdLabel, bool forgotPassword, String? forgotPasswordLink, List<SsoButton> sso, bool mfaPossible, bool mfaEnforced, String siteName, String serverVersion, String diagnosticId, bool externalBrowserForSso, Uri? siteUrl
});




}
/// @nodoc
class _$LoginOptionsCopyWithImpl<$Res>
    implements $LoginOptionsCopyWith<$Res> {
  _$LoginOptionsCopyWithImpl(this._self, this._then);

  final LoginOptions _self;
  final $Res Function(LoginOptions) _then;

/// Create a copy of LoginOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? password = null,Object? ldap = null,Object? ldapFieldLabel = null,Object? loginIdLabel = null,Object? forgotPassword = null,Object? forgotPasswordLink = freezed,Object? sso = null,Object? mfaPossible = null,Object? mfaEnforced = null,Object? siteName = null,Object? serverVersion = null,Object? diagnosticId = null,Object? externalBrowserForSso = null,Object? siteUrl = freezed,}) {
  return _then(LoginOptions(
password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as bool,ldap: null == ldap ? _self.ldap : ldap // ignore: cast_nullable_to_non_nullable
as bool,ldapFieldLabel: null == ldapFieldLabel ? _self.ldapFieldLabel : ldapFieldLabel // ignore: cast_nullable_to_non_nullable
as String,loginIdLabel: null == loginIdLabel ? _self.loginIdLabel : loginIdLabel // ignore: cast_nullable_to_non_nullable
as String,forgotPassword: null == forgotPassword ? _self.forgotPassword : forgotPassword // ignore: cast_nullable_to_non_nullable
as bool,forgotPasswordLink: freezed == forgotPasswordLink ? _self.forgotPasswordLink : forgotPasswordLink // ignore: cast_nullable_to_non_nullable
as String?,sso: null == sso ? _self.sso : sso // ignore: cast_nullable_to_non_nullable
as List<SsoButton>,mfaPossible: null == mfaPossible ? _self.mfaPossible : mfaPossible // ignore: cast_nullable_to_non_nullable
as bool,mfaEnforced: null == mfaEnforced ? _self.mfaEnforced : mfaEnforced // ignore: cast_nullable_to_non_nullable
as bool,siteName: null == siteName ? _self.siteName : siteName // ignore: cast_nullable_to_non_nullable
as String,serverVersion: null == serverVersion ? _self.serverVersion : serverVersion // ignore: cast_nullable_to_non_nullable
as String,diagnosticId: null == diagnosticId ? _self.diagnosticId : diagnosticId // ignore: cast_nullable_to_non_nullable
as String,externalBrowserForSso: null == externalBrowserForSso ? _self.externalBrowserForSso : externalBrowserForSso // ignore: cast_nullable_to_non_nullable
as bool,siteUrl: freezed == siteUrl ? _self.siteUrl : siteUrl // ignore: cast_nullable_to_non_nullable
as Uri?,
  ));
}

}


/// Adds pattern-matching-related methods to [LoginOptions].
extension LoginOptionsPatterns on LoginOptions {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoginOptions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoginOptions() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoginOptions value)  $default,){
final _that = this;
switch (_that) {
case _LoginOptions():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoginOptions value)?  $default,){
final _that = this;
switch (_that) {
case _LoginOptions() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool password,  bool ldap,  String ldapFieldLabel,  String loginIdLabel,  bool forgotPassword,  String? forgotPasswordLink,  List<SsoButton> sso,  bool mfaPossible,  bool mfaEnforced,  String siteName,  String serverVersion,  String diagnosticId,  bool externalBrowserForSso,  Uri? siteUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoginOptions() when $default != null:
return $default(_that.password,_that.ldap,_that.ldapFieldLabel,_that.loginIdLabel,_that.forgotPassword,_that.forgotPasswordLink,_that.sso,_that.mfaPossible,_that.mfaEnforced,_that.siteName,_that.serverVersion,_that.diagnosticId,_that.externalBrowserForSso,_that.siteUrl);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool password,  bool ldap,  String ldapFieldLabel,  String loginIdLabel,  bool forgotPassword,  String? forgotPasswordLink,  List<SsoButton> sso,  bool mfaPossible,  bool mfaEnforced,  String siteName,  String serverVersion,  String diagnosticId,  bool externalBrowserForSso,  Uri? siteUrl)  $default,) {final _that = this;
switch (_that) {
case _LoginOptions():
return $default(_that.password,_that.ldap,_that.ldapFieldLabel,_that.loginIdLabel,_that.forgotPassword,_that.forgotPasswordLink,_that.sso,_that.mfaPossible,_that.mfaEnforced,_that.siteName,_that.serverVersion,_that.diagnosticId,_that.externalBrowserForSso,_that.siteUrl);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool password,  bool ldap,  String ldapFieldLabel,  String loginIdLabel,  bool forgotPassword,  String? forgotPasswordLink,  List<SsoButton> sso,  bool mfaPossible,  bool mfaEnforced,  String siteName,  String serverVersion,  String diagnosticId,  bool externalBrowserForSso,  Uri? siteUrl)?  $default,) {final _that = this;
switch (_that) {
case _LoginOptions() when $default != null:
return $default(_that.password,_that.ldap,_that.ldapFieldLabel,_that.loginIdLabel,_that.forgotPassword,_that.forgotPasswordLink,_that.sso,_that.mfaPossible,_that.mfaEnforced,_that.siteName,_that.serverVersion,_that.diagnosticId,_that.externalBrowserForSso,_that.siteUrl);case _:
  return null;

}
}

}

/// @nodoc


class _LoginOptions extends LoginOptions {
  const _LoginOptions({required this.password, required this.ldap, required this.ldapFieldLabel, required this.loginIdLabel, required this.forgotPassword, required this.forgotPasswordLink, required  List<SsoButton> sso, required this.mfaPossible, required this.mfaEnforced, required this.siteName, required this.serverVersion, required this.diagnosticId, required this.externalBrowserForSso, this.siteUrl}): _sso = sso,super._();
  

@override final  bool password;
@override final  bool ldap;
@override final  String ldapFieldLabel;
/// "Email or username", with the LDAP field name when LDAP is on.
@override final  String loginIdLabel;
/// Whether to offer a password reset, and the admin's own reset page if
/// one is configured (else the server's web page).
@override final  bool forgotPassword;
@override final  String? forgotPasswordLink;
 final  List<SsoButton> _sso;
@override List<SsoButton> get sso {
  if (_sso is EqualUnmodifiableListView) return _sso;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sso);
}

@override final  bool mfaPossible;
@override final  bool mfaEnforced;
@override final  String siteName;
@override final  String serverVersion;
@override final  String diagnosticId;
@override final  bool externalBrowserForSso;
/// The address the server knows itself by (`SiteURL`), which it names
/// in an SSO redirect; it may differ from the one the user entered.
@override final  Uri? siteUrl;

/// Create a copy of LoginOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoginOptionsCopyWith<_LoginOptions> get copyWith => __$LoginOptionsCopyWithImpl<_LoginOptions>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoginOptions&&(identical(other.password, password) || other.password == password)&&(identical(other.ldap, ldap) || other.ldap == ldap)&&(identical(other.ldapFieldLabel, ldapFieldLabel) || other.ldapFieldLabel == ldapFieldLabel)&&(identical(other.loginIdLabel, loginIdLabel) || other.loginIdLabel == loginIdLabel)&&(identical(other.forgotPassword, forgotPassword) || other.forgotPassword == forgotPassword)&&(identical(other.forgotPasswordLink, forgotPasswordLink) || other.forgotPasswordLink == forgotPasswordLink)&&const DeepCollectionEquality().equals(other.sso, _sso)&&(identical(other.mfaPossible, mfaPossible) || other.mfaPossible == mfaPossible)&&(identical(other.mfaEnforced, mfaEnforced) || other.mfaEnforced == mfaEnforced)&&(identical(other.siteName, siteName) || other.siteName == siteName)&&(identical(other.serverVersion, serverVersion) || other.serverVersion == serverVersion)&&(identical(other.diagnosticId, diagnosticId) || other.diagnosticId == diagnosticId)&&(identical(other.externalBrowserForSso, externalBrowserForSso) || other.externalBrowserForSso == externalBrowserForSso)&&(identical(other.siteUrl, siteUrl) || other.siteUrl == siteUrl));
}


@override
int get hashCode {
    return Object.hash(runtimeType,password,ldap,ldapFieldLabel,loginIdLabel,forgotPassword,forgotPasswordLink,const DeepCollectionEquality().hash(_sso),mfaPossible,mfaEnforced,siteName,serverVersion,diagnosticId,externalBrowserForSso,siteUrl);
}

@override
String toString() {
    return 'LoginOptions(password: $password, ldap: $ldap, ldapFieldLabel: $ldapFieldLabel, loginIdLabel: $loginIdLabel, forgotPassword: $forgotPassword, forgotPasswordLink: $forgotPasswordLink, sso: $sso, mfaPossible: $mfaPossible, mfaEnforced: $mfaEnforced, siteName: $siteName, serverVersion: $serverVersion, diagnosticId: $diagnosticId, externalBrowserForSso: $externalBrowserForSso, siteUrl: $siteUrl)';
}


}

/// @nodoc
abstract mixin class _$LoginOptionsCopyWith<$Res> implements $LoginOptionsCopyWith<$Res> {
  factory _$LoginOptionsCopyWith(_LoginOptions value, $Res Function(_LoginOptions) _then) = __$LoginOptionsCopyWithImpl;
@override @useResult
$Res call({
 bool password, bool ldap, String ldapFieldLabel, String loginIdLabel, bool forgotPassword, String? forgotPasswordLink, List<SsoButton> sso, bool mfaPossible, bool mfaEnforced, String siteName, String serverVersion, String diagnosticId, bool externalBrowserForSso, Uri? siteUrl
});




}
/// @nodoc
class __$LoginOptionsCopyWithImpl<$Res>
    implements _$LoginOptionsCopyWith<$Res> {
  __$LoginOptionsCopyWithImpl(this._self, this._then);

  final _LoginOptions _self;
  final $Res Function(_LoginOptions) _then;

/// Create a copy of LoginOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? password = null,Object? ldap = null,Object? ldapFieldLabel = null,Object? loginIdLabel = null,Object? forgotPassword = null,Object? forgotPasswordLink = freezed,Object? sso = null,Object? mfaPossible = null,Object? mfaEnforced = null,Object? siteName = null,Object? serverVersion = null,Object? diagnosticId = null,Object? externalBrowserForSso = null,Object? siteUrl = freezed,}) {
  return _then(_LoginOptions(
password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as bool,ldap: null == ldap ? _self.ldap : ldap // ignore: cast_nullable_to_non_nullable
as bool,ldapFieldLabel: null == ldapFieldLabel ? _self.ldapFieldLabel : ldapFieldLabel // ignore: cast_nullable_to_non_nullable
as String,loginIdLabel: null == loginIdLabel ? _self.loginIdLabel : loginIdLabel // ignore: cast_nullable_to_non_nullable
as String,forgotPassword: null == forgotPassword ? _self.forgotPassword : forgotPassword // ignore: cast_nullable_to_non_nullable
as bool,forgotPasswordLink: freezed == forgotPasswordLink ? _self.forgotPasswordLink : forgotPasswordLink // ignore: cast_nullable_to_non_nullable
as String?,sso: null == sso ? _self._sso : sso // ignore: cast_nullable_to_non_nullable
as List<SsoButton>,mfaPossible: null == mfaPossible ? _self.mfaPossible : mfaPossible // ignore: cast_nullable_to_non_nullable
as bool,mfaEnforced: null == mfaEnforced ? _self.mfaEnforced : mfaEnforced // ignore: cast_nullable_to_non_nullable
as bool,siteName: null == siteName ? _self.siteName : siteName // ignore: cast_nullable_to_non_nullable
as String,serverVersion: null == serverVersion ? _self.serverVersion : serverVersion // ignore: cast_nullable_to_non_nullable
as String,diagnosticId: null == diagnosticId ? _self.diagnosticId : diagnosticId // ignore: cast_nullable_to_non_nullable
as String,externalBrowserForSso: null == externalBrowserForSso ? _self.externalBrowserForSso : externalBrowserForSso // ignore: cast_nullable_to_non_nullable
as bool,siteUrl: freezed == siteUrl ? _self.siteUrl : siteUrl // ignore: cast_nullable_to_non_nullable
as Uri?,
  ));
}


}

/// @nodoc
mixin _$SsoButton {

 SsoProvider get provider; String get label;
/// Create a copy of SsoButton
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SsoButtonCopyWith<SsoButton> get copyWith => _$SsoButtonCopyWithImpl<SsoButton>(this as SsoButton, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SsoButton;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SsoButton&&(identical(other.provider, _this.provider) || other.provider == _this.provider)&&(identical(other.label, _this.label) || other.label == _this.label));
}


@override
int get hashCode {
  final _this = this as SsoButton;
  return Object.hash(runtimeType,_this.provider,_this.label);
}

@override
String toString() {
  final _this = this as SsoButton;
  return 'SsoButton(provider: ${_this.provider}, label: ${_this.label})';
}


}

/// @nodoc
abstract mixin class $SsoButtonCopyWith<$Res>  {
  factory $SsoButtonCopyWith(SsoButton value, $Res Function(SsoButton) _then) = _$SsoButtonCopyWithImpl;
@useResult
$Res call({
 SsoProvider provider, String label
});




}
/// @nodoc
class _$SsoButtonCopyWithImpl<$Res>
    implements $SsoButtonCopyWith<$Res> {
  _$SsoButtonCopyWithImpl(this._self, this._then);

  final SsoButton _self;
  final $Res Function(SsoButton) _then;

/// Create a copy of SsoButton
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? provider = null,Object? label = null,}) {
  return _then(SsoButton(
provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as SsoProvider,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SsoButton].
extension SsoButtonPatterns on SsoButton {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SsoButton value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SsoButton() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SsoButton value)  $default,){
final _that = this;
switch (_that) {
case _SsoButton():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SsoButton value)?  $default,){
final _that = this;
switch (_that) {
case _SsoButton() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SsoProvider provider,  String label)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SsoButton() when $default != null:
return $default(_that.provider,_that.label);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SsoProvider provider,  String label)  $default,) {final _that = this;
switch (_that) {
case _SsoButton():
return $default(_that.provider,_that.label);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SsoProvider provider,  String label)?  $default,) {final _that = this;
switch (_that) {
case _SsoButton() when $default != null:
return $default(_that.provider,_that.label);case _:
  return null;

}
}

}

/// @nodoc


class _SsoButton extends SsoButton {
  const _SsoButton({required this.provider, required this.label}): super._();
  

@override final  SsoProvider provider;
@override final  String label;

/// Create a copy of SsoButton
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SsoButtonCopyWith<_SsoButton> get copyWith => __$SsoButtonCopyWithImpl<_SsoButton>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SsoButton&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.label, label) || other.label == label));
}


@override
int get hashCode {
    return Object.hash(runtimeType,provider,label);
}

@override
String toString() {
    return 'SsoButton(provider: $provider, label: $label)';
}


}

/// @nodoc
abstract mixin class _$SsoButtonCopyWith<$Res> implements $SsoButtonCopyWith<$Res> {
  factory _$SsoButtonCopyWith(_SsoButton value, $Res Function(_SsoButton) _then) = __$SsoButtonCopyWithImpl;
@override @useResult
$Res call({
 SsoProvider provider, String label
});




}
/// @nodoc
class __$SsoButtonCopyWithImpl<$Res>
    implements _$SsoButtonCopyWith<$Res> {
  __$SsoButtonCopyWithImpl(this._self, this._then);

  final _SsoButton _self;
  final $Res Function(_SsoButton) _then;

/// Create a copy of SsoButton
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? provider = null,Object? label = null,}) {
  return _then(_SsoButton(
provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as SsoProvider,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
