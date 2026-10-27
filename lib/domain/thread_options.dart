/// What can be done with a followed thread, in the order the sheet shows it.
enum ThreadOption {
  reply('Reply'),
  unfollow('Unfollow thread'),
  follow('Follow thread'),
  openInChannel('Open in channel'),
  markRead('Mark as read'),
  markUnread('Mark as unread'),
  save('Save'),
  unsave('Unsave'),
  copyLink('Copy link');

  const ThreadOption(this.label);

  final String label;
}

/// Pure: the options for a thread, as the official app orders them. The
/// link needs the team's name, so it is left out until that is known.
List<ThreadOption> threadOptions({
  required bool following,
  required bool unread,
  required bool saved,
  required bool canLink,
}) => [
  ThreadOption.reply,
  if (following) ThreadOption.unfollow else ThreadOption.follow,
  ThreadOption.openInChannel,
  if (unread) ThreadOption.markRead else ThreadOption.markUnread,
  if (saved) ThreadOption.unsave else ThreadOption.save,
  if (canLink) ThreadOption.copyLink,
];
