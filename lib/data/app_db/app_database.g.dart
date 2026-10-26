// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ServersTable extends Servers with TableInfo<$ServersTable, ServerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dbFileMeta = const VerificationMeta('dbFile');
  @override
  late final GeneratedColumn<String> dbFile = GeneratedColumn<String>(
    'db_file',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _diagnosticIdMeta = const VerificationMeta(
    'diagnosticId',
  );
  @override
  late final GeneratedColumn<String> diagnosticId = GeneratedColumn<String>(
    'diagnostic_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverVersionMeta = const VerificationMeta(
    'serverVersion',
  );
  @override
  late final GeneratedColumn<String> serverVersion = GeneratedColumn<String>(
    'server_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _siteNameMeta = const VerificationMeta(
    'siteName',
  );
  @override
  late final GeneratedColumn<String> siteName = GeneratedColumn<String>(
    'site_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> addedAt =
      GeneratedColumn<int>(
        'added_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ServersTable.$converteraddedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> lastActiveAt =
      GeneratedColumn<int>(
        'last_active_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($ServersTable.$converterlastActiveAtn);
  static const VerificationMeta _themeModeMeta = const VerificationMeta(
    'themeMode',
  );
  @override
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
    'theme_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('brand'),
  );
  static const VerificationMeta _ssoSchemeMeta = const VerificationMeta(
    'ssoScheme',
  );
  @override
  late final GeneratedColumn<String> ssoScheme = GeneratedColumn<String>(
    'sso_scheme',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastLoginIdMeta = const VerificationMeta(
    'lastLoginId',
  );
  @override
  late final GeneratedColumn<String> lastLoginId = GeneratedColumn<String>(
    'last_login_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    url,
    displayName,
    dbFile,
    diagnosticId,
    serverVersion,
    siteName,
    sortOrder,
    addedAt,
    lastActiveAt,
    themeMode,
    ssoScheme,
    lastLoginId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'servers';
  @override
  VerificationContext validateIntegrity(
    Insertable<ServerRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('db_file')) {
      context.handle(
        _dbFileMeta,
        dbFile.isAcceptableOrUnknown(data['db_file']!, _dbFileMeta),
      );
    } else if (isInserting) {
      context.missing(_dbFileMeta);
    }
    if (data.containsKey('diagnostic_id')) {
      context.handle(
        _diagnosticIdMeta,
        diagnosticId.isAcceptableOrUnknown(
          data['diagnostic_id']!,
          _diagnosticIdMeta,
        ),
      );
    }
    if (data.containsKey('server_version')) {
      context.handle(
        _serverVersionMeta,
        serverVersion.isAcceptableOrUnknown(
          data['server_version']!,
          _serverVersionMeta,
        ),
      );
    }
    if (data.containsKey('site_name')) {
      context.handle(
        _siteNameMeta,
        siteName.isAcceptableOrUnknown(data['site_name']!, _siteNameMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('theme_mode')) {
      context.handle(
        _themeModeMeta,
        themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta),
      );
    }
    if (data.containsKey('sso_scheme')) {
      context.handle(
        _ssoSchemeMeta,
        ssoScheme.isAcceptableOrUnknown(data['sso_scheme']!, _ssoSchemeMeta),
      );
    }
    if (data.containsKey('last_login_id')) {
      context.handle(
        _lastLoginIdMeta,
        lastLoginId.isAcceptableOrUnknown(
          data['last_login_id']!,
          _lastLoginIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {url};
  @override
  ServerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ServerRow(
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      dbFile: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}db_file'],
      )!,
      diagnosticId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}diagnostic_id'],
      ),
      serverVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_version'],
      ),
      siteName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}site_name'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      addedAt: $ServersTable.$converteraddedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}added_at'],
        )!,
      ),
      lastActiveAt: $ServersTable.$converterlastActiveAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}last_active_at'],
        ),
      ),
      themeMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_mode'],
      )!,
      ssoScheme: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sso_scheme'],
      ),
      lastLoginId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_login_id'],
      ),
    );
  }

  @override
  $ServersTable createAlias(String alias) {
    return $ServersTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $converteraddedAt = const Millis();
  static TypeConverter<DateTime, int> $converterlastActiveAt = const Millis();
  static TypeConverter<DateTime?, int?> $converterlastActiveAtn =
      NullAwareTypeConverter.wrap($converterlastActiveAt);
}

class ServerRow extends DataClass implements Insertable<ServerRow> {
  final String url;
  final String displayName;

  /// File name of this server's own database, derived from the URL once.
  final String dbFile;

  /// The server's DiagnosticId, which identifies it under any URL.
  final String? diagnosticId;
  final String? serverVersion;
  final String? siteName;
  final int sortOrder;
  final DateTime addedAt;

  /// Null until the first successful login; the newest is the active server.
  final DateTime? lastActiveAt;
  final String themeMode;

  /// Redirect scheme for SSO when the admin registered one for this app;
  /// null uses the scheme every stock server accepts.
  final String? ssoScheme;

  /// What was typed as the username or email at the last password sign-in,
  /// offered again after the session ends.
  final String? lastLoginId;
  const ServerRow({
    required this.url,
    required this.displayName,
    required this.dbFile,
    this.diagnosticId,
    this.serverVersion,
    this.siteName,
    required this.sortOrder,
    required this.addedAt,
    this.lastActiveAt,
    required this.themeMode,
    this.ssoScheme,
    this.lastLoginId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['url'] = Variable<String>(url);
    map['display_name'] = Variable<String>(displayName);
    map['db_file'] = Variable<String>(dbFile);
    if (!nullToAbsent || diagnosticId != null) {
      map['diagnostic_id'] = Variable<String>(diagnosticId);
    }
    if (!nullToAbsent || serverVersion != null) {
      map['server_version'] = Variable<String>(serverVersion);
    }
    if (!nullToAbsent || siteName != null) {
      map['site_name'] = Variable<String>(siteName);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    {
      map['added_at'] = Variable<int>(
        $ServersTable.$converteraddedAt.toSql(addedAt),
      );
    }
    if (!nullToAbsent || lastActiveAt != null) {
      map['last_active_at'] = Variable<int>(
        $ServersTable.$converterlastActiveAtn.toSql(lastActiveAt),
      );
    }
    map['theme_mode'] = Variable<String>(themeMode);
    if (!nullToAbsent || ssoScheme != null) {
      map['sso_scheme'] = Variable<String>(ssoScheme);
    }
    if (!nullToAbsent || lastLoginId != null) {
      map['last_login_id'] = Variable<String>(lastLoginId);
    }
    return map;
  }

  ServersCompanion toCompanion(bool nullToAbsent) {
    return ServersCompanion(
      url: Value(url),
      displayName: Value(displayName),
      dbFile: Value(dbFile),
      diagnosticId: diagnosticId == null && nullToAbsent
          ? const Value.absent()
          : Value(diagnosticId),
      serverVersion: serverVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(serverVersion),
      siteName: siteName == null && nullToAbsent
          ? const Value.absent()
          : Value(siteName),
      sortOrder: Value(sortOrder),
      addedAt: Value(addedAt),
      lastActiveAt: lastActiveAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastActiveAt),
      themeMode: Value(themeMode),
      ssoScheme: ssoScheme == null && nullToAbsent
          ? const Value.absent()
          : Value(ssoScheme),
      lastLoginId: lastLoginId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastLoginId),
    );
  }

  factory ServerRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ServerRow(
      url: serializer.fromJson<String>(json['url']),
      displayName: serializer.fromJson<String>(json['displayName']),
      dbFile: serializer.fromJson<String>(json['dbFile']),
      diagnosticId: serializer.fromJson<String?>(json['diagnosticId']),
      serverVersion: serializer.fromJson<String?>(json['serverVersion']),
      siteName: serializer.fromJson<String?>(json['siteName']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
      lastActiveAt: serializer.fromJson<DateTime?>(json['lastActiveAt']),
      themeMode: serializer.fromJson<String>(json['themeMode']),
      ssoScheme: serializer.fromJson<String?>(json['ssoScheme']),
      lastLoginId: serializer.fromJson<String?>(json['lastLoginId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'url': serializer.toJson<String>(url),
      'displayName': serializer.toJson<String>(displayName),
      'dbFile': serializer.toJson<String>(dbFile),
      'diagnosticId': serializer.toJson<String?>(diagnosticId),
      'serverVersion': serializer.toJson<String?>(serverVersion),
      'siteName': serializer.toJson<String?>(siteName),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'addedAt': serializer.toJson<DateTime>(addedAt),
      'lastActiveAt': serializer.toJson<DateTime?>(lastActiveAt),
      'themeMode': serializer.toJson<String>(themeMode),
      'ssoScheme': serializer.toJson<String?>(ssoScheme),
      'lastLoginId': serializer.toJson<String?>(lastLoginId),
    };
  }

  ServerRow copyWith({
    String? url,
    String? displayName,
    String? dbFile,
    Value<String?> diagnosticId = const Value.absent(),
    Value<String?> serverVersion = const Value.absent(),
    Value<String?> siteName = const Value.absent(),
    int? sortOrder,
    DateTime? addedAt,
    Value<DateTime?> lastActiveAt = const Value.absent(),
    String? themeMode,
    Value<String?> ssoScheme = const Value.absent(),
    Value<String?> lastLoginId = const Value.absent(),
  }) => ServerRow(
    url: url ?? this.url,
    displayName: displayName ?? this.displayName,
    dbFile: dbFile ?? this.dbFile,
    diagnosticId: diagnosticId.present ? diagnosticId.value : this.diagnosticId,
    serverVersion: serverVersion.present
        ? serverVersion.value
        : this.serverVersion,
    siteName: siteName.present ? siteName.value : this.siteName,
    sortOrder: sortOrder ?? this.sortOrder,
    addedAt: addedAt ?? this.addedAt,
    lastActiveAt: lastActiveAt.present ? lastActiveAt.value : this.lastActiveAt,
    themeMode: themeMode ?? this.themeMode,
    ssoScheme: ssoScheme.present ? ssoScheme.value : this.ssoScheme,
    lastLoginId: lastLoginId.present ? lastLoginId.value : this.lastLoginId,
  );
  ServerRow copyWithCompanion(ServersCompanion data) {
    return ServerRow(
      url: data.url.present ? data.url.value : this.url,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      dbFile: data.dbFile.present ? data.dbFile.value : this.dbFile,
      diagnosticId: data.diagnosticId.present
          ? data.diagnosticId.value
          : this.diagnosticId,
      serverVersion: data.serverVersion.present
          ? data.serverVersion.value
          : this.serverVersion,
      siteName: data.siteName.present ? data.siteName.value : this.siteName,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      lastActiveAt: data.lastActiveAt.present
          ? data.lastActiveAt.value
          : this.lastActiveAt,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      ssoScheme: data.ssoScheme.present ? data.ssoScheme.value : this.ssoScheme,
      lastLoginId: data.lastLoginId.present
          ? data.lastLoginId.value
          : this.lastLoginId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ServerRow(')
          ..write('url: $url, ')
          ..write('displayName: $displayName, ')
          ..write('dbFile: $dbFile, ')
          ..write('diagnosticId: $diagnosticId, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('siteName: $siteName, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('addedAt: $addedAt, ')
          ..write('lastActiveAt: $lastActiveAt, ')
          ..write('themeMode: $themeMode, ')
          ..write('ssoScheme: $ssoScheme, ')
          ..write('lastLoginId: $lastLoginId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    url,
    displayName,
    dbFile,
    diagnosticId,
    serverVersion,
    siteName,
    sortOrder,
    addedAt,
    lastActiveAt,
    themeMode,
    ssoScheme,
    lastLoginId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServerRow &&
          other.url == this.url &&
          other.displayName == this.displayName &&
          other.dbFile == this.dbFile &&
          other.diagnosticId == this.diagnosticId &&
          other.serverVersion == this.serverVersion &&
          other.siteName == this.siteName &&
          other.sortOrder == this.sortOrder &&
          other.addedAt == this.addedAt &&
          other.lastActiveAt == this.lastActiveAt &&
          other.themeMode == this.themeMode &&
          other.ssoScheme == this.ssoScheme &&
          other.lastLoginId == this.lastLoginId);
}

class ServersCompanion extends UpdateCompanion<ServerRow> {
  final Value<String> url;
  final Value<String> displayName;
  final Value<String> dbFile;
  final Value<String?> diagnosticId;
  final Value<String?> serverVersion;
  final Value<String?> siteName;
  final Value<int> sortOrder;
  final Value<DateTime> addedAt;
  final Value<DateTime?> lastActiveAt;
  final Value<String> themeMode;
  final Value<String?> ssoScheme;
  final Value<String?> lastLoginId;
  final Value<int> rowid;
  const ServersCompanion({
    this.url = const Value.absent(),
    this.displayName = const Value.absent(),
    this.dbFile = const Value.absent(),
    this.diagnosticId = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.siteName = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.lastActiveAt = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.ssoScheme = const Value.absent(),
    this.lastLoginId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ServersCompanion.insert({
    required String url,
    required String displayName,
    required String dbFile,
    this.diagnosticId = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.siteName = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime addedAt,
    this.lastActiveAt = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.ssoScheme = const Value.absent(),
    this.lastLoginId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : url = Value(url),
       displayName = Value(displayName),
       dbFile = Value(dbFile),
       addedAt = Value(addedAt);
  static Insertable<ServerRow> custom({
    Expression<String>? url,
    Expression<String>? displayName,
    Expression<String>? dbFile,
    Expression<String>? diagnosticId,
    Expression<String>? serverVersion,
    Expression<String>? siteName,
    Expression<int>? sortOrder,
    Expression<int>? addedAt,
    Expression<int>? lastActiveAt,
    Expression<String>? themeMode,
    Expression<String>? ssoScheme,
    Expression<String>? lastLoginId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (url != null) 'url': url,
      if (displayName != null) 'display_name': displayName,
      if (dbFile != null) 'db_file': dbFile,
      if (diagnosticId != null) 'diagnostic_id': diagnosticId,
      if (serverVersion != null) 'server_version': serverVersion,
      if (siteName != null) 'site_name': siteName,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (addedAt != null) 'added_at': addedAt,
      if (lastActiveAt != null) 'last_active_at': lastActiveAt,
      if (themeMode != null) 'theme_mode': themeMode,
      if (ssoScheme != null) 'sso_scheme': ssoScheme,
      if (lastLoginId != null) 'last_login_id': lastLoginId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ServersCompanion copyWith({
    Value<String>? url,
    Value<String>? displayName,
    Value<String>? dbFile,
    Value<String?>? diagnosticId,
    Value<String?>? serverVersion,
    Value<String?>? siteName,
    Value<int>? sortOrder,
    Value<DateTime>? addedAt,
    Value<DateTime?>? lastActiveAt,
    Value<String>? themeMode,
    Value<String?>? ssoScheme,
    Value<String?>? lastLoginId,
    Value<int>? rowid,
  }) {
    return ServersCompanion(
      url: url ?? this.url,
      displayName: displayName ?? this.displayName,
      dbFile: dbFile ?? this.dbFile,
      diagnosticId: diagnosticId ?? this.diagnosticId,
      serverVersion: serverVersion ?? this.serverVersion,
      siteName: siteName ?? this.siteName,
      sortOrder: sortOrder ?? this.sortOrder,
      addedAt: addedAt ?? this.addedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      themeMode: themeMode ?? this.themeMode,
      ssoScheme: ssoScheme ?? this.ssoScheme,
      lastLoginId: lastLoginId ?? this.lastLoginId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (dbFile.present) {
      map['db_file'] = Variable<String>(dbFile.value);
    }
    if (diagnosticId.present) {
      map['diagnostic_id'] = Variable<String>(diagnosticId.value);
    }
    if (serverVersion.present) {
      map['server_version'] = Variable<String>(serverVersion.value);
    }
    if (siteName.present) {
      map['site_name'] = Variable<String>(siteName.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<int>(
        $ServersTable.$converteraddedAt.toSql(addedAt.value),
      );
    }
    if (lastActiveAt.present) {
      map['last_active_at'] = Variable<int>(
        $ServersTable.$converterlastActiveAtn.toSql(lastActiveAt.value),
      );
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(themeMode.value);
    }
    if (ssoScheme.present) {
      map['sso_scheme'] = Variable<String>(ssoScheme.value);
    }
    if (lastLoginId.present) {
      map['last_login_id'] = Variable<String>(lastLoginId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServersCompanion(')
          ..write('url: $url, ')
          ..write('displayName: $displayName, ')
          ..write('dbFile: $dbFile, ')
          ..write('diagnosticId: $diagnosticId, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('siteName: $siteName, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('addedAt: $addedAt, ')
          ..write('lastActiveAt: $lastActiveAt, ')
          ..write('themeMode: $themeMode, ')
          ..write('ssoScheme: $ssoScheme, ')
          ..write('lastLoginId: $lastLoginId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingEntriesTable extends SettingEntries
    with TableInfo<$SettingEntriesTable, SettingEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'setting_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingEntry(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingEntriesTable createAlias(String alias) {
    return $SettingEntriesTable(attachedDatabase, alias);
  }
}

class SettingEntry extends DataClass implements Insertable<SettingEntry> {
  final String key;
  final String value;
  const SettingEntry({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingEntriesCompanion toCompanion(bool nullToAbsent) {
    return SettingEntriesCompanion(key: Value(key), value: Value(value));
  }

  factory SettingEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingEntry(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingEntry copyWith({String? key, String? value}) =>
      SettingEntry(key: key ?? this.key, value: value ?? this.value);
  SettingEntry copyWithCompanion(SettingEntriesCompanion data) {
    return SettingEntry(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingEntry(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingEntry &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingEntriesCompanion extends UpdateCompanion<SettingEntry> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingEntriesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingEntriesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingEntry> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingEntriesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingEntriesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingEntriesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ServersTable servers = $ServersTable(this);
  late final $SettingEntriesTable settingEntries = $SettingEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [servers, settingEntries];
}

typedef $$ServersTableCreateCompanionBuilder = ServersCompanion Function({
  required String url,
  required String displayName,
  required String dbFile,
  Value<String?> diagnosticId,
  Value<String?> serverVersion,
  Value<String?> siteName,
  Value<int> sortOrder,
  required DateTime addedAt,
  Value<DateTime?> lastActiveAt,
  Value<String> themeMode,
  Value<String?> ssoScheme,
  Value<String?> lastLoginId,
  Value<int> rowid,
});
typedef $$ServersTableUpdateCompanionBuilder = ServersCompanion Function({
  Value<String> url,
  Value<String> displayName,
  Value<String> dbFile,
  Value<String?> diagnosticId,
  Value<String?> serverVersion,
  Value<String?> siteName,
  Value<int> sortOrder,
  Value<DateTime> addedAt,
  Value<DateTime?> lastActiveAt,
  Value<String> themeMode,
  Value<String?> ssoScheme,
  Value<String?> lastLoginId,
  Value<int> rowid,
});

class $$ServersTableFilterComposer
    extends Composer<_$AppDatabase, $ServersTable> {
  $$ServersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dbFile => $composableBuilder(
    column: $table.dbFile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get diagnosticId => $composableBuilder(
    column: $table.diagnosticId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get siteName => $composableBuilder(
    column: $table.siteName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get addedAt =>
      $composableBuilder(
        column: $table.addedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get lastActiveAt =>
      $composableBuilder(
        column: $table.lastActiveAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ssoScheme => $composableBuilder(
    column: $table.ssoScheme,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastLoginId => $composableBuilder(
    column: $table.lastLoginId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ServersTableOrderingComposer
    extends Composer<_$AppDatabase, $ServersTable> {
  $$ServersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dbFile => $composableBuilder(
    column: $table.dbFile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get diagnosticId => $composableBuilder(
    column: $table.diagnosticId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get siteName => $composableBuilder(
    column: $table.siteName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastActiveAt => $composableBuilder(
    column: $table.lastActiveAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ssoScheme => $composableBuilder(
    column: $table.ssoScheme,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastLoginId => $composableBuilder(
    column: $table.lastLoginId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ServersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ServersTable> {
  $$ServersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dbFile =>
      $composableBuilder(column: $table.dbFile, builder: (column) => column);

  GeneratedColumn<String> get diagnosticId => $composableBuilder(
    column: $table.diagnosticId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get siteName =>
      $composableBuilder(column: $table.siteName, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get lastActiveAt =>
      $composableBuilder(
        column: $table.lastActiveAt,
        builder: (column) => column,
      );

  GeneratedColumn<String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<String> get ssoScheme =>
      $composableBuilder(column: $table.ssoScheme, builder: (column) => column);

  GeneratedColumn<String> get lastLoginId => $composableBuilder(
    column: $table.lastLoginId,
    builder: (column) => column,
  );
}

class $$ServersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ServersTable,
          ServerRow,
          $$ServersTableFilterComposer,
          $$ServersTableOrderingComposer,
          $$ServersTableAnnotationComposer,
          $$ServersTableCreateCompanionBuilder,
          $$ServersTableUpdateCompanionBuilder,
          (ServerRow, BaseReferences<_$AppDatabase, $ServersTable, ServerRow>),
          ServerRow,
          PrefetchHooks Function()
        > {
  $$ServersTableTableManager(_$AppDatabase db, $ServersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ServersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ServersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> url = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> dbFile = const Value.absent(),
                Value<String?> diagnosticId = const Value.absent(),
                Value<String?> serverVersion = const Value.absent(),
                Value<String?> siteName = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<DateTime?> lastActiveAt = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<String?> ssoScheme = const Value.absent(),
                Value<String?> lastLoginId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ServersCompanion(
                url: url,
                displayName: displayName,
                dbFile: dbFile,
                diagnosticId: diagnosticId,
                serverVersion: serverVersion,
                siteName: siteName,
                sortOrder: sortOrder,
                addedAt: addedAt,
                lastActiveAt: lastActiveAt,
                themeMode: themeMode,
                ssoScheme: ssoScheme,
                lastLoginId: lastLoginId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String url,
                required String displayName,
                required String dbFile,
                Value<String?> diagnosticId = const Value.absent(),
                Value<String?> serverVersion = const Value.absent(),
                Value<String?> siteName = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required DateTime addedAt,
                Value<DateTime?> lastActiveAt = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<String?> ssoScheme = const Value.absent(),
                Value<String?> lastLoginId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ServersCompanion.insert(
                url: url,
                displayName: displayName,
                dbFile: dbFile,
                diagnosticId: diagnosticId,
                serverVersion: serverVersion,
                siteName: siteName,
                sortOrder: sortOrder,
                addedAt: addedAt,
                lastActiveAt: lastActiveAt,
                themeMode: themeMode,
                ssoScheme: ssoScheme,
                lastLoginId: lastLoginId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ServersTable, ServerRow>(table),
                  BaseReferences<_$AppDatabase, $ServersTable, ServerRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ServersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ServersTable,
      ServerRow,
      $$ServersTableFilterComposer,
      $$ServersTableOrderingComposer,
      $$ServersTableAnnotationComposer,
      $$ServersTableCreateCompanionBuilder,
      $$ServersTableUpdateCompanionBuilder,
      (ServerRow, BaseReferences<_$AppDatabase, $ServersTable, ServerRow>),
      ServerRow,
      PrefetchHooks Function()
    >;
typedef $$SettingEntriesTableCreateCompanionBuilder =
    SettingEntriesCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SettingEntriesTableUpdateCompanionBuilder =
    SettingEntriesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SettingEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SettingEntriesTable> {
  $$SettingEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingEntriesTable> {
  $$SettingEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingEntriesTable> {
  $$SettingEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingEntriesTable,
          SettingEntry,
          $$SettingEntriesTableFilterComposer,
          $$SettingEntriesTableOrderingComposer,
          $$SettingEntriesTableAnnotationComposer,
          $$SettingEntriesTableCreateCompanionBuilder,
          $$SettingEntriesTableUpdateCompanionBuilder,
          (
            SettingEntry,
            BaseReferences<_$AppDatabase, $SettingEntriesTable, SettingEntry>,
          ),
          SettingEntry,
          PrefetchHooks Function()
        > {
  $$SettingEntriesTableTableManager(
    _$AppDatabase db,
    $SettingEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingEntriesCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingEntriesCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingEntriesTable, SettingEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SettingEntriesTable,
                    SettingEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingEntriesTable,
      SettingEntry,
      $$SettingEntriesTableFilterComposer,
      $$SettingEntriesTableOrderingComposer,
      $$SettingEntriesTableAnnotationComposer,
      $$SettingEntriesTableCreateCompanionBuilder,
      $$SettingEntriesTableUpdateCompanionBuilder,
      (
        SettingEntry,
        BaseReferences<_$AppDatabase, $SettingEntriesTable, SettingEntry>,
      ),
      SettingEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ServersTableTableManager get servers =>
      $$ServersTableTableManager(_db, _db.servers);
  $$SettingEntriesTableTableManager get settingEntries =>
      $$SettingEntriesTableTableManager(_db, _db.settingEntries);
}
