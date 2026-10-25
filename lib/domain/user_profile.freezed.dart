// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CustomStatus {

 String get emoji; String get text;/// Empty for "don't clear", else `thirty_minutes`, `one_hour`,
/// `four_hours`, `today`, `this_week` or `date_and_time`.
 String get duration;@JsonKey(name: 'expires_at', fromJson: _date, toJson: _dateJson) DateTime? get expiresAt;
/// Create a copy of CustomStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomStatusCopyWith<CustomStatus> get copyWith => _$CustomStatusCopyWithImpl<CustomStatus>(this as CustomStatus, _$identity);

  /// Serializes this CustomStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CustomStatus;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomStatus&&(identical(other.emoji, _this.emoji) || other.emoji == _this.emoji)&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.duration, _this.duration) || other.duration == _this.duration)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CustomStatus;
  return Object.hash(runtimeType,_this.emoji,_this.text,_this.duration,_this.expiresAt);
}

@override
String toString() {
  final _this = this as CustomStatus;
  return 'CustomStatus(emoji: ${_this.emoji}, text: ${_this.text}, duration: ${_this.duration}, expiresAt: ${_this.expiresAt})';
}


}

/// @nodoc
abstract mixin class $CustomStatusCopyWith<$Res>  {
  factory $CustomStatusCopyWith(CustomStatus value, $Res Function(CustomStatus) _then) = _$CustomStatusCopyWithImpl;
@useResult
$Res call({
 String emoji, String text, String duration,@JsonKey(name: 'expires_at', fromJson: _date, toJson: _dateJson) DateTime? expiresAt
});




}
/// @nodoc
class _$CustomStatusCopyWithImpl<$Res>
    implements $CustomStatusCopyWith<$Res> {
  _$CustomStatusCopyWithImpl(this._self, this._then);

  final CustomStatus _self;
  final $Res Function(CustomStatus) _then;

/// Create a copy of CustomStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? emoji = null,Object? text = null,Object? duration = null,Object? expiresAt = freezed,}) {
  return _then(CustomStatus(
emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as String,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [CustomStatus].
extension CustomStatusPatterns on CustomStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomStatus value)  $default,){
final _that = this;
switch (_that) {
case _CustomStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomStatus value)?  $default,){
final _that = this;
switch (_that) {
case _CustomStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String emoji,  String text,  String duration, @JsonKey(name: 'expires_at', fromJson: _date, toJson: _dateJson)  DateTime? expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomStatus() when $default != null:
return $default(_that.emoji,_that.text,_that.duration,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String emoji,  String text,  String duration, @JsonKey(name: 'expires_at', fromJson: _date, toJson: _dateJson)  DateTime? expiresAt)  $default,) {final _that = this;
switch (_that) {
case _CustomStatus():
return $default(_that.emoji,_that.text,_that.duration,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String emoji,  String text,  String duration, @JsonKey(name: 'expires_at', fromJson: _date, toJson: _dateJson)  DateTime? expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _CustomStatus() when $default != null:
return $default(_that.emoji,_that.text,_that.duration,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CustomStatus implements CustomStatus {
  const _CustomStatus({this.emoji = '', this.text = '', this.duration = '', @JsonKey(name: 'expires_at', fromJson: _date, toJson: _dateJson) this.expiresAt});
  factory _CustomStatus.fromJson(Map<String, dynamic> json) => _$CustomStatusFromJson(json);

@override@JsonKey() final  String emoji;
@override@JsonKey() final  String text;
/// Empty for "don't clear", else `thirty_minutes`, `one_hour`,
/// `four_hours`, `today`, `this_week` or `date_and_time`.
@override@JsonKey() final  String duration;
@override@JsonKey(name: 'expires_at', fromJson: _date, toJson: _dateJson) final  DateTime? expiresAt;

/// Create a copy of CustomStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomStatusCopyWith<_CustomStatus> get copyWith => __$CustomStatusCopyWithImpl<_CustomStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CustomStatusToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomStatus&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.text, text) || other.text == text)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,emoji,text,duration,expiresAt);
}

@override
String toString() {
    return 'CustomStatus(emoji: $emoji, text: $text, duration: $duration, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$CustomStatusCopyWith<$Res> implements $CustomStatusCopyWith<$Res> {
  factory _$CustomStatusCopyWith(_CustomStatus value, $Res Function(_CustomStatus) _then) = __$CustomStatusCopyWithImpl;
@override @useResult
$Res call({
 String emoji, String text, String duration,@JsonKey(name: 'expires_at', fromJson: _date, toJson: _dateJson) DateTime? expiresAt
});




}
/// @nodoc
class __$CustomStatusCopyWithImpl<$Res>
    implements _$CustomStatusCopyWith<$Res> {
  __$CustomStatusCopyWithImpl(this._self, this._then);

  final _CustomStatus _self;
  final $Res Function(_CustomStatus) _then;

/// Create a copy of CustomStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? emoji = null,Object? text = null,Object? duration = null,Object? expiresAt = freezed,}) {
  return _then(_CustomStatus(
emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as String,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
mixin _$UserProfile {

 String get id; String get name; String get username; String get nickname; String get firstName; String get lastName; String get position; String get status; int? get pictureUpdate; String? get timezone; CustomStatus? get customStatus; bool get isBot; bool get isMe;
/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileCopyWith<UserProfile> get copyWith => _$UserProfileCopyWithImpl<UserProfile>(this as UserProfile, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as UserProfile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfile&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.nickname, _this.nickname) || other.nickname == _this.nickname)&&(identical(other.firstName, _this.firstName) || other.firstName == _this.firstName)&&(identical(other.lastName, _this.lastName) || other.lastName == _this.lastName)&&(identical(other.position, _this.position) || other.position == _this.position)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.pictureUpdate, _this.pictureUpdate) || other.pictureUpdate == _this.pictureUpdate)&&(identical(other.timezone, _this.timezone) || other.timezone == _this.timezone)&&(identical(other.customStatus, _this.customStatus) || other.customStatus == _this.customStatus)&&(identical(other.isBot, _this.isBot) || other.isBot == _this.isBot)&&(identical(other.isMe, _this.isMe) || other.isMe == _this.isMe));
}


@override
int get hashCode {
  final _this = this as UserProfile;
  return Object.hash(runtimeType,_this.id,_this.name,_this.username,_this.nickname,_this.firstName,_this.lastName,_this.position,_this.status,_this.pictureUpdate,_this.timezone,_this.customStatus,_this.isBot,_this.isMe);
}

@override
String toString() {
  final _this = this as UserProfile;
  return 'UserProfile(id: ${_this.id}, name: ${_this.name}, username: ${_this.username}, nickname: ${_this.nickname}, firstName: ${_this.firstName}, lastName: ${_this.lastName}, position: ${_this.position}, status: ${_this.status}, pictureUpdate: ${_this.pictureUpdate}, timezone: ${_this.timezone}, customStatus: ${_this.customStatus}, isBot: ${_this.isBot}, isMe: ${_this.isMe})';
}


}

/// @nodoc
abstract mixin class $UserProfileCopyWith<$Res>  {
  factory $UserProfileCopyWith(UserProfile value, $Res Function(UserProfile) _then) = _$UserProfileCopyWithImpl;
@useResult
$Res call({
 String id, String name, String username, String nickname, String firstName, String lastName, String position, String status, int? pictureUpdate, String? timezone, CustomStatus? customStatus, bool isBot, bool isMe
});


$CustomStatusCopyWith<$Res>? get customStatus;

}
/// @nodoc
class _$UserProfileCopyWithImpl<$Res>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._self, this._then);

  final UserProfile _self;
  final $Res Function(UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? username = null,Object? nickname = null,Object? firstName = null,Object? lastName = null,Object? position = null,Object? status = null,Object? pictureUpdate = freezed,Object? timezone = freezed,Object? customStatus = freezed,Object? isBot = null,Object? isMe = null,}) {
  return _then(UserProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,nickname: null == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,pictureUpdate: freezed == pictureUpdate ? _self.pictureUpdate : pictureUpdate // ignore: cast_nullable_to_non_nullable
as int?,timezone: freezed == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String?,customStatus: freezed == customStatus ? _self.customStatus : customStatus // ignore: cast_nullable_to_non_nullable
as CustomStatus?,isBot: null == isBot ? _self.isBot : isBot // ignore: cast_nullable_to_non_nullable
as bool,isMe: null == isMe ? _self.isMe : isMe // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CustomStatusCopyWith<$Res>? get customStatus {
    if (_self.customStatus == null) {
    return null;
  }

  return $CustomStatusCopyWith<$Res>(_self.customStatus!, (value) {
    return _then(_self.copyWith(customStatus: value));
  });
}
}


/// Adds pattern-matching-related methods to [UserProfile].
extension UserProfilePatterns on UserProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfile value)  $default,){
final _that = this;
switch (_that) {
case _UserProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfile value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String username,  String nickname,  String firstName,  String lastName,  String position,  String status,  int? pictureUpdate,  String? timezone,  CustomStatus? customStatus,  bool isBot,  bool isMe)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.id,_that.name,_that.username,_that.nickname,_that.firstName,_that.lastName,_that.position,_that.status,_that.pictureUpdate,_that.timezone,_that.customStatus,_that.isBot,_that.isMe);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String username,  String nickname,  String firstName,  String lastName,  String position,  String status,  int? pictureUpdate,  String? timezone,  CustomStatus? customStatus,  bool isBot,  bool isMe)  $default,) {final _that = this;
switch (_that) {
case _UserProfile():
return $default(_that.id,_that.name,_that.username,_that.nickname,_that.firstName,_that.lastName,_that.position,_that.status,_that.pictureUpdate,_that.timezone,_that.customStatus,_that.isBot,_that.isMe);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String username,  String nickname,  String firstName,  String lastName,  String position,  String status,  int? pictureUpdate,  String? timezone,  CustomStatus? customStatus,  bool isBot,  bool isMe)?  $default,) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.id,_that.name,_that.username,_that.nickname,_that.firstName,_that.lastName,_that.position,_that.status,_that.pictureUpdate,_that.timezone,_that.customStatus,_that.isBot,_that.isMe);case _:
  return null;

}
}

}

/// @nodoc


class _UserProfile implements UserProfile {
  const _UserProfile({required this.id, required this.name, required this.username, required this.nickname, required this.firstName, required this.lastName, required this.position, required this.status, this.pictureUpdate, this.timezone, this.customStatus, required this.isBot, required this.isMe});
  

@override final  String id;
@override final  String name;
@override final  String username;
@override final  String nickname;
@override final  String firstName;
@override final  String lastName;
@override final  String position;
@override final  String status;
@override final  int? pictureUpdate;
@override final  String? timezone;
@override final  CustomStatus? customStatus;
@override final  bool isBot;
@override final  bool isMe;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileCopyWith<_UserProfile> get copyWith => __$UserProfileCopyWithImpl<_UserProfile>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.username, username) || other.username == username)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.position, position) || other.position == position)&&(identical(other.status, status) || other.status == status)&&(identical(other.pictureUpdate, pictureUpdate) || other.pictureUpdate == pictureUpdate)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.customStatus, customStatus) || other.customStatus == customStatus)&&(identical(other.isBot, isBot) || other.isBot == isBot)&&(identical(other.isMe, isMe) || other.isMe == isMe));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,username,nickname,firstName,lastName,position,status,pictureUpdate,timezone,customStatus,isBot,isMe);
}

@override
String toString() {
    return 'UserProfile(id: $id, name: $name, username: $username, nickname: $nickname, firstName: $firstName, lastName: $lastName, position: $position, status: $status, pictureUpdate: $pictureUpdate, timezone: $timezone, customStatus: $customStatus, isBot: $isBot, isMe: $isMe)';
}


}

/// @nodoc
abstract mixin class _$UserProfileCopyWith<$Res> implements $UserProfileCopyWith<$Res> {
  factory _$UserProfileCopyWith(_UserProfile value, $Res Function(_UserProfile) _then) = __$UserProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String username, String nickname, String firstName, String lastName, String position, String status, int? pictureUpdate, String? timezone, CustomStatus? customStatus, bool isBot, bool isMe
});


@override $CustomStatusCopyWith<$Res>? get customStatus;

}
/// @nodoc
class __$UserProfileCopyWithImpl<$Res>
    implements _$UserProfileCopyWith<$Res> {
  __$UserProfileCopyWithImpl(this._self, this._then);

  final _UserProfile _self;
  final $Res Function(_UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? username = null,Object? nickname = null,Object? firstName = null,Object? lastName = null,Object? position = null,Object? status = null,Object? pictureUpdate = freezed,Object? timezone = freezed,Object? customStatus = freezed,Object? isBot = null,Object? isMe = null,}) {
  return _then(_UserProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,nickname: null == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,pictureUpdate: freezed == pictureUpdate ? _self.pictureUpdate : pictureUpdate // ignore: cast_nullable_to_non_nullable
as int?,timezone: freezed == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String?,customStatus: freezed == customStatus ? _self.customStatus : customStatus // ignore: cast_nullable_to_non_nullable
as CustomStatus?,isBot: null == isBot ? _self.isBot : isBot // ignore: cast_nullable_to_non_nullable
as bool,isMe: null == isMe ? _self.isMe : isMe // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CustomStatusCopyWith<$Res>? get customStatus {
    if (_self.customStatus == null) {
    return null;
  }

  return $CustomStatusCopyWith<$Res>(_self.customStatus!, (value) {
    return _then(_self.copyWith(customStatus: value));
  });
}
}

// dart format on
