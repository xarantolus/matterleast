import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:matterleast/data/app_db/app_database.dart';
import 'package:matterleast/data/server_db/server_database.dart';

/// An empty server database in memory.
ServerDatabase memoryDatabase() =>
    ServerDatabase(DatabaseConnection(NativeDatabase.memory()));

/// An empty app database in memory.
AppDatabase memoryAppDatabase() =>
    AppDatabase(DatabaseConnection(NativeDatabase.memory()));
