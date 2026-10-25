// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'server_link.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ServerLink {

 Uri get server; String? get team;
/// Create a copy of ServerLink
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerLinkCopyWith<ServerLink> get copyWith => _$ServerLinkCopyWithImpl<ServerLink>(this as ServerLink, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ServerLink;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerLink&&(identical(other.server, _this.server) || other.server == _this.server)&&(identical(other.team, _this.team) || other.team == _this.team));
}


@override
int get hashCode {
  final _this = this as ServerLink;
  return Object.hash(runtimeType,_this.server,_this.team);
}

@override
String toString() {
  final _this = this as ServerLink;
  return 'ServerLink(server: ${_this.server}, team: ${_this.team})';
}


}

/// @nodoc
abstract mixin class $ServerLinkCopyWith<$Res>  {
  factory $ServerLinkCopyWith(ServerLink value, $Res Function(ServerLink) _then) = _$ServerLinkCopyWithImpl;
@useResult
$Res call({
 Uri server, String team
});




}
/// @nodoc
class _$ServerLinkCopyWithImpl<$Res>
    implements $ServerLinkCopyWith<$Res> {
  _$ServerLinkCopyWithImpl(this._self, this._then);

  final ServerLink _self;
  final $Res Function(ServerLink) _then;

/// Create a copy of ServerLink
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? server = null,Object? team = null,}) {
  return _then(_self.copyWith(
server: null == server ? _self.server : server // ignore: cast_nullable_to_non_nullable
as Uri,team: null == team ? _self.team! : team // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ServerLink].
extension ServerLinkPatterns on ServerLink {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PostLink value)?  post,TResult Function( ChannelNameLink value)?  channel,TResult Function( DirectMessageLink value)?  directMessage,TResult Function( ServerHomeLink value)?  home,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PostLink() when post != null:
return post(_that);case ChannelNameLink() when channel != null:
return channel(_that);case DirectMessageLink() when directMessage != null:
return directMessage(_that);case ServerHomeLink() when home != null:
return home(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PostLink value)  post,required TResult Function( ChannelNameLink value)  channel,required TResult Function( DirectMessageLink value)  directMessage,required TResult Function( ServerHomeLink value)  home,}){
final _that = this;
switch (_that) {
case PostLink():
return post(_that);case ChannelNameLink():
return channel(_that);case DirectMessageLink():
return directMessage(_that);case ServerHomeLink():
return home(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PostLink value)?  post,TResult? Function( ChannelNameLink value)?  channel,TResult? Function( DirectMessageLink value)?  directMessage,TResult? Function( ServerHomeLink value)?  home,}){
final _that = this;
switch (_that) {
case PostLink() when post != null:
return post(_that);case ChannelNameLink() when channel != null:
return channel(_that);case DirectMessageLink() when directMessage != null:
return directMessage(_that);case ServerHomeLink() when home != null:
return home(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( Uri server,  String team,  String postId)?  post,TResult Function( Uri server,  String team,  String name)?  channel,TResult Function( Uri server,  String team,  String username)?  directMessage,TResult Function( Uri server,  String? team)?  home,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PostLink() when post != null:
return post(_that.server,_that.team,_that.postId);case ChannelNameLink() when channel != null:
return channel(_that.server,_that.team,_that.name);case DirectMessageLink() when directMessage != null:
return directMessage(_that.server,_that.team,_that.username);case ServerHomeLink() when home != null:
return home(_that.server,_that.team);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( Uri server,  String team,  String postId)  post,required TResult Function( Uri server,  String team,  String name)  channel,required TResult Function( Uri server,  String team,  String username)  directMessage,required TResult Function( Uri server,  String? team)  home,}) {final _that = this;
switch (_that) {
case PostLink():
return post(_that.server,_that.team,_that.postId);case ChannelNameLink():
return channel(_that.server,_that.team,_that.name);case DirectMessageLink():
return directMessage(_that.server,_that.team,_that.username);case ServerHomeLink():
return home(_that.server,_that.team);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( Uri server,  String team,  String postId)?  post,TResult? Function( Uri server,  String team,  String name)?  channel,TResult? Function( Uri server,  String team,  String username)?  directMessage,TResult? Function( Uri server,  String? team)?  home,}) {final _that = this;
switch (_that) {
case PostLink() when post != null:
return post(_that.server,_that.team,_that.postId);case ChannelNameLink() when channel != null:
return channel(_that.server,_that.team,_that.name);case DirectMessageLink() when directMessage != null:
return directMessage(_that.server,_that.team,_that.username);case ServerHomeLink() when home != null:
return home(_that.server,_that.team);case _:
  return null;

}
}

}

/// @nodoc


class PostLink implements ServerLink {
  const PostLink({required this.server, required this.team, required this.postId});
  

@override final  Uri server;
@override final  String team;
 final  String postId;

/// Create a copy of ServerLink
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostLinkCopyWith<PostLink> get copyWith => _$PostLinkCopyWithImpl<PostLink>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PostLink&&(identical(other.server, server) || other.server == server)&&(identical(other.team, team) || other.team == team)&&(identical(other.postId, postId) || other.postId == postId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,server,team,postId);
}

@override
String toString() {
    return 'ServerLink.post(server: $server, team: $team, postId: $postId)';
}


}

/// @nodoc
abstract mixin class $PostLinkCopyWith<$Res> implements $ServerLinkCopyWith<$Res> {
  factory $PostLinkCopyWith(PostLink value, $Res Function(PostLink) _then) = _$PostLinkCopyWithImpl;
@override @useResult
$Res call({
 Uri server, String team, String postId
});




}
/// @nodoc
class _$PostLinkCopyWithImpl<$Res>
    implements $PostLinkCopyWith<$Res> {
  _$PostLinkCopyWithImpl(this._self, this._then);

  final PostLink _self;
  final $Res Function(PostLink) _then;

/// Create a copy of ServerLink
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? server = null,Object? team = null,Object? postId = null,}) {
  return _then(PostLink(
server: null == server ? _self.server : server // ignore: cast_nullable_to_non_nullable
as Uri,team: null == team ? _self.team : team // ignore: cast_nullable_to_non_nullable
as String,postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ChannelNameLink implements ServerLink {
  const ChannelNameLink({required this.server, required this.team, required this.name});
  

@override final  Uri server;
@override final  String team;
 final  String name;

/// Create a copy of ServerLink
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChannelNameLinkCopyWith<ChannelNameLink> get copyWith => _$ChannelNameLinkCopyWithImpl<ChannelNameLink>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ChannelNameLink&&(identical(other.server, server) || other.server == server)&&(identical(other.team, team) || other.team == team)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode {
    return Object.hash(runtimeType,server,team,name);
}

@override
String toString() {
    return 'ServerLink.channel(server: $server, team: $team, name: $name)';
}


}

/// @nodoc
abstract mixin class $ChannelNameLinkCopyWith<$Res> implements $ServerLinkCopyWith<$Res> {
  factory $ChannelNameLinkCopyWith(ChannelNameLink value, $Res Function(ChannelNameLink) _then) = _$ChannelNameLinkCopyWithImpl;
@override @useResult
$Res call({
 Uri server, String team, String name
});




}
/// @nodoc
class _$ChannelNameLinkCopyWithImpl<$Res>
    implements $ChannelNameLinkCopyWith<$Res> {
  _$ChannelNameLinkCopyWithImpl(this._self, this._then);

  final ChannelNameLink _self;
  final $Res Function(ChannelNameLink) _then;

/// Create a copy of ServerLink
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? server = null,Object? team = null,Object? name = null,}) {
  return _then(ChannelNameLink(
server: null == server ? _self.server : server // ignore: cast_nullable_to_non_nullable
as Uri,team: null == team ? _self.team : team // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class DirectMessageLink implements ServerLink {
  const DirectMessageLink({required this.server, required this.team, required this.username});
  

@override final  Uri server;
@override final  String team;
 final  String username;

/// Create a copy of ServerLink
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DirectMessageLinkCopyWith<DirectMessageLink> get copyWith => _$DirectMessageLinkCopyWithImpl<DirectMessageLink>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DirectMessageLink&&(identical(other.server, server) || other.server == server)&&(identical(other.team, team) || other.team == team)&&(identical(other.username, username) || other.username == username));
}


@override
int get hashCode {
    return Object.hash(runtimeType,server,team,username);
}

@override
String toString() {
    return 'ServerLink.directMessage(server: $server, team: $team, username: $username)';
}


}

/// @nodoc
abstract mixin class $DirectMessageLinkCopyWith<$Res> implements $ServerLinkCopyWith<$Res> {
  factory $DirectMessageLinkCopyWith(DirectMessageLink value, $Res Function(DirectMessageLink) _then) = _$DirectMessageLinkCopyWithImpl;
@override @useResult
$Res call({
 Uri server, String team, String username
});




}
/// @nodoc
class _$DirectMessageLinkCopyWithImpl<$Res>
    implements $DirectMessageLinkCopyWith<$Res> {
  _$DirectMessageLinkCopyWithImpl(this._self, this._then);

  final DirectMessageLink _self;
  final $Res Function(DirectMessageLink) _then;

/// Create a copy of ServerLink
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? server = null,Object? team = null,Object? username = null,}) {
  return _then(DirectMessageLink(
server: null == server ? _self.server : server // ignore: cast_nullable_to_non_nullable
as Uri,team: null == team ? _self.team : team // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ServerHomeLink implements ServerLink {
  const ServerHomeLink({required this.server, this.team});
  

@override final  Uri server;
@override final  String? team;

/// Create a copy of ServerLink
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerHomeLinkCopyWith<ServerHomeLink> get copyWith => _$ServerHomeLinkCopyWithImpl<ServerHomeLink>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerHomeLink&&(identical(other.server, server) || other.server == server)&&(identical(other.team, team) || other.team == team));
}


@override
int get hashCode {
    return Object.hash(runtimeType,server,team);
}

@override
String toString() {
    return 'ServerLink.home(server: $server, team: $team)';
}


}

/// @nodoc
abstract mixin class $ServerHomeLinkCopyWith<$Res> implements $ServerLinkCopyWith<$Res> {
  factory $ServerHomeLinkCopyWith(ServerHomeLink value, $Res Function(ServerHomeLink) _then) = _$ServerHomeLinkCopyWithImpl;
@override @useResult
$Res call({
 Uri server, String? team
});




}
/// @nodoc
class _$ServerHomeLinkCopyWithImpl<$Res>
    implements $ServerHomeLinkCopyWith<$Res> {
  _$ServerHomeLinkCopyWithImpl(this._self, this._then);

  final ServerHomeLink _self;
  final $Res Function(ServerHomeLink) _then;

/// Create a copy of ServerLink
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? server = null,Object? team = freezed,}) {
  return _then(ServerHomeLink(
server: null == server ? _self.server : server // ignore: cast_nullable_to_non_nullable
as Uri,team: freezed == team ? _self.team : team // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
