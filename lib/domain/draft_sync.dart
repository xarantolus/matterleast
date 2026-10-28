/// Where a draft is written: a channel, or a thread in it.
typedef DraftKey = ({String channelId, String rootId});

/// A draft on this device, as far as syncing cares.
typedef LocalDraftState = ({
  DraftKey key,
  DateTime updatedAt,

  /// The server's `update_at` of the copy it last confirmed; null when it
  /// never had this one.
  DateTime? syncedAt,
});

/// How long a draft must stay untouched before it goes to the server.
const draftQuietTime = Duration(seconds: 30);

/// Pure: whether a draft last changed at [lastChangeAt] goes to the server
/// now: when the user is [leaving] it, or when it has been quiet long enough.
bool shouldPushDraft({
  required DateTime lastChangeAt,
  required DateTime now,
  required bool leaving,
}) => leaving || now.difference(lastChangeAt) >= draftQuietTime;

/// What syncing does with one draft.
sealed class DraftSyncStep {
  const DraftSyncStep(this.key);
  final DraftKey key;
}

/// The server's copy is newer: it replaces ours.
final class TakeServerDraft extends DraftSyncStep {
  const TakeServerDraft(super.key);
}

/// Ours is newer or the server never had it: send it.
final class SendDraft extends DraftSyncStep {
  const SendDraft(super.key);
}

/// Another device deleted it, and it wasn't changed here since.
final class DropDraft extends DraftSyncStep {
  const DropDraft(super.key);
}

/// We deleted it while the server couldn't be told: tell it now.
final class DeleteServerDraft extends DraftSyncStep {
  const DeleteServerDraft(super.key);
}

/// Pure: how to bring this device's drafts and the server's together, the
/// newer copy winning. [server] maps each server draft to its `update_at`;
/// [deleted] maps drafts deleted here, not yet deleted on the server, to
/// when that happened.
List<DraftSyncStep> planDraftSync({
  required Iterable<LocalDraftState> local,
  required Map<DraftKey, DateTime> server,
  Map<DraftKey, DateTime> deleted = const {},
}) {
  final steps = <DraftSyncStep>[];
  final mine = {for (final d in local) d.key: d};
  for (final MapEntry(key: key, value: updateAt) in server.entries) {
    final draft = mine[key];
    if (draft == null) {
      final gone = deleted[key];
      steps.add(
        gone != null && !updateAt.isAfter(gone)
            ? DeleteServerDraft(key)
            : TakeServerDraft(key),
      );
    } else if (updateAt.isAfter(draft.updatedAt)) {
      steps.add(TakeServerDraft(key));
    } else if (draft.updatedAt.isAfter(updateAt) && _unsent(draft)) {
      steps.add(SendDraft(key));
    }
  }
  for (final draft in local) {
    if (server.containsKey(draft.key)) continue;
    steps.add(_unsent(draft) ? SendDraft(draft.key) : DropDraft(draft.key));
  }
  return steps;
}

bool _unsent(LocalDraftState draft) =>
    draft.syncedAt == null || draft.updatedAt.isAfter(draft.syncedAt!);

/// Pure: whether a draft the server reports, changed at [serverUpdateAt],
/// should replace the one here.
bool serverDraftWins(DateTime serverUpdateAt, LocalDraftState? local) =>
    local == null || serverUpdateAt.isAfter(local.updatedAt);

/// Pure: whether a deletion the server reports should remove the draft
/// here: only when it holds nothing the server hasn't seen.
bool serverDeleteWins(LocalDraftState? local) =>
    local != null && !_unsent(local);
