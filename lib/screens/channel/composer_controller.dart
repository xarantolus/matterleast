import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:matterleast/app/composer_providers.dart';
import 'package:matterleast/data/actions/composer_actions.dart';
import 'package:matterleast/data/actions/drafts.dart';
import 'package:matterleast/domain/autocomplete.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'composer_controller.g.dart';

/// What the composer shows: the text with its cursor, the post being
/// edited and the suggestions for the word at the cursor.
@immutable
class ComposerValue {
  const ComposerValue({
    this.text = TextEditingValue.empty,
    this.editing,
    this.suggestions = const [],
  });

  final TextEditingValue text;

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
    ref.onDispose(() => unawaited(_suggesting?.cancel()));
    unawaited(_restore());
    return const ComposerValue();
  }

  Future<void> _restore() async {
    final draft = await (await _actions).loadDraft(channelId, rootId: rootId);
    if (!ref.mounted || draft == null || state.text.text.isNotEmpty) return;
    final length = draft.message.length;
    state = ComposerValue(
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
    );
    if (typed) _suggest(value);
    if (editing != null) return;
    unawaited(
      _actions.then((a) {
        a.saveDraft(
          Draft(
            channelId: channelId,
            rootId: rootId,
            message: value.text,
            selectionBase: value.selection.baseOffset,
            selectionExtent: value.selection.extentOffset,
          ),
        );
        if (typed && value.text.isNotEmpty) {
          unawaited(a.userTyping(channelId, rootId: rootId));
        }
      }),
    );
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
    );
  }

  void stopEditing() {
    state = ComposerValue(text: _draftWhileEditing ?? TextEditingValue.empty);
    _draftWhileEditing = null;
  }

  /// Empties the field once its message went out.
  void sent() => changed(TextEditingValue.empty);
}
