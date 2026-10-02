// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_level.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetIsarLevelCollection on Isar {
  IsarCollection<int, IsarLevel> get isarLevels => this.collection();
}

final IsarLevelSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'IsarLevel',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(name: 'publicId', type: IsarType.string),
      IsarPropertySchema(name: 'ecosystemId', type: IsarType.string),
      IsarPropertySchema(name: 'title', type: IsarType.string),
      IsarPropertySchema(name: 'sequence', type: IsarType.long),
      IsarPropertySchema(
        name: 'status',
        type: IsarType.byte,

        enumMap: {"locked": 0, "available": 1, "inProgress": 2, "completed": 3},
      ),
      IsarPropertySchema(name: 'minimumScore', type: IsarType.double),
      IsarPropertySchema(name: 'requiredQuizIds', type: IsarType.stringList),
      IsarPropertySchema(name: 'plantIds', type: IsarType.stringList),
      IsarPropertySchema(name: 'requiredPlantIds', type: IsarType.stringList),
      IsarPropertySchema(name: 'requiredLevelIds', type: IsarType.stringList),
      IsarPropertySchema(name: 'learningGoal', type: IsarType.string),
      IsarPropertySchema(name: 'progress', type: IsarType.double),
      IsarPropertySchema(name: 'blockedReason', type: IsarType.string),
      IsarPropertySchema(name: 'contentVersion', type: IsarType.string),
    ],
    indexes: [
      IsarIndexSchema(
        name: 'publicId',
        properties: ["publicId"],
        unique: true,
        hash: false,
      ),
      IsarIndexSchema(
        name: 'ecosystemId',
        properties: ["ecosystemId"],
        unique: false,
        hash: false,
      ),
    ],
  ),
  converter: IsarObjectConverter<int, IsarLevel>(
    serialize: serializeIsarLevel,
    deserialize: deserializeIsarLevel,
    deserializeProperty: deserializeIsarLevelProp,
  ),
  getEmbeddedSchemas: () => [],
);

@isarProtected
int serializeIsarLevel(IsarWriter writer, IsarLevel object) {
  IsarCore.writeString(writer, 1, object.publicId);
  IsarCore.writeString(writer, 2, object.ecosystemId);
  IsarCore.writeString(writer, 3, object.title);
  IsarCore.writeLong(writer, 4, object.sequence);
  IsarCore.writeByte(writer, 5, object.status.index);
  IsarCore.writeDouble(writer, 6, object.minimumScore);
  {
    final list = object.requiredQuizIds;
    final listWriter = IsarCore.beginList(writer, 7, list.length);
    for (var i = 0; i < list.length; i++) {
      IsarCore.writeString(listWriter, i, list[i]);
    }
    IsarCore.endList(writer, listWriter);
  }
  {
    final list = object.plantIds;
    final listWriter = IsarCore.beginList(writer, 8, list.length);
    for (var i = 0; i < list.length; i++) {
      IsarCore.writeString(listWriter, i, list[i]);
    }
    IsarCore.endList(writer, listWriter);
  }
  {
    final list = object.requiredPlantIds;
    final listWriter = IsarCore.beginList(writer, 9, list.length);
    for (var i = 0; i < list.length; i++) {
      IsarCore.writeString(listWriter, i, list[i]);
    }
    IsarCore.endList(writer, listWriter);
  }
  {
    final list = object.requiredLevelIds;
    final listWriter = IsarCore.beginList(writer, 10, list.length);
    for (var i = 0; i < list.length; i++) {
      IsarCore.writeString(listWriter, i, list[i]);
    }
    IsarCore.endList(writer, listWriter);
  }
  {
    final value = object.learningGoal;
    if (value == null) {
      IsarCore.writeNull(writer, 11);
    } else {
      IsarCore.writeString(writer, 11, value);
    }
  }
  IsarCore.writeDouble(writer, 12, object.progress ?? double.nan);
  {
    final value = object.blockedReason;
    if (value == null) {
      IsarCore.writeNull(writer, 13);
    } else {
      IsarCore.writeString(writer, 13, value);
    }
  }
  IsarCore.writeString(writer, 14, object.contentVersion);
  return object.id;
}

@isarProtected
IsarLevel deserializeIsarLevel(IsarReader reader) {
  final object = IsarLevel();
  object.id = IsarCore.readId(reader);
  object.publicId = IsarCore.readString(reader, 1) ?? '';
  object.ecosystemId = IsarCore.readString(reader, 2) ?? '';
  object.title = IsarCore.readString(reader, 3) ?? '';
  object.sequence = IsarCore.readLong(reader, 4);
  {
    if (IsarCore.readNull(reader, 5)) {
      object.status = IsarLevelStatus.locked;
    } else {
      object.status =
          _isarLevelStatus[IsarCore.readByte(reader, 5)] ??
          IsarLevelStatus.locked;
    }
  }
  object.minimumScore = IsarCore.readDouble(reader, 6);
  {
    final length = IsarCore.readList(reader, 7, IsarCore.readerPtrPtr);
    {
      final reader = IsarCore.readerPtr;
      if (reader.isNull) {
        object.requiredQuizIds = const <String>[];
      } else {
        final list = List<String>.filled(length, '', growable: true);
        for (var i = 0; i < length; i++) {
          list[i] = IsarCore.readString(reader, i) ?? '';
        }
        IsarCore.freeReader(reader);
        object.requiredQuizIds = list;
      }
    }
  }
  {
    final length = IsarCore.readList(reader, 8, IsarCore.readerPtrPtr);
    {
      final reader = IsarCore.readerPtr;
      if (reader.isNull) {
        object.plantIds = const <String>[];
      } else {
        final list = List<String>.filled(length, '', growable: true);
        for (var i = 0; i < length; i++) {
          list[i] = IsarCore.readString(reader, i) ?? '';
        }
        IsarCore.freeReader(reader);
        object.plantIds = list;
      }
    }
  }
  {
    final length = IsarCore.readList(reader, 9, IsarCore.readerPtrPtr);
    {
      final reader = IsarCore.readerPtr;
      if (reader.isNull) {
        object.requiredPlantIds = const <String>[];
      } else {
        final list = List<String>.filled(length, '', growable: true);
        for (var i = 0; i < length; i++) {
          list[i] = IsarCore.readString(reader, i) ?? '';
        }
        IsarCore.freeReader(reader);
        object.requiredPlantIds = list;
      }
    }
  }
  {
    final length = IsarCore.readList(reader, 10, IsarCore.readerPtrPtr);
    {
      final reader = IsarCore.readerPtr;
      if (reader.isNull) {
        object.requiredLevelIds = const <String>[];
      } else {
        final list = List<String>.filled(length, '', growable: true);
        for (var i = 0; i < length; i++) {
          list[i] = IsarCore.readString(reader, i) ?? '';
        }
        IsarCore.freeReader(reader);
        object.requiredLevelIds = list;
      }
    }
  }
  object.learningGoal = IsarCore.readString(reader, 11);
  {
    final value = IsarCore.readDouble(reader, 12);
    if (value.isNaN) {
      object.progress = null;
    } else {
      object.progress = value;
    }
  }
  object.blockedReason = IsarCore.readString(reader, 13);
  object.contentVersion = IsarCore.readString(reader, 14) ?? '';
  return object;
}

@isarProtected
dynamic deserializeIsarLevelProp(IsarReader reader, int property) {
  switch (property) {
    case 0:
      return IsarCore.readId(reader);
    case 1:
      return IsarCore.readString(reader, 1) ?? '';
    case 2:
      return IsarCore.readString(reader, 2) ?? '';
    case 3:
      return IsarCore.readString(reader, 3) ?? '';
    case 4:
      return IsarCore.readLong(reader, 4);
    case 5:
      {
        if (IsarCore.readNull(reader, 5)) {
          return IsarLevelStatus.locked;
        } else {
          return _isarLevelStatus[IsarCore.readByte(reader, 5)] ??
              IsarLevelStatus.locked;
        }
      }
    case 6:
      return IsarCore.readDouble(reader, 6);
    case 7:
      {
        final length = IsarCore.readList(reader, 7, IsarCore.readerPtrPtr);
        {
          final reader = IsarCore.readerPtr;
          if (reader.isNull) {
            return const <String>[];
          } else {
            final list = List<String>.filled(length, '', growable: true);
            for (var i = 0; i < length; i++) {
              list[i] = IsarCore.readString(reader, i) ?? '';
            }
            IsarCore.freeReader(reader);
            return list;
          }
        }
      }
    case 8:
      {
        final length = IsarCore.readList(reader, 8, IsarCore.readerPtrPtr);
        {
          final reader = IsarCore.readerPtr;
          if (reader.isNull) {
            return const <String>[];
          } else {
            final list = List<String>.filled(length, '', growable: true);
            for (var i = 0; i < length; i++) {
              list[i] = IsarCore.readString(reader, i) ?? '';
            }
            IsarCore.freeReader(reader);
            return list;
          }
        }
      }
    case 9:
      {
        final length = IsarCore.readList(reader, 9, IsarCore.readerPtrPtr);
        {
          final reader = IsarCore.readerPtr;
          if (reader.isNull) {
            return const <String>[];
          } else {
            final list = List<String>.filled(length, '', growable: true);
            for (var i = 0; i < length; i++) {
              list[i] = IsarCore.readString(reader, i) ?? '';
            }
            IsarCore.freeReader(reader);
            return list;
          }
        }
      }
    case 10:
      {
        final length = IsarCore.readList(reader, 10, IsarCore.readerPtrPtr);
        {
          final reader = IsarCore.readerPtr;
          if (reader.isNull) {
            return const <String>[];
          } else {
            final list = List<String>.filled(length, '', growable: true);
            for (var i = 0; i < length; i++) {
              list[i] = IsarCore.readString(reader, i) ?? '';
            }
            IsarCore.freeReader(reader);
            return list;
          }
        }
      }
    case 11:
      return IsarCore.readString(reader, 11);
    case 12:
      {
        final value = IsarCore.readDouble(reader, 12);
        if (value.isNaN) {
          return null;
        } else {
          return value;
        }
      }
    case 13:
      return IsarCore.readString(reader, 13);
    case 14:
      return IsarCore.readString(reader, 14) ?? '';
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _IsarLevelUpdate {
  bool call({
    required int id,
    String? publicId,
    String? ecosystemId,
    String? title,
    int? sequence,
    IsarLevelStatus? status,
    double? minimumScore,
    String? learningGoal,
    double? progress,
    String? blockedReason,
    String? contentVersion,
  });
}

class _IsarLevelUpdateImpl implements _IsarLevelUpdate {
  const _IsarLevelUpdateImpl(this.collection);

  final IsarCollection<int, IsarLevel> collection;

  @override
  bool call({
    required int id,
    Object? publicId = ignore,
    Object? ecosystemId = ignore,
    Object? title = ignore,
    Object? sequence = ignore,
    Object? status = ignore,
    Object? minimumScore = ignore,
    Object? learningGoal = ignore,
    Object? progress = ignore,
    Object? blockedReason = ignore,
    Object? contentVersion = ignore,
  }) {
    return collection.updateProperties(
          [id],
          {
            if (publicId != ignore) 1: publicId as String?,
            if (ecosystemId != ignore) 2: ecosystemId as String?,
            if (title != ignore) 3: title as String?,
            if (sequence != ignore) 4: sequence as int?,
            if (status != ignore) 5: status as IsarLevelStatus?,
            if (minimumScore != ignore) 6: minimumScore as double?,
            if (learningGoal != ignore) 11: learningGoal as String?,
            if (progress != ignore) 12: progress as double?,
            if (blockedReason != ignore) 13: blockedReason as String?,
            if (contentVersion != ignore) 14: contentVersion as String?,
          },
        ) >
        0;
  }
}

sealed class _IsarLevelUpdateAll {
  int call({
    required List<int> id,
    String? publicId,
    String? ecosystemId,
    String? title,
    int? sequence,
    IsarLevelStatus? status,
    double? minimumScore,
    String? learningGoal,
    double? progress,
    String? blockedReason,
    String? contentVersion,
  });
}

class _IsarLevelUpdateAllImpl implements _IsarLevelUpdateAll {
  const _IsarLevelUpdateAllImpl(this.collection);

  final IsarCollection<int, IsarLevel> collection;

  @override
  int call({
    required List<int> id,
    Object? publicId = ignore,
    Object? ecosystemId = ignore,
    Object? title = ignore,
    Object? sequence = ignore,
    Object? status = ignore,
    Object? minimumScore = ignore,
    Object? learningGoal = ignore,
    Object? progress = ignore,
    Object? blockedReason = ignore,
    Object? contentVersion = ignore,
  }) {
    return collection.updateProperties(id, {
      if (publicId != ignore) 1: publicId as String?,
      if (ecosystemId != ignore) 2: ecosystemId as String?,
      if (title != ignore) 3: title as String?,
      if (sequence != ignore) 4: sequence as int?,
      if (status != ignore) 5: status as IsarLevelStatus?,
      if (minimumScore != ignore) 6: minimumScore as double?,
      if (learningGoal != ignore) 11: learningGoal as String?,
      if (progress != ignore) 12: progress as double?,
      if (blockedReason != ignore) 13: blockedReason as String?,
      if (contentVersion != ignore) 14: contentVersion as String?,
    });
  }
}

extension IsarLevelUpdate on IsarCollection<int, IsarLevel> {
  _IsarLevelUpdate get update => _IsarLevelUpdateImpl(this);

  _IsarLevelUpdateAll get updateAll => _IsarLevelUpdateAllImpl(this);
}

sealed class _IsarLevelQueryUpdate {
  int call({
    String? publicId,
    String? ecosystemId,
    String? title,
    int? sequence,
    IsarLevelStatus? status,
    double? minimumScore,
    String? learningGoal,
    double? progress,
    String? blockedReason,
    String? contentVersion,
  });
}

class _IsarLevelQueryUpdateImpl implements _IsarLevelQueryUpdate {
  const _IsarLevelQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<IsarLevel> query;
  final int? limit;

  @override
  int call({
    Object? publicId = ignore,
    Object? ecosystemId = ignore,
    Object? title = ignore,
    Object? sequence = ignore,
    Object? status = ignore,
    Object? minimumScore = ignore,
    Object? learningGoal = ignore,
    Object? progress = ignore,
    Object? blockedReason = ignore,
    Object? contentVersion = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (publicId != ignore) 1: publicId as String?,
      if (ecosystemId != ignore) 2: ecosystemId as String?,
      if (title != ignore) 3: title as String?,
      if (sequence != ignore) 4: sequence as int?,
      if (status != ignore) 5: status as IsarLevelStatus?,
      if (minimumScore != ignore) 6: minimumScore as double?,
      if (learningGoal != ignore) 11: learningGoal as String?,
      if (progress != ignore) 12: progress as double?,
      if (blockedReason != ignore) 13: blockedReason as String?,
      if (contentVersion != ignore) 14: contentVersion as String?,
    });
  }
}

extension IsarLevelQueryUpdate on IsarQuery<IsarLevel> {
  _IsarLevelQueryUpdate get updateFirst =>
      _IsarLevelQueryUpdateImpl(this, limit: 1);

  _IsarLevelQueryUpdate get updateAll => _IsarLevelQueryUpdateImpl(this);
}

class _IsarLevelQueryBuilderUpdateImpl implements _IsarLevelQueryUpdate {
  const _IsarLevelQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<IsarLevel, IsarLevel, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? publicId = ignore,
    Object? ecosystemId = ignore,
    Object? title = ignore,
    Object? sequence = ignore,
    Object? status = ignore,
    Object? minimumScore = ignore,
    Object? learningGoal = ignore,
    Object? progress = ignore,
    Object? blockedReason = ignore,
    Object? contentVersion = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (publicId != ignore) 1: publicId as String?,
        if (ecosystemId != ignore) 2: ecosystemId as String?,
        if (title != ignore) 3: title as String?,
        if (sequence != ignore) 4: sequence as int?,
        if (status != ignore) 5: status as IsarLevelStatus?,
        if (minimumScore != ignore) 6: minimumScore as double?,
        if (learningGoal != ignore) 11: learningGoal as String?,
        if (progress != ignore) 12: progress as double?,
        if (blockedReason != ignore) 13: blockedReason as String?,
        if (contentVersion != ignore) 14: contentVersion as String?,
      });
    } finally {
      q.close();
    }
  }
}

extension IsarLevelQueryBuilderUpdate
    on QueryBuilder<IsarLevel, IsarLevel, QOperations> {
  _IsarLevelQueryUpdate get updateFirst =>
      _IsarLevelQueryBuilderUpdateImpl(this, limit: 1);

  _IsarLevelQueryUpdate get updateAll => _IsarLevelQueryBuilderUpdateImpl(this);
}

const _isarLevelStatus = {
  0: IsarLevelStatus.locked,
  1: IsarLevelStatus.available,
  2: IsarLevelStatus.inProgress,
  3: IsarLevelStatus.completed,
};

extension IsarLevelQueryFilter
    on QueryBuilder<IsarLevel, IsarLevel, QFilterCondition> {
  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> idEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> idGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  idGreaterThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> idLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 0, value: value));
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> idLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> idBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 0, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> publicIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 1, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> publicIdGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  publicIdGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> publicIdLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 1, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  publicIdLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> publicIdBetween(
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

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> publicIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> publicIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> publicIdContains(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> publicIdMatches(
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

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> publicIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 1, value: ''),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  publicIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 1, value: ''),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> ecosystemIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 2, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  ecosystemIdGreaterThan(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  ecosystemIdGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> ecosystemIdLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 2, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  ecosystemIdLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> ecosystemIdBetween(
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

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  ecosystemIdStartsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> ecosystemIdEndsWith(
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

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> ecosystemIdContains(
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

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> ecosystemIdMatches(
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

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  ecosystemIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 2, value: ''),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  ecosystemIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 2, value: ''),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 3, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> titleGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  titleGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> titleLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 3, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  titleLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 3,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> titleContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> titleMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 3,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 3, value: ''),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 3, value: ''),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> sequenceEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 4, value: value),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> sequenceGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 4, value: value),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  sequenceGreaterThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 4, value: value),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> sequenceLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 4, value: value));
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  sequenceLessThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 4, value: value),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> sequenceBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 4, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> statusEqualTo(
    IsarLevelStatus value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 5, value: value.index),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> statusGreaterThan(
    IsarLevelStatus value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 5, value: value.index),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  statusGreaterThanOrEqualTo(IsarLevelStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 5, value: value.index),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> statusLessThan(
    IsarLevelStatus value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 5, value: value.index),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  statusLessThanOrEqualTo(IsarLevelStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 5, value: value.index),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> statusBetween(
    IsarLevelStatus lower,
    IsarLevelStatus upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 5, lower: lower.index, upper: upper.index),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> minimumScoreEqualTo(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 6, value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  minimumScoreGreaterThan(double value, {double epsilon = Filter.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 6, value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  minimumScoreGreaterThanOrEqualTo(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 6, value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  minimumScoreLessThan(double value, {double epsilon = Filter.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 6, value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  minimumScoreLessThanOrEqualTo(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 6, value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> minimumScoreBetween(
    double lower,
    double upper, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 6,
          lower: lower,
          upper: upper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredQuizIdsElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 7, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredQuizIdsElementGreaterThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredQuizIdsElementGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredQuizIdsElementLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 7, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredQuizIdsElementLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredQuizIdsElementBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 7,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredQuizIdsElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredQuizIdsElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredQuizIdsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredQuizIdsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 7,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredQuizIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 7, value: ''),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredQuizIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 7, value: ''),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredQuizIdsIsEmpty() {
    return not().requiredQuizIdsIsNotEmpty();
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredQuizIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterOrEqualCondition(property: 7, value: null),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  plantIdsElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 8, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  plantIdsElementGreaterThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  plantIdsElementGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  plantIdsElementLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 8, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  plantIdsElementLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  plantIdsElementBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 8,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  plantIdsElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  plantIdsElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  plantIdsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  plantIdsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 8,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  plantIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 8, value: ''),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  plantIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 8, value: ''),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> plantIdsIsEmpty() {
    return not().plantIdsIsNotEmpty();
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  plantIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterOrEqualCondition(property: 8, value: null),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredPlantIdsElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 9, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredPlantIdsElementGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredPlantIdsElementGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredPlantIdsElementLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 9, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredPlantIdsElementLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredPlantIdsElementBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 9,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredPlantIdsElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredPlantIdsElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredPlantIdsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredPlantIdsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 9,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredPlantIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 9, value: ''),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredPlantIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 9, value: ''),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredPlantIdsIsEmpty() {
    return not().requiredPlantIdsIsNotEmpty();
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredPlantIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterOrEqualCondition(property: 9, value: null),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredLevelIdsElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 10,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredLevelIdsElementGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 10,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredLevelIdsElementGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 10,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredLevelIdsElementLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 10, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredLevelIdsElementLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 10,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredLevelIdsElementBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 10,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredLevelIdsElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 10,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredLevelIdsElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 10,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredLevelIdsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 10,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredLevelIdsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 10,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredLevelIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 10, value: ''),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredLevelIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 10, value: ''),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredLevelIdsIsEmpty() {
    return not().requiredLevelIdsIsNotEmpty();
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredLevelIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterOrEqualCondition(property: 10, value: null),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  learningGoalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 11));
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  learningGoalIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 11));
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> learningGoalEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 11,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  learningGoalGreaterThan(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 11,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  learningGoalGreaterThanOrEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 11,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  learningGoalLessThan(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 11, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  learningGoalLessThanOrEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 11,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> learningGoalBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 11,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  learningGoalStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 11,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  learningGoalEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 11,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  learningGoalContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 11,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> learningGoalMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 11,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  learningGoalIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 11, value: ''),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  learningGoalIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 11, value: ''),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> progressIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 12));
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  progressIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 12));
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> progressEqualTo(
    double? value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 12, value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> progressGreaterThan(
    double? value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 12, value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  progressGreaterThanOrEqualTo(
    double? value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 12, value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> progressLessThan(
    double? value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 12, value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  progressLessThanOrEqualTo(double? value, {double epsilon = Filter.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 12, value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> progressBetween(
    double? lower,
    double? upper, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 12,
          lower: lower,
          upper: upper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  blockedReasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 13));
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  blockedReasonIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 13));
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  blockedReasonEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 13,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  blockedReasonGreaterThan(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 13,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  blockedReasonGreaterThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 13,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  blockedReasonLessThan(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 13, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  blockedReasonLessThanOrEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 13,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  blockedReasonBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 13,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  blockedReasonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 13,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  blockedReasonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 13,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  blockedReasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 13,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  blockedReasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 13,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  blockedReasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 13, value: ''),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  blockedReasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 13, value: ''),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  contentVersionEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 14,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  contentVersionGreaterThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 14,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  contentVersionGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 14,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  contentVersionLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 14, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  contentVersionLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 14,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  contentVersionBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 14,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  contentVersionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 14,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  contentVersionEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 14,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  contentVersionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 14,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  contentVersionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 14,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  contentVersionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 14, value: ''),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  contentVersionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 14, value: ''),
      );
    });
  }
}

extension IsarLevelQueryObject
    on QueryBuilder<IsarLevel, IsarLevel, QFilterCondition> {}

extension IsarLevelQuerySortBy on QueryBuilder<IsarLevel, IsarLevel, QSortBy> {
  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> sortByPublicId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> sortByPublicIdDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> sortByEcosystemId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> sortByEcosystemIdDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> sortByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> sortByTitleDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> sortBySequence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> sortBySequenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> sortByMinimumScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> sortByMinimumScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> sortByLearningGoal({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> sortByLearningGoalDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> sortByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(12);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> sortByProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(12, sort: Sort.desc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> sortByBlockedReason({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> sortByBlockedReasonDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> sortByContentVersion({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(14, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> sortByContentVersionDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(14, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }
}

extension IsarLevelQuerySortThenBy
    on QueryBuilder<IsarLevel, IsarLevel, QSortThenBy> {
  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> thenByPublicId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> thenByPublicIdDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> thenByEcosystemId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> thenByEcosystemIdDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> thenByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> thenByTitleDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> thenBySequence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> thenBySequenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> thenByMinimumScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> thenByMinimumScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> thenByLearningGoal({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> thenByLearningGoalDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> thenByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(12);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> thenByProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(12, sort: Sort.desc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> thenByBlockedReason({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> thenByBlockedReasonDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> thenByContentVersion({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(14, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> thenByContentVersionDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(14, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }
}

extension IsarLevelQueryWhereDistinct
    on QueryBuilder<IsarLevel, IsarLevel, QDistinct> {
  QueryBuilder<IsarLevel, IsarLevel, QAfterDistinct> distinctByPublicId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterDistinct> distinctByEcosystemId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterDistinct> distinctByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterDistinct> distinctBySequence() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterDistinct> distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterDistinct> distinctByMinimumScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterDistinct>
  distinctByRequiredQuizIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(7);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterDistinct> distinctByPlantIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(8);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterDistinct>
  distinctByRequiredPlantIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(9);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterDistinct>
  distinctByRequiredLevelIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(10);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterDistinct> distinctByLearningGoal({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(11, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterDistinct> distinctByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(12);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterDistinct> distinctByBlockedReason({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(13, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterDistinct> distinctByContentVersion({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(14, caseSensitive: caseSensitive);
    });
  }
}

extension IsarLevelQueryProperty1
    on QueryBuilder<IsarLevel, IsarLevel, QProperty> {
  QueryBuilder<IsarLevel, int, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<IsarLevel, String, QAfterProperty> publicIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<IsarLevel, String, QAfterProperty> ecosystemIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<IsarLevel, String, QAfterProperty> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<IsarLevel, int, QAfterProperty> sequenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<IsarLevel, IsarLevelStatus, QAfterProperty> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<IsarLevel, double, QAfterProperty> minimumScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<IsarLevel, List<String>, QAfterProperty>
  requiredQuizIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<IsarLevel, List<String>, QAfterProperty> plantIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<IsarLevel, List<String>, QAfterProperty>
  requiredPlantIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<IsarLevel, List<String>, QAfterProperty>
  requiredLevelIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<IsarLevel, String?, QAfterProperty> learningGoalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }

  QueryBuilder<IsarLevel, double?, QAfterProperty> progressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(12);
    });
  }

  QueryBuilder<IsarLevel, String?, QAfterProperty> blockedReasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(13);
    });
  }

  QueryBuilder<IsarLevel, String, QAfterProperty> contentVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(14);
    });
  }
}

extension IsarLevelQueryProperty2<R>
    on QueryBuilder<IsarLevel, R, QAfterProperty> {
  QueryBuilder<IsarLevel, (R, int), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<IsarLevel, (R, String), QAfterProperty> publicIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<IsarLevel, (R, String), QAfterProperty> ecosystemIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<IsarLevel, (R, String), QAfterProperty> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<IsarLevel, (R, int), QAfterProperty> sequenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<IsarLevel, (R, IsarLevelStatus), QAfterProperty>
  statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<IsarLevel, (R, double), QAfterProperty> minimumScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<IsarLevel, (R, List<String>), QAfterProperty>
  requiredQuizIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<IsarLevel, (R, List<String>), QAfterProperty>
  plantIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<IsarLevel, (R, List<String>), QAfterProperty>
  requiredPlantIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<IsarLevel, (R, List<String>), QAfterProperty>
  requiredLevelIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<IsarLevel, (R, String?), QAfterProperty> learningGoalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }

  QueryBuilder<IsarLevel, (R, double?), QAfterProperty> progressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(12);
    });
  }

  QueryBuilder<IsarLevel, (R, String?), QAfterProperty>
  blockedReasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(13);
    });
  }

  QueryBuilder<IsarLevel, (R, String), QAfterProperty>
  contentVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(14);
    });
  }
}

extension IsarLevelQueryProperty3<R1, R2>
    on QueryBuilder<IsarLevel, (R1, R2), QAfterProperty> {
  QueryBuilder<IsarLevel, (R1, R2, int), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<IsarLevel, (R1, R2, String), QOperations> publicIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<IsarLevel, (R1, R2, String), QOperations> ecosystemIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<IsarLevel, (R1, R2, String), QOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<IsarLevel, (R1, R2, int), QOperations> sequenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<IsarLevel, (R1, R2, IsarLevelStatus), QOperations>
  statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<IsarLevel, (R1, R2, double), QOperations>
  minimumScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<IsarLevel, (R1, R2, List<String>), QOperations>
  requiredQuizIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<IsarLevel, (R1, R2, List<String>), QOperations>
  plantIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<IsarLevel, (R1, R2, List<String>), QOperations>
  requiredPlantIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<IsarLevel, (R1, R2, List<String>), QOperations>
  requiredLevelIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<IsarLevel, (R1, R2, String?), QOperations>
  learningGoalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }

  QueryBuilder<IsarLevel, (R1, R2, double?), QOperations> progressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(12);
    });
  }

  QueryBuilder<IsarLevel, (R1, R2, String?), QOperations>
  blockedReasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(13);
    });
  }

  QueryBuilder<IsarLevel, (R1, R2, String), QOperations>
  contentVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(14);
    });
  }
}
