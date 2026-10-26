import 'package:matterleast/domain/permissions.dart';
import 'package:matterleast/domain/post_files.dart';

/// A link or file pinned to a channel's bookmark bar.
class Bookmark {
  const Bookmark({
    required this.id,
    required this.channelId,
    required this.displayName,
    required this.sortOrder,
    this.isFile = false,
    this.linkUrl,
    this.imageUrl,
    this.emoji,
    this.file,
    this.changedAt,
  });

  final String id;
  final String channelId;
  final String displayName;
  final int sortOrder;
  final bool isFile;
  final String? linkUrl;
  final String? imageUrl;
  final String? emoji;

  /// A file bookmark's file, once its details are stored.
  final PostFile? file;

  /// When it was added or last changed.
  final DateTime? changedAt;

  @override
  bool operator ==(Object other) =>
      other is Bookmark &&
      other.id == id &&
      other.channelId == channelId &&
      other.displayName == displayName &&
      other.sortOrder == sortOrder &&
      other.isFile == isFile &&
      other.linkUrl == linkUrl &&
      other.imageUrl == imageUrl &&
      other.emoji == emoji &&
      other.file?.id == file?.id &&
      other.file?.name == file?.name &&
      other.file?.size == file?.size &&
      other.changedAt == changedAt;

  @override
  int get hashCode => Object.hash(
    id,
    channelId,
    displayName,
    sortOrder,
    isFile,
    linkUrl,
    imageUrl,
    emoji,
    file?.id,
  );
}

abstract final class BookmarkPermission {
  static const addPublic = 'add_bookmark_public_channel';
  static const addPrivate = 'add_bookmark_private_channel';
  static const editPublic = 'edit_bookmark_public_channel';
  static const editPrivate = 'edit_bookmark_private_channel';
  static const deletePublic = 'delete_bookmark_public_channel';
  static const deletePrivate = 'delete_bookmark_private_channel';
  static const orderPublic = 'order_bookmark_public_channel';
  static const orderPrivate = 'order_bookmark_private_channel';
}

/// What the user may do with a channel's bookmarks.
typedef BookmarkRights = ({bool add, bool edit, bool delete, bool reorder});

const BookmarkRights noBookmarkRights = (
  add: false,
  edit: false,
  delete: false,
  reorder: false,
);

/// Pure: the bookmark rights in a channel of [type] (`O`, `P`, `D`, `G`).
/// Direct and group messages allow everything to members who aren't
/// guests, as the server does; archived channels allow nothing.
BookmarkRights bookmarkRights(
  String type, {
  required bool archived,
  required bool guest,
  required Iterable<String> roles,
  required Map<String, Set<String>> granted,
}) {
  if (archived || guest) return noBookmarkRights;
  if (type == 'D' || type == 'G') {
    return (add: true, edit: true, delete: true, reorder: true);
  }
  final public = type == 'O';
  bool can(String publicName, String privateName) => hasPermission(
    public ? publicName : privateName,
    roles: roles,
    granted: granted,
  );
  return (
    add: can(BookmarkPermission.addPublic, BookmarkPermission.addPrivate),
    edit: can(BookmarkPermission.editPublic, BookmarkPermission.editPrivate),
    delete: can(
      BookmarkPermission.deletePublic,
      BookmarkPermission.deletePrivate,
    ),
    reorder: can(
      BookmarkPermission.orderPublic,
      BookmarkPermission.orderPrivate,
    ),
  );
}

/// Pure: the link a typed address stands for, with `https://` added when
/// the user left the scheme out; null when it isn't a web address.
Uri? bookmarkLink(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty || trimmed.contains(' ')) return null;
  final withScheme = RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*://').hasMatch(trimmed)
      ? trimmed
      : 'https://$trimmed';
  final uri = Uri.tryParse(withScheme);
  if (uri == null || !const {'http', 'https'}.contains(uri.scheme)) {
    return null;
  }
  if (uri.host.isEmpty || !uri.host.contains('.') && uri.host != 'localhost') {
    return null;
  }
  return uri;
}
