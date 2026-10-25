/// Pure: a slash command as the server expects it: em dashes (which phone
/// keyboards make of `--`) back to two hyphens, the command word in lower
/// case and the arguments trimmed, except the trailing spaces of `/code`.
String normalizeCommand(String text) {
  final message = text.replaceAll('—', '--');
  final space = message.indexOf(' ');
  final end = space < 0 ? message.length : space;
  final command = message.substring(0, end).toLowerCase();
  final rest = message.substring(end);
  return command == '/code'
      ? '$command ${rest.trimRight()}'
      : '$command ${rest.trim()}';
}
