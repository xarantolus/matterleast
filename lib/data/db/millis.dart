import 'package:drift/drift.dart';
import 'package:sqlite3/common.dart';

/// Server times are milliseconds since the epoch; drift's own dateTime()
/// column rounds to seconds, which would reorder posts sent within a second.
class Millis extends TypeConverter<DateTime, int> {
  const Millis();

  @override
  DateTime fromSql(int fromDb) =>
      DateTime.fromMillisecondsSinceEpoch(fromDb, isUtc: true);

  @override
  int toSql(DateTime value) => value.millisecondsSinceEpoch;
}

void configureConnection(CommonDatabase db) {
  db.execute('PRAGMA journal_mode = WAL');
  db.execute('PRAGMA busy_timeout = 5000');
  db.execute('PRAGMA synchronous = NORMAL');
  db.execute('PRAGMA foreign_keys = ON');
}
