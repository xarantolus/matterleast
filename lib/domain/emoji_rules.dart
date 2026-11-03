import 'package:matterleast/domain/permissions.dart';

/// The server refuses custom emoji images over this size.
const maxEmojiImageBytes = 512 * 1024;

const maxEmojiNameLength = 64;

/// Image formats the server takes for custom emoji, by file extension.
const emojiImageTypes = <String, String>{
  'png': 'image/png',
  'jpg': 'image/jpeg',
  'jpeg': 'image/jpeg',
  'gif': 'image/gif',
};

final _nameChars = RegExp(r'^[a-z0-9_+-]+$');

/// Pure: why [name] can't be a new custom emoji's name, or null when it
/// can. [taken] says whether a name is a standard or custom emoji already.
String? emojiNameProblem(String name, {required bool Function(String) taken}) {
  if (name.isEmpty) return 'Give the emoji a name.';
  if (name.length > maxEmojiNameLength) {
    return 'Use at most $maxEmojiNameLength characters.';
  }
  if (!_nameChars.hasMatch(name)) {
    return 'Use lowercase letters, digits, - _ and + only.';
  }
  if (taken(name)) return 'That name is already used.';
  return null;
}

/// Pure: why an image called [fileName] of [bytes] can't be a custom emoji,
/// or null when it can.
String? emojiImageProblem({required String fileName, required int bytes}) {
  final dot = fileName.lastIndexOf('.');
  final extension = dot < 0 ? '' : fileName.substring(dot + 1).toLowerCase();
  if (!emojiImageTypes.containsKey(extension)) {
    return 'Pick a PNG, JPEG or GIF image.';
  }
  if (bytes > maxEmojiImageBytes) {
    return 'The image is larger than ${maxEmojiImageBytes ~/ 1024} KB.';
  }
  return null;
}

/// The media type for an image file name; null when not a custom emoji type.
String? emojiImageType(String fileName) =>
    emojiImageTypes[fileName.split('.').last.toLowerCase()];

/// Pure: a name for the emoji from an image's file name, to start from.
String suggestedEmojiName(String fileName) {
  final dot = fileName.lastIndexOf('.');
  final base = dot > 0 ? fileName.substring(0, dot) : fileName;
  final cleaned = base
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9_+-]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
  return cleaned.length > maxEmojiNameLength
      ? cleaned.substring(0, maxEmojiNameLength)
      : cleaned;
}

/// What the user may do with custom emoji.
typedef EmojiRights = ({bool create, bool deleteOwn, bool deleteOthers});

const noEmojiRights = (create: false, deleteOwn: false, deleteOthers: false);

/// Pure: the rights [can] grants (system or any team, as the web app
/// gates them); none when the server has custom emoji off.
EmojiRights emojiRights({required bool enabled, required Can can}) {
  if (!enabled) return noEmojiRights;
  return (
    create: can(Permission.createEmojis),
    deleteOwn: can(Permission.deleteEmojis),
    deleteOthers: can(Permission.deleteOthersEmojis),
  );
}

/// Pure: whether the user may delete an emoji made by [creatorId].
bool mayDeleteEmoji(
  EmojiRights rights, {
  required String creatorId,
  required String? me,
}) => creatorId == me ? rights.deleteOwn : rights.deleteOthers;

/// The picker asks the server for more when fewer custom emoji than this
/// match what was typed.
const serverSearchBelow = 5;

/// Pure: whether a typed [query] that [localCustomMatches] stored custom
/// emoji match is worth asking the server about.
bool asksServerForEmoji(String query, int localCustomMatches) =>
    query.length >= 2 && localCustomMatches < serverSearchBelow;
