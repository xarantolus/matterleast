import 'package:matterleast/api/generated/export.dart' as api;

/// One earlier text of an edited message.
typedef EditVersion = ({String id, String message, DateTime at});

/// Pure: the versions the server listed, in its order (newest first),
/// leaving out entries without an id or a time.
List<EditVersion> editVersions(List<api.Post> posts) => [
  for (final post in posts)
    if (post.id case final id? when id.isNotEmpty)
      if (post.editAt ?? post.createAt case final at?)
        (id: id, message: post.message ?? '', at: at),
];
