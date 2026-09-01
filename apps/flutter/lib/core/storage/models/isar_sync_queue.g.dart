// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_sync_queue.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetIsarSyncJobCollection on Isar {
  IsarCollection<int, IsarSyncJob> get isarSyncJobs => this.collection();
}

final IsarSyncJobSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'IsarSyncJob',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(name: 'clientId', type: IsarType.string),
      IsarPropertySchema(name: 'payload', type: IsarType.string),
      IsarPropertySchema(
        name: 'status',
        type: IsarType.byte,

        enumMap: {"pending": 0, "running": 1, "failed": 2, "completed": 3},
      ),
      IsarPropertySchema(name: 'attemptCount', type: IsarType.long),
      IsarPropertySchema(name: 'nextRetryAt', type: IsarType.dateTime),
      IsarPropertySchema(name: 'errorReason', type: IsarType.string),
      IsarPropertySchema(name: 'createdAt', type: IsarType.dateTime),
      IsarPropertySchema(name: 'updatedAt', type: IsarType.dateTime),
    ],
    indexes: [
      IsarIndexSchema(
        name: 'clientId',
        properties: ["clientId"],
        unique: true,
        hash: false,
      ),
      IsarIndexSchema(
        name: 'status',
        properties: ["status"],
        unique: false,
        hash: false,
      ),
      IsarIndexSchema(
        name: 'nextRetryAt',
        properties: ["nextRetryAt"],
        unique: false,
        hash: false,
      ),
    ],
  ),
  converter: IsarObjectConverter<int, IsarSyncJob>(
    serialize: serializeIsarSyncJob,
    deserialize: deserializeIsarSyncJob,
    deserializeProperty: deserializeIsarSyncJobProp,
  ),
  getEmbeddedSchemas: () => [],
);

@isarProtected
int serializeIsarSyncJob(IsarWriter writer, IsarSyncJob object) {
  IsarCore.writeString(writer, 1, object.clientId);
  IsarCore.writeString(writer, 2, object.payload);
  IsarCore.writeByte(writer, 3, object.status.index);
  IsarCore.writeLong(writer, 4, object.attemptCount);
  IsarCore.writeLong(
    writer,
    5,
    object.nextRetryAt?.toUtc().microsecondsSinceEpoch ?? -9223372036854775808,
  );
  {
    final value = object.errorReason;
    if (value == null) {
      IsarCore.writeNull(writer, 6);
    } else {
      IsarCore.writeString(writer, 6, value);
    }
  }
  IsarCore.writeLong(
    writer,
    7,
    object.createdAt.toUtc().microsecondsSinceEpoch,
  );
  IsarCore.writeLong(
    writer,
    8,
    object.updatedAt?.toUtc().microsecondsSinceEpoch ?? -9223372036854775808,
  );
  return object.id;
}

@isarProtected
IsarSyncJob deserializeIsarSyncJob(IsarReader reader) {
  final object = IsarSyncJob();
  object.id = IsarCore.readId(reader);
  object.clientId = IsarCore.readString(reader, 1) ?? '';
  object.payload = IsarCore.readString(reader, 2) ?? '';
  {
    if (IsarCore.readNull(reader, 3)) {
      object.status = SyncJobStatus.pending;
    } else {
      object.status =
          _isarSyncJobStatus[IsarCore.readByte(reader, 3)] ??
          SyncJobStatus.pending;
    }
  }
  object.attemptCount = IsarCore.readLong(reader, 4);
  {
    final value = IsarCore.readLong(reader, 5);
    if (value == -9223372036854775808) {
      object.nextRetryAt = null;
    } else {
      object.nextRetryAt = DateTime.fromMicrosecondsSinceEpoch(
        value,
        isUtc: true,
      ).toLocal();
    }
  }
  object.errorReason = IsarCore.readString(reader, 6);
  {
    final value = IsarCore.readLong(reader, 7);
    if (value == -9223372036854775808) {
      object.createdAt = DateTime.fromMillisecondsSinceEpoch(
        0,
        isUtc: true,
      ).toLocal();
    } else {
      object.createdAt = DateTime.fromMicrosecondsSinceEpoch(
        value,
        isUtc: true,
      ).toLocal();
    }
  }
  {
    final value = IsarCore.readLong(reader, 8);
    if (value == -9223372036854775808) {
      object.updatedAt = null;
    } else {
      object.updatedAt = DateTime.fromMicrosecondsSinceEpoch(
        value,
        isUtc: true,
      ).toLocal();
    }
  }
  return object;
}

@isarProtected
dynamic deserializeIsarSyncJobProp(IsarReader reader, int property) {
  switch (property) {
    case 0:
      return IsarCore.readId(reader);
    case 1:
      return IsarCore.readString(reader, 1) ?? '';
    case 2:
      return IsarCore.readString(reader, 2) ?? '';
    case 3:
      {
        if (IsarCore.readNull(reader, 3)) {
          return SyncJobStatus.pending;
        } else {
          return _isarSyncJobStatus[IsarCore.readByte(reader, 3)] ??
              SyncJobStatus.pending;
        }
      }
    case 4:
      return IsarCore.readLong(reader, 4);
    case 5:
      {
        final value = IsarCore.readLong(reader, 5);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(
            value,
            isUtc: true,
          ).toLocal();
        }
      }
    case 6:
      return IsarCore.readString(reader, 6);
    case 7:
      {
        final value = IsarCore.readLong(reader, 7);
        if (value == -9223372036854775808) {
          return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(
            value,
            isUtc: true,
          ).toLocal();
        }
      }
    case 8:
      {
        final value = IsarCore.readLong(reader, 8);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(
            value,
            isUtc: true,
          ).toLocal();
        }
      }
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _IsarSyncJobUpdate {
  bool call({
    required int id,
    String? clientId,
    String? payload,
    SyncJobStatus? status,
    int? attemptCount,
    DateTime? nextRetryAt,
    String? errorReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

class _IsarSyncJobUpdateImpl implements _IsarSyncJobUpdate {
  const _IsarSyncJobUpdateImpl(this.collection);

  final IsarCollection<int, IsarSyncJob> collection;

  @override
  bool call({
    required int id,
    Object? clientId = ignore,
    Object? payload = ignore,
    Object? status = ignore,
    Object? attemptCount = ignore,
    Object? nextRetryAt = ignore,
    Object? errorReason = ignore,
    Object? createdAt = ignore,
    Object? updatedAt = ignore,
  }) {
    return collection.updateProperties(
          [id],
          {
            if (clientId != ignore) 1: clientId as String?,
            if (payload != ignore) 2: payload as String?,
            if (status != ignore) 3: status as SyncJobStatus?,
            if (attemptCount != ignore) 4: attemptCount as int?,
            if (nextRetryAt != ignore) 5: nextRetryAt as DateTime?,
            if (errorReason != ignore) 6: errorReason as String?,
            if (createdAt != ignore) 7: createdAt as DateTime?,
            if (updatedAt != ignore) 8: updatedAt as DateTime?,
          },
        ) >
        0;
  }
}

sealed class _IsarSyncJobUpdateAll {
  int call({
    required List<int> id,
    String? clientId,
    String? payload,
    SyncJobStatus? status,
    int? attemptCount,
    DateTime? nextRetryAt,
    String? errorReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

class _IsarSyncJobUpdateAllImpl implements _IsarSyncJobUpdateAll {
  const _IsarSyncJobUpdateAllImpl(this.collection);

  final IsarCollection<int, IsarSyncJob> collection;

  @override
  int call({
    required List<int> id,
    Object? clientId = ignore,
    Object? payload = ignore,
    Object? status = ignore,
    Object? attemptCount = ignore,
    Object? nextRetryAt = ignore,
    Object? errorReason = ignore,
    Object? createdAt = ignore,
    Object? updatedAt = ignore,
  }) {
    return collection.updateProperties(id, {
      if (clientId != ignore) 1: clientId as String?,
      if (payload != ignore) 2: payload as String?,
      if (status != ignore) 3: status as SyncJobStatus?,
      if (attemptCount != ignore) 4: attemptCount as int?,
      if (nextRetryAt != ignore) 5: nextRetryAt as DateTime?,
      if (errorReason != ignore) 6: errorReason as String?,
      if (createdAt != ignore) 7: createdAt as DateTime?,
      if (updatedAt != ignore) 8: updatedAt as DateTime?,
    });
  }
}

extension IsarSyncJobUpdate on IsarCollection<int, IsarSyncJob> {
  _IsarSyncJobUpdate get update => _IsarSyncJobUpdateImpl(this);

  _IsarSyncJobUpdateAll get updateAll => _IsarSyncJobUpdateAllImpl(this);
}

sealed class _IsarSyncJobQueryUpdate {
  int call({
    String? clientId,
    String? payload,
    SyncJobStatus? status,
    int? attemptCount,
    DateTime? nextRetryAt,
    String? errorReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

class _IsarSyncJobQueryUpdateImpl implements _IsarSyncJobQueryUpdate {
  const _IsarSyncJobQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<IsarSyncJob> query;
  final int? limit;

  @override
  int call({
    Object? clientId = ignore,
    Object? payload = ignore,
    Object? status = ignore,
    Object? attemptCount = ignore,
    Object? nextRetryAt = ignore,
    Object? errorReason = ignore,
    Object? createdAt = ignore,
    Object? updatedAt = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (clientId != ignore) 1: clientId as String?,
      if (payload != ignore) 2: payload as String?,
      if (status != ignore) 3: status as SyncJobStatus?,
      if (attemptCount != ignore) 4: attemptCount as int?,
      if (nextRetryAt != ignore) 5: nextRetryAt as DateTime?,
      if (errorReason != ignore) 6: errorReason as String?,
      if (createdAt != ignore) 7: createdAt as DateTime?,
      if (updatedAt != ignore) 8: updatedAt as DateTime?,
    });
  }
}

extension IsarSyncJobQueryUpdate on IsarQuery<IsarSyncJob> {
  _IsarSyncJobQueryUpdate get updateFirst =>
      _IsarSyncJobQueryUpdateImpl(this, limit: 1);

  _IsarSyncJobQueryUpdate get updateAll => _IsarSyncJobQueryUpdateImpl(this);
}

class _IsarSyncJobQueryBuilderUpdateImpl implements _IsarSyncJobQueryUpdate {
  const _IsarSyncJobQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<IsarSyncJob, IsarSyncJob, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? clientId = ignore,
    Object? payload = ignore,
    Object? status = ignore,
    Object? attemptCount = ignore,
    Object? nextRetryAt = ignore,
    Object? errorReason = ignore,
    Object? createdAt = ignore,
    Object? updatedAt = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (clientId != ignore) 1: clientId as String?,
        if (payload != ignore) 2: payload as String?,
        if (status != ignore) 3: status as SyncJobStatus?,
        if (attemptCount != ignore) 4: attemptCount as int?,
        if (nextRetryAt != ignore) 5: nextRetryAt as DateTime?,
        if (errorReason != ignore) 6: errorReason as String?,
        if (createdAt != ignore) 7: createdAt as DateTime?,
        if (updatedAt != ignore) 8: updatedAt as DateTime?,
      });
    } finally {
      q.close();
    }
  }
}

extension IsarSyncJobQueryBuilderUpdate
    on QueryBuilder<IsarSyncJob, IsarSyncJob, QOperations> {
  _IsarSyncJobQueryUpdate get updateFirst =>
      _IsarSyncJobQueryBuilderUpdateImpl(this, limit: 1);

  _IsarSyncJobQueryUpdate get updateAll =>
      _IsarSyncJobQueryBuilderUpdateImpl(this);
}

const _isarSyncJobStatus = {
  0: SyncJobStatus.pending,
  1: SyncJobStatus.running,
  2: SyncJobStatus.failed,
  3: SyncJobStatus.completed,
};

extension IsarSyncJobQueryFilter
    on QueryBuilder<IsarSyncJob, IsarSyncJob, QFilterCondition> {
  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition> idEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition> idGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  idGreaterThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition> idLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 0, value: value));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  idLessThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition> idBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 0, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition> clientIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 1, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  clientIdGreaterThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  clientIdGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  clientIdLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 1, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  clientIdLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition> clientIdBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 1,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  clientIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  clientIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  clientIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition> clientIdMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 1,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  clientIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 1, value: ''),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  clientIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 1, value: ''),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition> payloadEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 2, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  payloadGreaterThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  payloadGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition> payloadLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 2, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  payloadLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition> payloadBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 2,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  payloadStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition> payloadEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition> payloadContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition> payloadMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 2,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  payloadIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 2, value: ''),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  payloadIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 2, value: ''),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition> statusEqualTo(
    SyncJobStatus value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 3, value: value.index),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  statusGreaterThan(SyncJobStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 3, value: value.index),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  statusGreaterThanOrEqualTo(SyncJobStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 3, value: value.index),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition> statusLessThan(
    SyncJobStatus value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 3, value: value.index),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  statusLessThanOrEqualTo(SyncJobStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 3, value: value.index),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition> statusBetween(
    SyncJobStatus lower,
    SyncJobStatus upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 3, lower: lower.index, upper: upper.index),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  attemptCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 4, value: value),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  attemptCountGreaterThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 4, value: value),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  attemptCountGreaterThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 4, value: value),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  attemptCountLessThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 4, value: value));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  attemptCountLessThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 4, value: value),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  attemptCountBetween(int lower, int upper) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 4, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  nextRetryAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 5));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  nextRetryAtIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 5));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  nextRetryAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 5, value: value),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  nextRetryAtGreaterThan(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 5, value: value),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  nextRetryAtGreaterThanOrEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 5, value: value),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  nextRetryAtLessThan(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 5, value: value));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  nextRetryAtLessThanOrEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 5, value: value),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  nextRetryAtBetween(DateTime? lower, DateTime? upper) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 5, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  errorReasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 6));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  errorReasonIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 6));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  errorReasonEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 6, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  errorReasonGreaterThan(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  errorReasonGreaterThanOrEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  errorReasonLessThan(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 6, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  errorReasonLessThanOrEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  errorReasonBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 6,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  errorReasonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  errorReasonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  errorReasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  errorReasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 6,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  errorReasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 6, value: ''),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  errorReasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 6, value: ''),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 7, value: value),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  createdAtGreaterThan(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 7, value: value),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  createdAtGreaterThanOrEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 7, value: value),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  createdAtLessThan(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 7, value: value));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  createdAtLessThanOrEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 7, value: value),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  createdAtBetween(DateTime lower, DateTime upper) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 7, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 8));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  updatedAtIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 8));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 8, value: value),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  updatedAtGreaterThan(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 8, value: value),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  updatedAtGreaterThanOrEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 8, value: value),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  updatedAtLessThan(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 8, value: value));
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  updatedAtLessThanOrEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 8, value: value),
      );
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterFilterCondition>
  updatedAtBetween(DateTime? lower, DateTime? upper) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 8, lower: lower, upper: upper),
      );
    });
  }
}

extension IsarSyncJobQueryObject
    on QueryBuilder<IsarSyncJob, IsarSyncJob, QFilterCondition> {}

extension IsarSyncJobQuerySortBy
    on QueryBuilder<IsarSyncJob, IsarSyncJob, QSortBy> {
  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> sortByClientId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> sortByClientIdDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> sortByPayload({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> sortByPayloadDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> sortByAttemptCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy>
  sortByAttemptCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> sortByNextRetryAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> sortByNextRetryAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> sortByErrorReason({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> sortByErrorReasonDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }
}

extension IsarSyncJobQuerySortThenBy
    on QueryBuilder<IsarSyncJob, IsarSyncJob, QSortThenBy> {
  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> thenByClientId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> thenByClientIdDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> thenByPayload({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> thenByPayloadDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> thenByAttemptCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy>
  thenByAttemptCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> thenByNextRetryAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> thenByNextRetryAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> thenByErrorReason({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> thenByErrorReasonDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }
}

extension IsarSyncJobQueryWhereDistinct
    on QueryBuilder<IsarSyncJob, IsarSyncJob, QDistinct> {
  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterDistinct> distinctByClientId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterDistinct> distinctByPayload({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterDistinct> distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterDistinct>
  distinctByAttemptCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterDistinct>
  distinctByNextRetryAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterDistinct> distinctByErrorReason({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(7);
    });
  }

  QueryBuilder<IsarSyncJob, IsarSyncJob, QAfterDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(8);
    });
  }
}

extension IsarSyncJobQueryProperty1
    on QueryBuilder<IsarSyncJob, IsarSyncJob, QProperty> {
  QueryBuilder<IsarSyncJob, int, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<IsarSyncJob, String, QAfterProperty> clientIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<IsarSyncJob, String, QAfterProperty> payloadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<IsarSyncJob, SyncJobStatus, QAfterProperty> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<IsarSyncJob, int, QAfterProperty> attemptCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<IsarSyncJob, DateTime?, QAfterProperty> nextRetryAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<IsarSyncJob, String?, QAfterProperty> errorReasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<IsarSyncJob, DateTime, QAfterProperty> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<IsarSyncJob, DateTime?, QAfterProperty> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }
}

extension IsarSyncJobQueryProperty2<R>
    on QueryBuilder<IsarSyncJob, R, QAfterProperty> {
  QueryBuilder<IsarSyncJob, (R, int), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<IsarSyncJob, (R, String), QAfterProperty> clientIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<IsarSyncJob, (R, String), QAfterProperty> payloadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<IsarSyncJob, (R, SyncJobStatus), QAfterProperty>
  statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<IsarSyncJob, (R, int), QAfterProperty> attemptCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<IsarSyncJob, (R, DateTime?), QAfterProperty>
  nextRetryAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<IsarSyncJob, (R, String?), QAfterProperty>
  errorReasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<IsarSyncJob, (R, DateTime), QAfterProperty> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<IsarSyncJob, (R, DateTime?), QAfterProperty>
  updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }
}

extension IsarSyncJobQueryProperty3<R1, R2>
    on QueryBuilder<IsarSyncJob, (R1, R2), QAfterProperty> {
  QueryBuilder<IsarSyncJob, (R1, R2, int), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<IsarSyncJob, (R1, R2, String), QOperations> clientIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<IsarSyncJob, (R1, R2, String), QOperations> payloadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<IsarSyncJob, (R1, R2, SyncJobStatus), QOperations>
  statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<IsarSyncJob, (R1, R2, int), QOperations> attemptCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<IsarSyncJob, (R1, R2, DateTime?), QOperations>
  nextRetryAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<IsarSyncJob, (R1, R2, String?), QOperations>
  errorReasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<IsarSyncJob, (R1, R2, DateTime), QOperations>
  createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<IsarSyncJob, (R1, R2, DateTime?), QOperations>
  updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }
}
