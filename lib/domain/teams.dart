/// A team as far as ordering needs it.
typedef TeamName = ({String id, String displayName});

/// Teams in the user's order: the `teams_order` preference (comma-separated
/// ids, set on the web), then the rest by name.
List<T> sortTeams<T extends TeamName>(Iterable<T> teams, String? teamsOrder) {
  final order = [
    for (final id in (teamsOrder ?? '').split(','))
      if (id.trim().isNotEmpty) id.trim(),
  ];
  int rank(T team) {
    final i = order.indexOf(team.id);
    return i < 0 ? order.length : i;
  }

  return [...teams]..sort((a, b) {
    final byRank = rank(a).compareTo(rank(b));
    if (byRank != 0) return byRank;
    return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
  });
}

/// The team to sync first: the one the user last looked at while still a
/// member, else the first in their order.
String? pickCurrentTeam(
  List<TeamName> teams, {
  String? current,
  String? teamsOrder,
}) {
  if (teams.any((t) => t.id == current)) return current;
  return sortTeams(teams, teamsOrder).firstOrNull?.id;
}

/// Whether replies are kept out of channels and counted per thread, from
/// the server's `CollapsedThreads` setting and the user's preference.
bool collapsedThreadsOn(String? serverSetting, String? preference) =>
    switch (serverSetting) {
      'always_on' => true,
      'default_on' => preference != 'off',
      'default_off' => preference == 'on',
      _ => false,
    };

/// The other person in a direct message channel named `id1__id2`; the user
/// themself for a message to self.
String? directPartnerId(String channelName, String myId) {
  final ids = channelName.split('__');
  if (ids.length != 2) return null;
  return ids[0] == myId ? ids[1] : ids[0];
}
