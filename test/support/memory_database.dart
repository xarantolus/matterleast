import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:matterleast/data/server_db/server_database.dart';

/// An empty server database in memory.
ServerDatabase memoryDatabase() =>
    ServerDatabase(DatabaseConnection(NativeDatabase.memory()));
