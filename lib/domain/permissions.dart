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
  static const createPost = 'create_post';
  static const editPost = 'edit_post';
  static const editOthersPosts = 'edit_others_posts';
  static const deletePost = 'delete_post';
  static const deleteOthersPosts = 'delete_others_posts';
  static const addReaction = 'add_reaction';
  static const useChannelMentions = 'use_channel_mentions';
  static const useGroupMentions = 'use_group_mentions';
}

/// The system role whose holders the default channel's read-only mode
/// doesn't apply to.
const systemAdminRole = 'system_admin';

/// Pure: whether a user's space-separated system [roles] make them a
/// guest account.
bool isGuest(String? roles) =>
    roleNames([roles ?? '']).contains('system_guest');

/// The server keeps at most this many different emoji on one message.
const maxDistinctReactions = 40;

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

/// Why the user can't write in a channel.
enum PostingBlock {
  archived,

  /// Only admins post here (the server's read-only default channel).
  readOnly,

  /// The user's roles don't include posting here.
  notAllowed,
}

/// What the user may do with messages in one channel.
typedef ChannelPermissions = ({
  /// Null when the user can post.
  PostingBlock? block,
  bool react,
  bool editOwn,
  bool editOthers,
  bool deleteOwn,
  bool deleteOthers,

  /// @all, @channel and @here notify everyone.
  bool channelMentions,

  /// @group notifies the group's members.
  bool groupMentions,
});

/// For a channel that isn't stored: nothing beyond reading.
const ChannelPermissions noChannelRights = (
  block: PostingBlock.notAllowed,
  react: false,
  editOwn: false,
  editOthers: false,
  deleteOwn: false,
  deleteOthers: false,
  channelMentions: false,
  groupMentions: false,
);

/// Pure: the user's rights in a channel from its state and the permissions
/// their system, team and channel roles grant together.
ChannelPermissions channelPermissions({
  required bool archived,
  required bool readOnly,
  required Set<String> granted,
}) {
  final write = !archived && !readOnly;
  final post = granted.contains(Permission.createPost);
  final canEdit = write && post && granted.contains(Permission.editPost);
  final canDelete = write && post;
  return (
    block: archived
        ? PostingBlock.archived
        : readOnly
        ? PostingBlock.readOnly
        : post
        ? null
        : PostingBlock.notAllowed,
    react: write && granted.contains(Permission.addReaction),
    editOwn: canEdit,
    editOthers: canEdit && granted.contains(Permission.editOthersPosts),
    deleteOwn: canDelete && granted.contains(Permission.deletePost),
    deleteOthers: canDelete && granted.contains(Permission.deleteOthersPosts),
    channelMentions: granted.contains(Permission.useChannelMentions),
    groupMentions: granted.contains(Permission.useGroupMentions),
  );
}

/// Pure: the permissions [roles] grant together; [granted] holds each
/// known role's permissions.
Set<String> grantedBy(
  Iterable<String> roles,
  Map<String, Set<String>> granted,
) => {for (final role in roles) ...?granted[role]};

/// Pure: whether the default channel is closed to [roles] because the
/// server makes it read-only for everyone but system admins.
bool readOnlyChannel({
  required String channelName,
  required bool townSquareReadOnly,
  required Set<String> roles,
}) =>
    townSquareReadOnly &&
    channelName == 'town-square' &&
    !roles.contains(systemAdminRole);

/// What the message menu offers for one message.
typedef MessageRights = ({
  bool react,
  bool reply,
  bool pin,
  bool edit,
  bool delete,
  bool markUnread,
});

/// Pure: the rights on one message in a channel with [channel] rights.
/// [editTimeLimit] is the server's window for edits after posting, null
/// for none.
MessageRights messageRights(
  ChannelPermissions channel, {
  required bool mine,
  required bool system,
  required bool fromWebhook,
  required DateTime createAt,
  required DateTime now,
  required Duration? editTimeLimit,
  required int distinctReactions,
}) {
  final archived = channel.block == PostingBlock.archived;
  final open = !archived && channel.block != PostingBlock.readOnly;
  final inTime =
      editTimeLimit == null || now.isBefore(createAt.add(editTimeLimit));
  return (
    react: !system && channel.react && distinctReactions < maxDistinctReactions,
    reply: !system && channel.block == null,
    pin: !system && open,
    edit: !system && inTime && (mine ? channel.editOwn : channel.editOthers),
    delete: mine ? channel.deleteOwn : channel.deleteOthers,
    markUnread: !archived && ((!mine && !system) || fromWebhook),
  );
}
