import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ProviderSubscription;
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/domain/rail.dart';
import 'package:matterleast/screens/open_channel.dart';
import 'package:matterleast/screens/root/open_panes.dart';
import 'package:matterleast/screens/root/rail_selection.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'place_reconciler.g.dart';

/// Closes what is open whenever the place the rail shows changes, for any
/// reason: a pick in the rail, a link or notification into another team, a
/// new sign-in, the shown server signed out or removed, the shown team
/// left. What belonged to the old place never stays on screen; switching
/// by the rail then opens what the new place had open.
@Riverpod(keepAlive: true)
PlaceReconciler placeReconciler(Ref ref) {
  final reconciler = PlaceReconciler(ref);
  ref.onDispose(reconciler.dispose);
  return reconciler;
}

class PlaceReconciler {
  PlaceReconciler(this._ref) {
    _shown = _place();
    _ref
      ..listen(railSelectionProvider, (_, _) => _check())
      ..listen(serversProvider, (_, _) => _check());
    _follow();
  }

  final Ref _ref;
  late RailTarget? _shown;
  ProviderSubscription<Object?>? _teams;
  String? _teamsOf;

  void dispose() => _teams?.close();

  RailTarget? _place() {
    final selected = _ref.read(railSelectionProvider);
    return shownPlace(
      selected,
      signedIn: _signedIn(),
      teams: selected == null
          ? null
          : _ref.read(railTeamsProvider(selected.url)).value,
    );
  }

  Set<String>? _signedIn() => _ref
      .read(serversProvider)
      .value
      ?.where((s) => s.signedIn)
      .map((s) => s.url)
      .toSet();

  // Follows the teams of the server the rail shows, so a team that goes
  // away is noticed.
  void _follow() {
    final url = _ref.read(railSelectionProvider)?.url;
    if (url == _teamsOf) return;
    _teams?.close();
    _teamsOf = url;
    _teams = url == null
        ? null
        : _ref.listen(railTeamsProvider(url), (_, _) => _check());
  }

  void _check() {
    _follow();
    final now = _place();
    final moved = placeChanged(_shown, now);
    _shown = now;
    if (!moved) return;
    final navigator = _ref.read(conversationRoutesProvider).navigator;
    if (navigator != null && navigator.mounted) closeConversations(navigator);
  }
}
