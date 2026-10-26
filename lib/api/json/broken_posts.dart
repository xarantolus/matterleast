import 'package:flutter/foundation.dart';
import 'package:matterleast/api/generated/models/post.dart';
import 'package:matterleast/api/json/lenient.dart';
import 'package:matterleast/log.dart';

final _problems = Expando<String>('post decode problem');

/// What went wrong reading [post] when it stands in for a post the
/// generated code couldn't read; null for a post read in full.
String? decodeProblemOf(Post post) => _problems[post];

/// One post of another party's JSON. A post that can't be read becomes a
/// stand-in with the little that can (id, channel, author, times, type),
/// so it keeps its place in the conversation instead of vanishing.
Post? decodePost(
  Map<String, Object?> json, {
  @visibleForTesting Post Function(Map<String, Object?>) decode = Post.fromJson,
}) {
  try {
    return decode(json);
  } on Object catch (e) {
    const text = LenientString();
    const time = MillisDateTime();
    final standIn = Post(
      id: text.fromJson(json['id']),
      channelId: text.fromJson(json['channel_id']),
      rootId: text.fromJson(json['root_id']),
      userId: text.fromJson(json['user_id']),
      type: text.fromJson(json['type']),
      createAt: time.fromJson(json['create_at']),
      updateAt: time.fromJson(json['update_at']),
      deleteAt: time.fromJson(json['delete_at']),
    );
    Log.warn(
      'json',
      'unreadable post ${standIn.id} of type "${standIn.type ?? ''}": '
          '${e.runtimeType}',
    );
    _problems[standIn] = e.runtimeType.toString();
    return standIn;
  }
}
