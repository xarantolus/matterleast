import 'dart:math' as math;

import 'package:matterleast/api/api_error.dart';

/// The client id of a post being sent, `<userId>:<epochMs>` as the official
/// app builds it. The server echoes it on the created post and its `posted`
/// event, which is how the optimistic row finds its server copy.
String pendingPostIdFor(String userId, DateTime at) =>
    '$userId:${at.millisecondsSinceEpoch}';

/// Delivery states of an outbox row.
abstract final class OutboxStates {
  static const queued = 'queued';
  static const sending = 'sending';
  static const failed = 'failed';
}

/// What the sender knows about one queued post.
typedef OutboxEntry = ({
  String pendingPostId,
  String channelId,
  DateTime queuedAt,
  String state,
  DateTime? nextAttemptAt,
});

sealed class OutboxStep {
  const OutboxStep();
}

final class SendNow extends OutboxStep {
  const SendNow(this.pendingPostId);
  final String pendingPostId;
}

final class WaitUntil extends OutboxStep {
  const WaitUntil(this.at);
  final DateTime at;
}

final class OutboxIdle extends OutboxStep {
  const OutboxIdle();
}

/// Pure: the next post to send. Each channel sends first in, first out, so
/// only the oldest unsent post of a channel can go; failed posts are out of
/// the line until retried. A channel waiting out a backoff doesn't hold up
/// the others.
OutboxStep nextOutboxStep(List<OutboxEntry> entries, DateTime now) {
  final heads = <String, OutboxEntry>{};
  for (final e in entries) {
    if (e.state == OutboxStates.failed) continue;
    final head = heads[e.channelId];
    if (head == null || _before(e, head)) heads[e.channelId] = e;
  }
  OutboxEntry? ready;
  DateTime? wakeAt;
  for (final head in heads.values) {
    final at = head.nextAttemptAt;
    if (at == null || !at.isAfter(now)) {
      if (ready == null || _before(head, ready)) ready = head;
    } else if (wakeAt == null || at.isBefore(wakeAt)) {
      wakeAt = at;
    }
  }
  if (ready != null) return SendNow(ready.pendingPostId);
  if (wakeAt != null) return WaitUntil(wakeAt);
  return const OutboxIdle();
}

bool _before(OutboxEntry a, OutboxEntry b) {
  final byTime = a.queuedAt.compareTo(b.queuedAt);
  return byTime != 0
      ? byTime < 0
      : a.pendingPostId.compareTo(b.pendingPostId) < 0;
}

const maxSendAttempts = 10;

/// 2 s after the first failure, doubling up to a minute.
Duration retryDelay(int failures) => Duration(
  milliseconds: math.min(2000 * math.pow(2, failures - 1).toInt(), 60000),
);

/// Server errors after which the official app removes the post instead of
/// offering a retry: the thread's first message was deleted, the channel is
/// read-only, or a plugin dismissed the post.
const _dropErrorIds = {
  'api.post.create_post.root_id.app_error',
  'api.post.create_post.town_square_read_only',
  'plugin.message_will_be_posted.dismiss_post',
};

sealed class SendFailure {
  const SendFailure();
}

final class RetryLater extends SendFailure {
  const RetryLater(this.delay);
  final Duration delay;
}

/// Stays as a failed post the user can retry or delete.
final class GiveUp extends SendFailure {
  const GiveUp(this.message);
  final String? message;
}

/// The post can never be sent; it is removed and the reason told once.
final class DropPost extends SendFailure {
  const DropPost(this.message);
  final String? message;
}

/// Pure: what to do after the [failures]th failed attempt with [error].
/// The server refusing the post fails it at once; anything that may pass
/// (no connection, timeouts, server trouble, rate limits) is retried.
SendFailure classifySendError(ApiError error, int failures) {
  if (error case ServerError(:final statusCode, :final id, :final message)) {
    if (_dropErrorIds.contains(id)) return DropPost(message);
    // 501: the server lacks something the post asks for; trying again
    // won't change that.
    final refused =
        statusCode == 501 ||
        statusCode >= 400 &&
            statusCode < 500 &&
            statusCode != 401 &&
            statusCode != 408 &&
            statusCode != 429;
    if (refused) return GiveUp(message);
  }
  if (failures >= maxSendAttempts) return const GiveUp(null);
  return RetryLater(retryDelay(failures));
}
