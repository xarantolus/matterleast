import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/app/composer_providers.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/actions/composer_actions.dart';
import 'package:matterleast/data/actions/drafts.dart';
import 'package:matterleast/data/actions/file_upload.dart';
import 'package:matterleast/domain/autocomplete.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'composer_controller.g.dart';

/// A file attached to the message being written: uploading, uploaded or
/// failed.
@immutable
class Attachment {
  const Attachment({
    required this.clientId,
    required this.name,
    required this.size,
    this.path,
    this.progress = 0,
    this.info,
    this.error,
  });

  final String clientId;
  final String name;
  final int size;

  /// Where the picked file is on the device; null for one restored from a
  /// draft.
  final String? path;
  final double progress;
  final api.FileInfo? info;
  final String? error;

  bool get uploading => info == null && error == null;
  bool get isImage => switch (name.split('.').last.toLowerCase()) {
    'png' || 'jpg' || 'jpeg' || 'gif' || 'webp' || 'bmp' || 'heic' => true,
    _ => false,
  };

  Attachment copyWith({double? progress, api.FileInfo? info, String? error}) =>
      Attachment(
        clientId: clientId,
        name: name,
        size: size,
        path: path,
        progress: progress ?? this.progress,
        info: info ?? this.info,
        error: error ?? this.error,
      );
}

/// A message holds at most this many files.
const maxAttachments = 10;

/// What the composer shows: the text with its cursor, the post being
/// edited and the suggestions for the word at the cursor.
@immutable
class ComposerValue {
  const ComposerValue({
    this.text = TextEditingValue.empty,
    this.editing,
    this.suggestions = const [],
    this.attachments = const [],
  });

  final TextEditingValue text;
  final List<Attachment> attachments;

  /// The post being edited, in place of a new message.
  final PostItem? editing;
  final List<Suggestion> suggestions;
}

/// The composer of one conversation. Lives as long as the conversation is
/// on screen, so rebuilds and the drawer keep what was typed; the draft
/// keeps it after that.
@riverpod
class ComposerDraft extends _$ComposerDraft {
  var _teamId = '';

  TextEditingValue? _draftWhileEditing;
  Trigger? _trigger;
  StreamSubscription<List<Suggestion>>? _suggesting;

  Future<ComposerActions> get _actions =>
      ref.read(composerActionsProvider(url).future);

  @override
  ComposerValue build(String url, String channelId, String rootId) {
    ref.onDispose(() {
      unawaited(_suggesting?.cancel());
      for (final u in _uploads.values) {
        u.cancel();
      }
    });
    unawaited(_restore());
    return const ComposerValue();
  }

  Future<void> _restore() async {
    final draft = await (await _actions).loadDraft(channelId, rootId: rootId);
    if (!ref.mounted || draft == null || state.text.text.isNotEmpty) return;
    final length = draft.message.length;
    state = ComposerValue(
      attachments: [
        for (final f in draft.files)
          Attachment(
            clientId: f.id ?? '',
            name: f.name ?? 'file',
            size: f.size ?? 0,
            info: f,
          ),
      ],
      text: TextEditingValue(
        text: draft.message,
        selection: TextSelection(
          baseOffset: (draft.selectionBase ?? length).clamp(0, length),
          extentOffset: (draft.selectionExtent ?? length).clamp(0, length),
        ),
      ),
    );
  }

  /// The team the conversation belongs to, for suggestions.
  void inTeam(String teamId) => _teamId = teamId;

  /// The field changed: text, cursor or both.
  void changed(TextEditingValue value) {
    final typed = value.text != state.text.text;
    final editing = state.editing;
    state = ComposerValue(
      text: value,
      editing: editing,
      suggestions: state.suggestions,
      attachments: state.attachments,
    );
    if (typed) _suggest(value);
    if (editing != null) return;
    _saveDraft();
    if (typed && value.text.isNotEmpty) {
      unawaited(_actions.then((a) => a.userTyping(channelId, rootId: rootId)));
    }
  }

  void _saveDraft() {
    final value = state.text;
    final files = [for (final a in state.attachments) ?a.info];
    unawaited(
      _actions.then(
        (a) => a.saveDraft(
          Draft(
            channelId: channelId,
            rootId: rootId,
            message: value.text,
            selectionBase: value.selection.baseOffset,
            selectionExtent: value.selection.extentOffset,
            files: files,
          ),
        ),
      ),
    );
  }

  final _uploads = <String, FileUpload>{};

  void _setAttachments(List<Attachment> attachments) {
    if (!ref.mounted) return;
    state = ComposerValue(
      text: state.text,
      editing: state.editing,
      suggestions: state.suggestions,
      attachments: attachments,
    );
  }

  void _updateAttachment(String clientId, Attachment Function(Attachment) f) =>
      _setAttachments([
        for (final a in state.attachments) a.clientId == clientId ? f(a) : a,
      ]);

  /// Starts uploading the file at once. [path] is for a preview, when the
  /// file is on disk.
  Future<void> attach({
    required Stream<List<int>> Function() open,
    required String name,
    required int size,
    String? path,
  }) async {
    final clientId =
        '${DateTime.now().microsecondsSinceEpoch}-${state.attachments.length}';
    final config = await (await ref.read(serverSessionProvider(url).future)).db
        .configJson('client_config');
    final limit = int.tryParse('${config['MaxFileSize'] ?? ''}');
    final tooBig = limit != null && size > limit;
    _setAttachments([
      ...state.attachments,
      Attachment(
        clientId: clientId,
        name: name,
        size: size,
        path: path,
        error: tooBig ? 'Larger than the ${_megabytes(limit)} allowed' : null,
      ),
    ]);
    if (tooBig) return;
    final session = await ref.read(serverSessionProvider(url).future);
    final upload = FileUpload.start(
      session.api,
      channelId: channelId,
      open: open,
      length: size,
      name: name,
      clientId: clientId,
    );
    _uploads[clientId] = upload;
    final progress = upload.progress.listen(
      (p) => _updateAttachment(clientId, (a) => a.copyWith(progress: p)),
    );
    try {
      final info = await upload.done;
      _updateAttachment(clientId, (a) => a.copyWith(info: info, progress: 1));
      _saveDraft();
    } on Cancelled {
      // Removed by the user; nothing to show.
    } on ApiError catch (e) {
      _updateAttachment(
        clientId,
        (a) => a.copyWith(
          error: e is ServerError && (e.message?.isNotEmpty ?? false)
              ? e.message
              : "Couldn't upload",
        ),
      );
    } finally {
      _uploads.remove(clientId);
      await progress.cancel();
    }
  }

  /// Stops the upload if it runs and takes the file off the message.
  void detach(String clientId) {
    _uploads.remove(clientId)?.cancel();
    _setAttachments([
      for (final a in state.attachments)
        if (a.clientId != clientId) a,
    ]);
    _saveDraft();
  }

  void _suggest(TextEditingValue value) {
    final selection = value.selection;
    final trigger = selection.isCollapsed
        ? triggerAt(value.text, selection.baseOffset)
        : null;
    unawaited(_suggesting?.cancel());
    _suggesting = null;
    _trigger = trigger;
    if (trigger == null) {
      if (state.suggestions.isNotEmpty) _setSuggestions(const []);
      return;
    }
    _suggesting = Stream.fromFuture(_actions)
        .asyncExpand(
          (a) => a.suggestions(
            channelId: channelId,
            teamId: _teamId,
            rootId: rootId,
            text: value.text,
            cursor: selection.baseOffset,
          ),
        )
        .listen(_setSuggestions, onError: (Object _) {});
  }

  void _setSuggestions(List<Suggestion> found) {
    if (!ref.mounted) return;
    state = ComposerValue(
      text: state.text,
      editing: state.editing,
      suggestions: found,
      attachments: state.attachments,
    );
  }

  /// Puts [suggestion] in place of the word being completed.
  void pick(Suggestion suggestion) {
    final trigger = _trigger;
    if (trigger == null) return;
    final applied = applySuggestion(
      state.text.text,
      state.text.selection.baseOffset,
      trigger,
      suggestion.replacement,
    );
    changed(
      TextEditingValue(
        text: applied.text,
        selection: TextSelection.collapsed(offset: applied.cursor),
      ),
    );
  }

  void startEditing(PostItem post) {
    _draftWhileEditing ??= state.text;
    state = ComposerValue(
      text: TextEditingValue(
        text: post.message,
        selection: TextSelection.collapsed(offset: post.message.length),
      ),
      editing: post,
      attachments: state.attachments,
    );
  }

  void stopEditing() {
    state = ComposerValue(
      text: _draftWhileEditing ?? TextEditingValue.empty,
      attachments: state.attachments,
    );
    _draftWhileEditing = null;
  }

  /// Empties the field once its message went out.
  void sent() {
    _setAttachments(const []);
    changed(TextEditingValue.empty);
  }
}

String _megabytes(int bytes) {
  final mb = bytes / (1024 * 1024);
  return '${mb.toStringAsFixed(mb < 10 ? 1 : 0)} MB';
}
