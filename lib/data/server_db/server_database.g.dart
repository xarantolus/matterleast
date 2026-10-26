// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, UserRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nicknameMeta = const VerificationMeta(
    'nickname',
  );
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
    'nickname',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _firstNameMeta = const VerificationMeta(
    'firstName',
  );
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
    'first_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _lastNameMeta = const VerificationMeta(
    'lastName',
  );
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
    'last_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<String> position = GeneratedColumn<String>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
    'locale',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isBotMeta = const VerificationMeta('isBot');
  @override
  late final GeneratedColumn<bool> isBot = GeneratedColumn<bool>(
    'is_bot',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_bot" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _rolesMeta = const VerificationMeta('roles');
  @override
  late final GeneratedColumn<String> roles = GeneratedColumn<String>(
    'roles',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> updateAt =
      GeneratedColumn<int>(
        'update_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($UsersTable.$converterupdateAtn);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> deleteAt =
      GeneratedColumn<int>(
        'delete_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($UsersTable.$converterdeleteAtn);
  static const VerificationMeta _lastPictureUpdateMeta = const VerificationMeta(
    'lastPictureUpdate',
  );
  @override
  late final GeneratedColumn<int> lastPictureUpdate = GeneratedColumn<int>(
    'last_picture_update',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Timezone?, String> timezone =
      GeneratedColumn<String>(
        'timezone_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Timezone?>($UsersTable.$convertertimezone);
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, Object?>?, String>
  props = GeneratedColumn<String>(
    'props_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<Map<String, Object?>?>($UsersTable.$converterpropsn);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('offline'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> statusUpdatedAt =
      GeneratedColumn<int>(
        'status_updated_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($UsersTable.$converterstatusUpdatedAtn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    username,
    nickname,
    firstName,
    lastName,
    position,
    locale,
    isBot,
    roles,
    updateAt,
    deleteAt,
    lastPictureUpdate,
    timezone,
    props,
    status,
    statusUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('nickname')) {
      context.handle(
        _nicknameMeta,
        nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta),
      );
    }
    if (data.containsKey('first_name')) {
      context.handle(
        _firstNameMeta,
        firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta),
      );
    }
    if (data.containsKey('last_name')) {
      context.handle(
        _lastNameMeta,
        lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('locale')) {
      context.handle(
        _localeMeta,
        locale.isAcceptableOrUnknown(data['locale']!, _localeMeta),
      );
    }
    if (data.containsKey('is_bot')) {
      context.handle(
        _isBotMeta,
        isBot.isAcceptableOrUnknown(data['is_bot']!, _isBotMeta),
      );
    }
    if (data.containsKey('roles')) {
      context.handle(
        _rolesMeta,
        roles.isAcceptableOrUnknown(data['roles']!, _rolesMeta),
      );
    }
    if (data.containsKey('last_picture_update')) {
      context.handle(
        _lastPictureUpdateMeta,
        lastPictureUpdate.isAcceptableOrUnknown(
          data['last_picture_update']!,
          _lastPictureUpdateMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      nickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nickname'],
      )!,
      firstName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_name'],
      )!,
      lastName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_name'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}position'],
      )!,
      locale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale'],
      ),
      isBot: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_bot'],
      )!,
      roles: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}roles'],
      ),
      updateAt: $UsersTable.$converterupdateAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}update_at'],
        ),
      ),
      deleteAt: $UsersTable.$converterdeleteAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}delete_at'],
        ),
      ),
      lastPictureUpdate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_picture_update'],
      ),
      timezone: $UsersTable.$convertertimezone.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}timezone_json'],
        ),
      ),
      props: $UsersTable.$converterpropsn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}props_json'],
        ),
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      statusUpdatedAt: $UsersTable.$converterstatusUpdatedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}status_updated_at'],
        ),
      ),
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $converterupdateAt = const Millis();
  static TypeConverter<DateTime?, int?> $converterupdateAtn =
      NullAwareTypeConverter.wrap($converterupdateAt);
  static TypeConverter<DateTime, int> $converterdeleteAt = const Millis();
  static TypeConverter<DateTime?, int?> $converterdeleteAtn =
      NullAwareTypeConverter.wrap($converterdeleteAt);
  static TypeConverter<Timezone?, String?> $convertertimezone =
      const TimezoneColumn();
  static TypeConverter<Map<String, Object?>, String> $converterprops =
      const JsonMapColumn();
  static TypeConverter<Map<String, Object?>?, String?> $converterpropsn =
      NullAwareTypeConverter.wrap($converterprops);
  static TypeConverter<DateTime, int> $converterstatusUpdatedAt =
      const Millis();
  static TypeConverter<DateTime?, int?> $converterstatusUpdatedAtn =
      NullAwareTypeConverter.wrap($converterstatusUpdatedAt);
}

class UserRow extends DataClass implements Insertable<UserRow> {
  final String id;
  final String username;
  final String nickname;
  final String firstName;
  final String lastName;
  final String position;
  final String? locale;
  final bool isBot;

  /// Space-separated system roles; null for a row stored before they were
  /// kept, which the user loader fetches again.
  final String? roles;
  final DateTime? updateAt;
  final DateTime? deleteAt;
  final int? lastPictureUpdate;
  final Timezone? timezone;
  final Map<String, Object?>? props;
  final String status;
  final DateTime? statusUpdatedAt;
  const UserRow({
    required this.id,
    required this.username,
    required this.nickname,
    required this.firstName,
    required this.lastName,
    required this.position,
    this.locale,
    required this.isBot,
    this.roles,
    this.updateAt,
    this.deleteAt,
    this.lastPictureUpdate,
    this.timezone,
    this.props,
    required this.status,
    this.statusUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['username'] = Variable<String>(username);
    map['nickname'] = Variable<String>(nickname);
    map['first_name'] = Variable<String>(firstName);
    map['last_name'] = Variable<String>(lastName);
    map['position'] = Variable<String>(position);
    if (!nullToAbsent || locale != null) {
      map['locale'] = Variable<String>(locale);
    }
    map['is_bot'] = Variable<bool>(isBot);
    if (!nullToAbsent || roles != null) {
      map['roles'] = Variable<String>(roles);
    }
    if (!nullToAbsent || updateAt != null) {
      map['update_at'] = Variable<int>(
        $UsersTable.$converterupdateAtn.toSql(updateAt),
      );
    }
    if (!nullToAbsent || deleteAt != null) {
      map['delete_at'] = Variable<int>(
        $UsersTable.$converterdeleteAtn.toSql(deleteAt),
      );
    }
    if (!nullToAbsent || lastPictureUpdate != null) {
      map['last_picture_update'] = Variable<int>(lastPictureUpdate);
    }
    if (!nullToAbsent || timezone != null) {
      map['timezone_json'] = Variable<String>(
        $UsersTable.$convertertimezone.toSql(timezone),
      );
    }
    if (!nullToAbsent || props != null) {
      map['props_json'] = Variable<String>(
        $UsersTable.$converterpropsn.toSql(props),
      );
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || statusUpdatedAt != null) {
      map['status_updated_at'] = Variable<int>(
        $UsersTable.$converterstatusUpdatedAtn.toSql(statusUpdatedAt),
      );
    }
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      username: Value(username),
      nickname: Value(nickname),
      firstName: Value(firstName),
      lastName: Value(lastName),
      position: Value(position),
      locale: locale == null && nullToAbsent
          ? const Value.absent()
          : Value(locale),
      isBot: Value(isBot),
      roles: roles == null && nullToAbsent
          ? const Value.absent()
          : Value(roles),
      updateAt: updateAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updateAt),
      deleteAt: deleteAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deleteAt),
      lastPictureUpdate: lastPictureUpdate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPictureUpdate),
      timezone: timezone == null && nullToAbsent
          ? const Value.absent()
          : Value(timezone),
      props: props == null && nullToAbsent
          ? const Value.absent()
          : Value(props),
      status: Value(status),
      statusUpdatedAt: statusUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(statusUpdatedAt),
    );
  }

  factory UserRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserRow(
      id: serializer.fromJson<String>(json['id']),
      username: serializer.fromJson<String>(json['username']),
      nickname: serializer.fromJson<String>(json['nickname']),
      firstName: serializer.fromJson<String>(json['firstName']),
      lastName: serializer.fromJson<String>(json['lastName']),
      position: serializer.fromJson<String>(json['position']),
      locale: serializer.fromJson<String?>(json['locale']),
      isBot: serializer.fromJson<bool>(json['isBot']),
      roles: serializer.fromJson<String?>(json['roles']),
      updateAt: serializer.fromJson<DateTime?>(json['updateAt']),
      deleteAt: serializer.fromJson<DateTime?>(json['deleteAt']),
      lastPictureUpdate: serializer.fromJson<int?>(json['lastPictureUpdate']),
      timezone: serializer.fromJson<Timezone?>(json['timezone']),
      props: serializer.fromJson<Map<String, Object?>?>(json['props']),
      status: serializer.fromJson<String>(json['status']),
      statusUpdatedAt: serializer.fromJson<DateTime?>(json['statusUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'username': serializer.toJson<String>(username),
      'nickname': serializer.toJson<String>(nickname),
      'firstName': serializer.toJson<String>(firstName),
      'lastName': serializer.toJson<String>(lastName),
      'position': serializer.toJson<String>(position),
      'locale': serializer.toJson<String?>(locale),
      'isBot': serializer.toJson<bool>(isBot),
      'roles': serializer.toJson<String?>(roles),
      'updateAt': serializer.toJson<DateTime?>(updateAt),
      'deleteAt': serializer.toJson<DateTime?>(deleteAt),
      'lastPictureUpdate': serializer.toJson<int?>(lastPictureUpdate),
      'timezone': serializer.toJson<Timezone?>(timezone),
      'props': serializer.toJson<Map<String, Object?>?>(props),
      'status': serializer.toJson<String>(status),
      'statusUpdatedAt': serializer.toJson<DateTime?>(statusUpdatedAt),
    };
  }

  UserRow copyWith({
    String? id,
    String? username,
    String? nickname,
    String? firstName,
    String? lastName,
    String? position,
    Value<String?> locale = const Value.absent(),
    bool? isBot,
    Value<String?> roles = const Value.absent(),
    Value<DateTime?> updateAt = const Value.absent(),
    Value<DateTime?> deleteAt = const Value.absent(),
    Value<int?> lastPictureUpdate = const Value.absent(),
    Value<Timezone?> timezone = const Value.absent(),
    Value<Map<String, Object?>?> props = const Value.absent(),
    String? status,
    Value<DateTime?> statusUpdatedAt = const Value.absent(),
  }) => UserRow(
    id: id ?? this.id,
    username: username ?? this.username,
    nickname: nickname ?? this.nickname,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    position: position ?? this.position,
    locale: locale.present ? locale.value : this.locale,
    isBot: isBot ?? this.isBot,
    roles: roles.present ? roles.value : this.roles,
    updateAt: updateAt.present ? updateAt.value : this.updateAt,
    deleteAt: deleteAt.present ? deleteAt.value : this.deleteAt,
    lastPictureUpdate: lastPictureUpdate.present
        ? lastPictureUpdate.value
        : this.lastPictureUpdate,
    timezone: timezone.present ? timezone.value : this.timezone,
    props: props.present ? props.value : this.props,
    status: status ?? this.status,
    statusUpdatedAt: statusUpdatedAt.present
        ? statusUpdatedAt.value
        : this.statusUpdatedAt,
  );
  UserRow copyWithCompanion(UsersCompanion data) {
    return UserRow(
      id: data.id.present ? data.id.value : this.id,
      username: data.username.present ? data.username.value : this.username,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      position: data.position.present ? data.position.value : this.position,
      locale: data.locale.present ? data.locale.value : this.locale,
      isBot: data.isBot.present ? data.isBot.value : this.isBot,
      roles: data.roles.present ? data.roles.value : this.roles,
      updateAt: data.updateAt.present ? data.updateAt.value : this.updateAt,
      deleteAt: data.deleteAt.present ? data.deleteAt.value : this.deleteAt,
      lastPictureUpdate: data.lastPictureUpdate.present
          ? data.lastPictureUpdate.value
          : this.lastPictureUpdate,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      props: data.props.present ? data.props.value : this.props,
      status: data.status.present ? data.status.value : this.status,
      statusUpdatedAt: data.statusUpdatedAt.present
          ? data.statusUpdatedAt.value
          : this.statusUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserRow(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('nickname: $nickname, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('position: $position, ')
          ..write('locale: $locale, ')
          ..write('isBot: $isBot, ')
          ..write('roles: $roles, ')
          ..write('updateAt: $updateAt, ')
          ..write('deleteAt: $deleteAt, ')
          ..write('lastPictureUpdate: $lastPictureUpdate, ')
          ..write('timezone: $timezone, ')
          ..write('props: $props, ')
          ..write('status: $status, ')
          ..write('statusUpdatedAt: $statusUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    username,
    nickname,
    firstName,
    lastName,
    position,
    locale,
    isBot,
    roles,
    updateAt,
    deleteAt,
    lastPictureUpdate,
    timezone,
    props,
    status,
    statusUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserRow &&
          other.id == this.id &&
          other.username == this.username &&
          other.nickname == this.nickname &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.position == this.position &&
          other.locale == this.locale &&
          other.isBot == this.isBot &&
          other.roles == this.roles &&
          other.updateAt == this.updateAt &&
          other.deleteAt == this.deleteAt &&
          other.lastPictureUpdate == this.lastPictureUpdate &&
          other.timezone == this.timezone &&
          other.props == this.props &&
          other.status == this.status &&
          other.statusUpdatedAt == this.statusUpdatedAt);
}

class UsersCompanion extends UpdateCompanion<UserRow> {
  final Value<String> id;
  final Value<String> username;
  final Value<String> nickname;
  final Value<String> firstName;
  final Value<String> lastName;
  final Value<String> position;
  final Value<String?> locale;
  final Value<bool> isBot;
  final Value<String?> roles;
  final Value<DateTime?> updateAt;
  final Value<DateTime?> deleteAt;
  final Value<int?> lastPictureUpdate;
  final Value<Timezone?> timezone;
  final Value<Map<String, Object?>?> props;
  final Value<String> status;
  final Value<DateTime?> statusUpdatedAt;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.username = const Value.absent(),
    this.nickname = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.position = const Value.absent(),
    this.locale = const Value.absent(),
    this.isBot = const Value.absent(),
    this.roles = const Value.absent(),
    this.updateAt = const Value.absent(),
    this.deleteAt = const Value.absent(),
    this.lastPictureUpdate = const Value.absent(),
    this.timezone = const Value.absent(),
    this.props = const Value.absent(),
    this.status = const Value.absent(),
    this.statusUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String username,
    this.nickname = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.position = const Value.absent(),
    this.locale = const Value.absent(),
    this.isBot = const Value.absent(),
    this.roles = const Value.absent(),
    this.updateAt = const Value.absent(),
    this.deleteAt = const Value.absent(),
    this.lastPictureUpdate = const Value.absent(),
    this.timezone = const Value.absent(),
    this.props = const Value.absent(),
    this.status = const Value.absent(),
    this.statusUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       username = Value(username);
  static Insertable<UserRow> custom({
    Expression<String>? id,
    Expression<String>? username,
    Expression<String>? nickname,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<String>? position,
    Expression<String>? locale,
    Expression<bool>? isBot,
    Expression<String>? roles,
    Expression<int>? updateAt,
    Expression<int>? deleteAt,
    Expression<int>? lastPictureUpdate,
    Expression<String>? timezone,
    Expression<String>? props,
    Expression<String>? status,
    Expression<int>? statusUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (username != null) 'username': username,
      if (nickname != null) 'nickname': nickname,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (position != null) 'position': position,
      if (locale != null) 'locale': locale,
      if (isBot != null) 'is_bot': isBot,
      if (roles != null) 'roles': roles,
      if (updateAt != null) 'update_at': updateAt,
      if (deleteAt != null) 'delete_at': deleteAt,
      if (lastPictureUpdate != null) 'last_picture_update': lastPictureUpdate,
      if (timezone != null) 'timezone_json': timezone,
      if (props != null) 'props_json': props,
      if (status != null) 'status': status,
      if (statusUpdatedAt != null) 'status_updated_at': statusUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? id,
    Value<String>? username,
    Value<String>? nickname,
    Value<String>? firstName,
    Value<String>? lastName,
    Value<String>? position,
    Value<String?>? locale,
    Value<bool>? isBot,
    Value<String?>? roles,
    Value<DateTime?>? updateAt,
    Value<DateTime?>? deleteAt,
    Value<int?>? lastPictureUpdate,
    Value<Timezone?>? timezone,
    Value<Map<String, Object?>?>? props,
    Value<String>? status,
    Value<DateTime?>? statusUpdatedAt,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      username: username ?? this.username,
      nickname: nickname ?? this.nickname,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      position: position ?? this.position,
      locale: locale ?? this.locale,
      isBot: isBot ?? this.isBot,
      roles: roles ?? this.roles,
      updateAt: updateAt ?? this.updateAt,
      deleteAt: deleteAt ?? this.deleteAt,
      lastPictureUpdate: lastPictureUpdate ?? this.lastPictureUpdate,
      timezone: timezone ?? this.timezone,
      props: props ?? this.props,
      status: status ?? this.status,
      statusUpdatedAt: statusUpdatedAt ?? this.statusUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (position.present) {
      map['position'] = Variable<String>(position.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
    }
    if (isBot.present) {
      map['is_bot'] = Variable<bool>(isBot.value);
    }
    if (roles.present) {
      map['roles'] = Variable<String>(roles.value);
    }
    if (updateAt.present) {
      map['update_at'] = Variable<int>(
        $UsersTable.$converterupdateAtn.toSql(updateAt.value),
      );
    }
    if (deleteAt.present) {
      map['delete_at'] = Variable<int>(
        $UsersTable.$converterdeleteAtn.toSql(deleteAt.value),
      );
    }
    if (lastPictureUpdate.present) {
      map['last_picture_update'] = Variable<int>(lastPictureUpdate.value);
    }
    if (timezone.present) {
      map['timezone_json'] = Variable<String>(
        $UsersTable.$convertertimezone.toSql(timezone.value),
      );
    }
    if (props.present) {
      map['props_json'] = Variable<String>(
        $UsersTable.$converterpropsn.toSql(props.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (statusUpdatedAt.present) {
      map['status_updated_at'] = Variable<int>(
        $UsersTable.$converterstatusUpdatedAtn.toSql(statusUpdatedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('nickname: $nickname, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('position: $position, ')
          ..write('locale: $locale, ')
          ..write('isBot: $isBot, ')
          ..write('roles: $roles, ')
          ..write('updateAt: $updateAt, ')
          ..write('deleteAt: $deleteAt, ')
          ..write('lastPictureUpdate: $lastPictureUpdate, ')
          ..write('timezone: $timezone, ')
          ..write('props: $props, ')
          ..write('status: $status, ')
          ..write('statusUpdatedAt: $statusUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TeamsTable extends Teams with TableInfo<$TeamsTable, TeamRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TeamsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> updateAt =
      GeneratedColumn<int>(
        'update_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($TeamsTable.$converterupdateAtn);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> deleteAt =
      GeneratedColumn<int>(
        'delete_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($TeamsTable.$converterdeleteAtn);
  static const VerificationMeta _lastTeamIconUpdateMeta =
      const VerificationMeta('lastTeamIconUpdate');
  @override
  late final GeneratedColumn<int> lastTeamIconUpdate = GeneratedColumn<int>(
    'last_team_icon_update',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    displayName,
    type,
    description,
    updateAt,
    deleteAt,
    lastTeamIconUpdate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'teams';
  @override
  VerificationContext validateIntegrity(
    Insertable<TeamRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
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
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('last_team_icon_update')) {
      context.handle(
        _lastTeamIconUpdateMeta,
        lastTeamIconUpdate.isAcceptableOrUnknown(
          data['last_team_icon_update']!,
          _lastTeamIconUpdateMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TeamRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TeamRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      updateAt: $TeamsTable.$converterupdateAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}update_at'],
        ),
      ),
      deleteAt: $TeamsTable.$converterdeleteAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}delete_at'],
        ),
      ),
      lastTeamIconUpdate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_team_icon_update'],
      ),
    );
  }

  @override
  $TeamsTable createAlias(String alias) {
    return $TeamsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $converterupdateAt = const Millis();
  static TypeConverter<DateTime?, int?> $converterupdateAtn =
      NullAwareTypeConverter.wrap($converterupdateAt);
  static TypeConverter<DateTime, int> $converterdeleteAt = const Millis();
  static TypeConverter<DateTime?, int?> $converterdeleteAtn =
      NullAwareTypeConverter.wrap($converterdeleteAt);
}

class TeamRow extends DataClass implements Insertable<TeamRow> {
  final String id;
  final String name;
  final String displayName;
  final String type;
  final String description;
  final DateTime? updateAt;
  final DateTime? deleteAt;
  final int? lastTeamIconUpdate;
  const TeamRow({
    required this.id,
    required this.name,
    required this.displayName,
    required this.type,
    required this.description,
    this.updateAt,
    this.deleteAt,
    this.lastTeamIconUpdate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['display_name'] = Variable<String>(displayName);
    map['type'] = Variable<String>(type);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || updateAt != null) {
      map['update_at'] = Variable<int>(
        $TeamsTable.$converterupdateAtn.toSql(updateAt),
      );
    }
    if (!nullToAbsent || deleteAt != null) {
      map['delete_at'] = Variable<int>(
        $TeamsTable.$converterdeleteAtn.toSql(deleteAt),
      );
    }
    if (!nullToAbsent || lastTeamIconUpdate != null) {
      map['last_team_icon_update'] = Variable<int>(lastTeamIconUpdate);
    }
    return map;
  }

  TeamsCompanion toCompanion(bool nullToAbsent) {
    return TeamsCompanion(
      id: Value(id),
      name: Value(name),
      displayName: Value(displayName),
      type: Value(type),
      description: Value(description),
      updateAt: updateAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updateAt),
      deleteAt: deleteAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deleteAt),
      lastTeamIconUpdate: lastTeamIconUpdate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastTeamIconUpdate),
    );
  }

  factory TeamRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TeamRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      displayName: serializer.fromJson<String>(json['displayName']),
      type: serializer.fromJson<String>(json['type']),
      description: serializer.fromJson<String>(json['description']),
      updateAt: serializer.fromJson<DateTime?>(json['updateAt']),
      deleteAt: serializer.fromJson<DateTime?>(json['deleteAt']),
      lastTeamIconUpdate: serializer.fromJson<int?>(json['lastTeamIconUpdate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'displayName': serializer.toJson<String>(displayName),
      'type': serializer.toJson<String>(type),
      'description': serializer.toJson<String>(description),
      'updateAt': serializer.toJson<DateTime?>(updateAt),
      'deleteAt': serializer.toJson<DateTime?>(deleteAt),
      'lastTeamIconUpdate': serializer.toJson<int?>(lastTeamIconUpdate),
    };
  }

  TeamRow copyWith({
    String? id,
    String? name,
    String? displayName,
    String? type,
    String? description,
    Value<DateTime?> updateAt = const Value.absent(),
    Value<DateTime?> deleteAt = const Value.absent(),
    Value<int?> lastTeamIconUpdate = const Value.absent(),
  }) => TeamRow(
    id: id ?? this.id,
    name: name ?? this.name,
    displayName: displayName ?? this.displayName,
    type: type ?? this.type,
    description: description ?? this.description,
    updateAt: updateAt.present ? updateAt.value : this.updateAt,
    deleteAt: deleteAt.present ? deleteAt.value : this.deleteAt,
    lastTeamIconUpdate: lastTeamIconUpdate.present
        ? lastTeamIconUpdate.value
        : this.lastTeamIconUpdate,
  );
  TeamRow copyWithCompanion(TeamsCompanion data) {
    return TeamRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      type: data.type.present ? data.type.value : this.type,
      description: data.description.present
          ? data.description.value
          : this.description,
      updateAt: data.updateAt.present ? data.updateAt.value : this.updateAt,
      deleteAt: data.deleteAt.present ? data.deleteAt.value : this.deleteAt,
      lastTeamIconUpdate: data.lastTeamIconUpdate.present
          ? data.lastTeamIconUpdate.value
          : this.lastTeamIconUpdate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TeamRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('displayName: $displayName, ')
          ..write('type: $type, ')
          ..write('description: $description, ')
          ..write('updateAt: $updateAt, ')
          ..write('deleteAt: $deleteAt, ')
          ..write('lastTeamIconUpdate: $lastTeamIconUpdate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    displayName,
    type,
    description,
    updateAt,
    deleteAt,
    lastTeamIconUpdate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TeamRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.displayName == this.displayName &&
          other.type == this.type &&
          other.description == this.description &&
          other.updateAt == this.updateAt &&
          other.deleteAt == this.deleteAt &&
          other.lastTeamIconUpdate == this.lastTeamIconUpdate);
}

class TeamsCompanion extends UpdateCompanion<TeamRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> displayName;
  final Value<String> type;
  final Value<String> description;
  final Value<DateTime?> updateAt;
  final Value<DateTime?> deleteAt;
  final Value<int?> lastTeamIconUpdate;
  final Value<int> rowid;
  const TeamsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.displayName = const Value.absent(),
    this.type = const Value.absent(),
    this.description = const Value.absent(),
    this.updateAt = const Value.absent(),
    this.deleteAt = const Value.absent(),
    this.lastTeamIconUpdate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TeamsCompanion.insert({
    required String id,
    required String name,
    required String displayName,
    required String type,
    this.description = const Value.absent(),
    this.updateAt = const Value.absent(),
    this.deleteAt = const Value.absent(),
    this.lastTeamIconUpdate = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       displayName = Value(displayName),
       type = Value(type);
  static Insertable<TeamRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? displayName,
    Expression<String>? type,
    Expression<String>? description,
    Expression<int>? updateAt,
    Expression<int>? deleteAt,
    Expression<int>? lastTeamIconUpdate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (displayName != null) 'display_name': displayName,
      if (type != null) 'type': type,
      if (description != null) 'description': description,
      if (updateAt != null) 'update_at': updateAt,
      if (deleteAt != null) 'delete_at': deleteAt,
      if (lastTeamIconUpdate != null)
        'last_team_icon_update': lastTeamIconUpdate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TeamsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? displayName,
    Value<String>? type,
    Value<String>? description,
    Value<DateTime?>? updateAt,
    Value<DateTime?>? deleteAt,
    Value<int?>? lastTeamIconUpdate,
    Value<int>? rowid,
  }) {
    return TeamsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      type: type ?? this.type,
      description: description ?? this.description,
      updateAt: updateAt ?? this.updateAt,
      deleteAt: deleteAt ?? this.deleteAt,
      lastTeamIconUpdate: lastTeamIconUpdate ?? this.lastTeamIconUpdate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (updateAt.present) {
      map['update_at'] = Variable<int>(
        $TeamsTable.$converterupdateAtn.toSql(updateAt.value),
      );
    }
    if (deleteAt.present) {
      map['delete_at'] = Variable<int>(
        $TeamsTable.$converterdeleteAtn.toSql(deleteAt.value),
      );
    }
    if (lastTeamIconUpdate.present) {
      map['last_team_icon_update'] = Variable<int>(lastTeamIconUpdate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TeamsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('displayName: $displayName, ')
          ..write('type: $type, ')
          ..write('description: $description, ')
          ..write('updateAt: $updateAt, ')
          ..write('deleteAt: $deleteAt, ')
          ..write('lastTeamIconUpdate: $lastTeamIconUpdate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MyTeamsTable extends MyTeams with TableInfo<$MyTeamsTable, MyTeamRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MyTeamsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _teamIdMeta = const VerificationMeta('teamId');
  @override
  late final GeneratedColumn<String> teamId = GeneratedColumn<String>(
    'team_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rolesMeta = const VerificationMeta('roles');
  @override
  late final GeneratedColumn<String> roles = GeneratedColumn<String>(
    'roles',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _msgCountMeta = const VerificationMeta(
    'msgCount',
  );
  @override
  late final GeneratedColumn<int> msgCount = GeneratedColumn<int>(
    'msg_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _mentionCountMeta = const VerificationMeta(
    'mentionCount',
  );
  @override
  late final GeneratedColumn<int> mentionCount = GeneratedColumn<int>(
    'mention_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _msgCountRootMeta = const VerificationMeta(
    'msgCountRoot',
  );
  @override
  late final GeneratedColumn<int> msgCountRoot = GeneratedColumn<int>(
    'msg_count_root',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _mentionCountRootMeta = const VerificationMeta(
    'mentionCountRoot',
  );
  @override
  late final GeneratedColumn<int> mentionCountRoot = GeneratedColumn<int>(
    'mention_count_root',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    teamId,
    roles,
    msgCount,
    mentionCount,
    msgCountRoot,
    mentionCountRoot,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'my_teams';
  @override
  VerificationContext validateIntegrity(
    Insertable<MyTeamRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('team_id')) {
      context.handle(
        _teamIdMeta,
        teamId.isAcceptableOrUnknown(data['team_id']!, _teamIdMeta),
      );
    } else if (isInserting) {
      context.missing(_teamIdMeta);
    }
    if (data.containsKey('roles')) {
      context.handle(
        _rolesMeta,
        roles.isAcceptableOrUnknown(data['roles']!, _rolesMeta),
      );
    }
    if (data.containsKey('msg_count')) {
      context.handle(
        _msgCountMeta,
        msgCount.isAcceptableOrUnknown(data['msg_count']!, _msgCountMeta),
      );
    }
    if (data.containsKey('mention_count')) {
      context.handle(
        _mentionCountMeta,
        mentionCount.isAcceptableOrUnknown(
          data['mention_count']!,
          _mentionCountMeta,
        ),
      );
    }
    if (data.containsKey('msg_count_root')) {
      context.handle(
        _msgCountRootMeta,
        msgCountRoot.isAcceptableOrUnknown(
          data['msg_count_root']!,
          _msgCountRootMeta,
        ),
      );
    }
    if (data.containsKey('mention_count_root')) {
      context.handle(
        _mentionCountRootMeta,
        mentionCountRoot.isAcceptableOrUnknown(
          data['mention_count_root']!,
          _mentionCountRootMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {teamId};
  @override
  MyTeamRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MyTeamRow(
      teamId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}team_id'],
      )!,
      roles: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}roles'],
      )!,
      msgCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}msg_count'],
      )!,
      mentionCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mention_count'],
      )!,
      msgCountRoot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}msg_count_root'],
      )!,
      mentionCountRoot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mention_count_root'],
      )!,
    );
  }

  @override
  $MyTeamsTable createAlias(String alias) {
    return $MyTeamsTable(attachedDatabase, alias);
  }
}

class MyTeamRow extends DataClass implements Insertable<MyTeamRow> {
  final String teamId;
  final String roles;
  final int msgCount;
  final int mentionCount;
  final int msgCountRoot;
  final int mentionCountRoot;
  const MyTeamRow({
    required this.teamId,
    required this.roles,
    required this.msgCount,
    required this.mentionCount,
    required this.msgCountRoot,
    required this.mentionCountRoot,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['team_id'] = Variable<String>(teamId);
    map['roles'] = Variable<String>(roles);
    map['msg_count'] = Variable<int>(msgCount);
    map['mention_count'] = Variable<int>(mentionCount);
    map['msg_count_root'] = Variable<int>(msgCountRoot);
    map['mention_count_root'] = Variable<int>(mentionCountRoot);
    return map;
  }

  MyTeamsCompanion toCompanion(bool nullToAbsent) {
    return MyTeamsCompanion(
      teamId: Value(teamId),
      roles: Value(roles),
      msgCount: Value(msgCount),
      mentionCount: Value(mentionCount),
      msgCountRoot: Value(msgCountRoot),
      mentionCountRoot: Value(mentionCountRoot),
    );
  }

  factory MyTeamRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MyTeamRow(
      teamId: serializer.fromJson<String>(json['teamId']),
      roles: serializer.fromJson<String>(json['roles']),
      msgCount: serializer.fromJson<int>(json['msgCount']),
      mentionCount: serializer.fromJson<int>(json['mentionCount']),
      msgCountRoot: serializer.fromJson<int>(json['msgCountRoot']),
      mentionCountRoot: serializer.fromJson<int>(json['mentionCountRoot']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'teamId': serializer.toJson<String>(teamId),
      'roles': serializer.toJson<String>(roles),
      'msgCount': serializer.toJson<int>(msgCount),
      'mentionCount': serializer.toJson<int>(mentionCount),
      'msgCountRoot': serializer.toJson<int>(msgCountRoot),
      'mentionCountRoot': serializer.toJson<int>(mentionCountRoot),
    };
  }

  MyTeamRow copyWith({
    String? teamId,
    String? roles,
    int? msgCount,
    int? mentionCount,
    int? msgCountRoot,
    int? mentionCountRoot,
  }) => MyTeamRow(
    teamId: teamId ?? this.teamId,
    roles: roles ?? this.roles,
    msgCount: msgCount ?? this.msgCount,
    mentionCount: mentionCount ?? this.mentionCount,
    msgCountRoot: msgCountRoot ?? this.msgCountRoot,
    mentionCountRoot: mentionCountRoot ?? this.mentionCountRoot,
  );
  MyTeamRow copyWithCompanion(MyTeamsCompanion data) {
    return MyTeamRow(
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
      roles: data.roles.present ? data.roles.value : this.roles,
      msgCount: data.msgCount.present ? data.msgCount.value : this.msgCount,
      mentionCount: data.mentionCount.present
          ? data.mentionCount.value
          : this.mentionCount,
      msgCountRoot: data.msgCountRoot.present
          ? data.msgCountRoot.value
          : this.msgCountRoot,
      mentionCountRoot: data.mentionCountRoot.present
          ? data.mentionCountRoot.value
          : this.mentionCountRoot,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MyTeamRow(')
          ..write('teamId: $teamId, ')
          ..write('roles: $roles, ')
          ..write('msgCount: $msgCount, ')
          ..write('mentionCount: $mentionCount, ')
          ..write('msgCountRoot: $msgCountRoot, ')
          ..write('mentionCountRoot: $mentionCountRoot')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    teamId,
    roles,
    msgCount,
    mentionCount,
    msgCountRoot,
    mentionCountRoot,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MyTeamRow &&
          other.teamId == this.teamId &&
          other.roles == this.roles &&
          other.msgCount == this.msgCount &&
          other.mentionCount == this.mentionCount &&
          other.msgCountRoot == this.msgCountRoot &&
          other.mentionCountRoot == this.mentionCountRoot);
}

class MyTeamsCompanion extends UpdateCompanion<MyTeamRow> {
  final Value<String> teamId;
  final Value<String> roles;
  final Value<int> msgCount;
  final Value<int> mentionCount;
  final Value<int> msgCountRoot;
  final Value<int> mentionCountRoot;
  final Value<int> rowid;
  const MyTeamsCompanion({
    this.teamId = const Value.absent(),
    this.roles = const Value.absent(),
    this.msgCount = const Value.absent(),
    this.mentionCount = const Value.absent(),
    this.msgCountRoot = const Value.absent(),
    this.mentionCountRoot = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MyTeamsCompanion.insert({
    required String teamId,
    this.roles = const Value.absent(),
    this.msgCount = const Value.absent(),
    this.mentionCount = const Value.absent(),
    this.msgCountRoot = const Value.absent(),
    this.mentionCountRoot = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : teamId = Value(teamId);
  static Insertable<MyTeamRow> custom({
    Expression<String>? teamId,
    Expression<String>? roles,
    Expression<int>? msgCount,
    Expression<int>? mentionCount,
    Expression<int>? msgCountRoot,
    Expression<int>? mentionCountRoot,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (teamId != null) 'team_id': teamId,
      if (roles != null) 'roles': roles,
      if (msgCount != null) 'msg_count': msgCount,
      if (mentionCount != null) 'mention_count': mentionCount,
      if (msgCountRoot != null) 'msg_count_root': msgCountRoot,
      if (mentionCountRoot != null) 'mention_count_root': mentionCountRoot,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MyTeamsCompanion copyWith({
    Value<String>? teamId,
    Value<String>? roles,
    Value<int>? msgCount,
    Value<int>? mentionCount,
    Value<int>? msgCountRoot,
    Value<int>? mentionCountRoot,
    Value<int>? rowid,
  }) {
    return MyTeamsCompanion(
      teamId: teamId ?? this.teamId,
      roles: roles ?? this.roles,
      msgCount: msgCount ?? this.msgCount,
      mentionCount: mentionCount ?? this.mentionCount,
      msgCountRoot: msgCountRoot ?? this.msgCountRoot,
      mentionCountRoot: mentionCountRoot ?? this.mentionCountRoot,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (teamId.present) {
      map['team_id'] = Variable<String>(teamId.value);
    }
    if (roles.present) {
      map['roles'] = Variable<String>(roles.value);
    }
    if (msgCount.present) {
      map['msg_count'] = Variable<int>(msgCount.value);
    }
    if (mentionCount.present) {
      map['mention_count'] = Variable<int>(mentionCount.value);
    }
    if (msgCountRoot.present) {
      map['msg_count_root'] = Variable<int>(msgCountRoot.value);
    }
    if (mentionCountRoot.present) {
      map['mention_count_root'] = Variable<int>(mentionCountRoot.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MyTeamsCompanion(')
          ..write('teamId: $teamId, ')
          ..write('roles: $roles, ')
          ..write('msgCount: $msgCount, ')
          ..write('mentionCount: $mentionCount, ')
          ..write('msgCountRoot: $msgCountRoot, ')
          ..write('mentionCountRoot: $mentionCountRoot, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChannelsTable extends Channels
    with TableInfo<$ChannelsTable, ChannelRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChannelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _teamIdMeta = const VerificationMeta('teamId');
  @override
  late final GeneratedColumn<String> teamId = GeneratedColumn<String>(
    'team_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
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
  static const VerificationMeta _headerMeta = const VerificationMeta('header');
  @override
  late final GeneratedColumn<String> header = GeneratedColumn<String>(
    'header',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _purposeMeta = const VerificationMeta(
    'purpose',
  );
  @override
  late final GeneratedColumn<String> purpose = GeneratedColumn<String>(
    'purpose',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _creatorIdMeta = const VerificationMeta(
    'creatorId',
  );
  @override
  late final GeneratedColumn<String> creatorId = GeneratedColumn<String>(
    'creator_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> createAt =
      GeneratedColumn<int>(
        'create_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($ChannelsTable.$convertercreateAtn);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> updateAt =
      GeneratedColumn<int>(
        'update_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($ChannelsTable.$converterupdateAtn);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> deleteAt =
      GeneratedColumn<int>(
        'delete_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($ChannelsTable.$converterdeleteAtn);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> lastPostAt =
      GeneratedColumn<int>(
        'last_post_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($ChannelsTable.$converterlastPostAtn);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> lastRootPostAt =
      GeneratedColumn<int>(
        'last_root_post_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($ChannelsTable.$converterlastRootPostAtn);
  static const VerificationMeta _totalMsgCountMeta = const VerificationMeta(
    'totalMsgCount',
  );
  @override
  late final GeneratedColumn<int> totalMsgCount = GeneratedColumn<int>(
    'total_msg_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalMsgCountRootMeta = const VerificationMeta(
    'totalMsgCountRoot',
  );
  @override
  late final GeneratedColumn<int> totalMsgCountRoot = GeneratedColumn<int>(
    'total_msg_count_root',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sharedMeta = const VerificationMeta('shared');
  @override
  late final GeneratedColumn<bool> shared = GeneratedColumn<bool>(
    'shared',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("shared" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _groupConstrainedMeta = const VerificationMeta(
    'groupConstrained',
  );
  @override
  late final GeneratedColumn<bool> groupConstrained = GeneratedColumn<bool>(
    'group_constrained',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("group_constrained" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _memberCountMeta = const VerificationMeta(
    'memberCount',
  );
  @override
  late final GeneratedColumn<int> memberCount = GeneratedColumn<int>(
    'member_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    teamId,
    type,
    name,
    displayName,
    header,
    purpose,
    creatorId,
    createAt,
    updateAt,
    deleteAt,
    lastPostAt,
    lastRootPostAt,
    totalMsgCount,
    totalMsgCountRoot,
    shared,
    groupConstrained,
    memberCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'channels';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChannelRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('team_id')) {
      context.handle(
        _teamIdMeta,
        teamId.isAcceptableOrUnknown(data['team_id']!, _teamIdMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
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
    if (data.containsKey('header')) {
      context.handle(
        _headerMeta,
        header.isAcceptableOrUnknown(data['header']!, _headerMeta),
      );
    }
    if (data.containsKey('purpose')) {
      context.handle(
        _purposeMeta,
        purpose.isAcceptableOrUnknown(data['purpose']!, _purposeMeta),
      );
    }
    if (data.containsKey('creator_id')) {
      context.handle(
        _creatorIdMeta,
        creatorId.isAcceptableOrUnknown(data['creator_id']!, _creatorIdMeta),
      );
    }
    if (data.containsKey('total_msg_count')) {
      context.handle(
        _totalMsgCountMeta,
        totalMsgCount.isAcceptableOrUnknown(
          data['total_msg_count']!,
          _totalMsgCountMeta,
        ),
      );
    }
    if (data.containsKey('total_msg_count_root')) {
      context.handle(
        _totalMsgCountRootMeta,
        totalMsgCountRoot.isAcceptableOrUnknown(
          data['total_msg_count_root']!,
          _totalMsgCountRootMeta,
        ),
      );
    }
    if (data.containsKey('shared')) {
      context.handle(
        _sharedMeta,
        shared.isAcceptableOrUnknown(data['shared']!, _sharedMeta),
      );
    }
    if (data.containsKey('group_constrained')) {
      context.handle(
        _groupConstrainedMeta,
        groupConstrained.isAcceptableOrUnknown(
          data['group_constrained']!,
          _groupConstrainedMeta,
        ),
      );
    }
    if (data.containsKey('member_count')) {
      context.handle(
        _memberCountMeta,
        memberCount.isAcceptableOrUnknown(
          data['member_count']!,
          _memberCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChannelRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChannelRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      teamId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}team_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      header: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}header'],
      )!,
      purpose: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purpose'],
      )!,
      creatorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}creator_id'],
      )!,
      createAt: $ChannelsTable.$convertercreateAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}create_at'],
        ),
      ),
      updateAt: $ChannelsTable.$converterupdateAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}update_at'],
        ),
      ),
      deleteAt: $ChannelsTable.$converterdeleteAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}delete_at'],
        ),
      ),
      lastPostAt: $ChannelsTable.$converterlastPostAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}last_post_at'],
        ),
      ),
      lastRootPostAt: $ChannelsTable.$converterlastRootPostAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}last_root_post_at'],
        ),
      ),
      totalMsgCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_msg_count'],
      )!,
      totalMsgCountRoot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_msg_count_root'],
      )!,
      shared: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}shared'],
      )!,
      groupConstrained: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}group_constrained'],
      )!,
      memberCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}member_count'],
      ),
    );
  }

  @override
  $ChannelsTable createAlias(String alias) {
    return $ChannelsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreateAt = const Millis();
  static TypeConverter<DateTime?, int?> $convertercreateAtn =
      NullAwareTypeConverter.wrap($convertercreateAt);
  static TypeConverter<DateTime, int> $converterupdateAt = const Millis();
  static TypeConverter<DateTime?, int?> $converterupdateAtn =
      NullAwareTypeConverter.wrap($converterupdateAt);
  static TypeConverter<DateTime, int> $converterdeleteAt = const Millis();
  static TypeConverter<DateTime?, int?> $converterdeleteAtn =
      NullAwareTypeConverter.wrap($converterdeleteAt);
  static TypeConverter<DateTime, int> $converterlastPostAt = const Millis();
  static TypeConverter<DateTime?, int?> $converterlastPostAtn =
      NullAwareTypeConverter.wrap($converterlastPostAt);
  static TypeConverter<DateTime, int> $converterlastRootPostAt = const Millis();
  static TypeConverter<DateTime?, int?> $converterlastRootPostAtn =
      NullAwareTypeConverter.wrap($converterlastRootPostAt);
}

class ChannelRow extends DataClass implements Insertable<ChannelRow> {
  final String id;

  /// Empty for direct and group messages, which belong to the server.
  final String teamId;
  final String type;
  final String name;
  final String displayName;
  final String header;
  final String purpose;
  final String creatorId;
  final DateTime? createAt;
  final DateTime? updateAt;
  final DateTime? deleteAt;
  final DateTime? lastPostAt;
  final DateTime? lastRootPostAt;
  final int totalMsgCount;
  final int totalMsgCountRoot;
  final bool shared;
  final bool groupConstrained;

  /// From the channel's stats, fetched when it is opened.
  final int? memberCount;
  const ChannelRow({
    required this.id,
    required this.teamId,
    required this.type,
    required this.name,
    required this.displayName,
    required this.header,
    required this.purpose,
    required this.creatorId,
    this.createAt,
    this.updateAt,
    this.deleteAt,
    this.lastPostAt,
    this.lastRootPostAt,
    required this.totalMsgCount,
    required this.totalMsgCountRoot,
    required this.shared,
    required this.groupConstrained,
    this.memberCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['team_id'] = Variable<String>(teamId);
    map['type'] = Variable<String>(type);
    map['name'] = Variable<String>(name);
    map['display_name'] = Variable<String>(displayName);
    map['header'] = Variable<String>(header);
    map['purpose'] = Variable<String>(purpose);
    map['creator_id'] = Variable<String>(creatorId);
    if (!nullToAbsent || createAt != null) {
      map['create_at'] = Variable<int>(
        $ChannelsTable.$convertercreateAtn.toSql(createAt),
      );
    }
    if (!nullToAbsent || updateAt != null) {
      map['update_at'] = Variable<int>(
        $ChannelsTable.$converterupdateAtn.toSql(updateAt),
      );
    }
    if (!nullToAbsent || deleteAt != null) {
      map['delete_at'] = Variable<int>(
        $ChannelsTable.$converterdeleteAtn.toSql(deleteAt),
      );
    }
    if (!nullToAbsent || lastPostAt != null) {
      map['last_post_at'] = Variable<int>(
        $ChannelsTable.$converterlastPostAtn.toSql(lastPostAt),
      );
    }
    if (!nullToAbsent || lastRootPostAt != null) {
      map['last_root_post_at'] = Variable<int>(
        $ChannelsTable.$converterlastRootPostAtn.toSql(lastRootPostAt),
      );
    }
    map['total_msg_count'] = Variable<int>(totalMsgCount);
    map['total_msg_count_root'] = Variable<int>(totalMsgCountRoot);
    map['shared'] = Variable<bool>(shared);
    map['group_constrained'] = Variable<bool>(groupConstrained);
    if (!nullToAbsent || memberCount != null) {
      map['member_count'] = Variable<int>(memberCount);
    }
    return map;
  }

  ChannelsCompanion toCompanion(bool nullToAbsent) {
    return ChannelsCompanion(
      id: Value(id),
      teamId: Value(teamId),
      type: Value(type),
      name: Value(name),
      displayName: Value(displayName),
      header: Value(header),
      purpose: Value(purpose),
      creatorId: Value(creatorId),
      createAt: createAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createAt),
      updateAt: updateAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updateAt),
      deleteAt: deleteAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deleteAt),
      lastPostAt: lastPostAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPostAt),
      lastRootPostAt: lastRootPostAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastRootPostAt),
      totalMsgCount: Value(totalMsgCount),
      totalMsgCountRoot: Value(totalMsgCountRoot),
      shared: Value(shared),
      groupConstrained: Value(groupConstrained),
      memberCount: memberCount == null && nullToAbsent
          ? const Value.absent()
          : Value(memberCount),
    );
  }

  factory ChannelRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChannelRow(
      id: serializer.fromJson<String>(json['id']),
      teamId: serializer.fromJson<String>(json['teamId']),
      type: serializer.fromJson<String>(json['type']),
      name: serializer.fromJson<String>(json['name']),
      displayName: serializer.fromJson<String>(json['displayName']),
      header: serializer.fromJson<String>(json['header']),
      purpose: serializer.fromJson<String>(json['purpose']),
      creatorId: serializer.fromJson<String>(json['creatorId']),
      createAt: serializer.fromJson<DateTime?>(json['createAt']),
      updateAt: serializer.fromJson<DateTime?>(json['updateAt']),
      deleteAt: serializer.fromJson<DateTime?>(json['deleteAt']),
      lastPostAt: serializer.fromJson<DateTime?>(json['lastPostAt']),
      lastRootPostAt: serializer.fromJson<DateTime?>(json['lastRootPostAt']),
      totalMsgCount: serializer.fromJson<int>(json['totalMsgCount']),
      totalMsgCountRoot: serializer.fromJson<int>(json['totalMsgCountRoot']),
      shared: serializer.fromJson<bool>(json['shared']),
      groupConstrained: serializer.fromJson<bool>(json['groupConstrained']),
      memberCount: serializer.fromJson<int?>(json['memberCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'teamId': serializer.toJson<String>(teamId),
      'type': serializer.toJson<String>(type),
      'name': serializer.toJson<String>(name),
      'displayName': serializer.toJson<String>(displayName),
      'header': serializer.toJson<String>(header),
      'purpose': serializer.toJson<String>(purpose),
      'creatorId': serializer.toJson<String>(creatorId),
      'createAt': serializer.toJson<DateTime?>(createAt),
      'updateAt': serializer.toJson<DateTime?>(updateAt),
      'deleteAt': serializer.toJson<DateTime?>(deleteAt),
      'lastPostAt': serializer.toJson<DateTime?>(lastPostAt),
      'lastRootPostAt': serializer.toJson<DateTime?>(lastRootPostAt),
      'totalMsgCount': serializer.toJson<int>(totalMsgCount),
      'totalMsgCountRoot': serializer.toJson<int>(totalMsgCountRoot),
      'shared': serializer.toJson<bool>(shared),
      'groupConstrained': serializer.toJson<bool>(groupConstrained),
      'memberCount': serializer.toJson<int?>(memberCount),
    };
  }

  ChannelRow copyWith({
    String? id,
    String? teamId,
    String? type,
    String? name,
    String? displayName,
    String? header,
    String? purpose,
    String? creatorId,
    Value<DateTime?> createAt = const Value.absent(),
    Value<DateTime?> updateAt = const Value.absent(),
    Value<DateTime?> deleteAt = const Value.absent(),
    Value<DateTime?> lastPostAt = const Value.absent(),
    Value<DateTime?> lastRootPostAt = const Value.absent(),
    int? totalMsgCount,
    int? totalMsgCountRoot,
    bool? shared,
    bool? groupConstrained,
    Value<int?> memberCount = const Value.absent(),
  }) => ChannelRow(
    id: id ?? this.id,
    teamId: teamId ?? this.teamId,
    type: type ?? this.type,
    name: name ?? this.name,
    displayName: displayName ?? this.displayName,
    header: header ?? this.header,
    purpose: purpose ?? this.purpose,
    creatorId: creatorId ?? this.creatorId,
    createAt: createAt.present ? createAt.value : this.createAt,
    updateAt: updateAt.present ? updateAt.value : this.updateAt,
    deleteAt: deleteAt.present ? deleteAt.value : this.deleteAt,
    lastPostAt: lastPostAt.present ? lastPostAt.value : this.lastPostAt,
    lastRootPostAt: lastRootPostAt.present
        ? lastRootPostAt.value
        : this.lastRootPostAt,
    totalMsgCount: totalMsgCount ?? this.totalMsgCount,
    totalMsgCountRoot: totalMsgCountRoot ?? this.totalMsgCountRoot,
    shared: shared ?? this.shared,
    groupConstrained: groupConstrained ?? this.groupConstrained,
    memberCount: memberCount.present ? memberCount.value : this.memberCount,
  );
  ChannelRow copyWithCompanion(ChannelsCompanion data) {
    return ChannelRow(
      id: data.id.present ? data.id.value : this.id,
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
      type: data.type.present ? data.type.value : this.type,
      name: data.name.present ? data.name.value : this.name,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      header: data.header.present ? data.header.value : this.header,
      purpose: data.purpose.present ? data.purpose.value : this.purpose,
      creatorId: data.creatorId.present ? data.creatorId.value : this.creatorId,
      createAt: data.createAt.present ? data.createAt.value : this.createAt,
      updateAt: data.updateAt.present ? data.updateAt.value : this.updateAt,
      deleteAt: data.deleteAt.present ? data.deleteAt.value : this.deleteAt,
      lastPostAt: data.lastPostAt.present
          ? data.lastPostAt.value
          : this.lastPostAt,
      lastRootPostAt: data.lastRootPostAt.present
          ? data.lastRootPostAt.value
          : this.lastRootPostAt,
      totalMsgCount: data.totalMsgCount.present
          ? data.totalMsgCount.value
          : this.totalMsgCount,
      totalMsgCountRoot: data.totalMsgCountRoot.present
          ? data.totalMsgCountRoot.value
          : this.totalMsgCountRoot,
      shared: data.shared.present ? data.shared.value : this.shared,
      groupConstrained: data.groupConstrained.present
          ? data.groupConstrained.value
          : this.groupConstrained,
      memberCount: data.memberCount.present
          ? data.memberCount.value
          : this.memberCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChannelRow(')
          ..write('id: $id, ')
          ..write('teamId: $teamId, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('displayName: $displayName, ')
          ..write('header: $header, ')
          ..write('purpose: $purpose, ')
          ..write('creatorId: $creatorId, ')
          ..write('createAt: $createAt, ')
          ..write('updateAt: $updateAt, ')
          ..write('deleteAt: $deleteAt, ')
          ..write('lastPostAt: $lastPostAt, ')
          ..write('lastRootPostAt: $lastRootPostAt, ')
          ..write('totalMsgCount: $totalMsgCount, ')
          ..write('totalMsgCountRoot: $totalMsgCountRoot, ')
          ..write('shared: $shared, ')
          ..write('groupConstrained: $groupConstrained, ')
          ..write('memberCount: $memberCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    teamId,
    type,
    name,
    displayName,
    header,
    purpose,
    creatorId,
    createAt,
    updateAt,
    deleteAt,
    lastPostAt,
    lastRootPostAt,
    totalMsgCount,
    totalMsgCountRoot,
    shared,
    groupConstrained,
    memberCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChannelRow &&
          other.id == this.id &&
          other.teamId == this.teamId &&
          other.type == this.type &&
          other.name == this.name &&
          other.displayName == this.displayName &&
          other.header == this.header &&
          other.purpose == this.purpose &&
          other.creatorId == this.creatorId &&
          other.createAt == this.createAt &&
          other.updateAt == this.updateAt &&
          other.deleteAt == this.deleteAt &&
          other.lastPostAt == this.lastPostAt &&
          other.lastRootPostAt == this.lastRootPostAt &&
          other.totalMsgCount == this.totalMsgCount &&
          other.totalMsgCountRoot == this.totalMsgCountRoot &&
          other.shared == this.shared &&
          other.groupConstrained == this.groupConstrained &&
          other.memberCount == this.memberCount);
}

class ChannelsCompanion extends UpdateCompanion<ChannelRow> {
  final Value<String> id;
  final Value<String> teamId;
  final Value<String> type;
  final Value<String> name;
  final Value<String> displayName;
  final Value<String> header;
  final Value<String> purpose;
  final Value<String> creatorId;
  final Value<DateTime?> createAt;
  final Value<DateTime?> updateAt;
  final Value<DateTime?> deleteAt;
  final Value<DateTime?> lastPostAt;
  final Value<DateTime?> lastRootPostAt;
  final Value<int> totalMsgCount;
  final Value<int> totalMsgCountRoot;
  final Value<bool> shared;
  final Value<bool> groupConstrained;
  final Value<int?> memberCount;
  final Value<int> rowid;
  const ChannelsCompanion({
    this.id = const Value.absent(),
    this.teamId = const Value.absent(),
    this.type = const Value.absent(),
    this.name = const Value.absent(),
    this.displayName = const Value.absent(),
    this.header = const Value.absent(),
    this.purpose = const Value.absent(),
    this.creatorId = const Value.absent(),
    this.createAt = const Value.absent(),
    this.updateAt = const Value.absent(),
    this.deleteAt = const Value.absent(),
    this.lastPostAt = const Value.absent(),
    this.lastRootPostAt = const Value.absent(),
    this.totalMsgCount = const Value.absent(),
    this.totalMsgCountRoot = const Value.absent(),
    this.shared = const Value.absent(),
    this.groupConstrained = const Value.absent(),
    this.memberCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChannelsCompanion.insert({
    required String id,
    this.teamId = const Value.absent(),
    required String type,
    required String name,
    required String displayName,
    this.header = const Value.absent(),
    this.purpose = const Value.absent(),
    this.creatorId = const Value.absent(),
    this.createAt = const Value.absent(),
    this.updateAt = const Value.absent(),
    this.deleteAt = const Value.absent(),
    this.lastPostAt = const Value.absent(),
    this.lastRootPostAt = const Value.absent(),
    this.totalMsgCount = const Value.absent(),
    this.totalMsgCountRoot = const Value.absent(),
    this.shared = const Value.absent(),
    this.groupConstrained = const Value.absent(),
    this.memberCount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       name = Value(name),
       displayName = Value(displayName);
  static Insertable<ChannelRow> custom({
    Expression<String>? id,
    Expression<String>? teamId,
    Expression<String>? type,
    Expression<String>? name,
    Expression<String>? displayName,
    Expression<String>? header,
    Expression<String>? purpose,
    Expression<String>? creatorId,
    Expression<int>? createAt,
    Expression<int>? updateAt,
    Expression<int>? deleteAt,
    Expression<int>? lastPostAt,
    Expression<int>? lastRootPostAt,
    Expression<int>? totalMsgCount,
    Expression<int>? totalMsgCountRoot,
    Expression<bool>? shared,
    Expression<bool>? groupConstrained,
    Expression<int>? memberCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (teamId != null) 'team_id': teamId,
      if (type != null) 'type': type,
      if (name != null) 'name': name,
      if (displayName != null) 'display_name': displayName,
      if (header != null) 'header': header,
      if (purpose != null) 'purpose': purpose,
      if (creatorId != null) 'creator_id': creatorId,
      if (createAt != null) 'create_at': createAt,
      if (updateAt != null) 'update_at': updateAt,
      if (deleteAt != null) 'delete_at': deleteAt,
      if (lastPostAt != null) 'last_post_at': lastPostAt,
      if (lastRootPostAt != null) 'last_root_post_at': lastRootPostAt,
      if (totalMsgCount != null) 'total_msg_count': totalMsgCount,
      if (totalMsgCountRoot != null) 'total_msg_count_root': totalMsgCountRoot,
      if (shared != null) 'shared': shared,
      if (groupConstrained != null) 'group_constrained': groupConstrained,
      if (memberCount != null) 'member_count': memberCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChannelsCompanion copyWith({
    Value<String>? id,
    Value<String>? teamId,
    Value<String>? type,
    Value<String>? name,
    Value<String>? displayName,
    Value<String>? header,
    Value<String>? purpose,
    Value<String>? creatorId,
    Value<DateTime?>? createAt,
    Value<DateTime?>? updateAt,
    Value<DateTime?>? deleteAt,
    Value<DateTime?>? lastPostAt,
    Value<DateTime?>? lastRootPostAt,
    Value<int>? totalMsgCount,
    Value<int>? totalMsgCountRoot,
    Value<bool>? shared,
    Value<bool>? groupConstrained,
    Value<int?>? memberCount,
    Value<int>? rowid,
  }) {
    return ChannelsCompanion(
      id: id ?? this.id,
      teamId: teamId ?? this.teamId,
      type: type ?? this.type,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      header: header ?? this.header,
      purpose: purpose ?? this.purpose,
      creatorId: creatorId ?? this.creatorId,
      createAt: createAt ?? this.createAt,
      updateAt: updateAt ?? this.updateAt,
      deleteAt: deleteAt ?? this.deleteAt,
      lastPostAt: lastPostAt ?? this.lastPostAt,
      lastRootPostAt: lastRootPostAt ?? this.lastRootPostAt,
      totalMsgCount: totalMsgCount ?? this.totalMsgCount,
      totalMsgCountRoot: totalMsgCountRoot ?? this.totalMsgCountRoot,
      shared: shared ?? this.shared,
      groupConstrained: groupConstrained ?? this.groupConstrained,
      memberCount: memberCount ?? this.memberCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (teamId.present) {
      map['team_id'] = Variable<String>(teamId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (header.present) {
      map['header'] = Variable<String>(header.value);
    }
    if (purpose.present) {
      map['purpose'] = Variable<String>(purpose.value);
    }
    if (creatorId.present) {
      map['creator_id'] = Variable<String>(creatorId.value);
    }
    if (createAt.present) {
      map['create_at'] = Variable<int>(
        $ChannelsTable.$convertercreateAtn.toSql(createAt.value),
      );
    }
    if (updateAt.present) {
      map['update_at'] = Variable<int>(
        $ChannelsTable.$converterupdateAtn.toSql(updateAt.value),
      );
    }
    if (deleteAt.present) {
      map['delete_at'] = Variable<int>(
        $ChannelsTable.$converterdeleteAtn.toSql(deleteAt.value),
      );
    }
    if (lastPostAt.present) {
      map['last_post_at'] = Variable<int>(
        $ChannelsTable.$converterlastPostAtn.toSql(lastPostAt.value),
      );
    }
    if (lastRootPostAt.present) {
      map['last_root_post_at'] = Variable<int>(
        $ChannelsTable.$converterlastRootPostAtn.toSql(lastRootPostAt.value),
      );
    }
    if (totalMsgCount.present) {
      map['total_msg_count'] = Variable<int>(totalMsgCount.value);
    }
    if (totalMsgCountRoot.present) {
      map['total_msg_count_root'] = Variable<int>(totalMsgCountRoot.value);
    }
    if (shared.present) {
      map['shared'] = Variable<bool>(shared.value);
    }
    if (groupConstrained.present) {
      map['group_constrained'] = Variable<bool>(groupConstrained.value);
    }
    if (memberCount.present) {
      map['member_count'] = Variable<int>(memberCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChannelsCompanion(')
          ..write('id: $id, ')
          ..write('teamId: $teamId, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('displayName: $displayName, ')
          ..write('header: $header, ')
          ..write('purpose: $purpose, ')
          ..write('creatorId: $creatorId, ')
          ..write('createAt: $createAt, ')
          ..write('updateAt: $updateAt, ')
          ..write('deleteAt: $deleteAt, ')
          ..write('lastPostAt: $lastPostAt, ')
          ..write('lastRootPostAt: $lastRootPostAt, ')
          ..write('totalMsgCount: $totalMsgCount, ')
          ..write('totalMsgCountRoot: $totalMsgCountRoot, ')
          ..write('shared: $shared, ')
          ..write('groupConstrained: $groupConstrained, ')
          ..write('memberCount: $memberCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MyChannelsTable extends MyChannels
    with TableInfo<$MyChannelsTable, MyChannelRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MyChannelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _channelIdMeta = const VerificationMeta(
    'channelId',
  );
  @override
  late final GeneratedColumn<String> channelId = GeneratedColumn<String>(
    'channel_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rolesMeta = const VerificationMeta('roles');
  @override
  late final GeneratedColumn<String> roles = GeneratedColumn<String>(
    'roles',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> lastViewedAt =
      GeneratedColumn<int>(
        'last_viewed_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($MyChannelsTable.$converterlastViewedAtn);
  static const VerificationMeta _msgCountMeta = const VerificationMeta(
    'msgCount',
  );
  @override
  late final GeneratedColumn<int> msgCount = GeneratedColumn<int>(
    'msg_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _msgCountRootMeta = const VerificationMeta(
    'msgCountRoot',
  );
  @override
  late final GeneratedColumn<int> msgCountRoot = GeneratedColumn<int>(
    'msg_count_root',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _mentionCountMeta = const VerificationMeta(
    'mentionCount',
  );
  @override
  late final GeneratedColumn<int> mentionCount = GeneratedColumn<int>(
    'mention_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _mentionCountRootMeta = const VerificationMeta(
    'mentionCountRoot',
  );
  @override
  late final GeneratedColumn<int> mentionCountRoot = GeneratedColumn<int>(
    'mention_count_root',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _urgentMentionCountMeta =
      const VerificationMeta('urgentMentionCount');
  @override
  late final GeneratedColumn<int> urgentMentionCount = GeneratedColumn<int>(
    'urgent_mention_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _manuallyUnreadMeta = const VerificationMeta(
    'manuallyUnread',
  );
  @override
  late final GeneratedColumn<bool> manuallyUnread = GeneratedColumn<bool>(
    'manually_unread',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("manually_unread" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ChannelNotifyProps?, String>
  notifyProps = GeneratedColumn<String>(
    'notify_props_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<ChannelNotifyProps?>($MyChannelsTable.$converternotifyProps);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> lastUpdateAt =
      GeneratedColumn<int>(
        'last_update_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($MyChannelsTable.$converterlastUpdateAtn);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> postsFetchedAt =
      GeneratedColumn<int>(
        'posts_fetched_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($MyChannelsTable.$converterpostsFetchedAtn);
  @override
  List<GeneratedColumn> get $columns => [
    channelId,
    roles,
    lastViewedAt,
    msgCount,
    msgCountRoot,
    mentionCount,
    mentionCountRoot,
    urgentMentionCount,
    manuallyUnread,
    notifyProps,
    lastUpdateAt,
    postsFetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'my_channels';
  @override
  VerificationContext validateIntegrity(
    Insertable<MyChannelRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('channel_id')) {
      context.handle(
        _channelIdMeta,
        channelId.isAcceptableOrUnknown(data['channel_id']!, _channelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_channelIdMeta);
    }
    if (data.containsKey('roles')) {
      context.handle(
        _rolesMeta,
        roles.isAcceptableOrUnknown(data['roles']!, _rolesMeta),
      );
    }
    if (data.containsKey('msg_count')) {
      context.handle(
        _msgCountMeta,
        msgCount.isAcceptableOrUnknown(data['msg_count']!, _msgCountMeta),
      );
    }
    if (data.containsKey('msg_count_root')) {
      context.handle(
        _msgCountRootMeta,
        msgCountRoot.isAcceptableOrUnknown(
          data['msg_count_root']!,
          _msgCountRootMeta,
        ),
      );
    }
    if (data.containsKey('mention_count')) {
      context.handle(
        _mentionCountMeta,
        mentionCount.isAcceptableOrUnknown(
          data['mention_count']!,
          _mentionCountMeta,
        ),
      );
    }
    if (data.containsKey('mention_count_root')) {
      context.handle(
        _mentionCountRootMeta,
        mentionCountRoot.isAcceptableOrUnknown(
          data['mention_count_root']!,
          _mentionCountRootMeta,
        ),
      );
    }
    if (data.containsKey('urgent_mention_count')) {
      context.handle(
        _urgentMentionCountMeta,
        urgentMentionCount.isAcceptableOrUnknown(
          data['urgent_mention_count']!,
          _urgentMentionCountMeta,
        ),
      );
    }
    if (data.containsKey('manually_unread')) {
      context.handle(
        _manuallyUnreadMeta,
        manuallyUnread.isAcceptableOrUnknown(
          data['manually_unread']!,
          _manuallyUnreadMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {channelId};
  @override
  MyChannelRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MyChannelRow(
      channelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}channel_id'],
      )!,
      roles: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}roles'],
      )!,
      lastViewedAt: $MyChannelsTable.$converterlastViewedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}last_viewed_at'],
        ),
      ),
      msgCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}msg_count'],
      )!,
      msgCountRoot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}msg_count_root'],
      )!,
      mentionCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mention_count'],
      )!,
      mentionCountRoot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mention_count_root'],
      )!,
      urgentMentionCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}urgent_mention_count'],
      )!,
      manuallyUnread: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}manually_unread'],
      )!,
      notifyProps: $MyChannelsTable.$converternotifyProps.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}notify_props_json'],
        ),
      ),
      lastUpdateAt: $MyChannelsTable.$converterlastUpdateAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}last_update_at'],
        ),
      ),
      postsFetchedAt: $MyChannelsTable.$converterpostsFetchedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}posts_fetched_at'],
        ),
      ),
    );
  }

  @override
  $MyChannelsTable createAlias(String alias) {
    return $MyChannelsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $converterlastViewedAt = const Millis();
  static TypeConverter<DateTime?, int?> $converterlastViewedAtn =
      NullAwareTypeConverter.wrap($converterlastViewedAt);
  static TypeConverter<ChannelNotifyProps?, String?> $converternotifyProps =
      const ChannelNotifyPropsColumn();
  static TypeConverter<DateTime, int> $converterlastUpdateAt = const Millis();
  static TypeConverter<DateTime?, int?> $converterlastUpdateAtn =
      NullAwareTypeConverter.wrap($converterlastUpdateAt);
  static TypeConverter<DateTime, int> $converterpostsFetchedAt = const Millis();
  static TypeConverter<DateTime?, int?> $converterpostsFetchedAtn =
      NullAwareTypeConverter.wrap($converterpostsFetchedAt);
}

class MyChannelRow extends DataClass implements Insertable<MyChannelRow> {
  final String channelId;
  final String roles;
  final DateTime? lastViewedAt;
  final int msgCount;
  final int msgCountRoot;
  final int mentionCount;
  final int mentionCountRoot;
  final int urgentMentionCount;
  final bool manuallyUnread;
  final ChannelNotifyProps? notifyProps;
  final DateTime? lastUpdateAt;

  /// Watermark for `posts?since=`: the newest create, update or delete time
  /// received for this channel.
  final DateTime? postsFetchedAt;
  const MyChannelRow({
    required this.channelId,
    required this.roles,
    this.lastViewedAt,
    required this.msgCount,
    required this.msgCountRoot,
    required this.mentionCount,
    required this.mentionCountRoot,
    required this.urgentMentionCount,
    required this.manuallyUnread,
    this.notifyProps,
    this.lastUpdateAt,
    this.postsFetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['channel_id'] = Variable<String>(channelId);
    map['roles'] = Variable<String>(roles);
    if (!nullToAbsent || lastViewedAt != null) {
      map['last_viewed_at'] = Variable<int>(
        $MyChannelsTable.$converterlastViewedAtn.toSql(lastViewedAt),
      );
    }
    map['msg_count'] = Variable<int>(msgCount);
    map['msg_count_root'] = Variable<int>(msgCountRoot);
    map['mention_count'] = Variable<int>(mentionCount);
    map['mention_count_root'] = Variable<int>(mentionCountRoot);
    map['urgent_mention_count'] = Variable<int>(urgentMentionCount);
    map['manually_unread'] = Variable<bool>(manuallyUnread);
    if (!nullToAbsent || notifyProps != null) {
      map['notify_props_json'] = Variable<String>(
        $MyChannelsTable.$converternotifyProps.toSql(notifyProps),
      );
    }
    if (!nullToAbsent || lastUpdateAt != null) {
      map['last_update_at'] = Variable<int>(
        $MyChannelsTable.$converterlastUpdateAtn.toSql(lastUpdateAt),
      );
    }
    if (!nullToAbsent || postsFetchedAt != null) {
      map['posts_fetched_at'] = Variable<int>(
        $MyChannelsTable.$converterpostsFetchedAtn.toSql(postsFetchedAt),
      );
    }
    return map;
  }

  MyChannelsCompanion toCompanion(bool nullToAbsent) {
    return MyChannelsCompanion(
      channelId: Value(channelId),
      roles: Value(roles),
      lastViewedAt: lastViewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastViewedAt),
      msgCount: Value(msgCount),
      msgCountRoot: Value(msgCountRoot),
      mentionCount: Value(mentionCount),
      mentionCountRoot: Value(mentionCountRoot),
      urgentMentionCount: Value(urgentMentionCount),
      manuallyUnread: Value(manuallyUnread),
      notifyProps: notifyProps == null && nullToAbsent
          ? const Value.absent()
          : Value(notifyProps),
      lastUpdateAt: lastUpdateAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUpdateAt),
      postsFetchedAt: postsFetchedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(postsFetchedAt),
    );
  }

  factory MyChannelRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MyChannelRow(
      channelId: serializer.fromJson<String>(json['channelId']),
      roles: serializer.fromJson<String>(json['roles']),
      lastViewedAt: serializer.fromJson<DateTime?>(json['lastViewedAt']),
      msgCount: serializer.fromJson<int>(json['msgCount']),
      msgCountRoot: serializer.fromJson<int>(json['msgCountRoot']),
      mentionCount: serializer.fromJson<int>(json['mentionCount']),
      mentionCountRoot: serializer.fromJson<int>(json['mentionCountRoot']),
      urgentMentionCount: serializer.fromJson<int>(json['urgentMentionCount']),
      manuallyUnread: serializer.fromJson<bool>(json['manuallyUnread']),
      notifyProps: serializer.fromJson<ChannelNotifyProps?>(
        json['notifyProps'],
      ),
      lastUpdateAt: serializer.fromJson<DateTime?>(json['lastUpdateAt']),
      postsFetchedAt: serializer.fromJson<DateTime?>(json['postsFetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'channelId': serializer.toJson<String>(channelId),
      'roles': serializer.toJson<String>(roles),
      'lastViewedAt': serializer.toJson<DateTime?>(lastViewedAt),
      'msgCount': serializer.toJson<int>(msgCount),
      'msgCountRoot': serializer.toJson<int>(msgCountRoot),
      'mentionCount': serializer.toJson<int>(mentionCount),
      'mentionCountRoot': serializer.toJson<int>(mentionCountRoot),
      'urgentMentionCount': serializer.toJson<int>(urgentMentionCount),
      'manuallyUnread': serializer.toJson<bool>(manuallyUnread),
      'notifyProps': serializer.toJson<ChannelNotifyProps?>(notifyProps),
      'lastUpdateAt': serializer.toJson<DateTime?>(lastUpdateAt),
      'postsFetchedAt': serializer.toJson<DateTime?>(postsFetchedAt),
    };
  }

  MyChannelRow copyWith({
    String? channelId,
    String? roles,
    Value<DateTime?> lastViewedAt = const Value.absent(),
    int? msgCount,
    int? msgCountRoot,
    int? mentionCount,
    int? mentionCountRoot,
    int? urgentMentionCount,
    bool? manuallyUnread,
    Value<ChannelNotifyProps?> notifyProps = const Value.absent(),
    Value<DateTime?> lastUpdateAt = const Value.absent(),
    Value<DateTime?> postsFetchedAt = const Value.absent(),
  }) => MyChannelRow(
    channelId: channelId ?? this.channelId,
    roles: roles ?? this.roles,
    lastViewedAt: lastViewedAt.present ? lastViewedAt.value : this.lastViewedAt,
    msgCount: msgCount ?? this.msgCount,
    msgCountRoot: msgCountRoot ?? this.msgCountRoot,
    mentionCount: mentionCount ?? this.mentionCount,
    mentionCountRoot: mentionCountRoot ?? this.mentionCountRoot,
    urgentMentionCount: urgentMentionCount ?? this.urgentMentionCount,
    manuallyUnread: manuallyUnread ?? this.manuallyUnread,
    notifyProps: notifyProps.present ? notifyProps.value : this.notifyProps,
    lastUpdateAt: lastUpdateAt.present ? lastUpdateAt.value : this.lastUpdateAt,
    postsFetchedAt: postsFetchedAt.present
        ? postsFetchedAt.value
        : this.postsFetchedAt,
  );
  MyChannelRow copyWithCompanion(MyChannelsCompanion data) {
    return MyChannelRow(
      channelId: data.channelId.present ? data.channelId.value : this.channelId,
      roles: data.roles.present ? data.roles.value : this.roles,
      lastViewedAt: data.lastViewedAt.present
          ? data.lastViewedAt.value
          : this.lastViewedAt,
      msgCount: data.msgCount.present ? data.msgCount.value : this.msgCount,
      msgCountRoot: data.msgCountRoot.present
          ? data.msgCountRoot.value
          : this.msgCountRoot,
      mentionCount: data.mentionCount.present
          ? data.mentionCount.value
          : this.mentionCount,
      mentionCountRoot: data.mentionCountRoot.present
          ? data.mentionCountRoot.value
          : this.mentionCountRoot,
      urgentMentionCount: data.urgentMentionCount.present
          ? data.urgentMentionCount.value
          : this.urgentMentionCount,
      manuallyUnread: data.manuallyUnread.present
          ? data.manuallyUnread.value
          : this.manuallyUnread,
      notifyProps: data.notifyProps.present
          ? data.notifyProps.value
          : this.notifyProps,
      lastUpdateAt: data.lastUpdateAt.present
          ? data.lastUpdateAt.value
          : this.lastUpdateAt,
      postsFetchedAt: data.postsFetchedAt.present
          ? data.postsFetchedAt.value
          : this.postsFetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MyChannelRow(')
          ..write('channelId: $channelId, ')
          ..write('roles: $roles, ')
          ..write('lastViewedAt: $lastViewedAt, ')
          ..write('msgCount: $msgCount, ')
          ..write('msgCountRoot: $msgCountRoot, ')
          ..write('mentionCount: $mentionCount, ')
          ..write('mentionCountRoot: $mentionCountRoot, ')
          ..write('urgentMentionCount: $urgentMentionCount, ')
          ..write('manuallyUnread: $manuallyUnread, ')
          ..write('notifyProps: $notifyProps, ')
          ..write('lastUpdateAt: $lastUpdateAt, ')
          ..write('postsFetchedAt: $postsFetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    channelId,
    roles,
    lastViewedAt,
    msgCount,
    msgCountRoot,
    mentionCount,
    mentionCountRoot,
    urgentMentionCount,
    manuallyUnread,
    notifyProps,
    lastUpdateAt,
    postsFetchedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MyChannelRow &&
          other.channelId == this.channelId &&
          other.roles == this.roles &&
          other.lastViewedAt == this.lastViewedAt &&
          other.msgCount == this.msgCount &&
          other.msgCountRoot == this.msgCountRoot &&
          other.mentionCount == this.mentionCount &&
          other.mentionCountRoot == this.mentionCountRoot &&
          other.urgentMentionCount == this.urgentMentionCount &&
          other.manuallyUnread == this.manuallyUnread &&
          other.notifyProps == this.notifyProps &&
          other.lastUpdateAt == this.lastUpdateAt &&
          other.postsFetchedAt == this.postsFetchedAt);
}

class MyChannelsCompanion extends UpdateCompanion<MyChannelRow> {
  final Value<String> channelId;
  final Value<String> roles;
  final Value<DateTime?> lastViewedAt;
  final Value<int> msgCount;
  final Value<int> msgCountRoot;
  final Value<int> mentionCount;
  final Value<int> mentionCountRoot;
  final Value<int> urgentMentionCount;
  final Value<bool> manuallyUnread;
  final Value<ChannelNotifyProps?> notifyProps;
  final Value<DateTime?> lastUpdateAt;
  final Value<DateTime?> postsFetchedAt;
  final Value<int> rowid;
  const MyChannelsCompanion({
    this.channelId = const Value.absent(),
    this.roles = const Value.absent(),
    this.lastViewedAt = const Value.absent(),
    this.msgCount = const Value.absent(),
    this.msgCountRoot = const Value.absent(),
    this.mentionCount = const Value.absent(),
    this.mentionCountRoot = const Value.absent(),
    this.urgentMentionCount = const Value.absent(),
    this.manuallyUnread = const Value.absent(),
    this.notifyProps = const Value.absent(),
    this.lastUpdateAt = const Value.absent(),
    this.postsFetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MyChannelsCompanion.insert({
    required String channelId,
    this.roles = const Value.absent(),
    this.lastViewedAt = const Value.absent(),
    this.msgCount = const Value.absent(),
    this.msgCountRoot = const Value.absent(),
    this.mentionCount = const Value.absent(),
    this.mentionCountRoot = const Value.absent(),
    this.urgentMentionCount = const Value.absent(),
    this.manuallyUnread = const Value.absent(),
    this.notifyProps = const Value.absent(),
    this.lastUpdateAt = const Value.absent(),
    this.postsFetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : channelId = Value(channelId);
  static Insertable<MyChannelRow> custom({
    Expression<String>? channelId,
    Expression<String>? roles,
    Expression<int>? lastViewedAt,
    Expression<int>? msgCount,
    Expression<int>? msgCountRoot,
    Expression<int>? mentionCount,
    Expression<int>? mentionCountRoot,
    Expression<int>? urgentMentionCount,
    Expression<bool>? manuallyUnread,
    Expression<String>? notifyProps,
    Expression<int>? lastUpdateAt,
    Expression<int>? postsFetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (channelId != null) 'channel_id': channelId,
      if (roles != null) 'roles': roles,
      if (lastViewedAt != null) 'last_viewed_at': lastViewedAt,
      if (msgCount != null) 'msg_count': msgCount,
      if (msgCountRoot != null) 'msg_count_root': msgCountRoot,
      if (mentionCount != null) 'mention_count': mentionCount,
      if (mentionCountRoot != null) 'mention_count_root': mentionCountRoot,
      if (urgentMentionCount != null)
        'urgent_mention_count': urgentMentionCount,
      if (manuallyUnread != null) 'manually_unread': manuallyUnread,
      if (notifyProps != null) 'notify_props_json': notifyProps,
      if (lastUpdateAt != null) 'last_update_at': lastUpdateAt,
      if (postsFetchedAt != null) 'posts_fetched_at': postsFetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MyChannelsCompanion copyWith({
    Value<String>? channelId,
    Value<String>? roles,
    Value<DateTime?>? lastViewedAt,
    Value<int>? msgCount,
    Value<int>? msgCountRoot,
    Value<int>? mentionCount,
    Value<int>? mentionCountRoot,
    Value<int>? urgentMentionCount,
    Value<bool>? manuallyUnread,
    Value<ChannelNotifyProps?>? notifyProps,
    Value<DateTime?>? lastUpdateAt,
    Value<DateTime?>? postsFetchedAt,
    Value<int>? rowid,
  }) {
    return MyChannelsCompanion(
      channelId: channelId ?? this.channelId,
      roles: roles ?? this.roles,
      lastViewedAt: lastViewedAt ?? this.lastViewedAt,
      msgCount: msgCount ?? this.msgCount,
      msgCountRoot: msgCountRoot ?? this.msgCountRoot,
      mentionCount: mentionCount ?? this.mentionCount,
      mentionCountRoot: mentionCountRoot ?? this.mentionCountRoot,
      urgentMentionCount: urgentMentionCount ?? this.urgentMentionCount,
      manuallyUnread: manuallyUnread ?? this.manuallyUnread,
      notifyProps: notifyProps ?? this.notifyProps,
      lastUpdateAt: lastUpdateAt ?? this.lastUpdateAt,
      postsFetchedAt: postsFetchedAt ?? this.postsFetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (channelId.present) {
      map['channel_id'] = Variable<String>(channelId.value);
    }
    if (roles.present) {
      map['roles'] = Variable<String>(roles.value);
    }
    if (lastViewedAt.present) {
      map['last_viewed_at'] = Variable<int>(
        $MyChannelsTable.$converterlastViewedAtn.toSql(lastViewedAt.value),
      );
    }
    if (msgCount.present) {
      map['msg_count'] = Variable<int>(msgCount.value);
    }
    if (msgCountRoot.present) {
      map['msg_count_root'] = Variable<int>(msgCountRoot.value);
    }
    if (mentionCount.present) {
      map['mention_count'] = Variable<int>(mentionCount.value);
    }
    if (mentionCountRoot.present) {
      map['mention_count_root'] = Variable<int>(mentionCountRoot.value);
    }
    if (urgentMentionCount.present) {
      map['urgent_mention_count'] = Variable<int>(urgentMentionCount.value);
    }
    if (manuallyUnread.present) {
      map['manually_unread'] = Variable<bool>(manuallyUnread.value);
    }
    if (notifyProps.present) {
      map['notify_props_json'] = Variable<String>(
        $MyChannelsTable.$converternotifyProps.toSql(notifyProps.value),
      );
    }
    if (lastUpdateAt.present) {
      map['last_update_at'] = Variable<int>(
        $MyChannelsTable.$converterlastUpdateAtn.toSql(lastUpdateAt.value),
      );
    }
    if (postsFetchedAt.present) {
      map['posts_fetched_at'] = Variable<int>(
        $MyChannelsTable.$converterpostsFetchedAtn.toSql(postsFetchedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MyChannelsCompanion(')
          ..write('channelId: $channelId, ')
          ..write('roles: $roles, ')
          ..write('lastViewedAt: $lastViewedAt, ')
          ..write('msgCount: $msgCount, ')
          ..write('msgCountRoot: $msgCountRoot, ')
          ..write('mentionCount: $mentionCount, ')
          ..write('mentionCountRoot: $mentionCountRoot, ')
          ..write('urgentMentionCount: $urgentMentionCount, ')
          ..write('manuallyUnread: $manuallyUnread, ')
          ..write('notifyProps: $notifyProps, ')
          ..write('lastUpdateAt: $lastUpdateAt, ')
          ..write('postsFetchedAt: $postsFetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _teamIdMeta = const VerificationMeta('teamId');
  @override
  late final GeneratedColumn<String> teamId = GeneratedColumn<String>(
    'team_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
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
  static const VerificationMeta _sortingMeta = const VerificationMeta(
    'sorting',
  );
  @override
  late final GeneratedColumn<String> sorting = GeneratedColumn<String>(
    'sorting',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
  static const VerificationMeta _mutedMeta = const VerificationMeta('muted');
  @override
  late final GeneratedColumn<bool> muted = GeneratedColumn<bool>(
    'muted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("muted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _collapsedMeta = const VerificationMeta(
    'collapsed',
  );
  @override
  late final GeneratedColumn<bool> collapsed = GeneratedColumn<bool>(
    'collapsed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("collapsed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    teamId,
    type,
    displayName,
    sorting,
    sortOrder,
    muted,
    collapsed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('team_id')) {
      context.handle(
        _teamIdMeta,
        teamId.isAcceptableOrUnknown(data['team_id']!, _teamIdMeta),
      );
    } else if (isInserting) {
      context.missing(_teamIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
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
    if (data.containsKey('sorting')) {
      context.handle(
        _sortingMeta,
        sorting.isAcceptableOrUnknown(data['sorting']!, _sortingMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('muted')) {
      context.handle(
        _mutedMeta,
        muted.isAcceptableOrUnknown(data['muted']!, _mutedMeta),
      );
    }
    if (data.containsKey('collapsed')) {
      context.handle(
        _collapsedMeta,
        collapsed.isAcceptableOrUnknown(data['collapsed']!, _collapsedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      teamId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}team_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      sorting: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sorting'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      muted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}muted'],
      )!,
      collapsed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}collapsed'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  final String id;
  final String teamId;
  final String type;
  final String displayName;
  final String sorting;
  final int sortOrder;
  final bool muted;

  /// Collapse state is kept on the device only, as the official app does.
  final bool collapsed;
  const CategoryRow({
    required this.id,
    required this.teamId,
    required this.type,
    required this.displayName,
    required this.sorting,
    required this.sortOrder,
    required this.muted,
    required this.collapsed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['team_id'] = Variable<String>(teamId);
    map['type'] = Variable<String>(type);
    map['display_name'] = Variable<String>(displayName);
    map['sorting'] = Variable<String>(sorting);
    map['sort_order'] = Variable<int>(sortOrder);
    map['muted'] = Variable<bool>(muted);
    map['collapsed'] = Variable<bool>(collapsed);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      teamId: Value(teamId),
      type: Value(type),
      displayName: Value(displayName),
      sorting: Value(sorting),
      sortOrder: Value(sortOrder),
      muted: Value(muted),
      collapsed: Value(collapsed),
    );
  }

  factory CategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      id: serializer.fromJson<String>(json['id']),
      teamId: serializer.fromJson<String>(json['teamId']),
      type: serializer.fromJson<String>(json['type']),
      displayName: serializer.fromJson<String>(json['displayName']),
      sorting: serializer.fromJson<String>(json['sorting']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      muted: serializer.fromJson<bool>(json['muted']),
      collapsed: serializer.fromJson<bool>(json['collapsed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'teamId': serializer.toJson<String>(teamId),
      'type': serializer.toJson<String>(type),
      'displayName': serializer.toJson<String>(displayName),
      'sorting': serializer.toJson<String>(sorting),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'muted': serializer.toJson<bool>(muted),
      'collapsed': serializer.toJson<bool>(collapsed),
    };
  }

  CategoryRow copyWith({
    String? id,
    String? teamId,
    String? type,
    String? displayName,
    String? sorting,
    int? sortOrder,
    bool? muted,
    bool? collapsed,
  }) => CategoryRow(
    id: id ?? this.id,
    teamId: teamId ?? this.teamId,
    type: type ?? this.type,
    displayName: displayName ?? this.displayName,
    sorting: sorting ?? this.sorting,
    sortOrder: sortOrder ?? this.sortOrder,
    muted: muted ?? this.muted,
    collapsed: collapsed ?? this.collapsed,
  );
  CategoryRow copyWithCompanion(CategoriesCompanion data) {
    return CategoryRow(
      id: data.id.present ? data.id.value : this.id,
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
      type: data.type.present ? data.type.value : this.type,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      sorting: data.sorting.present ? data.sorting.value : this.sorting,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      muted: data.muted.present ? data.muted.value : this.muted,
      collapsed: data.collapsed.present ? data.collapsed.value : this.collapsed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('id: $id, ')
          ..write('teamId: $teamId, ')
          ..write('type: $type, ')
          ..write('displayName: $displayName, ')
          ..write('sorting: $sorting, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('muted: $muted, ')
          ..write('collapsed: $collapsed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    teamId,
    type,
    displayName,
    sorting,
    sortOrder,
    muted,
    collapsed,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow &&
          other.id == this.id &&
          other.teamId == this.teamId &&
          other.type == this.type &&
          other.displayName == this.displayName &&
          other.sorting == this.sorting &&
          other.sortOrder == this.sortOrder &&
          other.muted == this.muted &&
          other.collapsed == this.collapsed);
}

class CategoriesCompanion extends UpdateCompanion<CategoryRow> {
  final Value<String> id;
  final Value<String> teamId;
  final Value<String> type;
  final Value<String> displayName;
  final Value<String> sorting;
  final Value<int> sortOrder;
  final Value<bool> muted;
  final Value<bool> collapsed;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.teamId = const Value.absent(),
    this.type = const Value.absent(),
    this.displayName = const Value.absent(),
    this.sorting = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.muted = const Value.absent(),
    this.collapsed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String teamId,
    required String type,
    required String displayName,
    this.sorting = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.muted = const Value.absent(),
    this.collapsed = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       teamId = Value(teamId),
       type = Value(type),
       displayName = Value(displayName);
  static Insertable<CategoryRow> custom({
    Expression<String>? id,
    Expression<String>? teamId,
    Expression<String>? type,
    Expression<String>? displayName,
    Expression<String>? sorting,
    Expression<int>? sortOrder,
    Expression<bool>? muted,
    Expression<bool>? collapsed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (teamId != null) 'team_id': teamId,
      if (type != null) 'type': type,
      if (displayName != null) 'display_name': displayName,
      if (sorting != null) 'sorting': sorting,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (muted != null) 'muted': muted,
      if (collapsed != null) 'collapsed': collapsed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? teamId,
    Value<String>? type,
    Value<String>? displayName,
    Value<String>? sorting,
    Value<int>? sortOrder,
    Value<bool>? muted,
    Value<bool>? collapsed,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      teamId: teamId ?? this.teamId,
      type: type ?? this.type,
      displayName: displayName ?? this.displayName,
      sorting: sorting ?? this.sorting,
      sortOrder: sortOrder ?? this.sortOrder,
      muted: muted ?? this.muted,
      collapsed: collapsed ?? this.collapsed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (teamId.present) {
      map['team_id'] = Variable<String>(teamId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (sorting.present) {
      map['sorting'] = Variable<String>(sorting.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (muted.present) {
      map['muted'] = Variable<bool>(muted.value);
    }
    if (collapsed.present) {
      map['collapsed'] = Variable<bool>(collapsed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('teamId: $teamId, ')
          ..write('type: $type, ')
          ..write('displayName: $displayName, ')
          ..write('sorting: $sorting, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('muted: $muted, ')
          ..write('collapsed: $collapsed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoryChannelsTable extends CategoryChannels
    with TableInfo<$CategoryChannelsTable, CategoryChannelRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoryChannelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _channelIdMeta = const VerificationMeta(
    'channelId',
  );
  @override
  late final GeneratedColumn<String> channelId = GeneratedColumn<String>(
    'channel_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  List<GeneratedColumn> get $columns => [categoryId, channelId, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'category_channels';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryChannelRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('channel_id')) {
      context.handle(
        _channelIdMeta,
        channelId.isAcceptableOrUnknown(data['channel_id']!, _channelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_channelIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {categoryId, channelId};
  @override
  CategoryChannelRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryChannelRow(
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      channelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}channel_id'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $CategoryChannelsTable createAlias(String alias) {
    return $CategoryChannelsTable(attachedDatabase, alias);
  }
}

class CategoryChannelRow extends DataClass
    implements Insertable<CategoryChannelRow> {
  final String categoryId;
  final String channelId;
  final int sortOrder;
  const CategoryChannelRow({
    required this.categoryId,
    required this.channelId,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['category_id'] = Variable<String>(categoryId);
    map['channel_id'] = Variable<String>(channelId);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  CategoryChannelsCompanion toCompanion(bool nullToAbsent) {
    return CategoryChannelsCompanion(
      categoryId: Value(categoryId),
      channelId: Value(channelId),
      sortOrder: Value(sortOrder),
    );
  }

  factory CategoryChannelRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryChannelRow(
      categoryId: serializer.fromJson<String>(json['categoryId']),
      channelId: serializer.fromJson<String>(json['channelId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'categoryId': serializer.toJson<String>(categoryId),
      'channelId': serializer.toJson<String>(channelId),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  CategoryChannelRow copyWith({
    String? categoryId,
    String? channelId,
    int? sortOrder,
  }) => CategoryChannelRow(
    categoryId: categoryId ?? this.categoryId,
    channelId: channelId ?? this.channelId,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  CategoryChannelRow copyWithCompanion(CategoryChannelsCompanion data) {
    return CategoryChannelRow(
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      channelId: data.channelId.present ? data.channelId.value : this.channelId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryChannelRow(')
          ..write('categoryId: $categoryId, ')
          ..write('channelId: $channelId, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(categoryId, channelId, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryChannelRow &&
          other.categoryId == this.categoryId &&
          other.channelId == this.channelId &&
          other.sortOrder == this.sortOrder);
}

class CategoryChannelsCompanion extends UpdateCompanion<CategoryChannelRow> {
  final Value<String> categoryId;
  final Value<String> channelId;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const CategoryChannelsCompanion({
    this.categoryId = const Value.absent(),
    this.channelId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoryChannelsCompanion.insert({
    required String categoryId,
    required String channelId,
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : categoryId = Value(categoryId),
       channelId = Value(channelId);
  static Insertable<CategoryChannelRow> custom({
    Expression<String>? categoryId,
    Expression<String>? channelId,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (categoryId != null) 'category_id': categoryId,
      if (channelId != null) 'channel_id': channelId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoryChannelsCompanion copyWith({
    Value<String>? categoryId,
    Value<String>? channelId,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return CategoryChannelsCompanion(
      categoryId: categoryId ?? this.categoryId,
      channelId: channelId ?? this.channelId,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (channelId.present) {
      map['channel_id'] = Variable<String>(channelId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoryChannelsCompanion(')
          ..write('categoryId: $categoryId, ')
          ..write('channelId: $channelId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PostsTable extends Posts with TableInfo<$PostsTable, PostRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PostsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _channelIdMeta = const VerificationMeta(
    'channelId',
  );
  @override
  late final GeneratedColumn<String> channelId = GeneratedColumn<String>(
    'channel_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rootIdMeta = const VerificationMeta('rootId');
  @override
  late final GeneratedColumn<String> rootId = GeneratedColumn<String>(
    'root_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createAt =
      GeneratedColumn<int>(
        'create_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($PostsTable.$convertercreateAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> updateAt =
      GeneratedColumn<int>(
        'update_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($PostsTable.$converterupdateAtn);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> editAt =
      GeneratedColumn<int>(
        'edit_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($PostsTable.$convertereditAtn);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> deleteAt =
      GeneratedColumn<int>(
        'delete_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($PostsTable.$converterdeleteAtn);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isPinnedMeta = const VerificationMeta(
    'isPinned',
  );
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
    'is_pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _replyCountMeta = const VerificationMeta(
    'replyCount',
  );
  @override
  late final GeneratedColumn<int> replyCount = GeneratedColumn<int>(
    'reply_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> lastReplyAt =
      GeneratedColumn<int>(
        'last_reply_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($PostsTable.$converterlastReplyAtn);
  static const VerificationMeta _originalIdMeta = const VerificationMeta(
    'originalId',
  );
  @override
  late final GeneratedColumn<String> originalId = GeneratedColumn<String>(
    'original_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _pendingPostIdMeta = const VerificationMeta(
    'pendingPostId',
  );
  @override
  late final GeneratedColumn<String> pendingPostId = GeneratedColumn<String>(
    'pending_post_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _sendStateMeta = const VerificationMeta(
    'sendState',
  );
  @override
  late final GeneratedColumn<String> sendState = GeneratedColumn<String>(
    'send_state',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _propsJsonMeta = const VerificationMeta(
    'propsJson',
  );
  @override
  late final GeneratedColumn<String> propsJson = GeneratedColumn<String>(
    'props_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _metadataJsonMeta = const VerificationMeta(
    'metadataJson',
  );
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
    'metadata_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fileCountMeta = const VerificationMeta(
    'fileCount',
  );
  @override
  late final GeneratedColumn<int> fileCount = GeneratedColumn<int>(
    'file_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _reactionCountMeta = const VerificationMeta(
    'reactionCount',
  );
  @override
  late final GeneratedColumn<int> reactionCount = GeneratedColumn<int>(
    'reaction_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String>
  participantIds = GeneratedColumn<String>(
    'participant_ids_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<List<String>?>($PostsTable.$converterparticipantIdsn);
  static const VerificationMeta _decodeProblemMeta = const VerificationMeta(
    'decodeProblem',
  );
  @override
  late final GeneratedColumn<String> decodeProblem = GeneratedColumn<String>(
    'decode_problem',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    channelId,
    rootId,
    userId,
    createAt,
    updateAt,
    editAt,
    deleteAt,
    type,
    message,
    isPinned,
    replyCount,
    lastReplyAt,
    originalId,
    pendingPostId,
    sendState,
    propsJson,
    metadataJson,
    fileCount,
    reactionCount,
    participantIds,
    decodeProblem,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'posts';
  @override
  VerificationContext validateIntegrity(
    Insertable<PostRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('channel_id')) {
      context.handle(
        _channelIdMeta,
        channelId.isAcceptableOrUnknown(data['channel_id']!, _channelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_channelIdMeta);
    }
    if (data.containsKey('root_id')) {
      context.handle(
        _rootIdMeta,
        rootId.isAcceptableOrUnknown(data['root_id']!, _rootIdMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    }
    if (data.containsKey('is_pinned')) {
      context.handle(
        _isPinnedMeta,
        isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta),
      );
    }
    if (data.containsKey('reply_count')) {
      context.handle(
        _replyCountMeta,
        replyCount.isAcceptableOrUnknown(data['reply_count']!, _replyCountMeta),
      );
    }
    if (data.containsKey('original_id')) {
      context.handle(
        _originalIdMeta,
        originalId.isAcceptableOrUnknown(data['original_id']!, _originalIdMeta),
      );
    }
    if (data.containsKey('pending_post_id')) {
      context.handle(
        _pendingPostIdMeta,
        pendingPostId.isAcceptableOrUnknown(
          data['pending_post_id']!,
          _pendingPostIdMeta,
        ),
      );
    }
    if (data.containsKey('send_state')) {
      context.handle(
        _sendStateMeta,
        sendState.isAcceptableOrUnknown(data['send_state']!, _sendStateMeta),
      );
    }
    if (data.containsKey('props_json')) {
      context.handle(
        _propsJsonMeta,
        propsJson.isAcceptableOrUnknown(data['props_json']!, _propsJsonMeta),
      );
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
        _metadataJsonMeta,
        metadataJson.isAcceptableOrUnknown(
          data['metadata_json']!,
          _metadataJsonMeta,
        ),
      );
    }
    if (data.containsKey('file_count')) {
      context.handle(
        _fileCountMeta,
        fileCount.isAcceptableOrUnknown(data['file_count']!, _fileCountMeta),
      );
    }
    if (data.containsKey('reaction_count')) {
      context.handle(
        _reactionCountMeta,
        reactionCount.isAcceptableOrUnknown(
          data['reaction_count']!,
          _reactionCountMeta,
        ),
      );
    }
    if (data.containsKey('decode_problem')) {
      context.handle(
        _decodeProblemMeta,
        decodeProblem.isAcceptableOrUnknown(
          data['decode_problem']!,
          _decodeProblemMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PostRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PostRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      channelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}channel_id'],
      )!,
      rootId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}root_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      createAt: $PostsTable.$convertercreateAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}create_at'],
        )!,
      ),
      updateAt: $PostsTable.$converterupdateAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}update_at'],
        ),
      ),
      editAt: $PostsTable.$convertereditAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}edit_at'],
        ),
      ),
      deleteAt: $PostsTable.$converterdeleteAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}delete_at'],
        ),
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      )!,
      isPinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pinned'],
      )!,
      replyCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reply_count'],
      )!,
      lastReplyAt: $PostsTable.$converterlastReplyAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}last_reply_at'],
        ),
      ),
      originalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_id'],
      )!,
      pendingPostId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pending_post_id'],
      )!,
      sendState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}send_state'],
      ),
      propsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}props_json'],
      ),
      metadataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata_json'],
      ),
      fileCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_count'],
      )!,
      reactionCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reaction_count'],
      )!,
      participantIds: $PostsTable.$converterparticipantIdsn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}participant_ids_json'],
        ),
      ),
      decodeProblem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}decode_problem'],
      ),
    );
  }

  @override
  $PostsTable createAlias(String alias) {
    return $PostsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreateAt = const Millis();
  static TypeConverter<DateTime, int> $converterupdateAt = const Millis();
  static TypeConverter<DateTime?, int?> $converterupdateAtn =
      NullAwareTypeConverter.wrap($converterupdateAt);
  static TypeConverter<DateTime, int> $convertereditAt = const Millis();
  static TypeConverter<DateTime?, int?> $convertereditAtn =
      NullAwareTypeConverter.wrap($convertereditAt);
  static TypeConverter<DateTime, int> $converterdeleteAt = const Millis();
  static TypeConverter<DateTime?, int?> $converterdeleteAtn =
      NullAwareTypeConverter.wrap($converterdeleteAt);
  static TypeConverter<DateTime, int> $converterlastReplyAt = const Millis();
  static TypeConverter<DateTime?, int?> $converterlastReplyAtn =
      NullAwareTypeConverter.wrap($converterlastReplyAt);
  static TypeConverter<List<String>, String> $converterparticipantIds =
      const StringListColumn();
  static TypeConverter<List<String>?, String?> $converterparticipantIdsn =
      NullAwareTypeConverter.wrap($converterparticipantIds);
}

class PostRow extends DataClass implements Insertable<PostRow> {
  final String id;
  final String channelId;
  final String rootId;
  final String userId;
  final DateTime createAt;
  final DateTime? updateAt;
  final DateTime? editAt;
  final DateTime? deleteAt;
  final String type;
  final String message;
  final bool isPinned;
  final int replyCount;
  final DateTime? lastReplyAt;
  final String originalId;
  final String pendingPostId;

  /// Null once the server has it; `pending` or `failed` for our own unsent
  /// posts, which are ordinary rows so the list has one source.
  final String? sendState;
  final String? propsJson;
  final String? metadataJson;
  final int fileCount;
  final int reactionCount;

  /// Who replied to a root post, as a JSON list of user ids, when the
  /// server said (collapsed reply threads).
  final List<String>? participantIds;

  /// Set when the server's copy couldn't be read or stored: what went
  /// wrong, as an error type. The row keeps its place but no content, and
  /// the next fetch that reads it clears this.
  final String? decodeProblem;
  const PostRow({
    required this.id,
    required this.channelId,
    required this.rootId,
    required this.userId,
    required this.createAt,
    this.updateAt,
    this.editAt,
    this.deleteAt,
    required this.type,
    required this.message,
    required this.isPinned,
    required this.replyCount,
    this.lastReplyAt,
    required this.originalId,
    required this.pendingPostId,
    this.sendState,
    this.propsJson,
    this.metadataJson,
    required this.fileCount,
    required this.reactionCount,
    this.participantIds,
    this.decodeProblem,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['channel_id'] = Variable<String>(channelId);
    map['root_id'] = Variable<String>(rootId);
    map['user_id'] = Variable<String>(userId);
    {
      map['create_at'] = Variable<int>(
        $PostsTable.$convertercreateAt.toSql(createAt),
      );
    }
    if (!nullToAbsent || updateAt != null) {
      map['update_at'] = Variable<int>(
        $PostsTable.$converterupdateAtn.toSql(updateAt),
      );
    }
    if (!nullToAbsent || editAt != null) {
      map['edit_at'] = Variable<int>(
        $PostsTable.$convertereditAtn.toSql(editAt),
      );
    }
    if (!nullToAbsent || deleteAt != null) {
      map['delete_at'] = Variable<int>(
        $PostsTable.$converterdeleteAtn.toSql(deleteAt),
      );
    }
    map['type'] = Variable<String>(type);
    map['message'] = Variable<String>(message);
    map['is_pinned'] = Variable<bool>(isPinned);
    map['reply_count'] = Variable<int>(replyCount);
    if (!nullToAbsent || lastReplyAt != null) {
      map['last_reply_at'] = Variable<int>(
        $PostsTable.$converterlastReplyAtn.toSql(lastReplyAt),
      );
    }
    map['original_id'] = Variable<String>(originalId);
    map['pending_post_id'] = Variable<String>(pendingPostId);
    if (!nullToAbsent || sendState != null) {
      map['send_state'] = Variable<String>(sendState);
    }
    if (!nullToAbsent || propsJson != null) {
      map['props_json'] = Variable<String>(propsJson);
    }
    if (!nullToAbsent || metadataJson != null) {
      map['metadata_json'] = Variable<String>(metadataJson);
    }
    map['file_count'] = Variable<int>(fileCount);
    map['reaction_count'] = Variable<int>(reactionCount);
    if (!nullToAbsent || participantIds != null) {
      map['participant_ids_json'] = Variable<String>(
        $PostsTable.$converterparticipantIdsn.toSql(participantIds),
      );
    }
    if (!nullToAbsent || decodeProblem != null) {
      map['decode_problem'] = Variable<String>(decodeProblem);
    }
    return map;
  }

  PostsCompanion toCompanion(bool nullToAbsent) {
    return PostsCompanion(
      id: Value(id),
      channelId: Value(channelId),
      rootId: Value(rootId),
      userId: Value(userId),
      createAt: Value(createAt),
      updateAt: updateAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updateAt),
      editAt: editAt == null && nullToAbsent
          ? const Value.absent()
          : Value(editAt),
      deleteAt: deleteAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deleteAt),
      type: Value(type),
      message: Value(message),
      isPinned: Value(isPinned),
      replyCount: Value(replyCount),
      lastReplyAt: lastReplyAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReplyAt),
      originalId: Value(originalId),
      pendingPostId: Value(pendingPostId),
      sendState: sendState == null && nullToAbsent
          ? const Value.absent()
          : Value(sendState),
      propsJson: propsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(propsJson),
      metadataJson: metadataJson == null && nullToAbsent
          ? const Value.absent()
          : Value(metadataJson),
      fileCount: Value(fileCount),
      reactionCount: Value(reactionCount),
      participantIds: participantIds == null && nullToAbsent
          ? const Value.absent()
          : Value(participantIds),
      decodeProblem: decodeProblem == null && nullToAbsent
          ? const Value.absent()
          : Value(decodeProblem),
    );
  }

  factory PostRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PostRow(
      id: serializer.fromJson<String>(json['id']),
      channelId: serializer.fromJson<String>(json['channelId']),
      rootId: serializer.fromJson<String>(json['rootId']),
      userId: serializer.fromJson<String>(json['userId']),
      createAt: serializer.fromJson<DateTime>(json['createAt']),
      updateAt: serializer.fromJson<DateTime?>(json['updateAt']),
      editAt: serializer.fromJson<DateTime?>(json['editAt']),
      deleteAt: serializer.fromJson<DateTime?>(json['deleteAt']),
      type: serializer.fromJson<String>(json['type']),
      message: serializer.fromJson<String>(json['message']),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
      replyCount: serializer.fromJson<int>(json['replyCount']),
      lastReplyAt: serializer.fromJson<DateTime?>(json['lastReplyAt']),
      originalId: serializer.fromJson<String>(json['originalId']),
      pendingPostId: serializer.fromJson<String>(json['pendingPostId']),
      sendState: serializer.fromJson<String?>(json['sendState']),
      propsJson: serializer.fromJson<String?>(json['propsJson']),
      metadataJson: serializer.fromJson<String?>(json['metadataJson']),
      fileCount: serializer.fromJson<int>(json['fileCount']),
      reactionCount: serializer.fromJson<int>(json['reactionCount']),
      participantIds: serializer.fromJson<List<String>?>(
        json['participantIds'],
      ),
      decodeProblem: serializer.fromJson<String?>(json['decodeProblem']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'channelId': serializer.toJson<String>(channelId),
      'rootId': serializer.toJson<String>(rootId),
      'userId': serializer.toJson<String>(userId),
      'createAt': serializer.toJson<DateTime>(createAt),
      'updateAt': serializer.toJson<DateTime?>(updateAt),
      'editAt': serializer.toJson<DateTime?>(editAt),
      'deleteAt': serializer.toJson<DateTime?>(deleteAt),
      'type': serializer.toJson<String>(type),
      'message': serializer.toJson<String>(message),
      'isPinned': serializer.toJson<bool>(isPinned),
      'replyCount': serializer.toJson<int>(replyCount),
      'lastReplyAt': serializer.toJson<DateTime?>(lastReplyAt),
      'originalId': serializer.toJson<String>(originalId),
      'pendingPostId': serializer.toJson<String>(pendingPostId),
      'sendState': serializer.toJson<String?>(sendState),
      'propsJson': serializer.toJson<String?>(propsJson),
      'metadataJson': serializer.toJson<String?>(metadataJson),
      'fileCount': serializer.toJson<int>(fileCount),
      'reactionCount': serializer.toJson<int>(reactionCount),
      'participantIds': serializer.toJson<List<String>?>(participantIds),
      'decodeProblem': serializer.toJson<String?>(decodeProblem),
    };
  }

  PostRow copyWith({
    String? id,
    String? channelId,
    String? rootId,
    String? userId,
    DateTime? createAt,
    Value<DateTime?> updateAt = const Value.absent(),
    Value<DateTime?> editAt = const Value.absent(),
    Value<DateTime?> deleteAt = const Value.absent(),
    String? type,
    String? message,
    bool? isPinned,
    int? replyCount,
    Value<DateTime?> lastReplyAt = const Value.absent(),
    String? originalId,
    String? pendingPostId,
    Value<String?> sendState = const Value.absent(),
    Value<String?> propsJson = const Value.absent(),
    Value<String?> metadataJson = const Value.absent(),
    int? fileCount,
    int? reactionCount,
    Value<List<String>?> participantIds = const Value.absent(),
    Value<String?> decodeProblem = const Value.absent(),
  }) => PostRow(
    id: id ?? this.id,
    channelId: channelId ?? this.channelId,
    rootId: rootId ?? this.rootId,
    userId: userId ?? this.userId,
    createAt: createAt ?? this.createAt,
    updateAt: updateAt.present ? updateAt.value : this.updateAt,
    editAt: editAt.present ? editAt.value : this.editAt,
    deleteAt: deleteAt.present ? deleteAt.value : this.deleteAt,
    type: type ?? this.type,
    message: message ?? this.message,
    isPinned: isPinned ?? this.isPinned,
    replyCount: replyCount ?? this.replyCount,
    lastReplyAt: lastReplyAt.present ? lastReplyAt.value : this.lastReplyAt,
    originalId: originalId ?? this.originalId,
    pendingPostId: pendingPostId ?? this.pendingPostId,
    sendState: sendState.present ? sendState.value : this.sendState,
    propsJson: propsJson.present ? propsJson.value : this.propsJson,
    metadataJson: metadataJson.present ? metadataJson.value : this.metadataJson,
    fileCount: fileCount ?? this.fileCount,
    reactionCount: reactionCount ?? this.reactionCount,
    participantIds: participantIds.present
        ? participantIds.value
        : this.participantIds,
    decodeProblem: decodeProblem.present
        ? decodeProblem.value
        : this.decodeProblem,
  );
  PostRow copyWithCompanion(PostsCompanion data) {
    return PostRow(
      id: data.id.present ? data.id.value : this.id,
      channelId: data.channelId.present ? data.channelId.value : this.channelId,
      rootId: data.rootId.present ? data.rootId.value : this.rootId,
      userId: data.userId.present ? data.userId.value : this.userId,
      createAt: data.createAt.present ? data.createAt.value : this.createAt,
      updateAt: data.updateAt.present ? data.updateAt.value : this.updateAt,
      editAt: data.editAt.present ? data.editAt.value : this.editAt,
      deleteAt: data.deleteAt.present ? data.deleteAt.value : this.deleteAt,
      type: data.type.present ? data.type.value : this.type,
      message: data.message.present ? data.message.value : this.message,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
      replyCount: data.replyCount.present
          ? data.replyCount.value
          : this.replyCount,
      lastReplyAt: data.lastReplyAt.present
          ? data.lastReplyAt.value
          : this.lastReplyAt,
      originalId: data.originalId.present
          ? data.originalId.value
          : this.originalId,
      pendingPostId: data.pendingPostId.present
          ? data.pendingPostId.value
          : this.pendingPostId,
      sendState: data.sendState.present ? data.sendState.value : this.sendState,
      propsJson: data.propsJson.present ? data.propsJson.value : this.propsJson,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
      fileCount: data.fileCount.present ? data.fileCount.value : this.fileCount,
      reactionCount: data.reactionCount.present
          ? data.reactionCount.value
          : this.reactionCount,
      participantIds: data.participantIds.present
          ? data.participantIds.value
          : this.participantIds,
      decodeProblem: data.decodeProblem.present
          ? data.decodeProblem.value
          : this.decodeProblem,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PostRow(')
          ..write('id: $id, ')
          ..write('channelId: $channelId, ')
          ..write('rootId: $rootId, ')
          ..write('userId: $userId, ')
          ..write('createAt: $createAt, ')
          ..write('updateAt: $updateAt, ')
          ..write('editAt: $editAt, ')
          ..write('deleteAt: $deleteAt, ')
          ..write('type: $type, ')
          ..write('message: $message, ')
          ..write('isPinned: $isPinned, ')
          ..write('replyCount: $replyCount, ')
          ..write('lastReplyAt: $lastReplyAt, ')
          ..write('originalId: $originalId, ')
          ..write('pendingPostId: $pendingPostId, ')
          ..write('sendState: $sendState, ')
          ..write('propsJson: $propsJson, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('fileCount: $fileCount, ')
          ..write('reactionCount: $reactionCount, ')
          ..write('participantIds: $participantIds, ')
          ..write('decodeProblem: $decodeProblem')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    channelId,
    rootId,
    userId,
    createAt,
    updateAt,
    editAt,
    deleteAt,
    type,
    message,
    isPinned,
    replyCount,
    lastReplyAt,
    originalId,
    pendingPostId,
    sendState,
    propsJson,
    metadataJson,
    fileCount,
    reactionCount,
    participantIds,
    decodeProblem,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PostRow &&
          other.id == this.id &&
          other.channelId == this.channelId &&
          other.rootId == this.rootId &&
          other.userId == this.userId &&
          other.createAt == this.createAt &&
          other.updateAt == this.updateAt &&
          other.editAt == this.editAt &&
          other.deleteAt == this.deleteAt &&
          other.type == this.type &&
          other.message == this.message &&
          other.isPinned == this.isPinned &&
          other.replyCount == this.replyCount &&
          other.lastReplyAt == this.lastReplyAt &&
          other.originalId == this.originalId &&
          other.pendingPostId == this.pendingPostId &&
          other.sendState == this.sendState &&
          other.propsJson == this.propsJson &&
          other.metadataJson == this.metadataJson &&
          other.fileCount == this.fileCount &&
          other.reactionCount == this.reactionCount &&
          other.participantIds == this.participantIds &&
          other.decodeProblem == this.decodeProblem);
}

class PostsCompanion extends UpdateCompanion<PostRow> {
  final Value<String> id;
  final Value<String> channelId;
  final Value<String> rootId;
  final Value<String> userId;
  final Value<DateTime> createAt;
  final Value<DateTime?> updateAt;
  final Value<DateTime?> editAt;
  final Value<DateTime?> deleteAt;
  final Value<String> type;
  final Value<String> message;
  final Value<bool> isPinned;
  final Value<int> replyCount;
  final Value<DateTime?> lastReplyAt;
  final Value<String> originalId;
  final Value<String> pendingPostId;
  final Value<String?> sendState;
  final Value<String?> propsJson;
  final Value<String?> metadataJson;
  final Value<int> fileCount;
  final Value<int> reactionCount;
  final Value<List<String>?> participantIds;
  final Value<String?> decodeProblem;
  final Value<int> rowid;
  const PostsCompanion({
    this.id = const Value.absent(),
    this.channelId = const Value.absent(),
    this.rootId = const Value.absent(),
    this.userId = const Value.absent(),
    this.createAt = const Value.absent(),
    this.updateAt = const Value.absent(),
    this.editAt = const Value.absent(),
    this.deleteAt = const Value.absent(),
    this.type = const Value.absent(),
    this.message = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.replyCount = const Value.absent(),
    this.lastReplyAt = const Value.absent(),
    this.originalId = const Value.absent(),
    this.pendingPostId = const Value.absent(),
    this.sendState = const Value.absent(),
    this.propsJson = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.fileCount = const Value.absent(),
    this.reactionCount = const Value.absent(),
    this.participantIds = const Value.absent(),
    this.decodeProblem = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PostsCompanion.insert({
    required String id,
    required String channelId,
    this.rootId = const Value.absent(),
    required String userId,
    required DateTime createAt,
    this.updateAt = const Value.absent(),
    this.editAt = const Value.absent(),
    this.deleteAt = const Value.absent(),
    this.type = const Value.absent(),
    this.message = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.replyCount = const Value.absent(),
    this.lastReplyAt = const Value.absent(),
    this.originalId = const Value.absent(),
    this.pendingPostId = const Value.absent(),
    this.sendState = const Value.absent(),
    this.propsJson = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.fileCount = const Value.absent(),
    this.reactionCount = const Value.absent(),
    this.participantIds = const Value.absent(),
    this.decodeProblem = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       channelId = Value(channelId),
       userId = Value(userId),
       createAt = Value(createAt);
  static Insertable<PostRow> custom({
    Expression<String>? id,
    Expression<String>? channelId,
    Expression<String>? rootId,
    Expression<String>? userId,
    Expression<int>? createAt,
    Expression<int>? updateAt,
    Expression<int>? editAt,
    Expression<int>? deleteAt,
    Expression<String>? type,
    Expression<String>? message,
    Expression<bool>? isPinned,
    Expression<int>? replyCount,
    Expression<int>? lastReplyAt,
    Expression<String>? originalId,
    Expression<String>? pendingPostId,
    Expression<String>? sendState,
    Expression<String>? propsJson,
    Expression<String>? metadataJson,
    Expression<int>? fileCount,
    Expression<int>? reactionCount,
    Expression<String>? participantIds,
    Expression<String>? decodeProblem,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (channelId != null) 'channel_id': channelId,
      if (rootId != null) 'root_id': rootId,
      if (userId != null) 'user_id': userId,
      if (createAt != null) 'create_at': createAt,
      if (updateAt != null) 'update_at': updateAt,
      if (editAt != null) 'edit_at': editAt,
      if (deleteAt != null) 'delete_at': deleteAt,
      if (type != null) 'type': type,
      if (message != null) 'message': message,
      if (isPinned != null) 'is_pinned': isPinned,
      if (replyCount != null) 'reply_count': replyCount,
      if (lastReplyAt != null) 'last_reply_at': lastReplyAt,
      if (originalId != null) 'original_id': originalId,
      if (pendingPostId != null) 'pending_post_id': pendingPostId,
      if (sendState != null) 'send_state': sendState,
      if (propsJson != null) 'props_json': propsJson,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (fileCount != null) 'file_count': fileCount,
      if (reactionCount != null) 'reaction_count': reactionCount,
      if (participantIds != null) 'participant_ids_json': participantIds,
      if (decodeProblem != null) 'decode_problem': decodeProblem,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PostsCompanion copyWith({
    Value<String>? id,
    Value<String>? channelId,
    Value<String>? rootId,
    Value<String>? userId,
    Value<DateTime>? createAt,
    Value<DateTime?>? updateAt,
    Value<DateTime?>? editAt,
    Value<DateTime?>? deleteAt,
    Value<String>? type,
    Value<String>? message,
    Value<bool>? isPinned,
    Value<int>? replyCount,
    Value<DateTime?>? lastReplyAt,
    Value<String>? originalId,
    Value<String>? pendingPostId,
    Value<String?>? sendState,
    Value<String?>? propsJson,
    Value<String?>? metadataJson,
    Value<int>? fileCount,
    Value<int>? reactionCount,
    Value<List<String>?>? participantIds,
    Value<String?>? decodeProblem,
    Value<int>? rowid,
  }) {
    return PostsCompanion(
      id: id ?? this.id,
      channelId: channelId ?? this.channelId,
      rootId: rootId ?? this.rootId,
      userId: userId ?? this.userId,
      createAt: createAt ?? this.createAt,
      updateAt: updateAt ?? this.updateAt,
      editAt: editAt ?? this.editAt,
      deleteAt: deleteAt ?? this.deleteAt,
      type: type ?? this.type,
      message: message ?? this.message,
      isPinned: isPinned ?? this.isPinned,
      replyCount: replyCount ?? this.replyCount,
      lastReplyAt: lastReplyAt ?? this.lastReplyAt,
      originalId: originalId ?? this.originalId,
      pendingPostId: pendingPostId ?? this.pendingPostId,
      sendState: sendState ?? this.sendState,
      propsJson: propsJson ?? this.propsJson,
      metadataJson: metadataJson ?? this.metadataJson,
      fileCount: fileCount ?? this.fileCount,
      reactionCount: reactionCount ?? this.reactionCount,
      participantIds: participantIds ?? this.participantIds,
      decodeProblem: decodeProblem ?? this.decodeProblem,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (channelId.present) {
      map['channel_id'] = Variable<String>(channelId.value);
    }
    if (rootId.present) {
      map['root_id'] = Variable<String>(rootId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (createAt.present) {
      map['create_at'] = Variable<int>(
        $PostsTable.$convertercreateAt.toSql(createAt.value),
      );
    }
    if (updateAt.present) {
      map['update_at'] = Variable<int>(
        $PostsTable.$converterupdateAtn.toSql(updateAt.value),
      );
    }
    if (editAt.present) {
      map['edit_at'] = Variable<int>(
        $PostsTable.$convertereditAtn.toSql(editAt.value),
      );
    }
    if (deleteAt.present) {
      map['delete_at'] = Variable<int>(
        $PostsTable.$converterdeleteAtn.toSql(deleteAt.value),
      );
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<bool>(isPinned.value);
    }
    if (replyCount.present) {
      map['reply_count'] = Variable<int>(replyCount.value);
    }
    if (lastReplyAt.present) {
      map['last_reply_at'] = Variable<int>(
        $PostsTable.$converterlastReplyAtn.toSql(lastReplyAt.value),
      );
    }
    if (originalId.present) {
      map['original_id'] = Variable<String>(originalId.value);
    }
    if (pendingPostId.present) {
      map['pending_post_id'] = Variable<String>(pendingPostId.value);
    }
    if (sendState.present) {
      map['send_state'] = Variable<String>(sendState.value);
    }
    if (propsJson.present) {
      map['props_json'] = Variable<String>(propsJson.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (fileCount.present) {
      map['file_count'] = Variable<int>(fileCount.value);
    }
    if (reactionCount.present) {
      map['reaction_count'] = Variable<int>(reactionCount.value);
    }
    if (participantIds.present) {
      map['participant_ids_json'] = Variable<String>(
        $PostsTable.$converterparticipantIdsn.toSql(participantIds.value),
      );
    }
    if (decodeProblem.present) {
      map['decode_problem'] = Variable<String>(decodeProblem.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PostsCompanion(')
          ..write('id: $id, ')
          ..write('channelId: $channelId, ')
          ..write('rootId: $rootId, ')
          ..write('userId: $userId, ')
          ..write('createAt: $createAt, ')
          ..write('updateAt: $updateAt, ')
          ..write('editAt: $editAt, ')
          ..write('deleteAt: $deleteAt, ')
          ..write('type: $type, ')
          ..write('message: $message, ')
          ..write('isPinned: $isPinned, ')
          ..write('replyCount: $replyCount, ')
          ..write('lastReplyAt: $lastReplyAt, ')
          ..write('originalId: $originalId, ')
          ..write('pendingPostId: $pendingPostId, ')
          ..write('sendState: $sendState, ')
          ..write('propsJson: $propsJson, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('fileCount: $fileCount, ')
          ..write('reactionCount: $reactionCount, ')
          ..write('participantIds: $participantIds, ')
          ..write('decodeProblem: $decodeProblem, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PostRangesTable extends PostRanges
    with TableInfo<$PostRangesTable, PostRangeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PostRangesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
    'scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scopeIdMeta = const VerificationMeta(
    'scopeId',
  );
  @override
  late final GeneratedColumn<String> scopeId = GeneratedColumn<String>(
    'scope_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> earliest =
      GeneratedColumn<int>(
        'earliest',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($PostRangesTable.$converterearliest);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> latest =
      GeneratedColumn<int>(
        'latest',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($PostRangesTable.$converterlatest);
  static const VerificationMeta _reachesStartMeta = const VerificationMeta(
    'reachesStart',
  );
  @override
  late final GeneratedColumn<bool> reachesStart = GeneratedColumn<bool>(
    'reaches_start',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reaches_start" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    scope,
    scopeId,
    earliest,
    latest,
    reachesStart,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'post_ranges';
  @override
  VerificationContext validateIntegrity(
    Insertable<PostRangeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('scope')) {
      context.handle(
        _scopeMeta,
        scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeMeta);
    }
    if (data.containsKey('scope_id')) {
      context.handle(
        _scopeIdMeta,
        scopeId.isAcceptableOrUnknown(data['scope_id']!, _scopeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeIdMeta);
    }
    if (data.containsKey('reaches_start')) {
      context.handle(
        _reachesStartMeta,
        reachesStart.isAcceptableOrUnknown(
          data['reaches_start']!,
          _reachesStartMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PostRangeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PostRangeRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      scope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope'],
      )!,
      scopeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope_id'],
      )!,
      earliest: $PostRangesTable.$converterearliest.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}earliest'],
        )!,
      ),
      latest: $PostRangesTable.$converterlatest.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}latest'],
        )!,
      ),
      reachesStart: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reaches_start'],
      )!,
    );
  }

  @override
  $PostRangesTable createAlias(String alias) {
    return $PostRangesTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $converterearliest = const Millis();
  static TypeConverter<DateTime, int> $converterlatest = const Millis();
}

class PostRangeRow extends DataClass implements Insertable<PostRangeRow> {
  final int id;

  /// `channel` or `thread`.
  final String scope;
  final String scopeId;
  final DateTime earliest;
  final DateTime latest;

  /// No older posts exist (or the server won't serve them).
  final bool reachesStart;
  const PostRangeRow({
    required this.id,
    required this.scope,
    required this.scopeId,
    required this.earliest,
    required this.latest,
    required this.reachesStart,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['scope'] = Variable<String>(scope);
    map['scope_id'] = Variable<String>(scopeId);
    {
      map['earliest'] = Variable<int>(
        $PostRangesTable.$converterearliest.toSql(earliest),
      );
    }
    {
      map['latest'] = Variable<int>(
        $PostRangesTable.$converterlatest.toSql(latest),
      );
    }
    map['reaches_start'] = Variable<bool>(reachesStart);
    return map;
  }

  PostRangesCompanion toCompanion(bool nullToAbsent) {
    return PostRangesCompanion(
      id: Value(id),
      scope: Value(scope),
      scopeId: Value(scopeId),
      earliest: Value(earliest),
      latest: Value(latest),
      reachesStart: Value(reachesStart),
    );
  }

  factory PostRangeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PostRangeRow(
      id: serializer.fromJson<int>(json['id']),
      scope: serializer.fromJson<String>(json['scope']),
      scopeId: serializer.fromJson<String>(json['scopeId']),
      earliest: serializer.fromJson<DateTime>(json['earliest']),
      latest: serializer.fromJson<DateTime>(json['latest']),
      reachesStart: serializer.fromJson<bool>(json['reachesStart']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'scope': serializer.toJson<String>(scope),
      'scopeId': serializer.toJson<String>(scopeId),
      'earliest': serializer.toJson<DateTime>(earliest),
      'latest': serializer.toJson<DateTime>(latest),
      'reachesStart': serializer.toJson<bool>(reachesStart),
    };
  }

  PostRangeRow copyWith({
    int? id,
    String? scope,
    String? scopeId,
    DateTime? earliest,
    DateTime? latest,
    bool? reachesStart,
  }) => PostRangeRow(
    id: id ?? this.id,
    scope: scope ?? this.scope,
    scopeId: scopeId ?? this.scopeId,
    earliest: earliest ?? this.earliest,
    latest: latest ?? this.latest,
    reachesStart: reachesStart ?? this.reachesStart,
  );
  PostRangeRow copyWithCompanion(PostRangesCompanion data) {
    return PostRangeRow(
      id: data.id.present ? data.id.value : this.id,
      scope: data.scope.present ? data.scope.value : this.scope,
      scopeId: data.scopeId.present ? data.scopeId.value : this.scopeId,
      earliest: data.earliest.present ? data.earliest.value : this.earliest,
      latest: data.latest.present ? data.latest.value : this.latest,
      reachesStart: data.reachesStart.present
          ? data.reachesStart.value
          : this.reachesStart,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PostRangeRow(')
          ..write('id: $id, ')
          ..write('scope: $scope, ')
          ..write('scopeId: $scopeId, ')
          ..write('earliest: $earliest, ')
          ..write('latest: $latest, ')
          ..write('reachesStart: $reachesStart')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, scope, scopeId, earliest, latest, reachesStart);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PostRangeRow &&
          other.id == this.id &&
          other.scope == this.scope &&
          other.scopeId == this.scopeId &&
          other.earliest == this.earliest &&
          other.latest == this.latest &&
          other.reachesStart == this.reachesStart);
}

class PostRangesCompanion extends UpdateCompanion<PostRangeRow> {
  final Value<int> id;
  final Value<String> scope;
  final Value<String> scopeId;
  final Value<DateTime> earliest;
  final Value<DateTime> latest;
  final Value<bool> reachesStart;
  const PostRangesCompanion({
    this.id = const Value.absent(),
    this.scope = const Value.absent(),
    this.scopeId = const Value.absent(),
    this.earliest = const Value.absent(),
    this.latest = const Value.absent(),
    this.reachesStart = const Value.absent(),
  });
  PostRangesCompanion.insert({
    this.id = const Value.absent(),
    required String scope,
    required String scopeId,
    required DateTime earliest,
    required DateTime latest,
    this.reachesStart = const Value.absent(),
  }) : scope = Value(scope),
       scopeId = Value(scopeId),
       earliest = Value(earliest),
       latest = Value(latest);
  static Insertable<PostRangeRow> custom({
    Expression<int>? id,
    Expression<String>? scope,
    Expression<String>? scopeId,
    Expression<int>? earliest,
    Expression<int>? latest,
    Expression<bool>? reachesStart,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scope != null) 'scope': scope,
      if (scopeId != null) 'scope_id': scopeId,
      if (earliest != null) 'earliest': earliest,
      if (latest != null) 'latest': latest,
      if (reachesStart != null) 'reaches_start': reachesStart,
    });
  }

  PostRangesCompanion copyWith({
    Value<int>? id,
    Value<String>? scope,
    Value<String>? scopeId,
    Value<DateTime>? earliest,
    Value<DateTime>? latest,
    Value<bool>? reachesStart,
  }) {
    return PostRangesCompanion(
      id: id ?? this.id,
      scope: scope ?? this.scope,
      scopeId: scopeId ?? this.scopeId,
      earliest: earliest ?? this.earliest,
      latest: latest ?? this.latest,
      reachesStart: reachesStart ?? this.reachesStart,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (scopeId.present) {
      map['scope_id'] = Variable<String>(scopeId.value);
    }
    if (earliest.present) {
      map['earliest'] = Variable<int>(
        $PostRangesTable.$converterearliest.toSql(earliest.value),
      );
    }
    if (latest.present) {
      map['latest'] = Variable<int>(
        $PostRangesTable.$converterlatest.toSql(latest.value),
      );
    }
    if (reachesStart.present) {
      map['reaches_start'] = Variable<bool>(reachesStart.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PostRangesCompanion(')
          ..write('id: $id, ')
          ..write('scope: $scope, ')
          ..write('scopeId: $scopeId, ')
          ..write('earliest: $earliest, ')
          ..write('latest: $latest, ')
          ..write('reachesStart: $reachesStart')
          ..write(')'))
        .toString();
  }
}

class $ReactionsTable extends Reactions
    with TableInfo<$ReactionsTable, ReactionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _postIdMeta = const VerificationMeta('postId');
  @override
  late final GeneratedColumn<String> postId = GeneratedColumn<String>(
    'post_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emojiNameMeta = const VerificationMeta(
    'emojiName',
  );
  @override
  late final GeneratedColumn<String> emojiName = GeneratedColumn<String>(
    'emoji_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> createAt =
      GeneratedColumn<int>(
        'create_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($ReactionsTable.$convertercreateAtn);
  @override
  List<GeneratedColumn> get $columns => [postId, userId, emojiName, createAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReactionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('post_id')) {
      context.handle(
        _postIdMeta,
        postId.isAcceptableOrUnknown(data['post_id']!, _postIdMeta),
      );
    } else if (isInserting) {
      context.missing(_postIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('emoji_name')) {
      context.handle(
        _emojiNameMeta,
        emojiName.isAcceptableOrUnknown(data['emoji_name']!, _emojiNameMeta),
      );
    } else if (isInserting) {
      context.missing(_emojiNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {postId, userId, emojiName};
  @override
  ReactionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReactionRow(
      postId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}post_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      emojiName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji_name'],
      )!,
      createAt: $ReactionsTable.$convertercreateAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}create_at'],
        ),
      ),
    );
  }

  @override
  $ReactionsTable createAlias(String alias) {
    return $ReactionsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreateAt = const Millis();
  static TypeConverter<DateTime?, int?> $convertercreateAtn =
      NullAwareTypeConverter.wrap($convertercreateAt);
}

class ReactionRow extends DataClass implements Insertable<ReactionRow> {
  final String postId;
  final String userId;
  final String emojiName;
  final DateTime? createAt;
  const ReactionRow({
    required this.postId,
    required this.userId,
    required this.emojiName,
    this.createAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['post_id'] = Variable<String>(postId);
    map['user_id'] = Variable<String>(userId);
    map['emoji_name'] = Variable<String>(emojiName);
    if (!nullToAbsent || createAt != null) {
      map['create_at'] = Variable<int>(
        $ReactionsTable.$convertercreateAtn.toSql(createAt),
      );
    }
    return map;
  }

  ReactionsCompanion toCompanion(bool nullToAbsent) {
    return ReactionsCompanion(
      postId: Value(postId),
      userId: Value(userId),
      emojiName: Value(emojiName),
      createAt: createAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createAt),
    );
  }

  factory ReactionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReactionRow(
      postId: serializer.fromJson<String>(json['postId']),
      userId: serializer.fromJson<String>(json['userId']),
      emojiName: serializer.fromJson<String>(json['emojiName']),
      createAt: serializer.fromJson<DateTime?>(json['createAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'postId': serializer.toJson<String>(postId),
      'userId': serializer.toJson<String>(userId),
      'emojiName': serializer.toJson<String>(emojiName),
      'createAt': serializer.toJson<DateTime?>(createAt),
    };
  }

  ReactionRow copyWith({
    String? postId,
    String? userId,
    String? emojiName,
    Value<DateTime?> createAt = const Value.absent(),
  }) => ReactionRow(
    postId: postId ?? this.postId,
    userId: userId ?? this.userId,
    emojiName: emojiName ?? this.emojiName,
    createAt: createAt.present ? createAt.value : this.createAt,
  );
  ReactionRow copyWithCompanion(ReactionsCompanion data) {
    return ReactionRow(
      postId: data.postId.present ? data.postId.value : this.postId,
      userId: data.userId.present ? data.userId.value : this.userId,
      emojiName: data.emojiName.present ? data.emojiName.value : this.emojiName,
      createAt: data.createAt.present ? data.createAt.value : this.createAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReactionRow(')
          ..write('postId: $postId, ')
          ..write('userId: $userId, ')
          ..write('emojiName: $emojiName, ')
          ..write('createAt: $createAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(postId, userId, emojiName, createAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReactionRow &&
          other.postId == this.postId &&
          other.userId == this.userId &&
          other.emojiName == this.emojiName &&
          other.createAt == this.createAt);
}

class ReactionsCompanion extends UpdateCompanion<ReactionRow> {
  final Value<String> postId;
  final Value<String> userId;
  final Value<String> emojiName;
  final Value<DateTime?> createAt;
  final Value<int> rowid;
  const ReactionsCompanion({
    this.postId = const Value.absent(),
    this.userId = const Value.absent(),
    this.emojiName = const Value.absent(),
    this.createAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReactionsCompanion.insert({
    required String postId,
    required String userId,
    required String emojiName,
    this.createAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : postId = Value(postId),
       userId = Value(userId),
       emojiName = Value(emojiName);
  static Insertable<ReactionRow> custom({
    Expression<String>? postId,
    Expression<String>? userId,
    Expression<String>? emojiName,
    Expression<int>? createAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (postId != null) 'post_id': postId,
      if (userId != null) 'user_id': userId,
      if (emojiName != null) 'emoji_name': emojiName,
      if (createAt != null) 'create_at': createAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReactionsCompanion copyWith({
    Value<String>? postId,
    Value<String>? userId,
    Value<String>? emojiName,
    Value<DateTime?>? createAt,
    Value<int>? rowid,
  }) {
    return ReactionsCompanion(
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      emojiName: emojiName ?? this.emojiName,
      createAt: createAt ?? this.createAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (postId.present) {
      map['post_id'] = Variable<String>(postId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (emojiName.present) {
      map['emoji_name'] = Variable<String>(emojiName.value);
    }
    if (createAt.present) {
      map['create_at'] = Variable<int>(
        $ReactionsTable.$convertercreateAtn.toSql(createAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReactionsCompanion(')
          ..write('postId: $postId, ')
          ..write('userId: $userId, ')
          ..write('emojiName: $emojiName, ')
          ..write('createAt: $createAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FilesTable extends Files with TableInfo<$FilesTable, FileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _postIdMeta = const VerificationMeta('postId');
  @override
  late final GeneratedColumn<String> postId = GeneratedColumn<String>(
    'post_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _extensionMeta = const VerificationMeta(
    'extension',
  );
  @override
  late final GeneratedColumn<String> extension = GeneratedColumn<String>(
    'extension',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<int> size = GeneratedColumn<int>(
    'size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hasPreviewMeta = const VerificationMeta(
    'hasPreview',
  );
  @override
  late final GeneratedColumn<bool> hasPreview = GeneratedColumn<bool>(
    'has_preview',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_preview" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _miniPreviewMeta = const VerificationMeta(
    'miniPreview',
  );
  @override
  late final GeneratedColumn<Uint8List> miniPreview =
      GeneratedColumn<Uint8List>(
        'mini_preview',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> deleteAt =
      GeneratedColumn<int>(
        'delete_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($FilesTable.$converterdeleteAtn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    postId,
    name,
    extension,
    mimeType,
    size,
    width,
    height,
    hasPreview,
    miniPreview,
    localPath,
    deleteAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'files';
  @override
  VerificationContext validateIntegrity(
    Insertable<FileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('post_id')) {
      context.handle(
        _postIdMeta,
        postId.isAcceptableOrUnknown(data['post_id']!, _postIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('extension')) {
      context.handle(
        _extensionMeta,
        extension.isAcceptableOrUnknown(data['extension']!, _extensionMeta),
      );
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    }
    if (data.containsKey('size')) {
      context.handle(
        _sizeMeta,
        size.isAcceptableOrUnknown(data['size']!, _sizeMeta),
      );
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('has_preview')) {
      context.handle(
        _hasPreviewMeta,
        hasPreview.isAcceptableOrUnknown(data['has_preview']!, _hasPreviewMeta),
      );
    }
    if (data.containsKey('mini_preview')) {
      context.handle(
        _miniPreviewMeta,
        miniPreview.isAcceptableOrUnknown(
          data['mini_preview']!,
          _miniPreviewMeta,
        ),
      );
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FileRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      postId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}post_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      extension: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extension'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      size: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size'],
      )!,
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      ),
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      ),
      hasPreview: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_preview'],
      )!,
      miniPreview: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}mini_preview'],
      ),
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      ),
      deleteAt: $FilesTable.$converterdeleteAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}delete_at'],
        ),
      ),
    );
  }

  @override
  $FilesTable createAlias(String alias) {
    return $FilesTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $converterdeleteAt = const Millis();
  static TypeConverter<DateTime?, int?> $converterdeleteAtn =
      NullAwareTypeConverter.wrap($converterdeleteAt);
}

class FileRow extends DataClass implements Insertable<FileRow> {
  final String id;
  final String postId;
  final String name;
  final String extension;
  final String mimeType;
  final int size;
  final int? width;
  final int? height;
  final bool hasPreview;
  final Uint8List? miniPreview;
  final String? localPath;
  final DateTime? deleteAt;
  const FileRow({
    required this.id,
    required this.postId,
    required this.name,
    required this.extension,
    required this.mimeType,
    required this.size,
    this.width,
    this.height,
    required this.hasPreview,
    this.miniPreview,
    this.localPath,
    this.deleteAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['post_id'] = Variable<String>(postId);
    map['name'] = Variable<String>(name);
    map['extension'] = Variable<String>(extension);
    map['mime_type'] = Variable<String>(mimeType);
    map['size'] = Variable<int>(size);
    if (!nullToAbsent || width != null) {
      map['width'] = Variable<int>(width);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<int>(height);
    }
    map['has_preview'] = Variable<bool>(hasPreview);
    if (!nullToAbsent || miniPreview != null) {
      map['mini_preview'] = Variable<Uint8List>(miniPreview);
    }
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    if (!nullToAbsent || deleteAt != null) {
      map['delete_at'] = Variable<int>(
        $FilesTable.$converterdeleteAtn.toSql(deleteAt),
      );
    }
    return map;
  }

  FilesCompanion toCompanion(bool nullToAbsent) {
    return FilesCompanion(
      id: Value(id),
      postId: Value(postId),
      name: Value(name),
      extension: Value(extension),
      mimeType: Value(mimeType),
      size: Value(size),
      width: width == null && nullToAbsent
          ? const Value.absent()
          : Value(width),
      height: height == null && nullToAbsent
          ? const Value.absent()
          : Value(height),
      hasPreview: Value(hasPreview),
      miniPreview: miniPreview == null && nullToAbsent
          ? const Value.absent()
          : Value(miniPreview),
      localPath: localPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPath),
      deleteAt: deleteAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deleteAt),
    );
  }

  factory FileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FileRow(
      id: serializer.fromJson<String>(json['id']),
      postId: serializer.fromJson<String>(json['postId']),
      name: serializer.fromJson<String>(json['name']),
      extension: serializer.fromJson<String>(json['extension']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      size: serializer.fromJson<int>(json['size']),
      width: serializer.fromJson<int?>(json['width']),
      height: serializer.fromJson<int?>(json['height']),
      hasPreview: serializer.fromJson<bool>(json['hasPreview']),
      miniPreview: serializer.fromJson<Uint8List?>(json['miniPreview']),
      localPath: serializer.fromJson<String?>(json['localPath']),
      deleteAt: serializer.fromJson<DateTime?>(json['deleteAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'postId': serializer.toJson<String>(postId),
      'name': serializer.toJson<String>(name),
      'extension': serializer.toJson<String>(extension),
      'mimeType': serializer.toJson<String>(mimeType),
      'size': serializer.toJson<int>(size),
      'width': serializer.toJson<int?>(width),
      'height': serializer.toJson<int?>(height),
      'hasPreview': serializer.toJson<bool>(hasPreview),
      'miniPreview': serializer.toJson<Uint8List?>(miniPreview),
      'localPath': serializer.toJson<String?>(localPath),
      'deleteAt': serializer.toJson<DateTime?>(deleteAt),
    };
  }

  FileRow copyWith({
    String? id,
    String? postId,
    String? name,
    String? extension,
    String? mimeType,
    int? size,
    Value<int?> width = const Value.absent(),
    Value<int?> height = const Value.absent(),
    bool? hasPreview,
    Value<Uint8List?> miniPreview = const Value.absent(),
    Value<String?> localPath = const Value.absent(),
    Value<DateTime?> deleteAt = const Value.absent(),
  }) => FileRow(
    id: id ?? this.id,
    postId: postId ?? this.postId,
    name: name ?? this.name,
    extension: extension ?? this.extension,
    mimeType: mimeType ?? this.mimeType,
    size: size ?? this.size,
    width: width.present ? width.value : this.width,
    height: height.present ? height.value : this.height,
    hasPreview: hasPreview ?? this.hasPreview,
    miniPreview: miniPreview.present ? miniPreview.value : this.miniPreview,
    localPath: localPath.present ? localPath.value : this.localPath,
    deleteAt: deleteAt.present ? deleteAt.value : this.deleteAt,
  );
  FileRow copyWithCompanion(FilesCompanion data) {
    return FileRow(
      id: data.id.present ? data.id.value : this.id,
      postId: data.postId.present ? data.postId.value : this.postId,
      name: data.name.present ? data.name.value : this.name,
      extension: data.extension.present ? data.extension.value : this.extension,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      size: data.size.present ? data.size.value : this.size,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      hasPreview: data.hasPreview.present
          ? data.hasPreview.value
          : this.hasPreview,
      miniPreview: data.miniPreview.present
          ? data.miniPreview.value
          : this.miniPreview,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      deleteAt: data.deleteAt.present ? data.deleteAt.value : this.deleteAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FileRow(')
          ..write('id: $id, ')
          ..write('postId: $postId, ')
          ..write('name: $name, ')
          ..write('extension: $extension, ')
          ..write('mimeType: $mimeType, ')
          ..write('size: $size, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('hasPreview: $hasPreview, ')
          ..write('miniPreview: $miniPreview, ')
          ..write('localPath: $localPath, ')
          ..write('deleteAt: $deleteAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    postId,
    name,
    extension,
    mimeType,
    size,
    width,
    height,
    hasPreview,
    $driftBlobEquality.hash(miniPreview),
    localPath,
    deleteAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FileRow &&
          other.id == this.id &&
          other.postId == this.postId &&
          other.name == this.name &&
          other.extension == this.extension &&
          other.mimeType == this.mimeType &&
          other.size == this.size &&
          other.width == this.width &&
          other.height == this.height &&
          other.hasPreview == this.hasPreview &&
          $driftBlobEquality.equals(other.miniPreview, this.miniPreview) &&
          other.localPath == this.localPath &&
          other.deleteAt == this.deleteAt);
}

class FilesCompanion extends UpdateCompanion<FileRow> {
  final Value<String> id;
  final Value<String> postId;
  final Value<String> name;
  final Value<String> extension;
  final Value<String> mimeType;
  final Value<int> size;
  final Value<int?> width;
  final Value<int?> height;
  final Value<bool> hasPreview;
  final Value<Uint8List?> miniPreview;
  final Value<String?> localPath;
  final Value<DateTime?> deleteAt;
  final Value<int> rowid;
  const FilesCompanion({
    this.id = const Value.absent(),
    this.postId = const Value.absent(),
    this.name = const Value.absent(),
    this.extension = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.size = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.hasPreview = const Value.absent(),
    this.miniPreview = const Value.absent(),
    this.localPath = const Value.absent(),
    this.deleteAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FilesCompanion.insert({
    required String id,
    this.postId = const Value.absent(),
    required String name,
    this.extension = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.size = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.hasPreview = const Value.absent(),
    this.miniPreview = const Value.absent(),
    this.localPath = const Value.absent(),
    this.deleteAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<FileRow> custom({
    Expression<String>? id,
    Expression<String>? postId,
    Expression<String>? name,
    Expression<String>? extension,
    Expression<String>? mimeType,
    Expression<int>? size,
    Expression<int>? width,
    Expression<int>? height,
    Expression<bool>? hasPreview,
    Expression<Uint8List>? miniPreview,
    Expression<String>? localPath,
    Expression<int>? deleteAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (postId != null) 'post_id': postId,
      if (name != null) 'name': name,
      if (extension != null) 'extension': extension,
      if (mimeType != null) 'mime_type': mimeType,
      if (size != null) 'size': size,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (hasPreview != null) 'has_preview': hasPreview,
      if (miniPreview != null) 'mini_preview': miniPreview,
      if (localPath != null) 'local_path': localPath,
      if (deleteAt != null) 'delete_at': deleteAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FilesCompanion copyWith({
    Value<String>? id,
    Value<String>? postId,
    Value<String>? name,
    Value<String>? extension,
    Value<String>? mimeType,
    Value<int>? size,
    Value<int?>? width,
    Value<int?>? height,
    Value<bool>? hasPreview,
    Value<Uint8List?>? miniPreview,
    Value<String?>? localPath,
    Value<DateTime?>? deleteAt,
    Value<int>? rowid,
  }) {
    return FilesCompanion(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      name: name ?? this.name,
      extension: extension ?? this.extension,
      mimeType: mimeType ?? this.mimeType,
      size: size ?? this.size,
      width: width ?? this.width,
      height: height ?? this.height,
      hasPreview: hasPreview ?? this.hasPreview,
      miniPreview: miniPreview ?? this.miniPreview,
      localPath: localPath ?? this.localPath,
      deleteAt: deleteAt ?? this.deleteAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (postId.present) {
      map['post_id'] = Variable<String>(postId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (extension.present) {
      map['extension'] = Variable<String>(extension.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (size.present) {
      map['size'] = Variable<int>(size.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (hasPreview.present) {
      map['has_preview'] = Variable<bool>(hasPreview.value);
    }
    if (miniPreview.present) {
      map['mini_preview'] = Variable<Uint8List>(miniPreview.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (deleteAt.present) {
      map['delete_at'] = Variable<int>(
        $FilesTable.$converterdeleteAtn.toSql(deleteAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FilesCompanion(')
          ..write('id: $id, ')
          ..write('postId: $postId, ')
          ..write('name: $name, ')
          ..write('extension: $extension, ')
          ..write('mimeType: $mimeType, ')
          ..write('size: $size, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('hasPreview: $hasPreview, ')
          ..write('miniPreview: $miniPreview, ')
          ..write('localPath: $localPath, ')
          ..write('deleteAt: $deleteAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ThreadsTable extends Threads with TableInfo<$ThreadsTable, ThreadRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ThreadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _rootIdMeta = const VerificationMeta('rootId');
  @override
  late final GeneratedColumn<String> rootId = GeneratedColumn<String>(
    'root_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _channelIdMeta = const VerificationMeta(
    'channelId',
  );
  @override
  late final GeneratedColumn<String> channelId = GeneratedColumn<String>(
    'channel_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> lastReplyAt =
      GeneratedColumn<int>(
        'last_reply_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($ThreadsTable.$converterlastReplyAtn);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> lastViewedAt =
      GeneratedColumn<int>(
        'last_viewed_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($ThreadsTable.$converterlastViewedAtn);
  static const VerificationMeta _replyCountMeta = const VerificationMeta(
    'replyCount',
  );
  @override
  late final GeneratedColumn<int> replyCount = GeneratedColumn<int>(
    'reply_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _unreadRepliesMeta = const VerificationMeta(
    'unreadReplies',
  );
  @override
  late final GeneratedColumn<int> unreadReplies = GeneratedColumn<int>(
    'unread_replies',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _unreadMentionsMeta = const VerificationMeta(
    'unreadMentions',
  );
  @override
  late final GeneratedColumn<int> unreadMentions = GeneratedColumn<int>(
    'unread_mentions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isFollowingMeta = const VerificationMeta(
    'isFollowing',
  );
  @override
  late final GeneratedColumn<bool> isFollowing = GeneratedColumn<bool>(
    'is_following',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_following" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  participantIds = GeneratedColumn<String>(
    'participant_ids_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  ).withConverter<List<String>>($ThreadsTable.$converterparticipantIds);
  @override
  List<GeneratedColumn> get $columns => [
    rootId,
    channelId,
    lastReplyAt,
    lastViewedAt,
    replyCount,
    unreadReplies,
    unreadMentions,
    isFollowing,
    participantIds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'threads';
  @override
  VerificationContext validateIntegrity(
    Insertable<ThreadRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('root_id')) {
      context.handle(
        _rootIdMeta,
        rootId.isAcceptableOrUnknown(data['root_id']!, _rootIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rootIdMeta);
    }
    if (data.containsKey('channel_id')) {
      context.handle(
        _channelIdMeta,
        channelId.isAcceptableOrUnknown(data['channel_id']!, _channelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_channelIdMeta);
    }
    if (data.containsKey('reply_count')) {
      context.handle(
        _replyCountMeta,
        replyCount.isAcceptableOrUnknown(data['reply_count']!, _replyCountMeta),
      );
    }
    if (data.containsKey('unread_replies')) {
      context.handle(
        _unreadRepliesMeta,
        unreadReplies.isAcceptableOrUnknown(
          data['unread_replies']!,
          _unreadRepliesMeta,
        ),
      );
    }
    if (data.containsKey('unread_mentions')) {
      context.handle(
        _unreadMentionsMeta,
        unreadMentions.isAcceptableOrUnknown(
          data['unread_mentions']!,
          _unreadMentionsMeta,
        ),
      );
    }
    if (data.containsKey('is_following')) {
      context.handle(
        _isFollowingMeta,
        isFollowing.isAcceptableOrUnknown(
          data['is_following']!,
          _isFollowingMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {rootId};
  @override
  ThreadRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ThreadRow(
      rootId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}root_id'],
      )!,
      channelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}channel_id'],
      )!,
      lastReplyAt: $ThreadsTable.$converterlastReplyAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}last_reply_at'],
        ),
      ),
      lastViewedAt: $ThreadsTable.$converterlastViewedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}last_viewed_at'],
        ),
      ),
      replyCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reply_count'],
      )!,
      unreadReplies: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unread_replies'],
      )!,
      unreadMentions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unread_mentions'],
      )!,
      isFollowing: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_following'],
      )!,
      participantIds: $ThreadsTable.$converterparticipantIds.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}participant_ids_json'],
        )!,
      ),
    );
  }

  @override
  $ThreadsTable createAlias(String alias) {
    return $ThreadsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $converterlastReplyAt = const Millis();
  static TypeConverter<DateTime?, int?> $converterlastReplyAtn =
      NullAwareTypeConverter.wrap($converterlastReplyAt);
  static TypeConverter<DateTime, int> $converterlastViewedAt = const Millis();
  static TypeConverter<DateTime?, int?> $converterlastViewedAtn =
      NullAwareTypeConverter.wrap($converterlastViewedAt);
  static TypeConverter<List<String>, String> $converterparticipantIds =
      const StringListColumn();
}

class ThreadRow extends DataClass implements Insertable<ThreadRow> {
  final String rootId;
  final String channelId;
  final DateTime? lastReplyAt;
  final DateTime? lastViewedAt;
  final int replyCount;
  final int unreadReplies;
  final int unreadMentions;
  final bool isFollowing;
  final List<String> participantIds;
  const ThreadRow({
    required this.rootId,
    required this.channelId,
    this.lastReplyAt,
    this.lastViewedAt,
    required this.replyCount,
    required this.unreadReplies,
    required this.unreadMentions,
    required this.isFollowing,
    required this.participantIds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['root_id'] = Variable<String>(rootId);
    map['channel_id'] = Variable<String>(channelId);
    if (!nullToAbsent || lastReplyAt != null) {
      map['last_reply_at'] = Variable<int>(
        $ThreadsTable.$converterlastReplyAtn.toSql(lastReplyAt),
      );
    }
    if (!nullToAbsent || lastViewedAt != null) {
      map['last_viewed_at'] = Variable<int>(
        $ThreadsTable.$converterlastViewedAtn.toSql(lastViewedAt),
      );
    }
    map['reply_count'] = Variable<int>(replyCount);
    map['unread_replies'] = Variable<int>(unreadReplies);
    map['unread_mentions'] = Variable<int>(unreadMentions);
    map['is_following'] = Variable<bool>(isFollowing);
    {
      map['participant_ids_json'] = Variable<String>(
        $ThreadsTable.$converterparticipantIds.toSql(participantIds),
      );
    }
    return map;
  }

  ThreadsCompanion toCompanion(bool nullToAbsent) {
    return ThreadsCompanion(
      rootId: Value(rootId),
      channelId: Value(channelId),
      lastReplyAt: lastReplyAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReplyAt),
      lastViewedAt: lastViewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastViewedAt),
      replyCount: Value(replyCount),
      unreadReplies: Value(unreadReplies),
      unreadMentions: Value(unreadMentions),
      isFollowing: Value(isFollowing),
      participantIds: Value(participantIds),
    );
  }

  factory ThreadRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ThreadRow(
      rootId: serializer.fromJson<String>(json['rootId']),
      channelId: serializer.fromJson<String>(json['channelId']),
      lastReplyAt: serializer.fromJson<DateTime?>(json['lastReplyAt']),
      lastViewedAt: serializer.fromJson<DateTime?>(json['lastViewedAt']),
      replyCount: serializer.fromJson<int>(json['replyCount']),
      unreadReplies: serializer.fromJson<int>(json['unreadReplies']),
      unreadMentions: serializer.fromJson<int>(json['unreadMentions']),
      isFollowing: serializer.fromJson<bool>(json['isFollowing']),
      participantIds: serializer.fromJson<List<String>>(json['participantIds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'rootId': serializer.toJson<String>(rootId),
      'channelId': serializer.toJson<String>(channelId),
      'lastReplyAt': serializer.toJson<DateTime?>(lastReplyAt),
      'lastViewedAt': serializer.toJson<DateTime?>(lastViewedAt),
      'replyCount': serializer.toJson<int>(replyCount),
      'unreadReplies': serializer.toJson<int>(unreadReplies),
      'unreadMentions': serializer.toJson<int>(unreadMentions),
      'isFollowing': serializer.toJson<bool>(isFollowing),
      'participantIds': serializer.toJson<List<String>>(participantIds),
    };
  }

  ThreadRow copyWith({
    String? rootId,
    String? channelId,
    Value<DateTime?> lastReplyAt = const Value.absent(),
    Value<DateTime?> lastViewedAt = const Value.absent(),
    int? replyCount,
    int? unreadReplies,
    int? unreadMentions,
    bool? isFollowing,
    List<String>? participantIds,
  }) => ThreadRow(
    rootId: rootId ?? this.rootId,
    channelId: channelId ?? this.channelId,
    lastReplyAt: lastReplyAt.present ? lastReplyAt.value : this.lastReplyAt,
    lastViewedAt: lastViewedAt.present ? lastViewedAt.value : this.lastViewedAt,
    replyCount: replyCount ?? this.replyCount,
    unreadReplies: unreadReplies ?? this.unreadReplies,
    unreadMentions: unreadMentions ?? this.unreadMentions,
    isFollowing: isFollowing ?? this.isFollowing,
    participantIds: participantIds ?? this.participantIds,
  );
  ThreadRow copyWithCompanion(ThreadsCompanion data) {
    return ThreadRow(
      rootId: data.rootId.present ? data.rootId.value : this.rootId,
      channelId: data.channelId.present ? data.channelId.value : this.channelId,
      lastReplyAt: data.lastReplyAt.present
          ? data.lastReplyAt.value
          : this.lastReplyAt,
      lastViewedAt: data.lastViewedAt.present
          ? data.lastViewedAt.value
          : this.lastViewedAt,
      replyCount: data.replyCount.present
          ? data.replyCount.value
          : this.replyCount,
      unreadReplies: data.unreadReplies.present
          ? data.unreadReplies.value
          : this.unreadReplies,
      unreadMentions: data.unreadMentions.present
          ? data.unreadMentions.value
          : this.unreadMentions,
      isFollowing: data.isFollowing.present
          ? data.isFollowing.value
          : this.isFollowing,
      participantIds: data.participantIds.present
          ? data.participantIds.value
          : this.participantIds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ThreadRow(')
          ..write('rootId: $rootId, ')
          ..write('channelId: $channelId, ')
          ..write('lastReplyAt: $lastReplyAt, ')
          ..write('lastViewedAt: $lastViewedAt, ')
          ..write('replyCount: $replyCount, ')
          ..write('unreadReplies: $unreadReplies, ')
          ..write('unreadMentions: $unreadMentions, ')
          ..write('isFollowing: $isFollowing, ')
          ..write('participantIds: $participantIds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    rootId,
    channelId,
    lastReplyAt,
    lastViewedAt,
    replyCount,
    unreadReplies,
    unreadMentions,
    isFollowing,
    participantIds,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ThreadRow &&
          other.rootId == this.rootId &&
          other.channelId == this.channelId &&
          other.lastReplyAt == this.lastReplyAt &&
          other.lastViewedAt == this.lastViewedAt &&
          other.replyCount == this.replyCount &&
          other.unreadReplies == this.unreadReplies &&
          other.unreadMentions == this.unreadMentions &&
          other.isFollowing == this.isFollowing &&
          other.participantIds == this.participantIds);
}

class ThreadsCompanion extends UpdateCompanion<ThreadRow> {
  final Value<String> rootId;
  final Value<String> channelId;
  final Value<DateTime?> lastReplyAt;
  final Value<DateTime?> lastViewedAt;
  final Value<int> replyCount;
  final Value<int> unreadReplies;
  final Value<int> unreadMentions;
  final Value<bool> isFollowing;
  final Value<List<String>> participantIds;
  final Value<int> rowid;
  const ThreadsCompanion({
    this.rootId = const Value.absent(),
    this.channelId = const Value.absent(),
    this.lastReplyAt = const Value.absent(),
    this.lastViewedAt = const Value.absent(),
    this.replyCount = const Value.absent(),
    this.unreadReplies = const Value.absent(),
    this.unreadMentions = const Value.absent(),
    this.isFollowing = const Value.absent(),
    this.participantIds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ThreadsCompanion.insert({
    required String rootId,
    required String channelId,
    this.lastReplyAt = const Value.absent(),
    this.lastViewedAt = const Value.absent(),
    this.replyCount = const Value.absent(),
    this.unreadReplies = const Value.absent(),
    this.unreadMentions = const Value.absent(),
    this.isFollowing = const Value.absent(),
    this.participantIds = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : rootId = Value(rootId),
       channelId = Value(channelId);
  static Insertable<ThreadRow> custom({
    Expression<String>? rootId,
    Expression<String>? channelId,
    Expression<int>? lastReplyAt,
    Expression<int>? lastViewedAt,
    Expression<int>? replyCount,
    Expression<int>? unreadReplies,
    Expression<int>? unreadMentions,
    Expression<bool>? isFollowing,
    Expression<String>? participantIds,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (rootId != null) 'root_id': rootId,
      if (channelId != null) 'channel_id': channelId,
      if (lastReplyAt != null) 'last_reply_at': lastReplyAt,
      if (lastViewedAt != null) 'last_viewed_at': lastViewedAt,
      if (replyCount != null) 'reply_count': replyCount,
      if (unreadReplies != null) 'unread_replies': unreadReplies,
      if (unreadMentions != null) 'unread_mentions': unreadMentions,
      if (isFollowing != null) 'is_following': isFollowing,
      if (participantIds != null) 'participant_ids_json': participantIds,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ThreadsCompanion copyWith({
    Value<String>? rootId,
    Value<String>? channelId,
    Value<DateTime?>? lastReplyAt,
    Value<DateTime?>? lastViewedAt,
    Value<int>? replyCount,
    Value<int>? unreadReplies,
    Value<int>? unreadMentions,
    Value<bool>? isFollowing,
    Value<List<String>>? participantIds,
    Value<int>? rowid,
  }) {
    return ThreadsCompanion(
      rootId: rootId ?? this.rootId,
      channelId: channelId ?? this.channelId,
      lastReplyAt: lastReplyAt ?? this.lastReplyAt,
      lastViewedAt: lastViewedAt ?? this.lastViewedAt,
      replyCount: replyCount ?? this.replyCount,
      unreadReplies: unreadReplies ?? this.unreadReplies,
      unreadMentions: unreadMentions ?? this.unreadMentions,
      isFollowing: isFollowing ?? this.isFollowing,
      participantIds: participantIds ?? this.participantIds,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (rootId.present) {
      map['root_id'] = Variable<String>(rootId.value);
    }
    if (channelId.present) {
      map['channel_id'] = Variable<String>(channelId.value);
    }
    if (lastReplyAt.present) {
      map['last_reply_at'] = Variable<int>(
        $ThreadsTable.$converterlastReplyAtn.toSql(lastReplyAt.value),
      );
    }
    if (lastViewedAt.present) {
      map['last_viewed_at'] = Variable<int>(
        $ThreadsTable.$converterlastViewedAtn.toSql(lastViewedAt.value),
      );
    }
    if (replyCount.present) {
      map['reply_count'] = Variable<int>(replyCount.value);
    }
    if (unreadReplies.present) {
      map['unread_replies'] = Variable<int>(unreadReplies.value);
    }
    if (unreadMentions.present) {
      map['unread_mentions'] = Variable<int>(unreadMentions.value);
    }
    if (isFollowing.present) {
      map['is_following'] = Variable<bool>(isFollowing.value);
    }
    if (participantIds.present) {
      map['participant_ids_json'] = Variable<String>(
        $ThreadsTable.$converterparticipantIds.toSql(participantIds.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ThreadsCompanion(')
          ..write('rootId: $rootId, ')
          ..write('channelId: $channelId, ')
          ..write('lastReplyAt: $lastReplyAt, ')
          ..write('lastViewedAt: $lastViewedAt, ')
          ..write('replyCount: $replyCount, ')
          ..write('unreadReplies: $unreadReplies, ')
          ..write('unreadMentions: $unreadMentions, ')
          ..write('isFollowing: $isFollowing, ')
          ..write('participantIds: $participantIds, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ThreadTeamsTable extends ThreadTeams
    with TableInfo<$ThreadTeamsTable, ThreadTeamRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ThreadTeamsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _teamIdMeta = const VerificationMeta('teamId');
  @override
  late final GeneratedColumn<String> teamId = GeneratedColumn<String>(
    'team_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rootIdMeta = const VerificationMeta('rootId');
  @override
  late final GeneratedColumn<String> rootId = GeneratedColumn<String>(
    'root_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [teamId, rootId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'thread_teams';
  @override
  VerificationContext validateIntegrity(
    Insertable<ThreadTeamRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('team_id')) {
      context.handle(
        _teamIdMeta,
        teamId.isAcceptableOrUnknown(data['team_id']!, _teamIdMeta),
      );
    } else if (isInserting) {
      context.missing(_teamIdMeta);
    }
    if (data.containsKey('root_id')) {
      context.handle(
        _rootIdMeta,
        rootId.isAcceptableOrUnknown(data['root_id']!, _rootIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rootIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {teamId, rootId};
  @override
  ThreadTeamRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ThreadTeamRow(
      teamId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}team_id'],
      )!,
      rootId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}root_id'],
      )!,
    );
  }

  @override
  $ThreadTeamsTable createAlias(String alias) {
    return $ThreadTeamsTable(attachedDatabase, alias);
  }
}

class ThreadTeamRow extends DataClass implements Insertable<ThreadTeamRow> {
  final String teamId;
  final String rootId;
  const ThreadTeamRow({required this.teamId, required this.rootId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['team_id'] = Variable<String>(teamId);
    map['root_id'] = Variable<String>(rootId);
    return map;
  }

  ThreadTeamsCompanion toCompanion(bool nullToAbsent) {
    return ThreadTeamsCompanion(teamId: Value(teamId), rootId: Value(rootId));
  }

  factory ThreadTeamRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ThreadTeamRow(
      teamId: serializer.fromJson<String>(json['teamId']),
      rootId: serializer.fromJson<String>(json['rootId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'teamId': serializer.toJson<String>(teamId),
      'rootId': serializer.toJson<String>(rootId),
    };
  }

  ThreadTeamRow copyWith({String? teamId, String? rootId}) => ThreadTeamRow(
    teamId: teamId ?? this.teamId,
    rootId: rootId ?? this.rootId,
  );
  ThreadTeamRow copyWithCompanion(ThreadTeamsCompanion data) {
    return ThreadTeamRow(
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
      rootId: data.rootId.present ? data.rootId.value : this.rootId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ThreadTeamRow(')
          ..write('teamId: $teamId, ')
          ..write('rootId: $rootId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(teamId, rootId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ThreadTeamRow &&
          other.teamId == this.teamId &&
          other.rootId == this.rootId);
}

class ThreadTeamsCompanion extends UpdateCompanion<ThreadTeamRow> {
  final Value<String> teamId;
  final Value<String> rootId;
  final Value<int> rowid;
  const ThreadTeamsCompanion({
    this.teamId = const Value.absent(),
    this.rootId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ThreadTeamsCompanion.insert({
    required String teamId,
    required String rootId,
    this.rowid = const Value.absent(),
  }) : teamId = Value(teamId),
       rootId = Value(rootId);
  static Insertable<ThreadTeamRow> custom({
    Expression<String>? teamId,
    Expression<String>? rootId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (teamId != null) 'team_id': teamId,
      if (rootId != null) 'root_id': rootId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ThreadTeamsCompanion copyWith({
    Value<String>? teamId,
    Value<String>? rootId,
    Value<int>? rowid,
  }) {
    return ThreadTeamsCompanion(
      teamId: teamId ?? this.teamId,
      rootId: rootId ?? this.rootId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (teamId.present) {
      map['team_id'] = Variable<String>(teamId.value);
    }
    if (rootId.present) {
      map['root_id'] = Variable<String>(rootId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ThreadTeamsCompanion(')
          ..write('teamId: $teamId, ')
          ..write('rootId: $rootId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ThreadSyncTable extends ThreadSync
    with TableInfo<$ThreadSyncTable, ThreadSyncRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ThreadSyncTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _teamIdMeta = const VerificationMeta('teamId');
  @override
  late final GeneratedColumn<String> teamId = GeneratedColumn<String>(
    'team_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> earliest =
      GeneratedColumn<int>(
        'earliest',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ThreadSyncTable.$converterearliest);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> latest =
      GeneratedColumn<int>(
        'latest',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ThreadSyncTable.$converterlatest);
  @override
  List<GeneratedColumn> get $columns => [teamId, earliest, latest];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'thread_sync';
  @override
  VerificationContext validateIntegrity(
    Insertable<ThreadSyncRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('team_id')) {
      context.handle(
        _teamIdMeta,
        teamId.isAcceptableOrUnknown(data['team_id']!, _teamIdMeta),
      );
    } else if (isInserting) {
      context.missing(_teamIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {teamId};
  @override
  ThreadSyncRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ThreadSyncRow(
      teamId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}team_id'],
      )!,
      earliest: $ThreadSyncTable.$converterearliest.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}earliest'],
        )!,
      ),
      latest: $ThreadSyncTable.$converterlatest.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}latest'],
        )!,
      ),
    );
  }

  @override
  $ThreadSyncTable createAlias(String alias) {
    return $ThreadSyncTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $converterearliest = const Millis();
  static TypeConverter<DateTime, int> $converterlatest = const Millis();
}

class ThreadSyncRow extends DataClass implements Insertable<ThreadSyncRow> {
  final String teamId;
  final DateTime earliest;
  final DateTime latest;
  const ThreadSyncRow({
    required this.teamId,
    required this.earliest,
    required this.latest,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['team_id'] = Variable<String>(teamId);
    {
      map['earliest'] = Variable<int>(
        $ThreadSyncTable.$converterearliest.toSql(earliest),
      );
    }
    {
      map['latest'] = Variable<int>(
        $ThreadSyncTable.$converterlatest.toSql(latest),
      );
    }
    return map;
  }

  ThreadSyncCompanion toCompanion(bool nullToAbsent) {
    return ThreadSyncCompanion(
      teamId: Value(teamId),
      earliest: Value(earliest),
      latest: Value(latest),
    );
  }

  factory ThreadSyncRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ThreadSyncRow(
      teamId: serializer.fromJson<String>(json['teamId']),
      earliest: serializer.fromJson<DateTime>(json['earliest']),
      latest: serializer.fromJson<DateTime>(json['latest']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'teamId': serializer.toJson<String>(teamId),
      'earliest': serializer.toJson<DateTime>(earliest),
      'latest': serializer.toJson<DateTime>(latest),
    };
  }

  ThreadSyncRow copyWith({
    String? teamId,
    DateTime? earliest,
    DateTime? latest,
  }) => ThreadSyncRow(
    teamId: teamId ?? this.teamId,
    earliest: earliest ?? this.earliest,
    latest: latest ?? this.latest,
  );
  ThreadSyncRow copyWithCompanion(ThreadSyncCompanion data) {
    return ThreadSyncRow(
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
      earliest: data.earliest.present ? data.earliest.value : this.earliest,
      latest: data.latest.present ? data.latest.value : this.latest,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ThreadSyncRow(')
          ..write('teamId: $teamId, ')
          ..write('earliest: $earliest, ')
          ..write('latest: $latest')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(teamId, earliest, latest);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ThreadSyncRow &&
          other.teamId == this.teamId &&
          other.earliest == this.earliest &&
          other.latest == this.latest);
}

class ThreadSyncCompanion extends UpdateCompanion<ThreadSyncRow> {
  final Value<String> teamId;
  final Value<DateTime> earliest;
  final Value<DateTime> latest;
  final Value<int> rowid;
  const ThreadSyncCompanion({
    this.teamId = const Value.absent(),
    this.earliest = const Value.absent(),
    this.latest = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ThreadSyncCompanion.insert({
    required String teamId,
    required DateTime earliest,
    required DateTime latest,
    this.rowid = const Value.absent(),
  }) : teamId = Value(teamId),
       earliest = Value(earliest),
       latest = Value(latest);
  static Insertable<ThreadSyncRow> custom({
    Expression<String>? teamId,
    Expression<int>? earliest,
    Expression<int>? latest,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (teamId != null) 'team_id': teamId,
      if (earliest != null) 'earliest': earliest,
      if (latest != null) 'latest': latest,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ThreadSyncCompanion copyWith({
    Value<String>? teamId,
    Value<DateTime>? earliest,
    Value<DateTime>? latest,
    Value<int>? rowid,
  }) {
    return ThreadSyncCompanion(
      teamId: teamId ?? this.teamId,
      earliest: earliest ?? this.earliest,
      latest: latest ?? this.latest,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (teamId.present) {
      map['team_id'] = Variable<String>(teamId.value);
    }
    if (earliest.present) {
      map['earliest'] = Variable<int>(
        $ThreadSyncTable.$converterearliest.toSql(earliest.value),
      );
    }
    if (latest.present) {
      map['latest'] = Variable<int>(
        $ThreadSyncTable.$converterlatest.toSql(latest.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ThreadSyncCompanion(')
          ..write('teamId: $teamId, ')
          ..write('earliest: $earliest, ')
          ..write('latest: $latest, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomEmojiTable extends CustomEmoji
    with TableInfo<$CustomEmojiTable, CustomEmojiRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomEmojiTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _creatorIdMeta = const VerificationMeta(
    'creatorId',
  );
  @override
  late final GeneratedColumn<String> creatorId = GeneratedColumn<String>(
    'creator_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> createAt =
      GeneratedColumn<int>(
        'create_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($CustomEmojiTable.$convertercreateAtn);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> deleteAt =
      GeneratedColumn<int>(
        'delete_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($CustomEmojiTable.$converterdeleteAtn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    creatorId,
    createAt,
    deleteAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_emoji';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomEmojiRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('creator_id')) {
      context.handle(
        _creatorIdMeta,
        creatorId.isAcceptableOrUnknown(data['creator_id']!, _creatorIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomEmojiRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomEmojiRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      creatorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}creator_id'],
      )!,
      createAt: $CustomEmojiTable.$convertercreateAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}create_at'],
        ),
      ),
      deleteAt: $CustomEmojiTable.$converterdeleteAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}delete_at'],
        ),
      ),
    );
  }

  @override
  $CustomEmojiTable createAlias(String alias) {
    return $CustomEmojiTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreateAt = const Millis();
  static TypeConverter<DateTime?, int?> $convertercreateAtn =
      NullAwareTypeConverter.wrap($convertercreateAt);
  static TypeConverter<DateTime, int> $converterdeleteAt = const Millis();
  static TypeConverter<DateTime?, int?> $converterdeleteAtn =
      NullAwareTypeConverter.wrap($converterdeleteAt);
}

class CustomEmojiRow extends DataClass implements Insertable<CustomEmojiRow> {
  final String id;
  final String name;
  final String creatorId;
  final DateTime? createAt;
  final DateTime? deleteAt;
  const CustomEmojiRow({
    required this.id,
    required this.name,
    required this.creatorId,
    this.createAt,
    this.deleteAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['creator_id'] = Variable<String>(creatorId);
    if (!nullToAbsent || createAt != null) {
      map['create_at'] = Variable<int>(
        $CustomEmojiTable.$convertercreateAtn.toSql(createAt),
      );
    }
    if (!nullToAbsent || deleteAt != null) {
      map['delete_at'] = Variable<int>(
        $CustomEmojiTable.$converterdeleteAtn.toSql(deleteAt),
      );
    }
    return map;
  }

  CustomEmojiCompanion toCompanion(bool nullToAbsent) {
    return CustomEmojiCompanion(
      id: Value(id),
      name: Value(name),
      creatorId: Value(creatorId),
      createAt: createAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createAt),
      deleteAt: deleteAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deleteAt),
    );
  }

  factory CustomEmojiRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomEmojiRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      creatorId: serializer.fromJson<String>(json['creatorId']),
      createAt: serializer.fromJson<DateTime?>(json['createAt']),
      deleteAt: serializer.fromJson<DateTime?>(json['deleteAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'creatorId': serializer.toJson<String>(creatorId),
      'createAt': serializer.toJson<DateTime?>(createAt),
      'deleteAt': serializer.toJson<DateTime?>(deleteAt),
    };
  }

  CustomEmojiRow copyWith({
    String? id,
    String? name,
    String? creatorId,
    Value<DateTime?> createAt = const Value.absent(),
    Value<DateTime?> deleteAt = const Value.absent(),
  }) => CustomEmojiRow(
    id: id ?? this.id,
    name: name ?? this.name,
    creatorId: creatorId ?? this.creatorId,
    createAt: createAt.present ? createAt.value : this.createAt,
    deleteAt: deleteAt.present ? deleteAt.value : this.deleteAt,
  );
  CustomEmojiRow copyWithCompanion(CustomEmojiCompanion data) {
    return CustomEmojiRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      creatorId: data.creatorId.present ? data.creatorId.value : this.creatorId,
      createAt: data.createAt.present ? data.createAt.value : this.createAt,
      deleteAt: data.deleteAt.present ? data.deleteAt.value : this.deleteAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomEmojiRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('creatorId: $creatorId, ')
          ..write('createAt: $createAt, ')
          ..write('deleteAt: $deleteAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, creatorId, createAt, deleteAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomEmojiRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.creatorId == this.creatorId &&
          other.createAt == this.createAt &&
          other.deleteAt == this.deleteAt);
}

class CustomEmojiCompanion extends UpdateCompanion<CustomEmojiRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> creatorId;
  final Value<DateTime?> createAt;
  final Value<DateTime?> deleteAt;
  final Value<int> rowid;
  const CustomEmojiCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.creatorId = const Value.absent(),
    this.createAt = const Value.absent(),
    this.deleteAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomEmojiCompanion.insert({
    required String id,
    required String name,
    this.creatorId = const Value.absent(),
    this.createAt = const Value.absent(),
    this.deleteAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<CustomEmojiRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? creatorId,
    Expression<int>? createAt,
    Expression<int>? deleteAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (creatorId != null) 'creator_id': creatorId,
      if (createAt != null) 'create_at': createAt,
      if (deleteAt != null) 'delete_at': deleteAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomEmojiCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? creatorId,
    Value<DateTime?>? createAt,
    Value<DateTime?>? deleteAt,
    Value<int>? rowid,
  }) {
    return CustomEmojiCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      creatorId: creatorId ?? this.creatorId,
      createAt: createAt ?? this.createAt,
      deleteAt: deleteAt ?? this.deleteAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (creatorId.present) {
      map['creator_id'] = Variable<String>(creatorId.value);
    }
    if (createAt.present) {
      map['create_at'] = Variable<int>(
        $CustomEmojiTable.$convertercreateAtn.toSql(createAt.value),
      );
    }
    if (deleteAt.present) {
      map['delete_at'] = Variable<int>(
        $CustomEmojiTable.$converterdeleteAtn.toSql(deleteAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomEmojiCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('creatorId: $creatorId, ')
          ..write('createAt: $createAt, ')
          ..write('deleteAt: $deleteAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PreferencesTable extends Preferences
    with TableInfo<$PreferencesTable, PreferenceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
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
  List<GeneratedColumn> get $columns => [category, name, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<PreferenceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
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
  Set<GeneratedColumn> get $primaryKey => {category, name};
  @override
  PreferenceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PreferenceRow(
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $PreferencesTable createAlias(String alias) {
    return $PreferencesTable(attachedDatabase, alias);
  }
}

class PreferenceRow extends DataClass implements Insertable<PreferenceRow> {
  final String category;
  final String name;
  final String value;
  const PreferenceRow({
    required this.category,
    required this.name,
    required this.value,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['category'] = Variable<String>(category);
    map['name'] = Variable<String>(name);
    map['value'] = Variable<String>(value);
    return map;
  }

  PreferencesCompanion toCompanion(bool nullToAbsent) {
    return PreferencesCompanion(
      category: Value(category),
      name: Value(name),
      value: Value(value),
    );
  }

  factory PreferenceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PreferenceRow(
      category: serializer.fromJson<String>(json['category']),
      name: serializer.fromJson<String>(json['name']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'category': serializer.toJson<String>(category),
      'name': serializer.toJson<String>(name),
      'value': serializer.toJson<String>(value),
    };
  }

  PreferenceRow copyWith({String? category, String? name, String? value}) =>
      PreferenceRow(
        category: category ?? this.category,
        name: name ?? this.name,
        value: value ?? this.value,
      );
  PreferenceRow copyWithCompanion(PreferencesCompanion data) {
    return PreferenceRow(
      category: data.category.present ? data.category.value : this.category,
      name: data.name.present ? data.name.value : this.name,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PreferenceRow(')
          ..write('category: $category, ')
          ..write('name: $name, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(category, name, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PreferenceRow &&
          other.category == this.category &&
          other.name == this.name &&
          other.value == this.value);
}

class PreferencesCompanion extends UpdateCompanion<PreferenceRow> {
  final Value<String> category;
  final Value<String> name;
  final Value<String> value;
  final Value<int> rowid;
  const PreferencesCompanion({
    this.category = const Value.absent(),
    this.name = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PreferencesCompanion.insert({
    required String category,
    required String name,
    required String value,
    this.rowid = const Value.absent(),
  }) : category = Value(category),
       name = Value(name),
       value = Value(value);
  static Insertable<PreferenceRow> custom({
    Expression<String>? category,
    Expression<String>? name,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (category != null) 'category': category,
      if (name != null) 'name': name,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PreferencesCompanion copyWith({
    Value<String>? category,
    Value<String>? name,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return PreferencesCompanion(
      category: category ?? this.category,
      name: name ?? this.name,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
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
    return (StringBuffer('PreferencesCompanion(')
          ..write('category: $category, ')
          ..write('name: $name, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RolesTable extends Roles with TableInfo<$RolesTable, RoleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RolesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  permissions = GeneratedColumn<String>(
    'permissions_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  ).withConverter<List<String>>($RolesTable.$converterpermissions);
  @override
  List<GeneratedColumn> get $columns => [name, permissions];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'roles';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {name};
  @override
  RoleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoleRow(
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      permissions: $RolesTable.$converterpermissions.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}permissions_json'],
        )!,
      ),
    );
  }

  @override
  $RolesTable createAlias(String alias) {
    return $RolesTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterpermissions =
      const StringListColumn();
}

class RoleRow extends DataClass implements Insertable<RoleRow> {
  final String name;
  final List<String> permissions;
  const RoleRow({required this.name, required this.permissions});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    {
      map['permissions_json'] = Variable<String>(
        $RolesTable.$converterpermissions.toSql(permissions),
      );
    }
    return map;
  }

  RolesCompanion toCompanion(bool nullToAbsent) {
    return RolesCompanion(name: Value(name), permissions: Value(permissions));
  }

  factory RoleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoleRow(
      name: serializer.fromJson<String>(json['name']),
      permissions: serializer.fromJson<List<String>>(json['permissions']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'permissions': serializer.toJson<List<String>>(permissions),
    };
  }

  RoleRow copyWith({String? name, List<String>? permissions}) => RoleRow(
    name: name ?? this.name,
    permissions: permissions ?? this.permissions,
  );
  RoleRow copyWithCompanion(RolesCompanion data) {
    return RoleRow(
      name: data.name.present ? data.name.value : this.name,
      permissions: data.permissions.present
          ? data.permissions.value
          : this.permissions,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoleRow(')
          ..write('name: $name, ')
          ..write('permissions: $permissions')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(name, permissions);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoleRow &&
          other.name == this.name &&
          other.permissions == this.permissions);
}

class RolesCompanion extends UpdateCompanion<RoleRow> {
  final Value<String> name;
  final Value<List<String>> permissions;
  final Value<int> rowid;
  const RolesCompanion({
    this.name = const Value.absent(),
    this.permissions = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RolesCompanion.insert({
    required String name,
    this.permissions = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name);
  static Insertable<RoleRow> custom({
    Expression<String>? name,
    Expression<String>? permissions,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (permissions != null) 'permissions_json': permissions,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RolesCompanion copyWith({
    Value<String>? name,
    Value<List<String>>? permissions,
    Value<int>? rowid,
  }) {
    return RolesCompanion(
      name: name ?? this.name,
      permissions: permissions ?? this.permissions,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (permissions.present) {
      map['permissions_json'] = Variable<String>(
        $RolesTable.$converterpermissions.toSql(permissions.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RolesCompanion(')
          ..write('name: $name, ')
          ..write('permissions: $permissions, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DraftsTable extends Drafts with TableInfo<$DraftsTable, DraftRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DraftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _channelIdMeta = const VerificationMeta(
    'channelId',
  );
  @override
  late final GeneratedColumn<String> channelId = GeneratedColumn<String>(
    'channel_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rootIdMeta = const VerificationMeta('rootId');
  @override
  late final GeneratedColumn<String> rootId = GeneratedColumn<String>(
    'root_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _selectionBaseMeta = const VerificationMeta(
    'selectionBase',
  );
  @override
  late final GeneratedColumn<int> selectionBase = GeneratedColumn<int>(
    'selection_base',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _selectionExtentMeta = const VerificationMeta(
    'selectionExtent',
  );
  @override
  late final GeneratedColumn<int> selectionExtent = GeneratedColumn<int>(
    'selection_extent',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<FileInfo>, String> files =
      GeneratedColumn<String>(
        'files_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<List<FileInfo>>($DraftsTable.$converterfiles);
  @override
  late final GeneratedColumnWithTypeConverter<PostPriority?, String> priority =
      GeneratedColumn<String>(
        'priority_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<PostPriority?>($DraftsTable.$converterpriority);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($DraftsTable.$converterupdatedAt);
  @override
  List<GeneratedColumn> get $columns => [
    channelId,
    rootId,
    message,
    selectionBase,
    selectionExtent,
    files,
    priority,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'drafts';
  @override
  VerificationContext validateIntegrity(
    Insertable<DraftRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('channel_id')) {
      context.handle(
        _channelIdMeta,
        channelId.isAcceptableOrUnknown(data['channel_id']!, _channelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_channelIdMeta);
    }
    if (data.containsKey('root_id')) {
      context.handle(
        _rootIdMeta,
        rootId.isAcceptableOrUnknown(data['root_id']!, _rootIdMeta),
      );
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    }
    if (data.containsKey('selection_base')) {
      context.handle(
        _selectionBaseMeta,
        selectionBase.isAcceptableOrUnknown(
          data['selection_base']!,
          _selectionBaseMeta,
        ),
      );
    }
    if (data.containsKey('selection_extent')) {
      context.handle(
        _selectionExtentMeta,
        selectionExtent.isAcceptableOrUnknown(
          data['selection_extent']!,
          _selectionExtentMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {channelId, rootId};
  @override
  DraftRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DraftRow(
      channelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}channel_id'],
      )!,
      rootId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}root_id'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      )!,
      selectionBase: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}selection_base'],
      ),
      selectionExtent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}selection_extent'],
      ),
      files: $DraftsTable.$converterfiles.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}files_json'],
        )!,
      ),
      priority: $DraftsTable.$converterpriority.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}priority_json'],
        ),
      ),
      updatedAt: $DraftsTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
    );
  }

  @override
  $DraftsTable createAlias(String alias) {
    return $DraftsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<FileInfo>, String> $converterfiles =
      const FileInfoListColumn();
  static TypeConverter<PostPriority?, String?> $converterpriority =
      const PostPriorityColumn();
  static TypeConverter<DateTime, int> $converterupdatedAt = const Millis();
}

class DraftRow extends DataClass implements Insertable<DraftRow> {
  final String channelId;
  final String rootId;
  final String message;
  final int? selectionBase;
  final int? selectionExtent;
  final List<FileInfo> files;
  final PostPriority? priority;
  final DateTime updatedAt;
  const DraftRow({
    required this.channelId,
    required this.rootId,
    required this.message,
    this.selectionBase,
    this.selectionExtent,
    required this.files,
    this.priority,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['channel_id'] = Variable<String>(channelId);
    map['root_id'] = Variable<String>(rootId);
    map['message'] = Variable<String>(message);
    if (!nullToAbsent || selectionBase != null) {
      map['selection_base'] = Variable<int>(selectionBase);
    }
    if (!nullToAbsent || selectionExtent != null) {
      map['selection_extent'] = Variable<int>(selectionExtent);
    }
    {
      map['files_json'] = Variable<String>(
        $DraftsTable.$converterfiles.toSql(files),
      );
    }
    if (!nullToAbsent || priority != null) {
      map['priority_json'] = Variable<String>(
        $DraftsTable.$converterpriority.toSql(priority),
      );
    }
    {
      map['updated_at'] = Variable<int>(
        $DraftsTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    return map;
  }

  DraftsCompanion toCompanion(bool nullToAbsent) {
    return DraftsCompanion(
      channelId: Value(channelId),
      rootId: Value(rootId),
      message: Value(message),
      selectionBase: selectionBase == null && nullToAbsent
          ? const Value.absent()
          : Value(selectionBase),
      selectionExtent: selectionExtent == null && nullToAbsent
          ? const Value.absent()
          : Value(selectionExtent),
      files: Value(files),
      priority: priority == null && nullToAbsent
          ? const Value.absent()
          : Value(priority),
      updatedAt: Value(updatedAt),
    );
  }

  factory DraftRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DraftRow(
      channelId: serializer.fromJson<String>(json['channelId']),
      rootId: serializer.fromJson<String>(json['rootId']),
      message: serializer.fromJson<String>(json['message']),
      selectionBase: serializer.fromJson<int?>(json['selectionBase']),
      selectionExtent: serializer.fromJson<int?>(json['selectionExtent']),
      files: serializer.fromJson<List<FileInfo>>(json['files']),
      priority: serializer.fromJson<PostPriority?>(json['priority']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'channelId': serializer.toJson<String>(channelId),
      'rootId': serializer.toJson<String>(rootId),
      'message': serializer.toJson<String>(message),
      'selectionBase': serializer.toJson<int?>(selectionBase),
      'selectionExtent': serializer.toJson<int?>(selectionExtent),
      'files': serializer.toJson<List<FileInfo>>(files),
      'priority': serializer.toJson<PostPriority?>(priority),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DraftRow copyWith({
    String? channelId,
    String? rootId,
    String? message,
    Value<int?> selectionBase = const Value.absent(),
    Value<int?> selectionExtent = const Value.absent(),
    List<FileInfo>? files,
    Value<PostPriority?> priority = const Value.absent(),
    DateTime? updatedAt,
  }) => DraftRow(
    channelId: channelId ?? this.channelId,
    rootId: rootId ?? this.rootId,
    message: message ?? this.message,
    selectionBase: selectionBase.present
        ? selectionBase.value
        : this.selectionBase,
    selectionExtent: selectionExtent.present
        ? selectionExtent.value
        : this.selectionExtent,
    files: files ?? this.files,
    priority: priority.present ? priority.value : this.priority,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DraftRow copyWithCompanion(DraftsCompanion data) {
    return DraftRow(
      channelId: data.channelId.present ? data.channelId.value : this.channelId,
      rootId: data.rootId.present ? data.rootId.value : this.rootId,
      message: data.message.present ? data.message.value : this.message,
      selectionBase: data.selectionBase.present
          ? data.selectionBase.value
          : this.selectionBase,
      selectionExtent: data.selectionExtent.present
          ? data.selectionExtent.value
          : this.selectionExtent,
      files: data.files.present ? data.files.value : this.files,
      priority: data.priority.present ? data.priority.value : this.priority,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DraftRow(')
          ..write('channelId: $channelId, ')
          ..write('rootId: $rootId, ')
          ..write('message: $message, ')
          ..write('selectionBase: $selectionBase, ')
          ..write('selectionExtent: $selectionExtent, ')
          ..write('files: $files, ')
          ..write('priority: $priority, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    channelId,
    rootId,
    message,
    selectionBase,
    selectionExtent,
    files,
    priority,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DraftRow &&
          other.channelId == this.channelId &&
          other.rootId == this.rootId &&
          other.message == this.message &&
          other.selectionBase == this.selectionBase &&
          other.selectionExtent == this.selectionExtent &&
          other.files == this.files &&
          other.priority == this.priority &&
          other.updatedAt == this.updatedAt);
}

class DraftsCompanion extends UpdateCompanion<DraftRow> {
  final Value<String> channelId;
  final Value<String> rootId;
  final Value<String> message;
  final Value<int?> selectionBase;
  final Value<int?> selectionExtent;
  final Value<List<FileInfo>> files;
  final Value<PostPriority?> priority;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DraftsCompanion({
    this.channelId = const Value.absent(),
    this.rootId = const Value.absent(),
    this.message = const Value.absent(),
    this.selectionBase = const Value.absent(),
    this.selectionExtent = const Value.absent(),
    this.files = const Value.absent(),
    this.priority = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DraftsCompanion.insert({
    required String channelId,
    this.rootId = const Value.absent(),
    this.message = const Value.absent(),
    this.selectionBase = const Value.absent(),
    this.selectionExtent = const Value.absent(),
    this.files = const Value.absent(),
    this.priority = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : channelId = Value(channelId),
       updatedAt = Value(updatedAt);
  static Insertable<DraftRow> custom({
    Expression<String>? channelId,
    Expression<String>? rootId,
    Expression<String>? message,
    Expression<int>? selectionBase,
    Expression<int>? selectionExtent,
    Expression<String>? files,
    Expression<String>? priority,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (channelId != null) 'channel_id': channelId,
      if (rootId != null) 'root_id': rootId,
      if (message != null) 'message': message,
      if (selectionBase != null) 'selection_base': selectionBase,
      if (selectionExtent != null) 'selection_extent': selectionExtent,
      if (files != null) 'files_json': files,
      if (priority != null) 'priority_json': priority,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DraftsCompanion copyWith({
    Value<String>? channelId,
    Value<String>? rootId,
    Value<String>? message,
    Value<int?>? selectionBase,
    Value<int?>? selectionExtent,
    Value<List<FileInfo>>? files,
    Value<PostPriority?>? priority,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return DraftsCompanion(
      channelId: channelId ?? this.channelId,
      rootId: rootId ?? this.rootId,
      message: message ?? this.message,
      selectionBase: selectionBase ?? this.selectionBase,
      selectionExtent: selectionExtent ?? this.selectionExtent,
      files: files ?? this.files,
      priority: priority ?? this.priority,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (channelId.present) {
      map['channel_id'] = Variable<String>(channelId.value);
    }
    if (rootId.present) {
      map['root_id'] = Variable<String>(rootId.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (selectionBase.present) {
      map['selection_base'] = Variable<int>(selectionBase.value);
    }
    if (selectionExtent.present) {
      map['selection_extent'] = Variable<int>(selectionExtent.value);
    }
    if (files.present) {
      map['files_json'] = Variable<String>(
        $DraftsTable.$converterfiles.toSql(files.value),
      );
    }
    if (priority.present) {
      map['priority_json'] = Variable<String>(
        $DraftsTable.$converterpriority.toSql(priority.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        $DraftsTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DraftsCompanion(')
          ..write('channelId: $channelId, ')
          ..write('rootId: $rootId, ')
          ..write('message: $message, ')
          ..write('selectionBase: $selectionBase, ')
          ..write('selectionExtent: $selectionExtent, ')
          ..write('files: $files, ')
          ..write('priority: $priority, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxTable extends Outbox with TableInfo<$OutboxTable, OutboxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pendingPostIdMeta = const VerificationMeta(
    'pendingPostId',
  );
  @override
  late final GeneratedColumn<String> pendingPostId = GeneratedColumn<String>(
    'pending_post_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _channelIdMeta = const VerificationMeta(
    'channelId',
  );
  @override
  late final GeneratedColumn<String> channelId = GeneratedColumn<String>(
    'channel_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rootIdMeta = const VerificationMeta('rootId');
  @override
  late final GeneratedColumn<String> rootId = GeneratedColumn<String>(
    'root_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> queuedAt =
      GeneratedColumn<int>(
        'queued_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($OutboxTable.$converterqueuedAt);
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> nextAttemptAt =
      GeneratedColumn<int>(
        'next_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($OutboxTable.$converternextAttemptAtn);
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('queued'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    pendingPostId,
    channelId,
    rootId,
    queuedAt,
    attempts,
    nextAttemptAt,
    lastError,
    state,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('pending_post_id')) {
      context.handle(
        _pendingPostIdMeta,
        pendingPostId.isAcceptableOrUnknown(
          data['pending_post_id']!,
          _pendingPostIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pendingPostIdMeta);
    }
    if (data.containsKey('channel_id')) {
      context.handle(
        _channelIdMeta,
        channelId.isAcceptableOrUnknown(data['channel_id']!, _channelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_channelIdMeta);
    }
    if (data.containsKey('root_id')) {
      context.handle(
        _rootIdMeta,
        rootId.isAcceptableOrUnknown(data['root_id']!, _rootIdMeta),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {pendingPostId};
  @override
  OutboxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxRow(
      pendingPostId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pending_post_id'],
      )!,
      channelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}channel_id'],
      )!,
      rootId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}root_id'],
      )!,
      queuedAt: $OutboxTable.$converterqueuedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}queued_at'],
        )!,
      ),
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      nextAttemptAt: $OutboxTable.$converternextAttemptAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}next_attempt_at'],
        ),
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
    );
  }

  @override
  $OutboxTable createAlias(String alias) {
    return $OutboxTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $converterqueuedAt = const Millis();
  static TypeConverter<DateTime, int> $converternextAttemptAt = const Millis();
  static TypeConverter<DateTime?, int?> $converternextAttemptAtn =
      NullAwareTypeConverter.wrap($converternextAttemptAt);
}

class OutboxRow extends DataClass implements Insertable<OutboxRow> {
  final String pendingPostId;
  final String channelId;
  final String rootId;
  final DateTime queuedAt;
  final int attempts;
  final DateTime? nextAttemptAt;
  final String? lastError;

  /// `queued`, `sending` or `failed`.
  final String state;
  const OutboxRow({
    required this.pendingPostId,
    required this.channelId,
    required this.rootId,
    required this.queuedAt,
    required this.attempts,
    this.nextAttemptAt,
    this.lastError,
    required this.state,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['pending_post_id'] = Variable<String>(pendingPostId);
    map['channel_id'] = Variable<String>(channelId);
    map['root_id'] = Variable<String>(rootId);
    {
      map['queued_at'] = Variable<int>(
        $OutboxTable.$converterqueuedAt.toSql(queuedAt),
      );
    }
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || nextAttemptAt != null) {
      map['next_attempt_at'] = Variable<int>(
        $OutboxTable.$converternextAttemptAtn.toSql(nextAttemptAt),
      );
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['state'] = Variable<String>(state);
    return map;
  }

  OutboxCompanion toCompanion(bool nullToAbsent) {
    return OutboxCompanion(
      pendingPostId: Value(pendingPostId),
      channelId: Value(channelId),
      rootId: Value(rootId),
      queuedAt: Value(queuedAt),
      attempts: Value(attempts),
      nextAttemptAt: nextAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      state: Value(state),
    );
  }

  factory OutboxRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxRow(
      pendingPostId: serializer.fromJson<String>(json['pendingPostId']),
      channelId: serializer.fromJson<String>(json['channelId']),
      rootId: serializer.fromJson<String>(json['rootId']),
      queuedAt: serializer.fromJson<DateTime>(json['queuedAt']),
      attempts: serializer.fromJson<int>(json['attempts']),
      nextAttemptAt: serializer.fromJson<DateTime?>(json['nextAttemptAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      state: serializer.fromJson<String>(json['state']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pendingPostId': serializer.toJson<String>(pendingPostId),
      'channelId': serializer.toJson<String>(channelId),
      'rootId': serializer.toJson<String>(rootId),
      'queuedAt': serializer.toJson<DateTime>(queuedAt),
      'attempts': serializer.toJson<int>(attempts),
      'nextAttemptAt': serializer.toJson<DateTime?>(nextAttemptAt),
      'lastError': serializer.toJson<String?>(lastError),
      'state': serializer.toJson<String>(state),
    };
  }

  OutboxRow copyWith({
    String? pendingPostId,
    String? channelId,
    String? rootId,
    DateTime? queuedAt,
    int? attempts,
    Value<DateTime?> nextAttemptAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
    String? state,
  }) => OutboxRow(
    pendingPostId: pendingPostId ?? this.pendingPostId,
    channelId: channelId ?? this.channelId,
    rootId: rootId ?? this.rootId,
    queuedAt: queuedAt ?? this.queuedAt,
    attempts: attempts ?? this.attempts,
    nextAttemptAt: nextAttemptAt.present
        ? nextAttemptAt.value
        : this.nextAttemptAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    state: state ?? this.state,
  );
  OutboxRow copyWithCompanion(OutboxCompanion data) {
    return OutboxRow(
      pendingPostId: data.pendingPostId.present
          ? data.pendingPostId.value
          : this.pendingPostId,
      channelId: data.channelId.present ? data.channelId.value : this.channelId,
      rootId: data.rootId.present ? data.rootId.value : this.rootId,
      queuedAt: data.queuedAt.present ? data.queuedAt.value : this.queuedAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      state: data.state.present ? data.state.value : this.state,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxRow(')
          ..write('pendingPostId: $pendingPostId, ')
          ..write('channelId: $channelId, ')
          ..write('rootId: $rootId, ')
          ..write('queuedAt: $queuedAt, ')
          ..write('attempts: $attempts, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastError: $lastError, ')
          ..write('state: $state')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    pendingPostId,
    channelId,
    rootId,
    queuedAt,
    attempts,
    nextAttemptAt,
    lastError,
    state,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxRow &&
          other.pendingPostId == this.pendingPostId &&
          other.channelId == this.channelId &&
          other.rootId == this.rootId &&
          other.queuedAt == this.queuedAt &&
          other.attempts == this.attempts &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.lastError == this.lastError &&
          other.state == this.state);
}

class OutboxCompanion extends UpdateCompanion<OutboxRow> {
  final Value<String> pendingPostId;
  final Value<String> channelId;
  final Value<String> rootId;
  final Value<DateTime> queuedAt;
  final Value<int> attempts;
  final Value<DateTime?> nextAttemptAt;
  final Value<String?> lastError;
  final Value<String> state;
  final Value<int> rowid;
  const OutboxCompanion({
    this.pendingPostId = const Value.absent(),
    this.channelId = const Value.absent(),
    this.rootId = const Value.absent(),
    this.queuedAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.state = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutboxCompanion.insert({
    required String pendingPostId,
    required String channelId,
    this.rootId = const Value.absent(),
    required DateTime queuedAt,
    this.attempts = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.state = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : pendingPostId = Value(pendingPostId),
       channelId = Value(channelId),
       queuedAt = Value(queuedAt);
  static Insertable<OutboxRow> custom({
    Expression<String>? pendingPostId,
    Expression<String>? channelId,
    Expression<String>? rootId,
    Expression<int>? queuedAt,
    Expression<int>? attempts,
    Expression<int>? nextAttemptAt,
    Expression<String>? lastError,
    Expression<String>? state,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (pendingPostId != null) 'pending_post_id': pendingPostId,
      if (channelId != null) 'channel_id': channelId,
      if (rootId != null) 'root_id': rootId,
      if (queuedAt != null) 'queued_at': queuedAt,
      if (attempts != null) 'attempts': attempts,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (lastError != null) 'last_error': lastError,
      if (state != null) 'state': state,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutboxCompanion copyWith({
    Value<String>? pendingPostId,
    Value<String>? channelId,
    Value<String>? rootId,
    Value<DateTime>? queuedAt,
    Value<int>? attempts,
    Value<DateTime?>? nextAttemptAt,
    Value<String?>? lastError,
    Value<String>? state,
    Value<int>? rowid,
  }) {
    return OutboxCompanion(
      pendingPostId: pendingPostId ?? this.pendingPostId,
      channelId: channelId ?? this.channelId,
      rootId: rootId ?? this.rootId,
      queuedAt: queuedAt ?? this.queuedAt,
      attempts: attempts ?? this.attempts,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      lastError: lastError ?? this.lastError,
      state: state ?? this.state,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pendingPostId.present) {
      map['pending_post_id'] = Variable<String>(pendingPostId.value);
    }
    if (channelId.present) {
      map['channel_id'] = Variable<String>(channelId.value);
    }
    if (rootId.present) {
      map['root_id'] = Variable<String>(rootId.value);
    }
    if (queuedAt.present) {
      map['queued_at'] = Variable<int>(
        $OutboxTable.$converterqueuedAt.toSql(queuedAt.value),
      );
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<int>(
        $OutboxTable.$converternextAttemptAtn.toSql(nextAttemptAt.value),
      );
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxCompanion(')
          ..write('pendingPostId: $pendingPostId, ')
          ..write('channelId: $channelId, ')
          ..write('rootId: $rootId, ')
          ..write('queuedAt: $queuedAt, ')
          ..write('attempts: $attempts, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastError: $lastError, ')
          ..write('state: $state, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PostListsTable extends PostLists
    with TableInfo<$PostListsTable, PostListRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PostListsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _listMeta = const VerificationMeta('list');
  @override
  late final GeneratedColumn<String> list = GeneratedColumn<String>(
    'list',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _postIdMeta = const VerificationMeta('postId');
  @override
  late final GeneratedColumn<String> postId = GeneratedColumn<String>(
    'post_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rankMeta = const VerificationMeta('rank');
  @override
  late final GeneratedColumn<int> rank = GeneratedColumn<int>(
    'rank',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [list, postId, rank];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'post_lists';
  @override
  VerificationContext validateIntegrity(
    Insertable<PostListRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('list')) {
      context.handle(
        _listMeta,
        list.isAcceptableOrUnknown(data['list']!, _listMeta),
      );
    } else if (isInserting) {
      context.missing(_listMeta);
    }
    if (data.containsKey('post_id')) {
      context.handle(
        _postIdMeta,
        postId.isAcceptableOrUnknown(data['post_id']!, _postIdMeta),
      );
    } else if (isInserting) {
      context.missing(_postIdMeta);
    }
    if (data.containsKey('rank')) {
      context.handle(
        _rankMeta,
        rank.isAcceptableOrUnknown(data['rank']!, _rankMeta),
      );
    } else if (isInserting) {
      context.missing(_rankMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {list, postId};
  @override
  PostListRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PostListRow(
      list: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}list'],
      )!,
      postId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}post_id'],
      )!,
      rank: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rank'],
      )!,
    );
  }

  @override
  $PostListsTable createAlias(String alias) {
    return $PostListsTable(attachedDatabase, alias);
  }
}

class PostListRow extends DataClass implements Insertable<PostListRow> {
  final String list;
  final String postId;
  final int rank;
  const PostListRow({
    required this.list,
    required this.postId,
    required this.rank,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['list'] = Variable<String>(list);
    map['post_id'] = Variable<String>(postId);
    map['rank'] = Variable<int>(rank);
    return map;
  }

  PostListsCompanion toCompanion(bool nullToAbsent) {
    return PostListsCompanion(
      list: Value(list),
      postId: Value(postId),
      rank: Value(rank),
    );
  }

  factory PostListRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PostListRow(
      list: serializer.fromJson<String>(json['list']),
      postId: serializer.fromJson<String>(json['postId']),
      rank: serializer.fromJson<int>(json['rank']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'list': serializer.toJson<String>(list),
      'postId': serializer.toJson<String>(postId),
      'rank': serializer.toJson<int>(rank),
    };
  }

  PostListRow copyWith({String? list, String? postId, int? rank}) =>
      PostListRow(
        list: list ?? this.list,
        postId: postId ?? this.postId,
        rank: rank ?? this.rank,
      );
  PostListRow copyWithCompanion(PostListsCompanion data) {
    return PostListRow(
      list: data.list.present ? data.list.value : this.list,
      postId: data.postId.present ? data.postId.value : this.postId,
      rank: data.rank.present ? data.rank.value : this.rank,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PostListRow(')
          ..write('list: $list, ')
          ..write('postId: $postId, ')
          ..write('rank: $rank')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(list, postId, rank);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PostListRow &&
          other.list == this.list &&
          other.postId == this.postId &&
          other.rank == this.rank);
}

class PostListsCompanion extends UpdateCompanion<PostListRow> {
  final Value<String> list;
  final Value<String> postId;
  final Value<int> rank;
  final Value<int> rowid;
  const PostListsCompanion({
    this.list = const Value.absent(),
    this.postId = const Value.absent(),
    this.rank = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PostListsCompanion.insert({
    required String list,
    required String postId,
    required int rank,
    this.rowid = const Value.absent(),
  }) : list = Value(list),
       postId = Value(postId),
       rank = Value(rank);
  static Insertable<PostListRow> custom({
    Expression<String>? list,
    Expression<String>? postId,
    Expression<int>? rank,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (list != null) 'list': list,
      if (postId != null) 'post_id': postId,
      if (rank != null) 'rank': rank,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PostListsCompanion copyWith({
    Value<String>? list,
    Value<String>? postId,
    Value<int>? rank,
    Value<int>? rowid,
  }) {
    return PostListsCompanion(
      list: list ?? this.list,
      postId: postId ?? this.postId,
      rank: rank ?? this.rank,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (list.present) {
      map['list'] = Variable<String>(list.value);
    }
    if (postId.present) {
      map['post_id'] = Variable<String>(postId.value);
    }
    if (rank.present) {
      map['rank'] = Variable<int>(rank.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PostListsCompanion(')
          ..write('list: $list, ')
          ..write('postId: $postId, ')
          ..write('rank: $rank, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SearchHistoryTable extends SearchHistory
    with TableInfo<$SearchHistoryTable, SearchHistoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SearchHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _teamIdMeta = const VerificationMeta('teamId');
  @override
  late final GeneratedColumn<String> teamId = GeneratedColumn<String>(
    'team_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _termMeta = const VerificationMeta('term');
  @override
  late final GeneratedColumn<String> term = GeneratedColumn<String>(
    'term',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($SearchHistoryTable.$convertercreatedAt);
  @override
  List<GeneratedColumn> get $columns => [teamId, term, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'search_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<SearchHistoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('team_id')) {
      context.handle(
        _teamIdMeta,
        teamId.isAcceptableOrUnknown(data['team_id']!, _teamIdMeta),
      );
    } else if (isInserting) {
      context.missing(_teamIdMeta);
    }
    if (data.containsKey('term')) {
      context.handle(
        _termMeta,
        term.isAcceptableOrUnknown(data['term']!, _termMeta),
      );
    } else if (isInserting) {
      context.missing(_termMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {teamId, term};
  @override
  SearchHistoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SearchHistoryRow(
      teamId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}team_id'],
      )!,
      term: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}term'],
      )!,
      createdAt: $SearchHistoryTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
    );
  }

  @override
  $SearchHistoryTable createAlias(String alias) {
    return $SearchHistoryTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreatedAt = const Millis();
}

class SearchHistoryRow extends DataClass
    implements Insertable<SearchHistoryRow> {
  final String teamId;
  final String term;
  final DateTime createdAt;
  const SearchHistoryRow({
    required this.teamId,
    required this.term,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['team_id'] = Variable<String>(teamId);
    map['term'] = Variable<String>(term);
    {
      map['created_at'] = Variable<int>(
        $SearchHistoryTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    return map;
  }

  SearchHistoryCompanion toCompanion(bool nullToAbsent) {
    return SearchHistoryCompanion(
      teamId: Value(teamId),
      term: Value(term),
      createdAt: Value(createdAt),
    );
  }

  factory SearchHistoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SearchHistoryRow(
      teamId: serializer.fromJson<String>(json['teamId']),
      term: serializer.fromJson<String>(json['term']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'teamId': serializer.toJson<String>(teamId),
      'term': serializer.toJson<String>(term),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SearchHistoryRow copyWith({
    String? teamId,
    String? term,
    DateTime? createdAt,
  }) => SearchHistoryRow(
    teamId: teamId ?? this.teamId,
    term: term ?? this.term,
    createdAt: createdAt ?? this.createdAt,
  );
  SearchHistoryRow copyWithCompanion(SearchHistoryCompanion data) {
    return SearchHistoryRow(
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
      term: data.term.present ? data.term.value : this.term,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SearchHistoryRow(')
          ..write('teamId: $teamId, ')
          ..write('term: $term, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(teamId, term, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SearchHistoryRow &&
          other.teamId == this.teamId &&
          other.term == this.term &&
          other.createdAt == this.createdAt);
}

class SearchHistoryCompanion extends UpdateCompanion<SearchHistoryRow> {
  final Value<String> teamId;
  final Value<String> term;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SearchHistoryCompanion({
    this.teamId = const Value.absent(),
    this.term = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SearchHistoryCompanion.insert({
    required String teamId,
    required String term,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : teamId = Value(teamId),
       term = Value(term),
       createdAt = Value(createdAt);
  static Insertable<SearchHistoryRow> custom({
    Expression<String>? teamId,
    Expression<String>? term,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (teamId != null) 'team_id': teamId,
      if (term != null) 'term': term,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SearchHistoryCompanion copyWith({
    Value<String>? teamId,
    Value<String>? term,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SearchHistoryCompanion(
      teamId: teamId ?? this.teamId,
      term: term ?? this.term,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (teamId.present) {
      map['team_id'] = Variable<String>(teamId.value);
    }
    if (term.present) {
      map['term'] = Variable<String>(term.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $SearchHistoryTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SearchHistoryCompanion(')
          ..write('teamId: $teamId, ')
          ..write('term: $term, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ViewStatesTable extends ViewStates
    with TableInfo<$ViewStatesTable, ViewStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ViewStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
    'scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scopeIdMeta = const VerificationMeta(
    'scopeId',
  );
  @override
  late final GeneratedColumn<String> scopeId = GeneratedColumn<String>(
    'scope_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _anchorPostIdMeta = const VerificationMeta(
    'anchorPostId',
  );
  @override
  late final GeneratedColumn<String> anchorPostId = GeneratedColumn<String>(
    'anchor_post_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _anchorOffsetPxMeta = const VerificationMeta(
    'anchorOffsetPx',
  );
  @override
  late final GeneratedColumn<double> anchorOffsetPx = GeneratedColumn<double>(
    'anchor_offset_px',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> savedAt =
      GeneratedColumn<int>(
        'saved_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ViewStatesTable.$convertersavedAt);
  @override
  List<GeneratedColumn> get $columns => [
    scope,
    scopeId,
    anchorPostId,
    anchorOffsetPx,
    savedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'view_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<ViewStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('scope')) {
      context.handle(
        _scopeMeta,
        scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeMeta);
    }
    if (data.containsKey('scope_id')) {
      context.handle(
        _scopeIdMeta,
        scopeId.isAcceptableOrUnknown(data['scope_id']!, _scopeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeIdMeta);
    }
    if (data.containsKey('anchor_post_id')) {
      context.handle(
        _anchorPostIdMeta,
        anchorPostId.isAcceptableOrUnknown(
          data['anchor_post_id']!,
          _anchorPostIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_anchorPostIdMeta);
    }
    if (data.containsKey('anchor_offset_px')) {
      context.handle(
        _anchorOffsetPxMeta,
        anchorOffsetPx.isAcceptableOrUnknown(
          data['anchor_offset_px']!,
          _anchorOffsetPxMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {scope, scopeId};
  @override
  ViewStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ViewStateRow(
      scope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope'],
      )!,
      scopeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope_id'],
      )!,
      anchorPostId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}anchor_post_id'],
      )!,
      anchorOffsetPx: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}anchor_offset_px'],
      )!,
      savedAt: $ViewStatesTable.$convertersavedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}saved_at'],
        )!,
      ),
    );
  }

  @override
  $ViewStatesTable createAlias(String alias) {
    return $ViewStatesTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertersavedAt = const Millis();
}

class ViewStateRow extends DataClass implements Insertable<ViewStateRow> {
  final String scope;
  final String scopeId;
  final String anchorPostId;
  final double anchorOffsetPx;
  final DateTime savedAt;
  const ViewStateRow({
    required this.scope,
    required this.scopeId,
    required this.anchorPostId,
    required this.anchorOffsetPx,
    required this.savedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['scope'] = Variable<String>(scope);
    map['scope_id'] = Variable<String>(scopeId);
    map['anchor_post_id'] = Variable<String>(anchorPostId);
    map['anchor_offset_px'] = Variable<double>(anchorOffsetPx);
    {
      map['saved_at'] = Variable<int>(
        $ViewStatesTable.$convertersavedAt.toSql(savedAt),
      );
    }
    return map;
  }

  ViewStatesCompanion toCompanion(bool nullToAbsent) {
    return ViewStatesCompanion(
      scope: Value(scope),
      scopeId: Value(scopeId),
      anchorPostId: Value(anchorPostId),
      anchorOffsetPx: Value(anchorOffsetPx),
      savedAt: Value(savedAt),
    );
  }

  factory ViewStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ViewStateRow(
      scope: serializer.fromJson<String>(json['scope']),
      scopeId: serializer.fromJson<String>(json['scopeId']),
      anchorPostId: serializer.fromJson<String>(json['anchorPostId']),
      anchorOffsetPx: serializer.fromJson<double>(json['anchorOffsetPx']),
      savedAt: serializer.fromJson<DateTime>(json['savedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'scope': serializer.toJson<String>(scope),
      'scopeId': serializer.toJson<String>(scopeId),
      'anchorPostId': serializer.toJson<String>(anchorPostId),
      'anchorOffsetPx': serializer.toJson<double>(anchorOffsetPx),
      'savedAt': serializer.toJson<DateTime>(savedAt),
    };
  }

  ViewStateRow copyWith({
    String? scope,
    String? scopeId,
    String? anchorPostId,
    double? anchorOffsetPx,
    DateTime? savedAt,
  }) => ViewStateRow(
    scope: scope ?? this.scope,
    scopeId: scopeId ?? this.scopeId,
    anchorPostId: anchorPostId ?? this.anchorPostId,
    anchorOffsetPx: anchorOffsetPx ?? this.anchorOffsetPx,
    savedAt: savedAt ?? this.savedAt,
  );
  ViewStateRow copyWithCompanion(ViewStatesCompanion data) {
    return ViewStateRow(
      scope: data.scope.present ? data.scope.value : this.scope,
      scopeId: data.scopeId.present ? data.scopeId.value : this.scopeId,
      anchorPostId: data.anchorPostId.present
          ? data.anchorPostId.value
          : this.anchorPostId,
      anchorOffsetPx: data.anchorOffsetPx.present
          ? data.anchorOffsetPx.value
          : this.anchorOffsetPx,
      savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ViewStateRow(')
          ..write('scope: $scope, ')
          ..write('scopeId: $scopeId, ')
          ..write('anchorPostId: $anchorPostId, ')
          ..write('anchorOffsetPx: $anchorOffsetPx, ')
          ..write('savedAt: $savedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(scope, scopeId, anchorPostId, anchorOffsetPx, savedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ViewStateRow &&
          other.scope == this.scope &&
          other.scopeId == this.scopeId &&
          other.anchorPostId == this.anchorPostId &&
          other.anchorOffsetPx == this.anchorOffsetPx &&
          other.savedAt == this.savedAt);
}

class ViewStatesCompanion extends UpdateCompanion<ViewStateRow> {
  final Value<String> scope;
  final Value<String> scopeId;
  final Value<String> anchorPostId;
  final Value<double> anchorOffsetPx;
  final Value<DateTime> savedAt;
  final Value<int> rowid;
  const ViewStatesCompanion({
    this.scope = const Value.absent(),
    this.scopeId = const Value.absent(),
    this.anchorPostId = const Value.absent(),
    this.anchorOffsetPx = const Value.absent(),
    this.savedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ViewStatesCompanion.insert({
    required String scope,
    required String scopeId,
    required String anchorPostId,
    this.anchorOffsetPx = const Value.absent(),
    required DateTime savedAt,
    this.rowid = const Value.absent(),
  }) : scope = Value(scope),
       scopeId = Value(scopeId),
       anchorPostId = Value(anchorPostId),
       savedAt = Value(savedAt);
  static Insertable<ViewStateRow> custom({
    Expression<String>? scope,
    Expression<String>? scopeId,
    Expression<String>? anchorPostId,
    Expression<double>? anchorOffsetPx,
    Expression<int>? savedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (scope != null) 'scope': scope,
      if (scopeId != null) 'scope_id': scopeId,
      if (anchorPostId != null) 'anchor_post_id': anchorPostId,
      if (anchorOffsetPx != null) 'anchor_offset_px': anchorOffsetPx,
      if (savedAt != null) 'saved_at': savedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ViewStatesCompanion copyWith({
    Value<String>? scope,
    Value<String>? scopeId,
    Value<String>? anchorPostId,
    Value<double>? anchorOffsetPx,
    Value<DateTime>? savedAt,
    Value<int>? rowid,
  }) {
    return ViewStatesCompanion(
      scope: scope ?? this.scope,
      scopeId: scopeId ?? this.scopeId,
      anchorPostId: anchorPostId ?? this.anchorPostId,
      anchorOffsetPx: anchorOffsetPx ?? this.anchorOffsetPx,
      savedAt: savedAt ?? this.savedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (scopeId.present) {
      map['scope_id'] = Variable<String>(scopeId.value);
    }
    if (anchorPostId.present) {
      map['anchor_post_id'] = Variable<String>(anchorPostId.value);
    }
    if (anchorOffsetPx.present) {
      map['anchor_offset_px'] = Variable<double>(anchorOffsetPx.value);
    }
    if (savedAt.present) {
      map['saved_at'] = Variable<int>(
        $ViewStatesTable.$convertersavedAt.toSql(savedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ViewStatesCompanion(')
          ..write('scope: $scope, ')
          ..write('scopeId: $scopeId, ')
          ..write('anchorPostId: $anchorPostId, ')
          ..write('anchorOffsetPx: $anchorOffsetPx, ')
          ..write('savedAt: $savedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncStateTable extends SyncState
    with TableInfo<$SyncStateTable, SyncStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueIntMeta = const VerificationMeta(
    'valueInt',
  );
  @override
  late final GeneratedColumn<int> valueInt = GeneratedColumn<int>(
    'value_int',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _valueTextMeta = const VerificationMeta(
    'valueText',
  );
  @override
  late final GeneratedColumn<String> valueText = GeneratedColumn<String>(
    'value_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [key, valueInt, valueText];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncStateRow> instance, {
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
    if (data.containsKey('value_int')) {
      context.handle(
        _valueIntMeta,
        valueInt.isAcceptableOrUnknown(data['value_int']!, _valueIntMeta),
      );
    }
    if (data.containsKey('value_text')) {
      context.handle(
        _valueTextMeta,
        valueText.isAcceptableOrUnknown(data['value_text']!, _valueTextMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SyncStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      valueInt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}value_int'],
      ),
      valueText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_text'],
      ),
    );
  }

  @override
  $SyncStateTable createAlias(String alias) {
    return $SyncStateTable(attachedDatabase, alias);
  }
}

class SyncStateRow extends DataClass implements Insertable<SyncStateRow> {
  final String key;
  final int? valueInt;
  final String? valueText;
  const SyncStateRow({required this.key, this.valueInt, this.valueText});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || valueInt != null) {
      map['value_int'] = Variable<int>(valueInt);
    }
    if (!nullToAbsent || valueText != null) {
      map['value_text'] = Variable<String>(valueText);
    }
    return map;
  }

  SyncStateCompanion toCompanion(bool nullToAbsent) {
    return SyncStateCompanion(
      key: Value(key),
      valueInt: valueInt == null && nullToAbsent
          ? const Value.absent()
          : Value(valueInt),
      valueText: valueText == null && nullToAbsent
          ? const Value.absent()
          : Value(valueText),
    );
  }

  factory SyncStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateRow(
      key: serializer.fromJson<String>(json['key']),
      valueInt: serializer.fromJson<int?>(json['valueInt']),
      valueText: serializer.fromJson<String?>(json['valueText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'valueInt': serializer.toJson<int?>(valueInt),
      'valueText': serializer.toJson<String?>(valueText),
    };
  }

  SyncStateRow copyWith({
    String? key,
    Value<int?> valueInt = const Value.absent(),
    Value<String?> valueText = const Value.absent(),
  }) => SyncStateRow(
    key: key ?? this.key,
    valueInt: valueInt.present ? valueInt.value : this.valueInt,
    valueText: valueText.present ? valueText.value : this.valueText,
  );
  SyncStateRow copyWithCompanion(SyncStateCompanion data) {
    return SyncStateRow(
      key: data.key.present ? data.key.value : this.key,
      valueInt: data.valueInt.present ? data.valueInt.value : this.valueInt,
      valueText: data.valueText.present ? data.valueText.value : this.valueText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateRow(')
          ..write('key: $key, ')
          ..write('valueInt: $valueInt, ')
          ..write('valueText: $valueText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, valueInt, valueText);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStateRow &&
          other.key == this.key &&
          other.valueInt == this.valueInt &&
          other.valueText == this.valueText);
}

class SyncStateCompanion extends UpdateCompanion<SyncStateRow> {
  final Value<String> key;
  final Value<int?> valueInt;
  final Value<String?> valueText;
  final Value<int> rowid;
  const SyncStateCompanion({
    this.key = const Value.absent(),
    this.valueInt = const Value.absent(),
    this.valueText = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStateCompanion.insert({
    required String key,
    this.valueInt = const Value.absent(),
    this.valueText = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<SyncStateRow> custom({
    Expression<String>? key,
    Expression<int>? valueInt,
    Expression<String>? valueText,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (valueInt != null) 'value_int': valueInt,
      if (valueText != null) 'value_text': valueText,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStateCompanion copyWith({
    Value<String>? key,
    Value<int?>? valueInt,
    Value<String?>? valueText,
    Value<int>? rowid,
  }) {
    return SyncStateCompanion(
      key: key ?? this.key,
      valueInt: valueInt ?? this.valueInt,
      valueText: valueText ?? this.valueText,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (valueInt.present) {
      map['value_int'] = Variable<int>(valueInt.value);
    }
    if (valueText.present) {
      map['value_text'] = Variable<String>(valueText.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateCompanion(')
          ..write('key: $key, ')
          ..write('valueInt: $valueInt, ')
          ..write('valueText: $valueText, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConfigTable extends Config with TableInfo<$ConfigTable, ConfigRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConfigTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> fetchedAt =
      GeneratedColumn<int>(
        'fetched_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ConfigTable.$converterfetchedAt);
  @override
  List<GeneratedColumn> get $columns => [key, json, fetchedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'config';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConfigRow> instance, {
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
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  ConfigRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConfigRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
      fetchedAt: $ConfigTable.$converterfetchedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}fetched_at'],
        )!,
      ),
    );
  }

  @override
  $ConfigTable createAlias(String alias) {
    return $ConfigTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $converterfetchedAt = const Millis();
}

class ConfigRow extends DataClass implements Insertable<ConfigRow> {
  final String key;
  final String json;
  final DateTime fetchedAt;
  const ConfigRow({
    required this.key,
    required this.json,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['json'] = Variable<String>(json);
    {
      map['fetched_at'] = Variable<int>(
        $ConfigTable.$converterfetchedAt.toSql(fetchedAt),
      );
    }
    return map;
  }

  ConfigCompanion toCompanion(bool nullToAbsent) {
    return ConfigCompanion(
      key: Value(key),
      json: Value(json),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory ConfigRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConfigRow(
      key: serializer.fromJson<String>(json['key']),
      json: serializer.fromJson<String>(json['json']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'json': serializer.toJson<String>(json),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  ConfigRow copyWith({String? key, String? json, DateTime? fetchedAt}) =>
      ConfigRow(
        key: key ?? this.key,
        json: json ?? this.json,
        fetchedAt: fetchedAt ?? this.fetchedAt,
      );
  ConfigRow copyWithCompanion(ConfigCompanion data) {
    return ConfigRow(
      key: data.key.present ? data.key.value : this.key,
      json: data.json.present ? data.json.value : this.json,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConfigRow(')
          ..write('key: $key, ')
          ..write('json: $json, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, json, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConfigRow &&
          other.key == this.key &&
          other.json == this.json &&
          other.fetchedAt == this.fetchedAt);
}

class ConfigCompanion extends UpdateCompanion<ConfigRow> {
  final Value<String> key;
  final Value<String> json;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const ConfigCompanion({
    this.key = const Value.absent(),
    this.json = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConfigCompanion.insert({
    required String key,
    required String json,
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       json = Value(json),
       fetchedAt = Value(fetchedAt);
  static Insertable<ConfigRow> custom({
    Expression<String>? key,
    Expression<String>? json,
    Expression<int>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (json != null) 'json': json,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConfigCompanion copyWith({
    Value<String>? key,
    Value<String>? json,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return ConfigCompanion(
      key: key ?? this.key,
      json: json ?? this.json,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<int>(
        $ConfigTable.$converterfetchedAt.toSql(fetchedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConfigCompanion(')
          ..write('key: $key, ')
          ..write('json: $json, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$ServerDatabase extends GeneratedDatabase {
  _$ServerDatabase(QueryExecutor e) : super(e);
  $ServerDatabaseManager get managers => $ServerDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $TeamsTable teams = $TeamsTable(this);
  late final $MyTeamsTable myTeams = $MyTeamsTable(this);
  late final $ChannelsTable channels = $ChannelsTable(this);
  late final $MyChannelsTable myChannels = $MyChannelsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $CategoryChannelsTable categoryChannels = $CategoryChannelsTable(
    this,
  );
  late final $PostsTable posts = $PostsTable(this);
  late final $PostRangesTable postRanges = $PostRangesTable(this);
  late final $ReactionsTable reactions = $ReactionsTable(this);
  late final $FilesTable files = $FilesTable(this);
  late final $ThreadsTable threads = $ThreadsTable(this);
  late final $ThreadTeamsTable threadTeams = $ThreadTeamsTable(this);
  late final $ThreadSyncTable threadSync = $ThreadSyncTable(this);
  late final $CustomEmojiTable customEmoji = $CustomEmojiTable(this);
  late final $PreferencesTable preferences = $PreferencesTable(this);
  late final $RolesTable roles = $RolesTable(this);
  late final $DraftsTable drafts = $DraftsTable(this);
  late final $OutboxTable outbox = $OutboxTable(this);
  late final $PostListsTable postLists = $PostListsTable(this);
  late final $SearchHistoryTable searchHistory = $SearchHistoryTable(this);
  late final $ViewStatesTable viewStates = $ViewStatesTable(this);
  late final $SyncStateTable syncState = $SyncStateTable(this);
  late final $ConfigTable config = $ConfigTable(this);
  late final Index channelsByTeam = Index(
    'channels_by_team',
    'CREATE INDEX channels_by_team ON channels (team_id)',
  );
  late final Index categoriesByTeam = Index(
    'categories_by_team',
    'CREATE INDEX categories_by_team ON categories (team_id)',
  );
  late final Index postsByChannel = Index(
    'posts_by_channel',
    'CREATE INDEX posts_by_channel ON posts (channel_id, create_at)',
  );
  late final Index postsByRoot = Index(
    'posts_by_root',
    'CREATE INDEX posts_by_root ON posts (root_id, create_at)',
  );
  late final Index postsByPending = Index(
    'posts_by_pending',
    'CREATE INDEX posts_by_pending ON posts (pending_post_id)',
  );
  late final Index postRangesByScope = Index(
    'post_ranges_by_scope',
    'CREATE INDEX post_ranges_by_scope ON post_ranges (scope, scope_id, latest)',
  );
  late final Index reactionsByPost = Index(
    'reactions_by_post',
    'CREATE INDEX reactions_by_post ON reactions (post_id)',
  );
  late final Index filesByPost = Index(
    'files_by_post',
    'CREATE INDEX files_by_post ON files (post_id)',
  );
  late final Index customEmojiByName = Index(
    'custom_emoji_by_name',
    'CREATE UNIQUE INDEX custom_emoji_by_name ON custom_emoji (name)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    teams,
    myTeams,
    channels,
    myChannels,
    categories,
    categoryChannels,
    posts,
    postRanges,
    reactions,
    files,
    threads,
    threadTeams,
    threadSync,
    customEmoji,
    preferences,
    roles,
    drafts,
    outbox,
    postLists,
    searchHistory,
    viewStates,
    syncState,
    config,
    channelsByTeam,
    categoriesByTeam,
    postsByChannel,
    postsByRoot,
    postsByPending,
    postRangesByScope,
    reactionsByPost,
    filesByPost,
    customEmojiByName,
  ];
}

typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  required String id,
  required String username,
  Value<String> nickname,
  Value<String> firstName,
  Value<String> lastName,
  Value<String> position,
  Value<String?> locale,
  Value<bool> isBot,
  Value<String?> roles,
  Value<DateTime?> updateAt,
  Value<DateTime?> deleteAt,
  Value<int?> lastPictureUpdate,
  Value<Timezone?> timezone,
  Value<Map<String, Object?>?> props,
  Value<String> status,
  Value<DateTime?> statusUpdatedAt,
  Value<int> rowid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<String> id,
  Value<String> username,
  Value<String> nickname,
  Value<String> firstName,
  Value<String> lastName,
  Value<String> position,
  Value<String?> locale,
  Value<bool> isBot,
  Value<String?> roles,
  Value<DateTime?> updateAt,
  Value<DateTime?> deleteAt,
  Value<int?> lastPictureUpdate,
  Value<Timezone?> timezone,
  Value<Map<String, Object?>?> props,
  Value<String> status,
  Value<DateTime?> statusUpdatedAt,
  Value<int> rowid,
});

class $$UsersTableFilterComposer
    extends Composer<_$ServerDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBot => $composableBuilder(
    column: $table.isBot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roles => $composableBuilder(
    column: $table.roles,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get updateAt =>
      $composableBuilder(
        column: $table.updateAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get deleteAt =>
      $composableBuilder(
        column: $table.deleteAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get lastPictureUpdate => $composableBuilder(
    column: $table.lastPictureUpdate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Timezone?, Timezone, String> get timezone =>
      $composableBuilder(
        column: $table.timezone,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<
    Map<String, Object?>?,
    Map<String, Object>?,
    String
  >
  get props => $composableBuilder(
    column: $table.props,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int>
  get statusUpdatedAt => $composableBuilder(
    column: $table.statusUpdatedAt,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$UsersTableOrderingComposer
    extends Composer<_$ServerDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBot => $composableBuilder(
    column: $table.isBot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roles => $composableBuilder(
    column: $table.roles,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updateAt => $composableBuilder(
    column: $table.updateAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deleteAt => $composableBuilder(
    column: $table.deleteAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastPictureUpdate => $composableBuilder(
    column: $table.lastPictureUpdate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get props => $composableBuilder(
    column: $table.props,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get statusUpdatedAt => $composableBuilder(
    column: $table.statusUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$ServerDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<bool> get isBot =>
      $composableBuilder(column: $table.isBot, builder: (column) => column);

  GeneratedColumn<String> get roles =>
      $composableBuilder(column: $table.roles, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get updateAt =>
      $composableBuilder(column: $table.updateAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get deleteAt =>
      $composableBuilder(column: $table.deleteAt, builder: (column) => column);

  GeneratedColumn<int> get lastPictureUpdate => $composableBuilder(
    column: $table.lastPictureUpdate,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Timezone?, String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, Object?>?, String> get props =>
      $composableBuilder(column: $table.props, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get statusUpdatedAt =>
      $composableBuilder(
        column: $table.statusUpdatedAt,
        builder: (column) => column,
      );
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$ServerDatabase,
          $UsersTable,
          UserRow,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (UserRow, BaseReferences<_$ServerDatabase, $UsersTable, UserRow>),
          UserRow,
          PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$ServerDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String> nickname = const Value.absent(),
                Value<String> firstName = const Value.absent(),
                Value<String> lastName = const Value.absent(),
                Value<String> position = const Value.absent(),
                Value<String?> locale = const Value.absent(),
                Value<bool> isBot = const Value.absent(),
                Value<String?> roles = const Value.absent(),
                Value<DateTime?> updateAt = const Value.absent(),
                Value<DateTime?> deleteAt = const Value.absent(),
                Value<int?> lastPictureUpdate = const Value.absent(),
                Value<Timezone?> timezone = const Value.absent(),
                Value<Map<String, Object?>?> props = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> statusUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                username: username,
                nickname: nickname,
                firstName: firstName,
                lastName: lastName,
                position: position,
                locale: locale,
                isBot: isBot,
                roles: roles,
                updateAt: updateAt,
                deleteAt: deleteAt,
                lastPictureUpdate: lastPictureUpdate,
                timezone: timezone,
                props: props,
                status: status,
                statusUpdatedAt: statusUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String username,
                Value<String> nickname = const Value.absent(),
                Value<String> firstName = const Value.absent(),
                Value<String> lastName = const Value.absent(),
                Value<String> position = const Value.absent(),
                Value<String?> locale = const Value.absent(),
                Value<bool> isBot = const Value.absent(),
                Value<String?> roles = const Value.absent(),
                Value<DateTime?> updateAt = const Value.absent(),
                Value<DateTime?> deleteAt = const Value.absent(),
                Value<int?> lastPictureUpdate = const Value.absent(),
                Value<Timezone?> timezone = const Value.absent(),
                Value<Map<String, Object?>?> props = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> statusUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                username: username,
                nickname: nickname,
                firstName: firstName,
                lastName: lastName,
                position: position,
                locale: locale,
                isBot: isBot,
                roles: roles,
                updateAt: updateAt,
                deleteAt: deleteAt,
                lastPictureUpdate: lastPictureUpdate,
                timezone: timezone,
                props: props,
                status: status,
                statusUpdatedAt: statusUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UsersTable, UserRow>(table),
                  BaseReferences<_$ServerDatabase, $UsersTable, UserRow>(
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

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$ServerDatabase,
      $UsersTable,
      UserRow,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (UserRow, BaseReferences<_$ServerDatabase, $UsersTable, UserRow>),
      UserRow,
      PrefetchHooks Function()
    >;
typedef $$TeamsTableCreateCompanionBuilder = TeamsCompanion Function({
  required String id,
  required String name,
  required String displayName,
  required String type,
  Value<String> description,
  Value<DateTime?> updateAt,
  Value<DateTime?> deleteAt,
  Value<int?> lastTeamIconUpdate,
  Value<int> rowid,
});
typedef $$TeamsTableUpdateCompanionBuilder = TeamsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> displayName,
  Value<String> type,
  Value<String> description,
  Value<DateTime?> updateAt,
  Value<DateTime?> deleteAt,
  Value<int?> lastTeamIconUpdate,
  Value<int> rowid,
});

class $$TeamsTableFilterComposer
    extends Composer<_$ServerDatabase, $TeamsTable> {
  $$TeamsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get updateAt =>
      $composableBuilder(
        column: $table.updateAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get deleteAt =>
      $composableBuilder(
        column: $table.deleteAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get lastTeamIconUpdate => $composableBuilder(
    column: $table.lastTeamIconUpdate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TeamsTableOrderingComposer
    extends Composer<_$ServerDatabase, $TeamsTable> {
  $$TeamsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updateAt => $composableBuilder(
    column: $table.updateAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deleteAt => $composableBuilder(
    column: $table.deleteAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastTeamIconUpdate => $composableBuilder(
    column: $table.lastTeamIconUpdate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TeamsTableAnnotationComposer
    extends Composer<_$ServerDatabase, $TeamsTable> {
  $$TeamsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime?, int> get updateAt =>
      $composableBuilder(column: $table.updateAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get deleteAt =>
      $composableBuilder(column: $table.deleteAt, builder: (column) => column);

  GeneratedColumn<int> get lastTeamIconUpdate => $composableBuilder(
    column: $table.lastTeamIconUpdate,
    builder: (column) => column,
  );
}

class $$TeamsTableTableManager
    extends
        RootTableManager<
          _$ServerDatabase,
          $TeamsTable,
          TeamRow,
          $$TeamsTableFilterComposer,
          $$TeamsTableOrderingComposer,
          $$TeamsTableAnnotationComposer,
          $$TeamsTableCreateCompanionBuilder,
          $$TeamsTableUpdateCompanionBuilder,
          (TeamRow, BaseReferences<_$ServerDatabase, $TeamsTable, TeamRow>),
          TeamRow,
          PrefetchHooks Function()
        > {
  $$TeamsTableTableManager(_$ServerDatabase db, $TeamsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TeamsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TeamsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TeamsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<DateTime?> updateAt = const Value.absent(),
                Value<DateTime?> deleteAt = const Value.absent(),
                Value<int?> lastTeamIconUpdate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TeamsCompanion(
                id: id,
                name: name,
                displayName: displayName,
                type: type,
                description: description,
                updateAt: updateAt,
                deleteAt: deleteAt,
                lastTeamIconUpdate: lastTeamIconUpdate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String displayName,
                required String type,
                Value<String> description = const Value.absent(),
                Value<DateTime?> updateAt = const Value.absent(),
                Value<DateTime?> deleteAt = const Value.absent(),
                Value<int?> lastTeamIconUpdate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TeamsCompanion.insert(
                id: id,
                name: name,
                displayName: displayName,
                type: type,
                description: description,
                updateAt: updateAt,
                deleteAt: deleteAt,
                lastTeamIconUpdate: lastTeamIconUpdate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TeamsTable, TeamRow>(table),
                  BaseReferences<_$ServerDatabase, $TeamsTable, TeamRow>(
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

typedef $$TeamsTableProcessedTableManager =
    ProcessedTableManager<
      _$ServerDatabase,
      $TeamsTable,
      TeamRow,
      $$TeamsTableFilterComposer,
      $$TeamsTableOrderingComposer,
      $$TeamsTableAnnotationComposer,
      $$TeamsTableCreateCompanionBuilder,
      $$TeamsTableUpdateCompanionBuilder,
      (TeamRow, BaseReferences<_$ServerDatabase, $TeamsTable, TeamRow>),
      TeamRow,
      PrefetchHooks Function()
    >;
typedef $$MyTeamsTableCreateCompanionBuilder = MyTeamsCompanion Function({
  required String teamId,
  Value<String> roles,
  Value<int> msgCount,
  Value<int> mentionCount,
  Value<int> msgCountRoot,
  Value<int> mentionCountRoot,
  Value<int> rowid,
});
typedef $$MyTeamsTableUpdateCompanionBuilder = MyTeamsCompanion Function({
  Value<String> teamId,
  Value<String> roles,
  Value<int> msgCount,
  Value<int> mentionCount,
  Value<int> msgCountRoot,
  Value<int> mentionCountRoot,
  Value<int> rowid,
});

class $$MyTeamsTableFilterComposer
    extends Composer<_$ServerDatabase, $MyTeamsTable> {
  $$MyTeamsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roles => $composableBuilder(
    column: $table.roles,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get msgCount => $composableBuilder(
    column: $table.msgCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mentionCount => $composableBuilder(
    column: $table.mentionCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get msgCountRoot => $composableBuilder(
    column: $table.msgCountRoot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mentionCountRoot => $composableBuilder(
    column: $table.mentionCountRoot,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MyTeamsTableOrderingComposer
    extends Composer<_$ServerDatabase, $MyTeamsTable> {
  $$MyTeamsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roles => $composableBuilder(
    column: $table.roles,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get msgCount => $composableBuilder(
    column: $table.msgCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mentionCount => $composableBuilder(
    column: $table.mentionCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get msgCountRoot => $composableBuilder(
    column: $table.msgCountRoot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mentionCountRoot => $composableBuilder(
    column: $table.mentionCountRoot,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MyTeamsTableAnnotationComposer
    extends Composer<_$ServerDatabase, $MyTeamsTable> {
  $$MyTeamsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get teamId =>
      $composableBuilder(column: $table.teamId, builder: (column) => column);

  GeneratedColumn<String> get roles =>
      $composableBuilder(column: $table.roles, builder: (column) => column);

  GeneratedColumn<int> get msgCount =>
      $composableBuilder(column: $table.msgCount, builder: (column) => column);

  GeneratedColumn<int> get mentionCount => $composableBuilder(
    column: $table.mentionCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get msgCountRoot => $composableBuilder(
    column: $table.msgCountRoot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get mentionCountRoot => $composableBuilder(
    column: $table.mentionCountRoot,
    builder: (column) => column,
  );
}

class $$MyTeamsTableTableManager
    extends
        RootTableManager<
          _$ServerDatabase,
          $MyTeamsTable,
          MyTeamRow,
          $$MyTeamsTableFilterComposer,
          $$MyTeamsTableOrderingComposer,
          $$MyTeamsTableAnnotationComposer,
          $$MyTeamsTableCreateCompanionBuilder,
          $$MyTeamsTableUpdateCompanionBuilder,
          (
            MyTeamRow,
            BaseReferences<_$ServerDatabase, $MyTeamsTable, MyTeamRow>,
          ),
          MyTeamRow,
          PrefetchHooks Function()
        > {
  $$MyTeamsTableTableManager(_$ServerDatabase db, $MyTeamsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MyTeamsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MyTeamsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MyTeamsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> teamId = const Value.absent(),
                Value<String> roles = const Value.absent(),
                Value<int> msgCount = const Value.absent(),
                Value<int> mentionCount = const Value.absent(),
                Value<int> msgCountRoot = const Value.absent(),
                Value<int> mentionCountRoot = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MyTeamsCompanion(
                teamId: teamId,
                roles: roles,
                msgCount: msgCount,
                mentionCount: mentionCount,
                msgCountRoot: msgCountRoot,
                mentionCountRoot: mentionCountRoot,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String teamId,
                Value<String> roles = const Value.absent(),
                Value<int> msgCount = const Value.absent(),
                Value<int> mentionCount = const Value.absent(),
                Value<int> msgCountRoot = const Value.absent(),
                Value<int> mentionCountRoot = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MyTeamsCompanion.insert(
                teamId: teamId,
                roles: roles,
                msgCount: msgCount,
                mentionCount: mentionCount,
                msgCountRoot: msgCountRoot,
                mentionCountRoot: mentionCountRoot,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MyTeamsTable, MyTeamRow>(table),
                  BaseReferences<_$ServerDatabase, $MyTeamsTable, MyTeamRow>(
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

typedef $$MyTeamsTableProcessedTableManager =
    ProcessedTableManager<
      _$ServerDatabase,
      $MyTeamsTable,
      MyTeamRow,
      $$MyTeamsTableFilterComposer,
      $$MyTeamsTableOrderingComposer,
      $$MyTeamsTableAnnotationComposer,
      $$MyTeamsTableCreateCompanionBuilder,
      $$MyTeamsTableUpdateCompanionBuilder,
      (MyTeamRow, BaseReferences<_$ServerDatabase, $MyTeamsTable, MyTeamRow>),
      MyTeamRow,
      PrefetchHooks Function()
    >;
typedef $$ChannelsTableCreateCompanionBuilder = ChannelsCompanion Function({
  required String id,
  Value<String> teamId,
  required String type,
  required String name,
  required String displayName,
  Value<String> header,
  Value<String> purpose,
  Value<String> creatorId,
  Value<DateTime?> createAt,
  Value<DateTime?> updateAt,
  Value<DateTime?> deleteAt,
  Value<DateTime?> lastPostAt,
  Value<DateTime?> lastRootPostAt,
  Value<int> totalMsgCount,
  Value<int> totalMsgCountRoot,
  Value<bool> shared,
  Value<bool> groupConstrained,
  Value<int?> memberCount,
  Value<int> rowid,
});
typedef $$ChannelsTableUpdateCompanionBuilder = ChannelsCompanion Function({
  Value<String> id,
  Value<String> teamId,
  Value<String> type,
  Value<String> name,
  Value<String> displayName,
  Value<String> header,
  Value<String> purpose,
  Value<String> creatorId,
  Value<DateTime?> createAt,
  Value<DateTime?> updateAt,
  Value<DateTime?> deleteAt,
  Value<DateTime?> lastPostAt,
  Value<DateTime?> lastRootPostAt,
  Value<int> totalMsgCount,
  Value<int> totalMsgCountRoot,
  Value<bool> shared,
  Value<bool> groupConstrained,
  Value<int?> memberCount,
  Value<int> rowid,
});

class $$ChannelsTableFilterComposer
    extends Composer<_$ServerDatabase, $ChannelsTable> {
  $$ChannelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get header => $composableBuilder(
    column: $table.header,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get purpose => $composableBuilder(
    column: $table.purpose,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get creatorId => $composableBuilder(
    column: $table.creatorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get createAt =>
      $composableBuilder(
        column: $table.createAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get updateAt =>
      $composableBuilder(
        column: $table.updateAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get deleteAt =>
      $composableBuilder(
        column: $table.deleteAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get lastPostAt =>
      $composableBuilder(
        column: $table.lastPostAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get lastRootPostAt =>
      $composableBuilder(
        column: $table.lastRootPostAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get totalMsgCount => $composableBuilder(
    column: $table.totalMsgCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalMsgCountRoot => $composableBuilder(
    column: $table.totalMsgCountRoot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get shared => $composableBuilder(
    column: $table.shared,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get groupConstrained => $composableBuilder(
    column: $table.groupConstrained,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get memberCount => $composableBuilder(
    column: $table.memberCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChannelsTableOrderingComposer
    extends Composer<_$ServerDatabase, $ChannelsTable> {
  $$ChannelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get header => $composableBuilder(
    column: $table.header,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get purpose => $composableBuilder(
    column: $table.purpose,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get creatorId => $composableBuilder(
    column: $table.creatorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createAt => $composableBuilder(
    column: $table.createAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updateAt => $composableBuilder(
    column: $table.updateAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deleteAt => $composableBuilder(
    column: $table.deleteAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastPostAt => $composableBuilder(
    column: $table.lastPostAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastRootPostAt => $composableBuilder(
    column: $table.lastRootPostAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalMsgCount => $composableBuilder(
    column: $table.totalMsgCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalMsgCountRoot => $composableBuilder(
    column: $table.totalMsgCountRoot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get shared => $composableBuilder(
    column: $table.shared,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get groupConstrained => $composableBuilder(
    column: $table.groupConstrained,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get memberCount => $composableBuilder(
    column: $table.memberCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChannelsTableAnnotationComposer
    extends Composer<_$ServerDatabase, $ChannelsTable> {
  $$ChannelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get teamId =>
      $composableBuilder(column: $table.teamId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get header =>
      $composableBuilder(column: $table.header, builder: (column) => column);

  GeneratedColumn<String> get purpose =>
      $composableBuilder(column: $table.purpose, builder: (column) => column);

  GeneratedColumn<String> get creatorId =>
      $composableBuilder(column: $table.creatorId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get createAt =>
      $composableBuilder(column: $table.createAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get updateAt =>
      $composableBuilder(column: $table.updateAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get deleteAt =>
      $composableBuilder(column: $table.deleteAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get lastPostAt =>
      $composableBuilder(
        column: $table.lastPostAt,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime?, int> get lastRootPostAt =>
      $composableBuilder(
        column: $table.lastRootPostAt,
        builder: (column) => column,
      );

  GeneratedColumn<int> get totalMsgCount => $composableBuilder(
    column: $table.totalMsgCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalMsgCountRoot => $composableBuilder(
    column: $table.totalMsgCountRoot,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get shared =>
      $composableBuilder(column: $table.shared, builder: (column) => column);

  GeneratedColumn<bool> get groupConstrained => $composableBuilder(
    column: $table.groupConstrained,
    builder: (column) => column,
  );

  GeneratedColumn<int> get memberCount => $composableBuilder(
    column: $table.memberCount,
    builder: (column) => column,
  );
}

class $$ChannelsTableTableManager
    extends
        RootTableManager<
          _$ServerDatabase,
          $ChannelsTable,
          ChannelRow,
          $$ChannelsTableFilterComposer,
          $$ChannelsTableOrderingComposer,
          $$ChannelsTableAnnotationComposer,
          $$ChannelsTableCreateCompanionBuilder,
          $$ChannelsTableUpdateCompanionBuilder,
          (
            ChannelRow,
            BaseReferences<_$ServerDatabase, $ChannelsTable, ChannelRow>,
          ),
          ChannelRow,
          PrefetchHooks Function()
        > {
  $$ChannelsTableTableManager(_$ServerDatabase db, $ChannelsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChannelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChannelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChannelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> teamId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> header = const Value.absent(),
                Value<String> purpose = const Value.absent(),
                Value<String> creatorId = const Value.absent(),
                Value<DateTime?> createAt = const Value.absent(),
                Value<DateTime?> updateAt = const Value.absent(),
                Value<DateTime?> deleteAt = const Value.absent(),
                Value<DateTime?> lastPostAt = const Value.absent(),
                Value<DateTime?> lastRootPostAt = const Value.absent(),
                Value<int> totalMsgCount = const Value.absent(),
                Value<int> totalMsgCountRoot = const Value.absent(),
                Value<bool> shared = const Value.absent(),
                Value<bool> groupConstrained = const Value.absent(),
                Value<int?> memberCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChannelsCompanion(
                id: id,
                teamId: teamId,
                type: type,
                name: name,
                displayName: displayName,
                header: header,
                purpose: purpose,
                creatorId: creatorId,
                createAt: createAt,
                updateAt: updateAt,
                deleteAt: deleteAt,
                lastPostAt: lastPostAt,
                lastRootPostAt: lastRootPostAt,
                totalMsgCount: totalMsgCount,
                totalMsgCountRoot: totalMsgCountRoot,
                shared: shared,
                groupConstrained: groupConstrained,
                memberCount: memberCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> teamId = const Value.absent(),
                required String type,
                required String name,
                required String displayName,
                Value<String> header = const Value.absent(),
                Value<String> purpose = const Value.absent(),
                Value<String> creatorId = const Value.absent(),
                Value<DateTime?> createAt = const Value.absent(),
                Value<DateTime?> updateAt = const Value.absent(),
                Value<DateTime?> deleteAt = const Value.absent(),
                Value<DateTime?> lastPostAt = const Value.absent(),
                Value<DateTime?> lastRootPostAt = const Value.absent(),
                Value<int> totalMsgCount = const Value.absent(),
                Value<int> totalMsgCountRoot = const Value.absent(),
                Value<bool> shared = const Value.absent(),
                Value<bool> groupConstrained = const Value.absent(),
                Value<int?> memberCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChannelsCompanion.insert(
                id: id,
                teamId: teamId,
                type: type,
                name: name,
                displayName: displayName,
                header: header,
                purpose: purpose,
                creatorId: creatorId,
                createAt: createAt,
                updateAt: updateAt,
                deleteAt: deleteAt,
                lastPostAt: lastPostAt,
                lastRootPostAt: lastRootPostAt,
                totalMsgCount: totalMsgCount,
                totalMsgCountRoot: totalMsgCountRoot,
                shared: shared,
                groupConstrained: groupConstrained,
                memberCount: memberCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ChannelsTable, ChannelRow>(table),
                  BaseReferences<_$ServerDatabase, $ChannelsTable, ChannelRow>(
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

typedef $$ChannelsTableProcessedTableManager =
    ProcessedTableManager<
      _$ServerDatabase,
      $ChannelsTable,
      ChannelRow,
      $$ChannelsTableFilterComposer,
      $$ChannelsTableOrderingComposer,
      $$ChannelsTableAnnotationComposer,
      $$ChannelsTableCreateCompanionBuilder,
      $$ChannelsTableUpdateCompanionBuilder,
      (
        ChannelRow,
        BaseReferences<_$ServerDatabase, $ChannelsTable, ChannelRow>,
      ),
      ChannelRow,
      PrefetchHooks Function()
    >;
typedef $$MyChannelsTableCreateCompanionBuilder = MyChannelsCompanion Function({
  required String channelId,
  Value<String> roles,
  Value<DateTime?> lastViewedAt,
  Value<int> msgCount,
  Value<int> msgCountRoot,
  Value<int> mentionCount,
  Value<int> mentionCountRoot,
  Value<int> urgentMentionCount,
  Value<bool> manuallyUnread,
  Value<ChannelNotifyProps?> notifyProps,
  Value<DateTime?> lastUpdateAt,
  Value<DateTime?> postsFetchedAt,
  Value<int> rowid,
});
typedef $$MyChannelsTableUpdateCompanionBuilder = MyChannelsCompanion Function({
  Value<String> channelId,
  Value<String> roles,
  Value<DateTime?> lastViewedAt,
  Value<int> msgCount,
  Value<int> msgCountRoot,
  Value<int> mentionCount,
  Value<int> mentionCountRoot,
  Value<int> urgentMentionCount,
  Value<bool> manuallyUnread,
  Value<ChannelNotifyProps?> notifyProps,
  Value<DateTime?> lastUpdateAt,
  Value<DateTime?> postsFetchedAt,
  Value<int> rowid,
});

class $$MyChannelsTableFilterComposer
    extends Composer<_$ServerDatabase, $MyChannelsTable> {
  $$MyChannelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get channelId => $composableBuilder(
    column: $table.channelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roles => $composableBuilder(
    column: $table.roles,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get lastViewedAt =>
      $composableBuilder(
        column: $table.lastViewedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get msgCount => $composableBuilder(
    column: $table.msgCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get msgCountRoot => $composableBuilder(
    column: $table.msgCountRoot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mentionCount => $composableBuilder(
    column: $table.mentionCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mentionCountRoot => $composableBuilder(
    column: $table.mentionCountRoot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get urgentMentionCount => $composableBuilder(
    column: $table.urgentMentionCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get manuallyUnread => $composableBuilder(
    column: $table.manuallyUnread,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    ChannelNotifyProps?,
    ChannelNotifyProps,
    String
  >
  get notifyProps => $composableBuilder(
    column: $table.notifyProps,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get lastUpdateAt =>
      $composableBuilder(
        column: $table.lastUpdateAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get postsFetchedAt =>
      $composableBuilder(
        column: $table.postsFetchedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$MyChannelsTableOrderingComposer
    extends Composer<_$ServerDatabase, $MyChannelsTable> {
  $$MyChannelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get channelId => $composableBuilder(
    column: $table.channelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roles => $composableBuilder(
    column: $table.roles,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastViewedAt => $composableBuilder(
    column: $table.lastViewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get msgCount => $composableBuilder(
    column: $table.msgCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get msgCountRoot => $composableBuilder(
    column: $table.msgCountRoot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mentionCount => $composableBuilder(
    column: $table.mentionCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mentionCountRoot => $composableBuilder(
    column: $table.mentionCountRoot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get urgentMentionCount => $composableBuilder(
    column: $table.urgentMentionCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get manuallyUnread => $composableBuilder(
    column: $table.manuallyUnread,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notifyProps => $composableBuilder(
    column: $table.notifyProps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastUpdateAt => $composableBuilder(
    column: $table.lastUpdateAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get postsFetchedAt => $composableBuilder(
    column: $table.postsFetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MyChannelsTableAnnotationComposer
    extends Composer<_$ServerDatabase, $MyChannelsTable> {
  $$MyChannelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get channelId =>
      $composableBuilder(column: $table.channelId, builder: (column) => column);

  GeneratedColumn<String> get roles =>
      $composableBuilder(column: $table.roles, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get lastViewedAt =>
      $composableBuilder(
        column: $table.lastViewedAt,
        builder: (column) => column,
      );

  GeneratedColumn<int> get msgCount =>
      $composableBuilder(column: $table.msgCount, builder: (column) => column);

  GeneratedColumn<int> get msgCountRoot => $composableBuilder(
    column: $table.msgCountRoot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get mentionCount => $composableBuilder(
    column: $table.mentionCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get mentionCountRoot => $composableBuilder(
    column: $table.mentionCountRoot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get urgentMentionCount => $composableBuilder(
    column: $table.urgentMentionCount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get manuallyUnread => $composableBuilder(
    column: $table.manuallyUnread,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ChannelNotifyProps?, String>
  get notifyProps => $composableBuilder(
    column: $table.notifyProps,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime?, int> get lastUpdateAt =>
      $composableBuilder(
        column: $table.lastUpdateAt,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime?, int> get postsFetchedAt =>
      $composableBuilder(
        column: $table.postsFetchedAt,
        builder: (column) => column,
      );
}

class $$MyChannelsTableTableManager
    extends
        RootTableManager<
          _$ServerDatabase,
          $MyChannelsTable,
          MyChannelRow,
          $$MyChannelsTableFilterComposer,
          $$MyChannelsTableOrderingComposer,
          $$MyChannelsTableAnnotationComposer,
          $$MyChannelsTableCreateCompanionBuilder,
          $$MyChannelsTableUpdateCompanionBuilder,
          (
            MyChannelRow,
            BaseReferences<_$ServerDatabase, $MyChannelsTable, MyChannelRow>,
          ),
          MyChannelRow,
          PrefetchHooks Function()
        > {
  $$MyChannelsTableTableManager(_$ServerDatabase db, $MyChannelsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MyChannelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MyChannelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MyChannelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> channelId = const Value.absent(),
                Value<String> roles = const Value.absent(),
                Value<DateTime?> lastViewedAt = const Value.absent(),
                Value<int> msgCount = const Value.absent(),
                Value<int> msgCountRoot = const Value.absent(),
                Value<int> mentionCount = const Value.absent(),
                Value<int> mentionCountRoot = const Value.absent(),
                Value<int> urgentMentionCount = const Value.absent(),
                Value<bool> manuallyUnread = const Value.absent(),
                Value<ChannelNotifyProps?> notifyProps = const Value.absent(),
                Value<DateTime?> lastUpdateAt = const Value.absent(),
                Value<DateTime?> postsFetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MyChannelsCompanion(
                channelId: channelId,
                roles: roles,
                lastViewedAt: lastViewedAt,
                msgCount: msgCount,
                msgCountRoot: msgCountRoot,
                mentionCount: mentionCount,
                mentionCountRoot: mentionCountRoot,
                urgentMentionCount: urgentMentionCount,
                manuallyUnread: manuallyUnread,
                notifyProps: notifyProps,
                lastUpdateAt: lastUpdateAt,
                postsFetchedAt: postsFetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String channelId,
                Value<String> roles = const Value.absent(),
                Value<DateTime?> lastViewedAt = const Value.absent(),
                Value<int> msgCount = const Value.absent(),
                Value<int> msgCountRoot = const Value.absent(),
                Value<int> mentionCount = const Value.absent(),
                Value<int> mentionCountRoot = const Value.absent(),
                Value<int> urgentMentionCount = const Value.absent(),
                Value<bool> manuallyUnread = const Value.absent(),
                Value<ChannelNotifyProps?> notifyProps = const Value.absent(),
                Value<DateTime?> lastUpdateAt = const Value.absent(),
                Value<DateTime?> postsFetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MyChannelsCompanion.insert(
                channelId: channelId,
                roles: roles,
                lastViewedAt: lastViewedAt,
                msgCount: msgCount,
                msgCountRoot: msgCountRoot,
                mentionCount: mentionCount,
                mentionCountRoot: mentionCountRoot,
                urgentMentionCount: urgentMentionCount,
                manuallyUnread: manuallyUnread,
                notifyProps: notifyProps,
                lastUpdateAt: lastUpdateAt,
                postsFetchedAt: postsFetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MyChannelsTable, MyChannelRow>(table),
                  BaseReferences<
                    _$ServerDatabase,
                    $MyChannelsTable,
                    MyChannelRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MyChannelsTableProcessedTableManager =
    ProcessedTableManager<
      _$ServerDatabase,
      $MyChannelsTable,
      MyChannelRow,
      $$MyChannelsTableFilterComposer,
      $$MyChannelsTableOrderingComposer,
      $$MyChannelsTableAnnotationComposer,
      $$MyChannelsTableCreateCompanionBuilder,
      $$MyChannelsTableUpdateCompanionBuilder,
      (
        MyChannelRow,
        BaseReferences<_$ServerDatabase, $MyChannelsTable, MyChannelRow>,
      ),
      MyChannelRow,
      PrefetchHooks Function()
    >;
typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  required String id,
  required String teamId,
  required String type,
  required String displayName,
  Value<String> sorting,
  Value<int> sortOrder,
  Value<bool> muted,
  Value<bool> collapsed,
  Value<int> rowid,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<String> id,
  Value<String> teamId,
  Value<String> type,
  Value<String> displayName,
  Value<String> sorting,
  Value<int> sortOrder,
  Value<bool> muted,
  Value<bool> collapsed,
  Value<int> rowid,
});

class $$CategoriesTableFilterComposer
    extends Composer<_$ServerDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sorting => $composableBuilder(
    column: $table.sorting,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get muted => $composableBuilder(
    column: $table.muted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get collapsed => $composableBuilder(
    column: $table.collapsed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$ServerDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sorting => $composableBuilder(
    column: $table.sorting,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get muted => $composableBuilder(
    column: $table.muted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get collapsed => $composableBuilder(
    column: $table.collapsed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$ServerDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get teamId =>
      $composableBuilder(column: $table.teamId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sorting =>
      $composableBuilder(column: $table.sorting, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get muted =>
      $composableBuilder(column: $table.muted, builder: (column) => column);

  GeneratedColumn<bool> get collapsed =>
      $composableBuilder(column: $table.collapsed, builder: (column) => column);
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$ServerDatabase,
          $CategoriesTable,
          CategoryRow,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (
            CategoryRow,
            BaseReferences<_$ServerDatabase, $CategoriesTable, CategoryRow>,
          ),
          CategoryRow,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableManager(_$ServerDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> teamId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> sorting = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> muted = const Value.absent(),
                Value<bool> collapsed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                teamId: teamId,
                type: type,
                displayName: displayName,
                sorting: sorting,
                sortOrder: sortOrder,
                muted: muted,
                collapsed: collapsed,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String teamId,
                required String type,
                required String displayName,
                Value<String> sorting = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> muted = const Value.absent(),
                Value<bool> collapsed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                teamId: teamId,
                type: type,
                displayName: displayName,
                sorting: sorting,
                sortOrder: sortOrder,
                muted: muted,
                collapsed: collapsed,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoriesTable, CategoryRow>(table),
                  BaseReferences<
                    _$ServerDatabase,
                    $CategoriesTable,
                    CategoryRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$ServerDatabase,
      $CategoriesTable,
      CategoryRow,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (
        CategoryRow,
        BaseReferences<_$ServerDatabase, $CategoriesTable, CategoryRow>,
      ),
      CategoryRow,
      PrefetchHooks Function()
    >;
typedef $$CategoryChannelsTableCreateCompanionBuilder =
    CategoryChannelsCompanion Function({
      required String categoryId,
      required String channelId,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$CategoryChannelsTableUpdateCompanionBuilder =
    CategoryChannelsCompanion Function({
      Value<String> categoryId,
      Value<String> channelId,
      Value<int> sortOrder,
      Value<int> rowid,
    });

class $$CategoryChannelsTableFilterComposer
    extends Composer<_$ServerDatabase, $CategoryChannelsTable> {
  $$CategoryChannelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get channelId => $composableBuilder(
    column: $table.channelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoryChannelsTableOrderingComposer
    extends Composer<_$ServerDatabase, $CategoryChannelsTable> {
  $$CategoryChannelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get channelId => $composableBuilder(
    column: $table.channelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoryChannelsTableAnnotationComposer
    extends Composer<_$ServerDatabase, $CategoryChannelsTable> {
  $$CategoryChannelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get channelId =>
      $composableBuilder(column: $table.channelId, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$CategoryChannelsTableTableManager
    extends
        RootTableManager<
          _$ServerDatabase,
          $CategoryChannelsTable,
          CategoryChannelRow,
          $$CategoryChannelsTableFilterComposer,
          $$CategoryChannelsTableOrderingComposer,
          $$CategoryChannelsTableAnnotationComposer,
          $$CategoryChannelsTableCreateCompanionBuilder,
          $$CategoryChannelsTableUpdateCompanionBuilder,
          (
            CategoryChannelRow,
            BaseReferences<
              _$ServerDatabase,
              $CategoryChannelsTable,
              CategoryChannelRow
            >,
          ),
          CategoryChannelRow,
          PrefetchHooks Function()
        > {
  $$CategoryChannelsTableTableManager(
    _$ServerDatabase db,
    $CategoryChannelsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoryChannelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoryChannelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoryChannelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> categoryId = const Value.absent(),
                Value<String> channelId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoryChannelsCompanion(
                categoryId: categoryId,
                channelId: channelId,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String categoryId,
                required String channelId,
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoryChannelsCompanion.insert(
                categoryId: categoryId,
                channelId: channelId,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoryChannelsTable, CategoryChannelRow>(
                    table,
                  ),
                  BaseReferences<
                    _$ServerDatabase,
                    $CategoryChannelsTable,
                    CategoryChannelRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoryChannelsTableProcessedTableManager =
    ProcessedTableManager<
      _$ServerDatabase,
      $CategoryChannelsTable,
      CategoryChannelRow,
      $$CategoryChannelsTableFilterComposer,
      $$CategoryChannelsTableOrderingComposer,
      $$CategoryChannelsTableAnnotationComposer,
      $$CategoryChannelsTableCreateCompanionBuilder,
      $$CategoryChannelsTableUpdateCompanionBuilder,
      (
        CategoryChannelRow,
        BaseReferences<
          _$ServerDatabase,
          $CategoryChannelsTable,
          CategoryChannelRow
        >,
      ),
      CategoryChannelRow,
      PrefetchHooks Function()
    >;
typedef $$PostsTableCreateCompanionBuilder = PostsCompanion Function({
  required String id,
  required String channelId,
  Value<String> rootId,
  required String userId,
  required DateTime createAt,
  Value<DateTime?> updateAt,
  Value<DateTime?> editAt,
  Value<DateTime?> deleteAt,
  Value<String> type,
  Value<String> message,
  Value<bool> isPinned,
  Value<int> replyCount,
  Value<DateTime?> lastReplyAt,
  Value<String> originalId,
  Value<String> pendingPostId,
  Value<String?> sendState,
  Value<String?> propsJson,
  Value<String?> metadataJson,
  Value<int> fileCount,
  Value<int> reactionCount,
  Value<List<String>?> participantIds,
  Value<String?> decodeProblem,
  Value<int> rowid,
});
typedef $$PostsTableUpdateCompanionBuilder = PostsCompanion Function({
  Value<String> id,
  Value<String> channelId,
  Value<String> rootId,
  Value<String> userId,
  Value<DateTime> createAt,
  Value<DateTime?> updateAt,
  Value<DateTime?> editAt,
  Value<DateTime?> deleteAt,
  Value<String> type,
  Value<String> message,
  Value<bool> isPinned,
  Value<int> replyCount,
  Value<DateTime?> lastReplyAt,
  Value<String> originalId,
  Value<String> pendingPostId,
  Value<String?> sendState,
  Value<String?> propsJson,
  Value<String?> metadataJson,
  Value<int> fileCount,
  Value<int> reactionCount,
  Value<List<String>?> participantIds,
  Value<String?> decodeProblem,
  Value<int> rowid,
});

class $$PostsTableFilterComposer
    extends Composer<_$ServerDatabase, $PostsTable> {
  $$PostsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get channelId => $composableBuilder(
    column: $table.channelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rootId => $composableBuilder(
    column: $table.rootId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createAt =>
      $composableBuilder(
        column: $table.createAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get updateAt =>
      $composableBuilder(
        column: $table.updateAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get editAt =>
      $composableBuilder(
        column: $table.editAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get deleteAt =>
      $composableBuilder(
        column: $table.deleteAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get replyCount => $composableBuilder(
    column: $table.replyCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get lastReplyAt =>
      $composableBuilder(
        column: $table.lastReplyAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get originalId => $composableBuilder(
    column: $table.originalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pendingPostId => $composableBuilder(
    column: $table.pendingPostId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sendState => $composableBuilder(
    column: $table.sendState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get propsJson => $composableBuilder(
    column: $table.propsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileCount => $composableBuilder(
    column: $table.fileCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reactionCount => $composableBuilder(
    column: $table.reactionCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>?, List<String>, String>
  get participantIds => $composableBuilder(
    column: $table.participantIds,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get decodeProblem => $composableBuilder(
    column: $table.decodeProblem,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PostsTableOrderingComposer
    extends Composer<_$ServerDatabase, $PostsTable> {
  $$PostsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get channelId => $composableBuilder(
    column: $table.channelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rootId => $composableBuilder(
    column: $table.rootId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createAt => $composableBuilder(
    column: $table.createAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updateAt => $composableBuilder(
    column: $table.updateAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get editAt => $composableBuilder(
    column: $table.editAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deleteAt => $composableBuilder(
    column: $table.deleteAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get replyCount => $composableBuilder(
    column: $table.replyCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastReplyAt => $composableBuilder(
    column: $table.lastReplyAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalId => $composableBuilder(
    column: $table.originalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pendingPostId => $composableBuilder(
    column: $table.pendingPostId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sendState => $composableBuilder(
    column: $table.sendState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get propsJson => $composableBuilder(
    column: $table.propsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileCount => $composableBuilder(
    column: $table.fileCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reactionCount => $composableBuilder(
    column: $table.reactionCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get participantIds => $composableBuilder(
    column: $table.participantIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get decodeProblem => $composableBuilder(
    column: $table.decodeProblem,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PostsTableAnnotationComposer
    extends Composer<_$ServerDatabase, $PostsTable> {
  $$PostsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get channelId =>
      $composableBuilder(column: $table.channelId, builder: (column) => column);

  GeneratedColumn<String> get rootId =>
      $composableBuilder(column: $table.rootId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createAt =>
      $composableBuilder(column: $table.createAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get updateAt =>
      $composableBuilder(column: $table.updateAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get editAt =>
      $composableBuilder(column: $table.editAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get deleteAt =>
      $composableBuilder(column: $table.deleteAt, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);

  GeneratedColumn<int> get replyCount => $composableBuilder(
    column: $table.replyCount,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime?, int> get lastReplyAt =>
      $composableBuilder(
        column: $table.lastReplyAt,
        builder: (column) => column,
      );

  GeneratedColumn<String> get originalId => $composableBuilder(
    column: $table.originalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pendingPostId => $composableBuilder(
    column: $table.pendingPostId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sendState =>
      $composableBuilder(column: $table.sendState, builder: (column) => column);

  GeneratedColumn<String> get propsJson =>
      $composableBuilder(column: $table.propsJson, builder: (column) => column);

  GeneratedColumn<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fileCount =>
      $composableBuilder(column: $table.fileCount, builder: (column) => column);

  GeneratedColumn<int> get reactionCount => $composableBuilder(
    column: $table.reactionCount,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<String>?, String> get participantIds =>
      $composableBuilder(
        column: $table.participantIds,
        builder: (column) => column,
      );

  GeneratedColumn<String> get decodeProblem => $composableBuilder(
    column: $table.decodeProblem,
    builder: (column) => column,
  );
}

class $$PostsTableTableManager
    extends
        RootTableManager<
          _$ServerDatabase,
          $PostsTable,
          PostRow,
          $$PostsTableFilterComposer,
          $$PostsTableOrderingComposer,
          $$PostsTableAnnotationComposer,
          $$PostsTableCreateCompanionBuilder,
          $$PostsTableUpdateCompanionBuilder,
          (PostRow, BaseReferences<_$ServerDatabase, $PostsTable, PostRow>),
          PostRow,
          PrefetchHooks Function()
        > {
  $$PostsTableTableManager(_$ServerDatabase db, $PostsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PostsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PostsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PostsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> channelId = const Value.absent(),
                Value<String> rootId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> createAt = const Value.absent(),
                Value<DateTime?> updateAt = const Value.absent(),
                Value<DateTime?> editAt = const Value.absent(),
                Value<DateTime?> deleteAt = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<int> replyCount = const Value.absent(),
                Value<DateTime?> lastReplyAt = const Value.absent(),
                Value<String> originalId = const Value.absent(),
                Value<String> pendingPostId = const Value.absent(),
                Value<String?> sendState = const Value.absent(),
                Value<String?> propsJson = const Value.absent(),
                Value<String?> metadataJson = const Value.absent(),
                Value<int> fileCount = const Value.absent(),
                Value<int> reactionCount = const Value.absent(),
                Value<List<String>?> participantIds = const Value.absent(),
                Value<String?> decodeProblem = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PostsCompanion(
                id: id,
                channelId: channelId,
                rootId: rootId,
                userId: userId,
                createAt: createAt,
                updateAt: updateAt,
                editAt: editAt,
                deleteAt: deleteAt,
                type: type,
                message: message,
                isPinned: isPinned,
                replyCount: replyCount,
                lastReplyAt: lastReplyAt,
                originalId: originalId,
                pendingPostId: pendingPostId,
                sendState: sendState,
                propsJson: propsJson,
                metadataJson: metadataJson,
                fileCount: fileCount,
                reactionCount: reactionCount,
                participantIds: participantIds,
                decodeProblem: decodeProblem,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String channelId,
                Value<String> rootId = const Value.absent(),
                required String userId,
                required DateTime createAt,
                Value<DateTime?> updateAt = const Value.absent(),
                Value<DateTime?> editAt = const Value.absent(),
                Value<DateTime?> deleteAt = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<int> replyCount = const Value.absent(),
                Value<DateTime?> lastReplyAt = const Value.absent(),
                Value<String> originalId = const Value.absent(),
                Value<String> pendingPostId = const Value.absent(),
                Value<String?> sendState = const Value.absent(),
                Value<String?> propsJson = const Value.absent(),
                Value<String?> metadataJson = const Value.absent(),
                Value<int> fileCount = const Value.absent(),
                Value<int> reactionCount = const Value.absent(),
                Value<List<String>?> participantIds = const Value.absent(),
                Value<String?> decodeProblem = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PostsCompanion.insert(
                id: id,
                channelId: channelId,
                rootId: rootId,
                userId: userId,
                createAt: createAt,
                updateAt: updateAt,
                editAt: editAt,
                deleteAt: deleteAt,
                type: type,
                message: message,
                isPinned: isPinned,
                replyCount: replyCount,
                lastReplyAt: lastReplyAt,
                originalId: originalId,
                pendingPostId: pendingPostId,
                sendState: sendState,
                propsJson: propsJson,
                metadataJson: metadataJson,
                fileCount: fileCount,
                reactionCount: reactionCount,
                participantIds: participantIds,
                decodeProblem: decodeProblem,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PostsTable, PostRow>(table),
                  BaseReferences<_$ServerDatabase, $PostsTable, PostRow>(
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

typedef $$PostsTableProcessedTableManager =
    ProcessedTableManager<
      _$ServerDatabase,
      $PostsTable,
      PostRow,
      $$PostsTableFilterComposer,
      $$PostsTableOrderingComposer,
      $$PostsTableAnnotationComposer,
      $$PostsTableCreateCompanionBuilder,
      $$PostsTableUpdateCompanionBuilder,
      (PostRow, BaseReferences<_$ServerDatabase, $PostsTable, PostRow>),
      PostRow,
      PrefetchHooks Function()
    >;
typedef $$PostRangesTableCreateCompanionBuilder = PostRangesCompanion Function({
  Value<int> id,
  required String scope,
  required String scopeId,
  required DateTime earliest,
  required DateTime latest,
  Value<bool> reachesStart,
});
typedef $$PostRangesTableUpdateCompanionBuilder = PostRangesCompanion Function({
  Value<int> id,
  Value<String> scope,
  Value<String> scopeId,
  Value<DateTime> earliest,
  Value<DateTime> latest,
  Value<bool> reachesStart,
});

class $$PostRangesTableFilterComposer
    extends Composer<_$ServerDatabase, $PostRangesTable> {
  $$PostRangesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scopeId => $composableBuilder(
    column: $table.scopeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get earliest =>
      $composableBuilder(
        column: $table.earliest,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get latest =>
      $composableBuilder(
        column: $table.latest,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get reachesStart => $composableBuilder(
    column: $table.reachesStart,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PostRangesTableOrderingComposer
    extends Composer<_$ServerDatabase, $PostRangesTable> {
  $$PostRangesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scopeId => $composableBuilder(
    column: $table.scopeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get earliest => $composableBuilder(
    column: $table.earliest,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get latest => $composableBuilder(
    column: $table.latest,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reachesStart => $composableBuilder(
    column: $table.reachesStart,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PostRangesTableAnnotationComposer
    extends Composer<_$ServerDatabase, $PostRangesTable> {
  $$PostRangesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumn<String> get scopeId =>
      $composableBuilder(column: $table.scopeId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get earliest =>
      $composableBuilder(column: $table.earliest, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get latest =>
      $composableBuilder(column: $table.latest, builder: (column) => column);

  GeneratedColumn<bool> get reachesStart => $composableBuilder(
    column: $table.reachesStart,
    builder: (column) => column,
  );
}

class $$PostRangesTableTableManager
    extends
        RootTableManager<
          _$ServerDatabase,
          $PostRangesTable,
          PostRangeRow,
          $$PostRangesTableFilterComposer,
          $$PostRangesTableOrderingComposer,
          $$PostRangesTableAnnotationComposer,
          $$PostRangesTableCreateCompanionBuilder,
          $$PostRangesTableUpdateCompanionBuilder,
          (
            PostRangeRow,
            BaseReferences<_$ServerDatabase, $PostRangesTable, PostRangeRow>,
          ),
          PostRangeRow,
          PrefetchHooks Function()
        > {
  $$PostRangesTableTableManager(_$ServerDatabase db, $PostRangesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PostRangesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PostRangesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PostRangesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> scope = const Value.absent(),
                Value<String> scopeId = const Value.absent(),
                Value<DateTime> earliest = const Value.absent(),
                Value<DateTime> latest = const Value.absent(),
                Value<bool> reachesStart = const Value.absent(),
              }) => PostRangesCompanion(
                id: id,
                scope: scope,
                scopeId: scopeId,
                earliest: earliest,
                latest: latest,
                reachesStart: reachesStart,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String scope,
                required String scopeId,
                required DateTime earliest,
                required DateTime latest,
                Value<bool> reachesStart = const Value.absent(),
              }) => PostRangesCompanion.insert(
                id: id,
                scope: scope,
                scopeId: scopeId,
                earliest: earliest,
                latest: latest,
                reachesStart: reachesStart,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PostRangesTable, PostRangeRow>(table),
                  BaseReferences<
                    _$ServerDatabase,
                    $PostRangesTable,
                    PostRangeRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PostRangesTableProcessedTableManager =
    ProcessedTableManager<
      _$ServerDatabase,
      $PostRangesTable,
      PostRangeRow,
      $$PostRangesTableFilterComposer,
      $$PostRangesTableOrderingComposer,
      $$PostRangesTableAnnotationComposer,
      $$PostRangesTableCreateCompanionBuilder,
      $$PostRangesTableUpdateCompanionBuilder,
      (
        PostRangeRow,
        BaseReferences<_$ServerDatabase, $PostRangesTable, PostRangeRow>,
      ),
      PostRangeRow,
      PrefetchHooks Function()
    >;
typedef $$ReactionsTableCreateCompanionBuilder = ReactionsCompanion Function({
  required String postId,
  required String userId,
  required String emojiName,
  Value<DateTime?> createAt,
  Value<int> rowid,
});
typedef $$ReactionsTableUpdateCompanionBuilder = ReactionsCompanion Function({
  Value<String> postId,
  Value<String> userId,
  Value<String> emojiName,
  Value<DateTime?> createAt,
  Value<int> rowid,
});

class $$ReactionsTableFilterComposer
    extends Composer<_$ServerDatabase, $ReactionsTable> {
  $$ReactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get postId => $composableBuilder(
    column: $table.postId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emojiName => $composableBuilder(
    column: $table.emojiName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get createAt =>
      $composableBuilder(
        column: $table.createAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$ReactionsTableOrderingComposer
    extends Composer<_$ServerDatabase, $ReactionsTable> {
  $$ReactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get postId => $composableBuilder(
    column: $table.postId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emojiName => $composableBuilder(
    column: $table.emojiName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createAt => $composableBuilder(
    column: $table.createAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReactionsTableAnnotationComposer
    extends Composer<_$ServerDatabase, $ReactionsTable> {
  $$ReactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get postId =>
      $composableBuilder(column: $table.postId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get emojiName =>
      $composableBuilder(column: $table.emojiName, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get createAt =>
      $composableBuilder(column: $table.createAt, builder: (column) => column);
}

class $$ReactionsTableTableManager
    extends
        RootTableManager<
          _$ServerDatabase,
          $ReactionsTable,
          ReactionRow,
          $$ReactionsTableFilterComposer,
          $$ReactionsTableOrderingComposer,
          $$ReactionsTableAnnotationComposer,
          $$ReactionsTableCreateCompanionBuilder,
          $$ReactionsTableUpdateCompanionBuilder,
          (
            ReactionRow,
            BaseReferences<_$ServerDatabase, $ReactionsTable, ReactionRow>,
          ),
          ReactionRow,
          PrefetchHooks Function()
        > {
  $$ReactionsTableTableManager(_$ServerDatabase db, $ReactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> postId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> emojiName = const Value.absent(),
                Value<DateTime?> createAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReactionsCompanion(
                postId: postId,
                userId: userId,
                emojiName: emojiName,
                createAt: createAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String postId,
                required String userId,
                required String emojiName,
                Value<DateTime?> createAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReactionsCompanion.insert(
                postId: postId,
                userId: userId,
                emojiName: emojiName,
                createAt: createAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReactionsTable, ReactionRow>(table),
                  BaseReferences<
                    _$ServerDatabase,
                    $ReactionsTable,
                    ReactionRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$ServerDatabase,
      $ReactionsTable,
      ReactionRow,
      $$ReactionsTableFilterComposer,
      $$ReactionsTableOrderingComposer,
      $$ReactionsTableAnnotationComposer,
      $$ReactionsTableCreateCompanionBuilder,
      $$ReactionsTableUpdateCompanionBuilder,
      (
        ReactionRow,
        BaseReferences<_$ServerDatabase, $ReactionsTable, ReactionRow>,
      ),
      ReactionRow,
      PrefetchHooks Function()
    >;
typedef $$FilesTableCreateCompanionBuilder = FilesCompanion Function({
  required String id,
  Value<String> postId,
  required String name,
  Value<String> extension,
  Value<String> mimeType,
  Value<int> size,
  Value<int?> width,
  Value<int?> height,
  Value<bool> hasPreview,
  Value<Uint8List?> miniPreview,
  Value<String?> localPath,
  Value<DateTime?> deleteAt,
  Value<int> rowid,
});
typedef $$FilesTableUpdateCompanionBuilder = FilesCompanion Function({
  Value<String> id,
  Value<String> postId,
  Value<String> name,
  Value<String> extension,
  Value<String> mimeType,
  Value<int> size,
  Value<int?> width,
  Value<int?> height,
  Value<bool> hasPreview,
  Value<Uint8List?> miniPreview,
  Value<String?> localPath,
  Value<DateTime?> deleteAt,
  Value<int> rowid,
});

class $$FilesTableFilterComposer
    extends Composer<_$ServerDatabase, $FilesTable> {
  $$FilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get postId => $composableBuilder(
    column: $table.postId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extension => $composableBuilder(
    column: $table.extension,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasPreview => $composableBuilder(
    column: $table.hasPreview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get miniPreview => $composableBuilder(
    column: $table.miniPreview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get deleteAt =>
      $composableBuilder(
        column: $table.deleteAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$FilesTableOrderingComposer
    extends Composer<_$ServerDatabase, $FilesTable> {
  $$FilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get postId => $composableBuilder(
    column: $table.postId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extension => $composableBuilder(
    column: $table.extension,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasPreview => $composableBuilder(
    column: $table.hasPreview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get miniPreview => $composableBuilder(
    column: $table.miniPreview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deleteAt => $composableBuilder(
    column: $table.deleteAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FilesTableAnnotationComposer
    extends Composer<_$ServerDatabase, $FilesTable> {
  $$FilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get postId =>
      $composableBuilder(column: $table.postId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get extension =>
      $composableBuilder(column: $table.extension, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<bool> get hasPreview => $composableBuilder(
    column: $table.hasPreview,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get miniPreview => $composableBuilder(
    column: $table.miniPreview,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get deleteAt =>
      $composableBuilder(column: $table.deleteAt, builder: (column) => column);
}

class $$FilesTableTableManager
    extends
        RootTableManager<
          _$ServerDatabase,
          $FilesTable,
          FileRow,
          $$FilesTableFilterComposer,
          $$FilesTableOrderingComposer,
          $$FilesTableAnnotationComposer,
          $$FilesTableCreateCompanionBuilder,
          $$FilesTableUpdateCompanionBuilder,
          (FileRow, BaseReferences<_$ServerDatabase, $FilesTable, FileRow>),
          FileRow,
          PrefetchHooks Function()
        > {
  $$FilesTableTableManager(_$ServerDatabase db, $FilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> postId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> extension = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<int> size = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<bool> hasPreview = const Value.absent(),
                Value<Uint8List?> miniPreview = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<DateTime?> deleteAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FilesCompanion(
                id: id,
                postId: postId,
                name: name,
                extension: extension,
                mimeType: mimeType,
                size: size,
                width: width,
                height: height,
                hasPreview: hasPreview,
                miniPreview: miniPreview,
                localPath: localPath,
                deleteAt: deleteAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> postId = const Value.absent(),
                required String name,
                Value<String> extension = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<int> size = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<bool> hasPreview = const Value.absent(),
                Value<Uint8List?> miniPreview = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<DateTime?> deleteAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FilesCompanion.insert(
                id: id,
                postId: postId,
                name: name,
                extension: extension,
                mimeType: mimeType,
                size: size,
                width: width,
                height: height,
                hasPreview: hasPreview,
                miniPreview: miniPreview,
                localPath: localPath,
                deleteAt: deleteAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FilesTable, FileRow>(table),
                  BaseReferences<_$ServerDatabase, $FilesTable, FileRow>(
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

typedef $$FilesTableProcessedTableManager =
    ProcessedTableManager<
      _$ServerDatabase,
      $FilesTable,
      FileRow,
      $$FilesTableFilterComposer,
      $$FilesTableOrderingComposer,
      $$FilesTableAnnotationComposer,
      $$FilesTableCreateCompanionBuilder,
      $$FilesTableUpdateCompanionBuilder,
      (FileRow, BaseReferences<_$ServerDatabase, $FilesTable, FileRow>),
      FileRow,
      PrefetchHooks Function()
    >;
typedef $$ThreadsTableCreateCompanionBuilder = ThreadsCompanion Function({
  required String rootId,
  required String channelId,
  Value<DateTime?> lastReplyAt,
  Value<DateTime?> lastViewedAt,
  Value<int> replyCount,
  Value<int> unreadReplies,
  Value<int> unreadMentions,
  Value<bool> isFollowing,
  Value<List<String>> participantIds,
  Value<int> rowid,
});
typedef $$ThreadsTableUpdateCompanionBuilder = ThreadsCompanion Function({
  Value<String> rootId,
  Value<String> channelId,
  Value<DateTime?> lastReplyAt,
  Value<DateTime?> lastViewedAt,
  Value<int> replyCount,
  Value<int> unreadReplies,
  Value<int> unreadMentions,
  Value<bool> isFollowing,
  Value<List<String>> participantIds,
  Value<int> rowid,
});

class $$ThreadsTableFilterComposer
    extends Composer<_$ServerDatabase, $ThreadsTable> {
  $$ThreadsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get rootId => $composableBuilder(
    column: $table.rootId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get channelId => $composableBuilder(
    column: $table.channelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get lastReplyAt =>
      $composableBuilder(
        column: $table.lastReplyAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get lastViewedAt =>
      $composableBuilder(
        column: $table.lastViewedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get replyCount => $composableBuilder(
    column: $table.replyCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unreadReplies => $composableBuilder(
    column: $table.unreadReplies,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unreadMentions => $composableBuilder(
    column: $table.unreadMentions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFollowing => $composableBuilder(
    column: $table.isFollowing,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get participantIds => $composableBuilder(
    column: $table.participantIds,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$ThreadsTableOrderingComposer
    extends Composer<_$ServerDatabase, $ThreadsTable> {
  $$ThreadsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get rootId => $composableBuilder(
    column: $table.rootId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get channelId => $composableBuilder(
    column: $table.channelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastReplyAt => $composableBuilder(
    column: $table.lastReplyAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastViewedAt => $composableBuilder(
    column: $table.lastViewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get replyCount => $composableBuilder(
    column: $table.replyCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unreadReplies => $composableBuilder(
    column: $table.unreadReplies,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unreadMentions => $composableBuilder(
    column: $table.unreadMentions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFollowing => $composableBuilder(
    column: $table.isFollowing,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get participantIds => $composableBuilder(
    column: $table.participantIds,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ThreadsTableAnnotationComposer
    extends Composer<_$ServerDatabase, $ThreadsTable> {
  $$ThreadsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get rootId =>
      $composableBuilder(column: $table.rootId, builder: (column) => column);

  GeneratedColumn<String> get channelId =>
      $composableBuilder(column: $table.channelId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get lastReplyAt =>
      $composableBuilder(
        column: $table.lastReplyAt,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime?, int> get lastViewedAt =>
      $composableBuilder(
        column: $table.lastViewedAt,
        builder: (column) => column,
      );

  GeneratedColumn<int> get replyCount => $composableBuilder(
    column: $table.replyCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unreadReplies => $composableBuilder(
    column: $table.unreadReplies,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unreadMentions => $composableBuilder(
    column: $table.unreadMentions,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFollowing => $composableBuilder(
    column: $table.isFollowing,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<String>, String> get participantIds =>
      $composableBuilder(
        column: $table.participantIds,
        builder: (column) => column,
      );
}

class $$ThreadsTableTableManager
    extends
        RootTableManager<
          _$ServerDatabase,
          $ThreadsTable,
          ThreadRow,
          $$ThreadsTableFilterComposer,
          $$ThreadsTableOrderingComposer,
          $$ThreadsTableAnnotationComposer,
          $$ThreadsTableCreateCompanionBuilder,
          $$ThreadsTableUpdateCompanionBuilder,
          (
            ThreadRow,
            BaseReferences<_$ServerDatabase, $ThreadsTable, ThreadRow>,
          ),
          ThreadRow,
          PrefetchHooks Function()
        > {
  $$ThreadsTableTableManager(_$ServerDatabase db, $ThreadsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ThreadsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ThreadsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ThreadsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> rootId = const Value.absent(),
                Value<String> channelId = const Value.absent(),
                Value<DateTime?> lastReplyAt = const Value.absent(),
                Value<DateTime?> lastViewedAt = const Value.absent(),
                Value<int> replyCount = const Value.absent(),
                Value<int> unreadReplies = const Value.absent(),
                Value<int> unreadMentions = const Value.absent(),
                Value<bool> isFollowing = const Value.absent(),
                Value<List<String>> participantIds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ThreadsCompanion(
                rootId: rootId,
                channelId: channelId,
                lastReplyAt: lastReplyAt,
                lastViewedAt: lastViewedAt,
                replyCount: replyCount,
                unreadReplies: unreadReplies,
                unreadMentions: unreadMentions,
                isFollowing: isFollowing,
                participantIds: participantIds,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String rootId,
                required String channelId,
                Value<DateTime?> lastReplyAt = const Value.absent(),
                Value<DateTime?> lastViewedAt = const Value.absent(),
                Value<int> replyCount = const Value.absent(),
                Value<int> unreadReplies = const Value.absent(),
                Value<int> unreadMentions = const Value.absent(),
                Value<bool> isFollowing = const Value.absent(),
                Value<List<String>> participantIds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ThreadsCompanion.insert(
                rootId: rootId,
                channelId: channelId,
                lastReplyAt: lastReplyAt,
                lastViewedAt: lastViewedAt,
                replyCount: replyCount,
                unreadReplies: unreadReplies,
                unreadMentions: unreadMentions,
                isFollowing: isFollowing,
                participantIds: participantIds,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ThreadsTable, ThreadRow>(table),
                  BaseReferences<_$ServerDatabase, $ThreadsTable, ThreadRow>(
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

typedef $$ThreadsTableProcessedTableManager =
    ProcessedTableManager<
      _$ServerDatabase,
      $ThreadsTable,
      ThreadRow,
      $$ThreadsTableFilterComposer,
      $$ThreadsTableOrderingComposer,
      $$ThreadsTableAnnotationComposer,
      $$ThreadsTableCreateCompanionBuilder,
      $$ThreadsTableUpdateCompanionBuilder,
      (ThreadRow, BaseReferences<_$ServerDatabase, $ThreadsTable, ThreadRow>),
      ThreadRow,
      PrefetchHooks Function()
    >;
typedef $$ThreadTeamsTableCreateCompanionBuilder =
    ThreadTeamsCompanion Function({
      required String teamId,
      required String rootId,
      Value<int> rowid,
    });
typedef $$ThreadTeamsTableUpdateCompanionBuilder =
    ThreadTeamsCompanion Function({
      Value<String> teamId,
      Value<String> rootId,
      Value<int> rowid,
    });

class $$ThreadTeamsTableFilterComposer
    extends Composer<_$ServerDatabase, $ThreadTeamsTable> {
  $$ThreadTeamsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rootId => $composableBuilder(
    column: $table.rootId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ThreadTeamsTableOrderingComposer
    extends Composer<_$ServerDatabase, $ThreadTeamsTable> {
  $$ThreadTeamsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rootId => $composableBuilder(
    column: $table.rootId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ThreadTeamsTableAnnotationComposer
    extends Composer<_$ServerDatabase, $ThreadTeamsTable> {
  $$ThreadTeamsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get teamId =>
      $composableBuilder(column: $table.teamId, builder: (column) => column);

  GeneratedColumn<String> get rootId =>
      $composableBuilder(column: $table.rootId, builder: (column) => column);
}

class $$ThreadTeamsTableTableManager
    extends
        RootTableManager<
          _$ServerDatabase,
          $ThreadTeamsTable,
          ThreadTeamRow,
          $$ThreadTeamsTableFilterComposer,
          $$ThreadTeamsTableOrderingComposer,
          $$ThreadTeamsTableAnnotationComposer,
          $$ThreadTeamsTableCreateCompanionBuilder,
          $$ThreadTeamsTableUpdateCompanionBuilder,
          (
            ThreadTeamRow,
            BaseReferences<_$ServerDatabase, $ThreadTeamsTable, ThreadTeamRow>,
          ),
          ThreadTeamRow,
          PrefetchHooks Function()
        > {
  $$ThreadTeamsTableTableManager(_$ServerDatabase db, $ThreadTeamsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ThreadTeamsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ThreadTeamsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ThreadTeamsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> teamId = const Value.absent(),
                Value<String> rootId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ThreadTeamsCompanion(
                teamId: teamId,
                rootId: rootId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String teamId,
                required String rootId,
                Value<int> rowid = const Value.absent(),
              }) => ThreadTeamsCompanion.insert(
                teamId: teamId,
                rootId: rootId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ThreadTeamsTable, ThreadTeamRow>(table),
                  BaseReferences<
                    _$ServerDatabase,
                    $ThreadTeamsTable,
                    ThreadTeamRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ThreadTeamsTableProcessedTableManager =
    ProcessedTableManager<
      _$ServerDatabase,
      $ThreadTeamsTable,
      ThreadTeamRow,
      $$ThreadTeamsTableFilterComposer,
      $$ThreadTeamsTableOrderingComposer,
      $$ThreadTeamsTableAnnotationComposer,
      $$ThreadTeamsTableCreateCompanionBuilder,
      $$ThreadTeamsTableUpdateCompanionBuilder,
      (
        ThreadTeamRow,
        BaseReferences<_$ServerDatabase, $ThreadTeamsTable, ThreadTeamRow>,
      ),
      ThreadTeamRow,
      PrefetchHooks Function()
    >;
typedef $$ThreadSyncTableCreateCompanionBuilder = ThreadSyncCompanion Function({
  required String teamId,
  required DateTime earliest,
  required DateTime latest,
  Value<int> rowid,
});
typedef $$ThreadSyncTableUpdateCompanionBuilder = ThreadSyncCompanion Function({
  Value<String> teamId,
  Value<DateTime> earliest,
  Value<DateTime> latest,
  Value<int> rowid,
});

class $$ThreadSyncTableFilterComposer
    extends Composer<_$ServerDatabase, $ThreadSyncTable> {
  $$ThreadSyncTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get earliest =>
      $composableBuilder(
        column: $table.earliest,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get latest =>
      $composableBuilder(
        column: $table.latest,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$ThreadSyncTableOrderingComposer
    extends Composer<_$ServerDatabase, $ThreadSyncTable> {
  $$ThreadSyncTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get earliest => $composableBuilder(
    column: $table.earliest,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get latest => $composableBuilder(
    column: $table.latest,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ThreadSyncTableAnnotationComposer
    extends Composer<_$ServerDatabase, $ThreadSyncTable> {
  $$ThreadSyncTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get teamId =>
      $composableBuilder(column: $table.teamId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get earliest =>
      $composableBuilder(column: $table.earliest, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get latest =>
      $composableBuilder(column: $table.latest, builder: (column) => column);
}

class $$ThreadSyncTableTableManager
    extends
        RootTableManager<
          _$ServerDatabase,
          $ThreadSyncTable,
          ThreadSyncRow,
          $$ThreadSyncTableFilterComposer,
          $$ThreadSyncTableOrderingComposer,
          $$ThreadSyncTableAnnotationComposer,
          $$ThreadSyncTableCreateCompanionBuilder,
          $$ThreadSyncTableUpdateCompanionBuilder,
          (
            ThreadSyncRow,
            BaseReferences<_$ServerDatabase, $ThreadSyncTable, ThreadSyncRow>,
          ),
          ThreadSyncRow,
          PrefetchHooks Function()
        > {
  $$ThreadSyncTableTableManager(_$ServerDatabase db, $ThreadSyncTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ThreadSyncTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ThreadSyncTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ThreadSyncTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> teamId = const Value.absent(),
                Value<DateTime> earliest = const Value.absent(),
                Value<DateTime> latest = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ThreadSyncCompanion(
                teamId: teamId,
                earliest: earliest,
                latest: latest,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String teamId,
                required DateTime earliest,
                required DateTime latest,
                Value<int> rowid = const Value.absent(),
              }) => ThreadSyncCompanion.insert(
                teamId: teamId,
                earliest: earliest,
                latest: latest,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ThreadSyncTable, ThreadSyncRow>(table),
                  BaseReferences<
                    _$ServerDatabase,
                    $ThreadSyncTable,
                    ThreadSyncRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ThreadSyncTableProcessedTableManager =
    ProcessedTableManager<
      _$ServerDatabase,
      $ThreadSyncTable,
      ThreadSyncRow,
      $$ThreadSyncTableFilterComposer,
      $$ThreadSyncTableOrderingComposer,
      $$ThreadSyncTableAnnotationComposer,
      $$ThreadSyncTableCreateCompanionBuilder,
      $$ThreadSyncTableUpdateCompanionBuilder,
      (
        ThreadSyncRow,
        BaseReferences<_$ServerDatabase, $ThreadSyncTable, ThreadSyncRow>,
      ),
      ThreadSyncRow,
      PrefetchHooks Function()
    >;
typedef $$CustomEmojiTableCreateCompanionBuilder =
    CustomEmojiCompanion Function({
      required String id,
      required String name,
      Value<String> creatorId,
      Value<DateTime?> createAt,
      Value<DateTime?> deleteAt,
      Value<int> rowid,
    });
typedef $$CustomEmojiTableUpdateCompanionBuilder =
    CustomEmojiCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> creatorId,
      Value<DateTime?> createAt,
      Value<DateTime?> deleteAt,
      Value<int> rowid,
    });

class $$CustomEmojiTableFilterComposer
    extends Composer<_$ServerDatabase, $CustomEmojiTable> {
  $$CustomEmojiTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get creatorId => $composableBuilder(
    column: $table.creatorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get createAt =>
      $composableBuilder(
        column: $table.createAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get deleteAt =>
      $composableBuilder(
        column: $table.deleteAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$CustomEmojiTableOrderingComposer
    extends Composer<_$ServerDatabase, $CustomEmojiTable> {
  $$CustomEmojiTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get creatorId => $composableBuilder(
    column: $table.creatorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createAt => $composableBuilder(
    column: $table.createAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deleteAt => $composableBuilder(
    column: $table.deleteAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomEmojiTableAnnotationComposer
    extends Composer<_$ServerDatabase, $CustomEmojiTable> {
  $$CustomEmojiTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get creatorId =>
      $composableBuilder(column: $table.creatorId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get createAt =>
      $composableBuilder(column: $table.createAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get deleteAt =>
      $composableBuilder(column: $table.deleteAt, builder: (column) => column);
}

class $$CustomEmojiTableTableManager
    extends
        RootTableManager<
          _$ServerDatabase,
          $CustomEmojiTable,
          CustomEmojiRow,
          $$CustomEmojiTableFilterComposer,
          $$CustomEmojiTableOrderingComposer,
          $$CustomEmojiTableAnnotationComposer,
          $$CustomEmojiTableCreateCompanionBuilder,
          $$CustomEmojiTableUpdateCompanionBuilder,
          (
            CustomEmojiRow,
            BaseReferences<_$ServerDatabase, $CustomEmojiTable, CustomEmojiRow>,
          ),
          CustomEmojiRow,
          PrefetchHooks Function()
        > {
  $$CustomEmojiTableTableManager(_$ServerDatabase db, $CustomEmojiTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomEmojiTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomEmojiTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomEmojiTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> creatorId = const Value.absent(),
                Value<DateTime?> createAt = const Value.absent(),
                Value<DateTime?> deleteAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomEmojiCompanion(
                id: id,
                name: name,
                creatorId: creatorId,
                createAt: createAt,
                deleteAt: deleteAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> creatorId = const Value.absent(),
                Value<DateTime?> createAt = const Value.absent(),
                Value<DateTime?> deleteAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomEmojiCompanion.insert(
                id: id,
                name: name,
                creatorId: creatorId,
                createAt: createAt,
                deleteAt: deleteAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CustomEmojiTable, CustomEmojiRow>(table),
                  BaseReferences<
                    _$ServerDatabase,
                    $CustomEmojiTable,
                    CustomEmojiRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomEmojiTableProcessedTableManager =
    ProcessedTableManager<
      _$ServerDatabase,
      $CustomEmojiTable,
      CustomEmojiRow,
      $$CustomEmojiTableFilterComposer,
      $$CustomEmojiTableOrderingComposer,
      $$CustomEmojiTableAnnotationComposer,
      $$CustomEmojiTableCreateCompanionBuilder,
      $$CustomEmojiTableUpdateCompanionBuilder,
      (
        CustomEmojiRow,
        BaseReferences<_$ServerDatabase, $CustomEmojiTable, CustomEmojiRow>,
      ),
      CustomEmojiRow,
      PrefetchHooks Function()
    >;
typedef $$PreferencesTableCreateCompanionBuilder =
    PreferencesCompanion Function({
      required String category,
      required String name,
      required String value,
      Value<int> rowid,
    });
typedef $$PreferencesTableUpdateCompanionBuilder =
    PreferencesCompanion Function({
      Value<String> category,
      Value<String> name,
      Value<String> value,
      Value<int> rowid,
    });

class $$PreferencesTableFilterComposer
    extends Composer<_$ServerDatabase, $PreferencesTable> {
  $$PreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PreferencesTableOrderingComposer
    extends Composer<_$ServerDatabase, $PreferencesTable> {
  $$PreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PreferencesTableAnnotationComposer
    extends Composer<_$ServerDatabase, $PreferencesTable> {
  $$PreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$PreferencesTableTableManager
    extends
        RootTableManager<
          _$ServerDatabase,
          $PreferencesTable,
          PreferenceRow,
          $$PreferencesTableFilterComposer,
          $$PreferencesTableOrderingComposer,
          $$PreferencesTableAnnotationComposer,
          $$PreferencesTableCreateCompanionBuilder,
          $$PreferencesTableUpdateCompanionBuilder,
          (
            PreferenceRow,
            BaseReferences<_$ServerDatabase, $PreferencesTable, PreferenceRow>,
          ),
          PreferenceRow,
          PrefetchHooks Function()
        > {
  $$PreferencesTableTableManager(_$ServerDatabase db, $PreferencesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> category = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PreferencesCompanion(
                category: category,
                name: name,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String category,
                required String name,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => PreferencesCompanion.insert(
                category: category,
                name: name,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PreferencesTable, PreferenceRow>(table),
                  BaseReferences<
                    _$ServerDatabase,
                    $PreferencesTable,
                    PreferenceRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$ServerDatabase,
      $PreferencesTable,
      PreferenceRow,
      $$PreferencesTableFilterComposer,
      $$PreferencesTableOrderingComposer,
      $$PreferencesTableAnnotationComposer,
      $$PreferencesTableCreateCompanionBuilder,
      $$PreferencesTableUpdateCompanionBuilder,
      (
        PreferenceRow,
        BaseReferences<_$ServerDatabase, $PreferencesTable, PreferenceRow>,
      ),
      PreferenceRow,
      PrefetchHooks Function()
    >;
typedef $$RolesTableCreateCompanionBuilder = RolesCompanion Function({
  required String name,
  Value<List<String>> permissions,
  Value<int> rowid,
});
typedef $$RolesTableUpdateCompanionBuilder = RolesCompanion Function({
  Value<String> name,
  Value<List<String>> permissions,
  Value<int> rowid,
});

class $$RolesTableFilterComposer
    extends Composer<_$ServerDatabase, $RolesTable> {
  $$RolesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get permissions => $composableBuilder(
    column: $table.permissions,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$RolesTableOrderingComposer
    extends Composer<_$ServerDatabase, $RolesTable> {
  $$RolesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get permissions => $composableBuilder(
    column: $table.permissions,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RolesTableAnnotationComposer
    extends Composer<_$ServerDatabase, $RolesTable> {
  $$RolesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get permissions =>
      $composableBuilder(
        column: $table.permissions,
        builder: (column) => column,
      );
}

class $$RolesTableTableManager
    extends
        RootTableManager<
          _$ServerDatabase,
          $RolesTable,
          RoleRow,
          $$RolesTableFilterComposer,
          $$RolesTableOrderingComposer,
          $$RolesTableAnnotationComposer,
          $$RolesTableCreateCompanionBuilder,
          $$RolesTableUpdateCompanionBuilder,
          (RoleRow, BaseReferences<_$ServerDatabase, $RolesTable, RoleRow>),
          RoleRow,
          PrefetchHooks Function()
        > {
  $$RolesTableTableManager(_$ServerDatabase db, $RolesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RolesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RolesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RolesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> name = const Value.absent(),
                Value<List<String>> permissions = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RolesCompanion(
                name: name,
                permissions: permissions,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String name,
                Value<List<String>> permissions = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RolesCompanion.insert(
                name: name,
                permissions: permissions,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RolesTable, RoleRow>(table),
                  BaseReferences<_$ServerDatabase, $RolesTable, RoleRow>(
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

typedef $$RolesTableProcessedTableManager =
    ProcessedTableManager<
      _$ServerDatabase,
      $RolesTable,
      RoleRow,
      $$RolesTableFilterComposer,
      $$RolesTableOrderingComposer,
      $$RolesTableAnnotationComposer,
      $$RolesTableCreateCompanionBuilder,
      $$RolesTableUpdateCompanionBuilder,
      (RoleRow, BaseReferences<_$ServerDatabase, $RolesTable, RoleRow>),
      RoleRow,
      PrefetchHooks Function()
    >;
typedef $$DraftsTableCreateCompanionBuilder = DraftsCompanion Function({
  required String channelId,
  Value<String> rootId,
  Value<String> message,
  Value<int?> selectionBase,
  Value<int?> selectionExtent,
  Value<List<FileInfo>> files,
  Value<PostPriority?> priority,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$DraftsTableUpdateCompanionBuilder = DraftsCompanion Function({
  Value<String> channelId,
  Value<String> rootId,
  Value<String> message,
  Value<int?> selectionBase,
  Value<int?> selectionExtent,
  Value<List<FileInfo>> files,
  Value<PostPriority?> priority,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$DraftsTableFilterComposer
    extends Composer<_$ServerDatabase, $DraftsTable> {
  $$DraftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get channelId => $composableBuilder(
    column: $table.channelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rootId => $composableBuilder(
    column: $table.rootId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get selectionBase => $composableBuilder(
    column: $table.selectionBase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get selectionExtent => $composableBuilder(
    column: $table.selectionExtent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<FileInfo>, List<FileInfo>, String>
  get files => $composableBuilder(
    column: $table.files,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<PostPriority?, PostPriority, String>
  get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$DraftsTableOrderingComposer
    extends Composer<_$ServerDatabase, $DraftsTable> {
  $$DraftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get channelId => $composableBuilder(
    column: $table.channelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rootId => $composableBuilder(
    column: $table.rootId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get selectionBase => $composableBuilder(
    column: $table.selectionBase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get selectionExtent => $composableBuilder(
    column: $table.selectionExtent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get files => $composableBuilder(
    column: $table.files,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DraftsTableAnnotationComposer
    extends Composer<_$ServerDatabase, $DraftsTable> {
  $$DraftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get channelId =>
      $composableBuilder(column: $table.channelId, builder: (column) => column);

  GeneratedColumn<String> get rootId =>
      $composableBuilder(column: $table.rootId, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<int> get selectionBase => $composableBuilder(
    column: $table.selectionBase,
    builder: (column) => column,
  );

  GeneratedColumn<int> get selectionExtent => $composableBuilder(
    column: $table.selectionExtent,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<FileInfo>, String> get files =>
      $composableBuilder(column: $table.files, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PostPriority?, String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DraftsTableTableManager
    extends
        RootTableManager<
          _$ServerDatabase,
          $DraftsTable,
          DraftRow,
          $$DraftsTableFilterComposer,
          $$DraftsTableOrderingComposer,
          $$DraftsTableAnnotationComposer,
          $$DraftsTableCreateCompanionBuilder,
          $$DraftsTableUpdateCompanionBuilder,
          (DraftRow, BaseReferences<_$ServerDatabase, $DraftsTable, DraftRow>),
          DraftRow,
          PrefetchHooks Function()
        > {
  $$DraftsTableTableManager(_$ServerDatabase db, $DraftsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DraftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DraftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DraftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> channelId = const Value.absent(),
                Value<String> rootId = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<int?> selectionBase = const Value.absent(),
                Value<int?> selectionExtent = const Value.absent(),
                Value<List<FileInfo>> files = const Value.absent(),
                Value<PostPriority?> priority = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DraftsCompanion(
                channelId: channelId,
                rootId: rootId,
                message: message,
                selectionBase: selectionBase,
                selectionExtent: selectionExtent,
                files: files,
                priority: priority,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String channelId,
                Value<String> rootId = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<int?> selectionBase = const Value.absent(),
                Value<int?> selectionExtent = const Value.absent(),
                Value<List<FileInfo>> files = const Value.absent(),
                Value<PostPriority?> priority = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => DraftsCompanion.insert(
                channelId: channelId,
                rootId: rootId,
                message: message,
                selectionBase: selectionBase,
                selectionExtent: selectionExtent,
                files: files,
                priority: priority,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DraftsTable, DraftRow>(table),
                  BaseReferences<_$ServerDatabase, $DraftsTable, DraftRow>(
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

typedef $$DraftsTableProcessedTableManager =
    ProcessedTableManager<
      _$ServerDatabase,
      $DraftsTable,
      DraftRow,
      $$DraftsTableFilterComposer,
      $$DraftsTableOrderingComposer,
      $$DraftsTableAnnotationComposer,
      $$DraftsTableCreateCompanionBuilder,
      $$DraftsTableUpdateCompanionBuilder,
      (DraftRow, BaseReferences<_$ServerDatabase, $DraftsTable, DraftRow>),
      DraftRow,
      PrefetchHooks Function()
    >;
typedef $$OutboxTableCreateCompanionBuilder = OutboxCompanion Function({
  required String pendingPostId,
  required String channelId,
  Value<String> rootId,
  required DateTime queuedAt,
  Value<int> attempts,
  Value<DateTime?> nextAttemptAt,
  Value<String?> lastError,
  Value<String> state,
  Value<int> rowid,
});
typedef $$OutboxTableUpdateCompanionBuilder = OutboxCompanion Function({
  Value<String> pendingPostId,
  Value<String> channelId,
  Value<String> rootId,
  Value<DateTime> queuedAt,
  Value<int> attempts,
  Value<DateTime?> nextAttemptAt,
  Value<String?> lastError,
  Value<String> state,
  Value<int> rowid,
});

class $$OutboxTableFilterComposer
    extends Composer<_$ServerDatabase, $OutboxTable> {
  $$OutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get pendingPostId => $composableBuilder(
    column: $table.pendingPostId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get channelId => $composableBuilder(
    column: $table.channelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rootId => $composableBuilder(
    column: $table.rootId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get queuedAt =>
      $composableBuilder(
        column: $table.queuedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get nextAttemptAt =>
      $composableBuilder(
        column: $table.nextAttemptAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxTableOrderingComposer
    extends Composer<_$ServerDatabase, $OutboxTable> {
  $$OutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get pendingPostId => $composableBuilder(
    column: $table.pendingPostId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get channelId => $composableBuilder(
    column: $table.channelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rootId => $composableBuilder(
    column: $table.rootId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get queuedAt => $composableBuilder(
    column: $table.queuedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxTableAnnotationComposer
    extends Composer<_$ServerDatabase, $OutboxTable> {
  $$OutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get pendingPostId => $composableBuilder(
    column: $table.pendingPostId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get channelId =>
      $composableBuilder(column: $table.channelId, builder: (column) => column);

  GeneratedColumn<String> get rootId =>
      $composableBuilder(column: $table.rootId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get queuedAt =>
      $composableBuilder(column: $table.queuedAt, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get nextAttemptAt =>
      $composableBuilder(
        column: $table.nextAttemptAt,
        builder: (column) => column,
      );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);
}

class $$OutboxTableTableManager
    extends
        RootTableManager<
          _$ServerDatabase,
          $OutboxTable,
          OutboxRow,
          $$OutboxTableFilterComposer,
          $$OutboxTableOrderingComposer,
          $$OutboxTableAnnotationComposer,
          $$OutboxTableCreateCompanionBuilder,
          $$OutboxTableUpdateCompanionBuilder,
          (
            OutboxRow,
            BaseReferences<_$ServerDatabase, $OutboxTable, OutboxRow>,
          ),
          OutboxRow,
          PrefetchHooks Function()
        > {
  $$OutboxTableTableManager(_$ServerDatabase db, $OutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> pendingPostId = const Value.absent(),
                Value<String> channelId = const Value.absent(),
                Value<String> rootId = const Value.absent(),
                Value<DateTime> queuedAt = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxCompanion(
                pendingPostId: pendingPostId,
                channelId: channelId,
                rootId: rootId,
                queuedAt: queuedAt,
                attempts: attempts,
                nextAttemptAt: nextAttemptAt,
                lastError: lastError,
                state: state,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String pendingPostId,
                required String channelId,
                Value<String> rootId = const Value.absent(),
                required DateTime queuedAt,
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxCompanion.insert(
                pendingPostId: pendingPostId,
                channelId: channelId,
                rootId: rootId,
                queuedAt: queuedAt,
                attempts: attempts,
                nextAttemptAt: nextAttemptAt,
                lastError: lastError,
                state: state,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OutboxTable, OutboxRow>(table),
                  BaseReferences<_$ServerDatabase, $OutboxTable, OutboxRow>(
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

typedef $$OutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$ServerDatabase,
      $OutboxTable,
      OutboxRow,
      $$OutboxTableFilterComposer,
      $$OutboxTableOrderingComposer,
      $$OutboxTableAnnotationComposer,
      $$OutboxTableCreateCompanionBuilder,
      $$OutboxTableUpdateCompanionBuilder,
      (OutboxRow, BaseReferences<_$ServerDatabase, $OutboxTable, OutboxRow>),
      OutboxRow,
      PrefetchHooks Function()
    >;
typedef $$PostListsTableCreateCompanionBuilder = PostListsCompanion Function({
  required String list,
  required String postId,
  required int rank,
  Value<int> rowid,
});
typedef $$PostListsTableUpdateCompanionBuilder = PostListsCompanion Function({
  Value<String> list,
  Value<String> postId,
  Value<int> rank,
  Value<int> rowid,
});

class $$PostListsTableFilterComposer
    extends Composer<_$ServerDatabase, $PostListsTable> {
  $$PostListsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get list => $composableBuilder(
    column: $table.list,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get postId => $composableBuilder(
    column: $table.postId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rank => $composableBuilder(
    column: $table.rank,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PostListsTableOrderingComposer
    extends Composer<_$ServerDatabase, $PostListsTable> {
  $$PostListsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get list => $composableBuilder(
    column: $table.list,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get postId => $composableBuilder(
    column: $table.postId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rank => $composableBuilder(
    column: $table.rank,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PostListsTableAnnotationComposer
    extends Composer<_$ServerDatabase, $PostListsTable> {
  $$PostListsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get list =>
      $composableBuilder(column: $table.list, builder: (column) => column);

  GeneratedColumn<String> get postId =>
      $composableBuilder(column: $table.postId, builder: (column) => column);

  GeneratedColumn<int> get rank =>
      $composableBuilder(column: $table.rank, builder: (column) => column);
}

class $$PostListsTableTableManager
    extends
        RootTableManager<
          _$ServerDatabase,
          $PostListsTable,
          PostListRow,
          $$PostListsTableFilterComposer,
          $$PostListsTableOrderingComposer,
          $$PostListsTableAnnotationComposer,
          $$PostListsTableCreateCompanionBuilder,
          $$PostListsTableUpdateCompanionBuilder,
          (
            PostListRow,
            BaseReferences<_$ServerDatabase, $PostListsTable, PostListRow>,
          ),
          PostListRow,
          PrefetchHooks Function()
        > {
  $$PostListsTableTableManager(_$ServerDatabase db, $PostListsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PostListsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PostListsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PostListsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> list = const Value.absent(),
                Value<String> postId = const Value.absent(),
                Value<int> rank = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PostListsCompanion(
                list: list,
                postId: postId,
                rank: rank,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String list,
                required String postId,
                required int rank,
                Value<int> rowid = const Value.absent(),
              }) => PostListsCompanion.insert(
                list: list,
                postId: postId,
                rank: rank,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PostListsTable, PostListRow>(table),
                  BaseReferences<
                    _$ServerDatabase,
                    $PostListsTable,
                    PostListRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PostListsTableProcessedTableManager =
    ProcessedTableManager<
      _$ServerDatabase,
      $PostListsTable,
      PostListRow,
      $$PostListsTableFilterComposer,
      $$PostListsTableOrderingComposer,
      $$PostListsTableAnnotationComposer,
      $$PostListsTableCreateCompanionBuilder,
      $$PostListsTableUpdateCompanionBuilder,
      (
        PostListRow,
        BaseReferences<_$ServerDatabase, $PostListsTable, PostListRow>,
      ),
      PostListRow,
      PrefetchHooks Function()
    >;
typedef $$SearchHistoryTableCreateCompanionBuilder =
    SearchHistoryCompanion Function({
      required String teamId,
      required String term,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$SearchHistoryTableUpdateCompanionBuilder =
    SearchHistoryCompanion Function({
      Value<String> teamId,
      Value<String> term,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$SearchHistoryTableFilterComposer
    extends Composer<_$ServerDatabase, $SearchHistoryTable> {
  $$SearchHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get term => $composableBuilder(
    column: $table.term,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$SearchHistoryTableOrderingComposer
    extends Composer<_$ServerDatabase, $SearchHistoryTable> {
  $$SearchHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get term => $composableBuilder(
    column: $table.term,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SearchHistoryTableAnnotationComposer
    extends Composer<_$ServerDatabase, $SearchHistoryTable> {
  $$SearchHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get teamId =>
      $composableBuilder(column: $table.teamId, builder: (column) => column);

  GeneratedColumn<String> get term =>
      $composableBuilder(column: $table.term, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SearchHistoryTableTableManager
    extends
        RootTableManager<
          _$ServerDatabase,
          $SearchHistoryTable,
          SearchHistoryRow,
          $$SearchHistoryTableFilterComposer,
          $$SearchHistoryTableOrderingComposer,
          $$SearchHistoryTableAnnotationComposer,
          $$SearchHistoryTableCreateCompanionBuilder,
          $$SearchHistoryTableUpdateCompanionBuilder,
          (
            SearchHistoryRow,
            BaseReferences<
              _$ServerDatabase,
              $SearchHistoryTable,
              SearchHistoryRow
            >,
          ),
          SearchHistoryRow,
          PrefetchHooks Function()
        > {
  $$SearchHistoryTableTableManager(
    _$ServerDatabase db,
    $SearchHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SearchHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SearchHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SearchHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> teamId = const Value.absent(),
                Value<String> term = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SearchHistoryCompanion(
                teamId: teamId,
                term: term,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String teamId,
                required String term,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SearchHistoryCompanion.insert(
                teamId: teamId,
                term: term,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SearchHistoryTable, SearchHistoryRow>(table),
                  BaseReferences<
                    _$ServerDatabase,
                    $SearchHistoryTable,
                    SearchHistoryRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SearchHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$ServerDatabase,
      $SearchHistoryTable,
      SearchHistoryRow,
      $$SearchHistoryTableFilterComposer,
      $$SearchHistoryTableOrderingComposer,
      $$SearchHistoryTableAnnotationComposer,
      $$SearchHistoryTableCreateCompanionBuilder,
      $$SearchHistoryTableUpdateCompanionBuilder,
      (
        SearchHistoryRow,
        BaseReferences<_$ServerDatabase, $SearchHistoryTable, SearchHistoryRow>,
      ),
      SearchHistoryRow,
      PrefetchHooks Function()
    >;
typedef $$ViewStatesTableCreateCompanionBuilder = ViewStatesCompanion Function({
  required String scope,
  required String scopeId,
  required String anchorPostId,
  Value<double> anchorOffsetPx,
  required DateTime savedAt,
  Value<int> rowid,
});
typedef $$ViewStatesTableUpdateCompanionBuilder = ViewStatesCompanion Function({
  Value<String> scope,
  Value<String> scopeId,
  Value<String> anchorPostId,
  Value<double> anchorOffsetPx,
  Value<DateTime> savedAt,
  Value<int> rowid,
});

class $$ViewStatesTableFilterComposer
    extends Composer<_$ServerDatabase, $ViewStatesTable> {
  $$ViewStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scopeId => $composableBuilder(
    column: $table.scopeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get anchorPostId => $composableBuilder(
    column: $table.anchorPostId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get anchorOffsetPx => $composableBuilder(
    column: $table.anchorOffsetPx,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get savedAt =>
      $composableBuilder(
        column: $table.savedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$ViewStatesTableOrderingComposer
    extends Composer<_$ServerDatabase, $ViewStatesTable> {
  $$ViewStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scopeId => $composableBuilder(
    column: $table.scopeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get anchorPostId => $composableBuilder(
    column: $table.anchorPostId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get anchorOffsetPx => $composableBuilder(
    column: $table.anchorOffsetPx,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ViewStatesTableAnnotationComposer
    extends Composer<_$ServerDatabase, $ViewStatesTable> {
  $$ViewStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumn<String> get scopeId =>
      $composableBuilder(column: $table.scopeId, builder: (column) => column);

  GeneratedColumn<String> get anchorPostId => $composableBuilder(
    column: $table.anchorPostId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get anchorOffsetPx => $composableBuilder(
    column: $table.anchorOffsetPx,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, int> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => column);
}

class $$ViewStatesTableTableManager
    extends
        RootTableManager<
          _$ServerDatabase,
          $ViewStatesTable,
          ViewStateRow,
          $$ViewStatesTableFilterComposer,
          $$ViewStatesTableOrderingComposer,
          $$ViewStatesTableAnnotationComposer,
          $$ViewStatesTableCreateCompanionBuilder,
          $$ViewStatesTableUpdateCompanionBuilder,
          (
            ViewStateRow,
            BaseReferences<_$ServerDatabase, $ViewStatesTable, ViewStateRow>,
          ),
          ViewStateRow,
          PrefetchHooks Function()
        > {
  $$ViewStatesTableTableManager(_$ServerDatabase db, $ViewStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ViewStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ViewStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ViewStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> scope = const Value.absent(),
                Value<String> scopeId = const Value.absent(),
                Value<String> anchorPostId = const Value.absent(),
                Value<double> anchorOffsetPx = const Value.absent(),
                Value<DateTime> savedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ViewStatesCompanion(
                scope: scope,
                scopeId: scopeId,
                anchorPostId: anchorPostId,
                anchorOffsetPx: anchorOffsetPx,
                savedAt: savedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String scope,
                required String scopeId,
                required String anchorPostId,
                Value<double> anchorOffsetPx = const Value.absent(),
                required DateTime savedAt,
                Value<int> rowid = const Value.absent(),
              }) => ViewStatesCompanion.insert(
                scope: scope,
                scopeId: scopeId,
                anchorPostId: anchorPostId,
                anchorOffsetPx: anchorOffsetPx,
                savedAt: savedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ViewStatesTable, ViewStateRow>(table),
                  BaseReferences<
                    _$ServerDatabase,
                    $ViewStatesTable,
                    ViewStateRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ViewStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$ServerDatabase,
      $ViewStatesTable,
      ViewStateRow,
      $$ViewStatesTableFilterComposer,
      $$ViewStatesTableOrderingComposer,
      $$ViewStatesTableAnnotationComposer,
      $$ViewStatesTableCreateCompanionBuilder,
      $$ViewStatesTableUpdateCompanionBuilder,
      (
        ViewStateRow,
        BaseReferences<_$ServerDatabase, $ViewStatesTable, ViewStateRow>,
      ),
      ViewStateRow,
      PrefetchHooks Function()
    >;
typedef $$SyncStateTableCreateCompanionBuilder = SyncStateCompanion Function({
  required String key,
  Value<int?> valueInt,
  Value<String?> valueText,
  Value<int> rowid,
});
typedef $$SyncStateTableUpdateCompanionBuilder = SyncStateCompanion Function({
  Value<String> key,
  Value<int?> valueInt,
  Value<String?> valueText,
  Value<int> rowid,
});

class $$SyncStateTableFilterComposer
    extends Composer<_$ServerDatabase, $SyncStateTable> {
  $$SyncStateTableFilterComposer({
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

  ColumnFilters<int> get valueInt => $composableBuilder(
    column: $table.valueInt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valueText => $composableBuilder(
    column: $table.valueText,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncStateTableOrderingComposer
    extends Composer<_$ServerDatabase, $SyncStateTable> {
  $$SyncStateTableOrderingComposer({
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

  ColumnOrderings<int> get valueInt => $composableBuilder(
    column: $table.valueInt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valueText => $composableBuilder(
    column: $table.valueText,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncStateTableAnnotationComposer
    extends Composer<_$ServerDatabase, $SyncStateTable> {
  $$SyncStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<int> get valueInt =>
      $composableBuilder(column: $table.valueInt, builder: (column) => column);

  GeneratedColumn<String> get valueText =>
      $composableBuilder(column: $table.valueText, builder: (column) => column);
}

class $$SyncStateTableTableManager
    extends
        RootTableManager<
          _$ServerDatabase,
          $SyncStateTable,
          SyncStateRow,
          $$SyncStateTableFilterComposer,
          $$SyncStateTableOrderingComposer,
          $$SyncStateTableAnnotationComposer,
          $$SyncStateTableCreateCompanionBuilder,
          $$SyncStateTableUpdateCompanionBuilder,
          (
            SyncStateRow,
            BaseReferences<_$ServerDatabase, $SyncStateTable, SyncStateRow>,
          ),
          SyncStateRow,
          PrefetchHooks Function()
        > {
  $$SyncStateTableTableManager(_$ServerDatabase db, $SyncStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<int?> valueInt = const Value.absent(),
                Value<String?> valueText = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStateCompanion(
                key: key,
                valueInt: valueInt,
                valueText: valueText,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                Value<int?> valueInt = const Value.absent(),
                Value<String?> valueText = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStateCompanion.insert(
                key: key,
                valueInt: valueInt,
                valueText: valueText,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncStateTable, SyncStateRow>(table),
                  BaseReferences<
                    _$ServerDatabase,
                    $SyncStateTable,
                    SyncStateRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncStateTableProcessedTableManager =
    ProcessedTableManager<
      _$ServerDatabase,
      $SyncStateTable,
      SyncStateRow,
      $$SyncStateTableFilterComposer,
      $$SyncStateTableOrderingComposer,
      $$SyncStateTableAnnotationComposer,
      $$SyncStateTableCreateCompanionBuilder,
      $$SyncStateTableUpdateCompanionBuilder,
      (
        SyncStateRow,
        BaseReferences<_$ServerDatabase, $SyncStateTable, SyncStateRow>,
      ),
      SyncStateRow,
      PrefetchHooks Function()
    >;
typedef $$ConfigTableCreateCompanionBuilder = ConfigCompanion Function({
  required String key,
  required String json,
  required DateTime fetchedAt,
  Value<int> rowid,
});
typedef $$ConfigTableUpdateCompanionBuilder = ConfigCompanion Function({
  Value<String> key,
  Value<String> json,
  Value<DateTime> fetchedAt,
  Value<int> rowid,
});

class $$ConfigTableFilterComposer
    extends Composer<_$ServerDatabase, $ConfigTable> {
  $$ConfigTableFilterComposer({
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

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get fetchedAt =>
      $composableBuilder(
        column: $table.fetchedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$ConfigTableOrderingComposer
    extends Composer<_$ServerDatabase, $ConfigTable> {
  $$ConfigTableOrderingComposer({
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

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConfigTableAnnotationComposer
    extends Composer<_$ServerDatabase, $ConfigTable> {
  $$ConfigTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$ConfigTableTableManager
    extends
        RootTableManager<
          _$ServerDatabase,
          $ConfigTable,
          ConfigRow,
          $$ConfigTableFilterComposer,
          $$ConfigTableOrderingComposer,
          $$ConfigTableAnnotationComposer,
          $$ConfigTableCreateCompanionBuilder,
          $$ConfigTableUpdateCompanionBuilder,
          (
            ConfigRow,
            BaseReferences<_$ServerDatabase, $ConfigTable, ConfigRow>,
          ),
          ConfigRow,
          PrefetchHooks Function()
        > {
  $$ConfigTableTableManager(_$ServerDatabase db, $ConfigTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConfigTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConfigTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConfigTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> json = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConfigCompanion(
                key: key,
                json: json,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String json,
                required DateTime fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => ConfigCompanion.insert(
                key: key,
                json: json,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ConfigTable, ConfigRow>(table),
                  BaseReferences<_$ServerDatabase, $ConfigTable, ConfigRow>(
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

typedef $$ConfigTableProcessedTableManager =
    ProcessedTableManager<
      _$ServerDatabase,
      $ConfigTable,
      ConfigRow,
      $$ConfigTableFilterComposer,
      $$ConfigTableOrderingComposer,
      $$ConfigTableAnnotationComposer,
      $$ConfigTableCreateCompanionBuilder,
      $$ConfigTableUpdateCompanionBuilder,
      (ConfigRow, BaseReferences<_$ServerDatabase, $ConfigTable, ConfigRow>),
      ConfigRow,
      PrefetchHooks Function()
    >;

class $ServerDatabaseManager {
  final _$ServerDatabase _db;
  $ServerDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$TeamsTableTableManager get teams =>
      $$TeamsTableTableManager(_db, _db.teams);
  $$MyTeamsTableTableManager get myTeams =>
      $$MyTeamsTableTableManager(_db, _db.myTeams);
  $$ChannelsTableTableManager get channels =>
      $$ChannelsTableTableManager(_db, _db.channels);
  $$MyChannelsTableTableManager get myChannels =>
      $$MyChannelsTableTableManager(_db, _db.myChannels);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$CategoryChannelsTableTableManager get categoryChannels =>
      $$CategoryChannelsTableTableManager(_db, _db.categoryChannels);
  $$PostsTableTableManager get posts =>
      $$PostsTableTableManager(_db, _db.posts);
  $$PostRangesTableTableManager get postRanges =>
      $$PostRangesTableTableManager(_db, _db.postRanges);
  $$ReactionsTableTableManager get reactions =>
      $$ReactionsTableTableManager(_db, _db.reactions);
  $$FilesTableTableManager get files =>
      $$FilesTableTableManager(_db, _db.files);
  $$ThreadsTableTableManager get threads =>
      $$ThreadsTableTableManager(_db, _db.threads);
  $$ThreadTeamsTableTableManager get threadTeams =>
      $$ThreadTeamsTableTableManager(_db, _db.threadTeams);
  $$ThreadSyncTableTableManager get threadSync =>
      $$ThreadSyncTableTableManager(_db, _db.threadSync);
  $$CustomEmojiTableTableManager get customEmoji =>
      $$CustomEmojiTableTableManager(_db, _db.customEmoji);
  $$PreferencesTableTableManager get preferences =>
      $$PreferencesTableTableManager(_db, _db.preferences);
  $$RolesTableTableManager get roles =>
      $$RolesTableTableManager(_db, _db.roles);
  $$DraftsTableTableManager get drafts =>
      $$DraftsTableTableManager(_db, _db.drafts);
  $$OutboxTableTableManager get outbox =>
      $$OutboxTableTableManager(_db, _db.outbox);
  $$PostListsTableTableManager get postLists =>
      $$PostListsTableTableManager(_db, _db.postLists);
  $$SearchHistoryTableTableManager get searchHistory =>
      $$SearchHistoryTableTableManager(_db, _db.searchHistory);
  $$ViewStatesTableTableManager get viewStates =>
      $$ViewStatesTableTableManager(_db, _db.viewStates);
  $$SyncStateTableTableManager get syncState =>
      $$SyncStateTableTableManager(_db, _db.syncState);
  $$ConfigTableTableManager get config =>
      $$ConfigTableTableManager(_db, _db.config);
}
