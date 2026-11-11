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
  static const convertPublicToPrivate = 'convert_public_channel_to_private';
  static const manageChannelRoles = 'manage_channel_roles';
  static const manageTeam = 'manage_team';
  static const manageSystem = 'manage_system';
  static const inviteUser = 'invite_user';
  static const addUserToTeam = 'add_user_to_team';
  static const createPost = 'create_post';
  static const editPost = 'edit_post';
  static const editOthersPosts = 'edit_others_posts';
  static const deletePost = 'delete_post';
  static const deleteOthersPosts = 'delete_others_posts';
  static const addReaction = 'add_reaction';
  static const useChannelMentions = 'use_channel_mentions';
  static const useGroupMentions = 'use_group_mentions';
  static const createEmojis = 'create_emojis';
  static const deleteEmojis = 'delete_emojis';
  static const deleteOthersEmojis = 'delete_others_emojis';
}

/// The system role whose holders the default channel's read-only mode
/// doesn't apply to.
const systemAdminRole = 'system_admin';

/// Pure: whether a user's space-separated system [roles] make them a
/// system admin.
bool isSystemAdmin(String? roles) =>
    roleNames([roles ?? '']).contains(systemAdminRole);

/// Pure: whether a user's space-separated system [roles] make them a
/// guest account.
bool isGuest(String? roles) =>
    roleNames([roles ?? '']).contains('system_guest');

/// Each known role's permissions by role name.
typedef Grants = Map<String, Set<String>>;

/// Answers whether the user holds a permission at one level of the cascade.
typedef Can = bool Function(String permission);

bool _held(String permission, String roles, Grants granted) =>
    roleNames([roles])
        .any((role) => granted[role]?.contains(permission) ?? false);

/// Pure: `haveISystemPermission` of the web app: the user's system roles.
Can haveISystemPermission({
  required String systemRoles,
  required Grants granted,
}) =>
    (permission) => _held(permission, systemRoles, granted);

/// Pure: `haveITeamPermission`: the system roles, then the roles in the
/// membership of that team.
Can haveITeamPermission({
  required String systemRoles,
  required String teamRoles,
  required Grants granted,
}) {
  final system = haveISystemPermission(
    systemRoles: systemRoles,
    granted: granted,
  );
  return (permission) =>
      system(permission) || _held(permission, teamRoles, granted);
}

/// Pure: `haveIChannelPermission`: the system roles, then the roles in the
/// membership of the channel's team (empty for direct and group messages),
/// then the roles in the channel membership.
Can haveIChannelPermission({
  required String systemRoles,
  required String teamRoles,
  required String channelRoles,
  required Grants granted,
}) {
  final team = haveITeamPermission(
    systemRoles: systemRoles,
    teamRoles: teamRoles,
    granted: granted,
  );
  return (permission) =>
      team(permission) || _held(permission, channelRoles, granted);
}

/// Pure: the web app's any-team gate, used for custom emoji: the system
/// roles or the roles in any team the user belongs to.
Can haveIAnyTeamPermission({
  required String systemRoles,
  required Iterable<String> teamRoles,
  required Grants granted,
}) {
  final system = haveISystemPermission(
    systemRoles: systemRoles,
    granted: granted,
  );
  return (permission) =>
      system(permission) ||
      teamRoles.any((roles) => _held(permission, roles, granted));
}

/// Role names from the server's space-separated role strings.
Set<String> roleNames(Iterable<String> roleStrings) => {
  for (final roles in roleStrings)
    for (final name in roles.split(' '))
      if (name.isNotEmpty) name,
};

/// What the user may do with one channel.
typedef ChannelRights = ({
  bool edit,
  bool archive,
  bool manageMembers,

  /// Make members channel admins or ordinary members.
  bool manageRoles,

  /// Make a public channel private; never true for a private one.
  bool convert,

  /// Bring an archived channel back, a team admin's right.
  bool unarchive,
});

/// Pure: the rights for a channel of [type] (`O` public, `P` private; direct
/// and group messages have none of these). Restoring a channel is checked
/// for its team, everything else for the channel.
ChannelRights channelRights(
  String type, {
  required Can can,
  required Can canInTeam,
}) {
  return switch (type) {
    'O' => (
      edit: can(Permission.managePublicProperties),
      archive: can(Permission.deletePublicChannel),
      manageMembers: can(Permission.managePublicMembers),
      manageRoles:
          can(Permission.managePublicMembers) &&
          can(Permission.manageChannelRoles),
      convert: can(Permission.convertPublicToPrivate),
      unarchive: canInTeam(Permission.manageTeam),
    ),
    'P' => (
      edit: can(Permission.managePrivateProperties),
      archive: can(Permission.deletePrivateChannel),
      manageMembers: can(Permission.managePrivateMembers),
      manageRoles:
          can(Permission.managePrivateMembers) &&
          can(Permission.manageChannelRoles),
      convert: false,
      unarchive: canInTeam(Permission.manageTeam),
    ),
    _ => (
      edit: false,
      archive: false,
      manageMembers: false,
      manageRoles: false,
      convert: false,
      unarchive: false,
    ),
  };
}

/// What the user may do about inviting people to a team.
typedef TeamInviteRights = ({bool byEmail, bool byLink});

/// Pure: inviting by email needs the permission and the server's email
/// invitations; the link is for those who may add people to the team.
TeamInviteRights teamInviteRights({
  required Can can,
  required bool emailInvitations,
}) {
  return (
    byEmail: emailInvitations && can(Permission.inviteUser),
    byLink: can(Permission.addUserToTeam),
  );
}

/// Pure: whether a group message can become a private channel: the server
/// is 9.1 or newer and the user may create private channels.
bool canConvertGroupMessage({
  required String type,
  required bool serverSupports,
  required bool createPrivate,
}) => type == 'G' && serverSupports && createPrivate;

/// Why the user can't write in a channel.
enum PostingBlock {
  archived,

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

/// Pure: the user's rights in a channel from its state and [can], their
/// permissions there.
ChannelPermissions channelPermissions({
  required bool archived,
  required Can can,
}) {
  final write = !archived;
  final post = can(Permission.createPost);
  final canEdit = write && post && can(Permission.editPost);
  final canDelete = write && post;
  return (
    block: archived
        ? PostingBlock.archived
        : post
        ? null
        : PostingBlock.notAllowed,
    react: write && can(Permission.addReaction),
    editOwn: canEdit,
    editOthers: canEdit && can(Permission.editOthersPosts),
    deleteOwn: canDelete && can(Permission.deletePost),
    deleteOthers: canDelete && can(Permission.deleteOthersPosts),
    channelMentions: can(Permission.useChannelMentions),
    groupMentions: can(Permission.useGroupMentions),
  );
}

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
  required DateTime createAt,
  required DateTime now,
  required Duration? editTimeLimit,
}) {
  final archived = channel.block == PostingBlock.archived;
  final open = !archived;
  final inTime =
      editTimeLimit == null || now.isBefore(createAt.add(editTimeLimit));
  return (
    react: !system && channel.react,
    reply: !system && channel.block == null,
    pin: !system && open,
    edit: !system && inTime && (mine ? channel.editOwn : channel.editOthers),
    delete: mine ? channel.deleteOwn : channel.deleteOthers,
    markUnread: !archived && !system,
  );
}
