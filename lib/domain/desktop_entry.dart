/// Pure: the launcher entry a Linux start should write, or null when the one
/// on disk ([existing]) is already right or the app isn't run from a folder
/// of its own. A Flatpak or an AppImage has its own integration, and a path a
/// launcher entry can't quote is left alone.
String? desktopEntryToWrite({
  required Map<String, String> environment,
  required String executable,
  required String? iconPath,
  required String? existing,
}) {
  if (environment.containsKey('FLATPAK_ID') ||
      environment.containsKey('APPIMAGE')) {
    return null;
  }
  if (_unquotable(executable) || (iconPath != null && _unquotable(iconPath))) {
    return null;
  }
  final entry = [
    '[Desktop Entry]',
    'Type=Application',
    'Name=Matterleast',
    'Comment=Chat on Mattermost servers',
    'Exec="$executable" %u',
    'Icon=${iconPath ?? 'io.github.xarantolus.matterleast'}',
    'Terminal=false',
    'Categories=Network;Chat;InstantMessaging;',
    'StartupWMClass=io.github.xarantolus.matterleast',
    'MimeType=x-scheme-handler/mmauth;',
    '',
  ].join('\n');
  return existing == entry ? null : entry;
}

bool _unquotable(String path) =>
    path.contains(RegExp(r'["\\$`\n]')) || !path.startsWith('/');
