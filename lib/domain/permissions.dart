/// Permission names the app checks, as the server's roles list them.
abstract final class Permission {
  static const createPublicChannel = 'create_public_channel';
  static const createPrivateChannel = 'create_private_channel';
  static const joinPublicChannels = 'join_public_channels';
  static const managePublicProperties = 'manage_public_channel_properties';
  static const managePrivateProperties = 'manage_private_channel_properties';
  static const managePublicMembers = 'manage_public_channel_members';
  static const managePrivateMembers = 'manage_private_channel_members';
  static const deletePublicChannel = 'delete_public_channel';
  static const deletePrivateChannel = 'delete_private_channel';
}

/// Pure: whether any of the user's [roles] (system, team and channel roles
/// together, as the server checks them) grants [permission]. [granted] holds
/// each known role's permissions.
bool hasPermission(
  String permission, {
  required Iterable<String> roles,
  required Map<String, Set<String>> granted,
}) => roles.any((role) => granted[role]?.contains(permission) ?? false);

/// Role names from the server's space-separated role strings.
Set<String> roleNames(Iterable<String> roleStrings) => {
  for (final roles in roleStrings)
    for (final name in roles.split(' '))
      if (name.isNotEmpty) name,
};

/// What the user may do with one channel.
typedef ChannelRights = ({bool edit, bool archive, bool manageMembers});

/// Pure: the rights for a channel of [type] (`O` public, `P` private; direct
/// and group messages have none of these).
ChannelRights channelRights(
  String type, {
  required Iterable<String> roles,
  required Map<String, Set<String>> granted,
}) {
  bool can(String permission) =>
      hasPermission(permission, roles: roles, granted: granted);
  return switch (type) {
    'O' => (
      edit: can(Permission.managePublicProperties),
      archive: can(Permission.deletePublicChannel),
      manageMembers: can(Permission.managePublicMembers),
    ),
    'P' => (
      edit: can(Permission.managePrivateProperties),
      archive: can(Permission.deletePrivateChannel),
      manageMembers: can(Permission.managePrivateMembers),
    ),
    _ => (edit: false, archive: false, manageMembers: false),
  };
}
