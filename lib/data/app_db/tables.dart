import 'package:drift/drift.dart';
import 'package:matterleast/data/db/millis.dart';

/// A server the user added. Tokens live in the token store, never here.
@DataClassName('ServerRow')
class Servers extends Table {
  TextColumn get url => text()();
  TextColumn get displayName => text()();

  /// File name of this server's own database, derived from the URL once.
  TextColumn get dbFile => text()();

  /// The server's DiagnosticId, which identifies it under any URL.
  TextColumn get diagnosticId => text().nullable()();
  TextColumn get serverVersion => text().nullable()();
  TextColumn get siteName => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  IntColumn get addedAt => integer().map(const Millis())();

  /// Null until the first successful login; the newest is the active server.
  IntColumn get lastActiveAt => integer().map(const Millis()).nullable()();
  TextColumn get themeMode => text().withDefault(const Constant('brand'))();

  /// Redirect scheme for SSO when the admin registered one for this app;
  /// null uses the scheme every stock server accepts.
  TextColumn get ssoScheme => text().nullable()();

  /// What was typed as the username or email at the last password sign-in,
  /// offered again after the session ends.
  TextColumn get lastLoginId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {url};
}

@DataClassName('SettingEntry')
class SettingEntries extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
