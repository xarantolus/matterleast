// Compares the core model schemas of the prepared spec with the server's Go
// structs and prints the fields each side has that the other lacks. Report
// only: new Go fields are candidates for tool/api/overlay.yaml.
//
//   dart run tool/api/drift_report.dart <spec.json> <server/public/model dir>
import 'dart:convert';
import 'dart:io';

const _pairs = [
  ('post.go', 'Post'),
  ('post_metadata.go', 'PostMetadata'),
  ('post_list.go', 'PostList'),
  ('user.go', 'User'),
  ('channel.go', 'Channel'),
  ('channel_member.go', 'ChannelMember'),
  ('status.go', 'Status'),
  ('team.go', 'Team'),
  ('team_member.go', 'TeamMember'),
  ('file_info.go', 'FileInfo'),
  ('reaction.go', 'Reaction'),
  ('emoji.go', 'Emoji'),
  ('preference.go', 'Preference'),
  ('thread.go', 'ThreadResponse'),
];

void main(List<String> args) {
  if (args.length != 2) {
    stderr.writeln('usage: drift_report.dart <spec.json> <go model dir>');
    exit(2);
  }
  final spec =
      jsonDecode(File(args[0]).readAsStringSync()) as Map<String, Object?>;
  final schemas =
      (spec['components'] as Map<String, Object?>)['schemas']
          as Map<String, Object?>;

  for (final (file, name) in _pairs) {
    final goFile = File('${args[1]}/$file');
    final schema = schemas[name];
    if (!goFile.existsSync() || schema is! Map<String, Object?>) {
      stdout.writeln('$name: missing ${goFile.existsSync() ? "schema" : file}');
      continue;
    }
    final struct = RegExp(
      'type $name struct \\{(.*?)\\n\\}',
      dotAll: true,
    ).firstMatch(goFile.readAsStringSync());
    if (struct == null) {
      stdout.writeln('$name: struct not found in $file');
      continue;
    }
    final goFields = RegExp(r'json:"([a-z_0-9]+)')
        .allMatches(struct.group(1)!)
        .map((m) => m.group(1)!)
        .toSet();
    final specFields = ((schema['properties'] as Map<String, Object?>?) ?? {})
        .keys
        .toSet();
    final goOnly = (goFields.difference(specFields).toList())..sort();
    final specOnly = (specFields.difference(goFields).toList())..sort();
    stdout.writeln('$name | go-only: $goOnly | spec-only: $specOnly');
  }
}
