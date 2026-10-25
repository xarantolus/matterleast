import 'package:matterleast/data/app_db/app_database.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/domain/server_entry.dart';

ServerEntry serverEntryOf(ServerRow row) => ServerEntry(
  url: row.url,
  displayName: row.displayName,
  siteName: row.siteName,
  serverVersion: row.serverVersion,
  lastActiveAt: row.lastActiveAt,
  ssoScheme: row.ssoScheme,
);

Me meOf(UserRow row) => Me(
  id: row.id,
  username: row.username,
  firstName: row.firstName,
  lastName: row.lastName,
  nickname: row.nickname,
);
