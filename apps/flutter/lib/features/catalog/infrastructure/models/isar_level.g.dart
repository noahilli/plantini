// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_level.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarLevelCollection on Isar {
  IsarCollection<IsarLevel> get isarLevels => this.collection();
}

const IsarLevelSchema = CollectionSchema(
  name: r'IsarLevel',
  id: 3759401853428457336,
  properties: {
    r'blockedReason': PropertySchema(
      id: 0,
      name: r'blockedReason',
      type: IsarType.string,
    ),
    r'contentVersion': PropertySchema(
      id: 1,
      name: r'contentVersion',
      type: IsarType.string,
    ),
    r'ecosystemId': PropertySchema(
      id: 2,
      name: r'ecosystemId',
      type: IsarType.string,
    ),
    r'learningGoal': PropertySchema(
      id: 3,
      name: r'learningGoal',
      type: IsarType.string,
    ),
    r'minimumScore': PropertySchema(
      id: 4,
      name: r'minimumScore',
      type: IsarType.double,
    ),
    r'plantIds': PropertySchema(
      id: 5,
      name: r'plantIds',
      type: IsarType.stringList,
    ),
    r'progress': PropertySchema(
      id: 6,
      name: r'progress',
      type: IsarType.double,
    ),
    r'publicId': PropertySchema(
      id: 7,
      name: r'publicId',
      type: IsarType.string,
    ),
    r'requiredQuizIds': PropertySchema(
      id: 8,
      name: r'requiredQuizIds',
      type: IsarType.stringList,
    ),
    r'sequence': PropertySchema(id: 9, name: r'sequence', type: IsarType.long),
    r'status': PropertySchema(
      id: 10,
      name: r'status',
      type: IsarType.string,
      enumMap: _IsarLevelstatusEnumValueMap,
    ),
    r'title': PropertySchema(id: 11, name: r'title', type: IsarType.string),
  },
  estimateSize: _isarLevelEstimateSize,
  serialize: _isarLevelSerialize,
  deserialize: _isarLevelDeserialize,
  deserializeProp: _isarLevelDeserializeProp,
  idName: r'id',
  indexes: {
    r'publicId': IndexSchema(
      id: 779961479559886054,
      name: r'publicId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'publicId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'ecosystemId': IndexSchema(
      id: -6487657717982149933,
      name: r'ecosystemId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'ecosystemId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _isarLevelGetId,
  getLinks: _isarLevelGetLinks,
  attach: _isarLevelAttach,
  version: '3.1.0+1',
);

int _isarLevelEstimateSize(
  IsarLevel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.blockedReason;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.contentVersion.length * 3;
  bytesCount += 3 + object.ecosystemId.length * 3;
  {
    final value = object.learningGoal;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.plantIds.length * 3;
  {
    for (var i = 0; i < object.plantIds.length; i++) {
      final value = object.plantIds[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.publicId.length * 3;
  bytesCount += 3 + object.requiredQuizIds.length * 3;
  {
    for (var i = 0; i < object.requiredQuizIds.length; i++) {
      final value = object.requiredQuizIds[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.status.name.length * 3;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _isarLevelSerialize(
  IsarLevel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.blockedReason);
  writer.writeString(offsets[1], object.contentVersion);
  writer.writeString(offsets[2], object.ecosystemId);
  writer.writeString(offsets[3], object.learningGoal);
  writer.writeDouble(offsets[4], object.minimumScore);
  writer.writeStringList(offsets[5], object.plantIds);
  writer.writeDouble(offsets[6], object.progress);
  writer.writeString(offsets[7], object.publicId);
  writer.writeStringList(offsets[8], object.requiredQuizIds);
  writer.writeLong(offsets[9], object.sequence);
  writer.writeString(offsets[10], object.status.name);
  writer.writeString(offsets[11], object.title);
}

IsarLevel _isarLevelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarLevel();
  object.blockedReason = reader.readStringOrNull(offsets[0]);
  object.contentVersion = reader.readString(offsets[1]);
  object.ecosystemId = reader.readString(offsets[2]);
  object.id = id;
  object.learningGoal = reader.readStringOrNull(offsets[3]);
  object.minimumScore = reader.readDouble(offsets[4]);
  object.plantIds = reader.readStringList(offsets[5]) ?? [];
  object.progress = reader.readDoubleOrNull(offsets[6]);
  object.publicId = reader.readString(offsets[7]);
  object.requiredQuizIds = reader.readStringList(offsets[8]) ?? [];
  object.sequence = reader.readLong(offsets[9]);
  object.status =
      _IsarLevelstatusValueEnumMap[reader.readStringOrNull(offsets[10])] ??
      IsarLevelStatus.locked;
  object.title = reader.readString(offsets[11]);
  return object;
}

P _isarLevelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readStringList(offset) ?? []) as P;
    case 6:
      return (reader.readDoubleOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readStringList(offset) ?? []) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (_IsarLevelstatusValueEnumMap[reader.readStringOrNull(offset)] ??
              IsarLevelStatus.locked)
          as P;
    case 11:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _IsarLevelstatusEnumValueMap = {
  r'locked': r'locked',
  r'available': r'available',
  r'inProgress': r'inProgress',
  r'completed': r'completed',
};
const _IsarLevelstatusValueEnumMap = {
  r'locked': IsarLevelStatus.locked,
  r'available': IsarLevelStatus.available,
  r'inProgress': IsarLevelStatus.inProgress,
  r'completed': IsarLevelStatus.completed,
};

Id _isarLevelGetId(IsarLevel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarLevelGetLinks(IsarLevel object) {
  return [];
}

void _isarLevelAttach(IsarCollection<dynamic> col, Id id, IsarLevel object) {
  object.id = id;
}

extension IsarLevelByIndex on IsarCollection<IsarLevel> {
  Future<IsarLevel?> getByPublicId(String publicId) {
    return getByIndex(r'publicId', [publicId]);
  }

  IsarLevel? getByPublicIdSync(String publicId) {
    return getByIndexSync(r'publicId', [publicId]);
  }

  Future<bool> deleteByPublicId(String publicId) {
    return deleteByIndex(r'publicId', [publicId]);
  }

  bool deleteByPublicIdSync(String publicId) {
    return deleteByIndexSync(r'publicId', [publicId]);
  }

  Future<List<IsarLevel?>> getAllByPublicId(List<String> publicIdValues) {
    final values = publicIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'publicId', values);
  }

  List<IsarLevel?> getAllByPublicIdSync(List<String> publicIdValues) {
    final values = publicIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'publicId', values);
  }

  Future<int> deleteAllByPublicId(List<String> publicIdValues) {
    final values = publicIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'publicId', values);
  }

  int deleteAllByPublicIdSync(List<String> publicIdValues) {
    final values = publicIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'publicId', values);
  }

  Future<Id> putByPublicId(IsarLevel object) {
    return putByIndex(r'publicId', object);
  }

  Id putByPublicIdSync(IsarLevel object, {bool saveLinks = true}) {
    return putByIndexSync(r'publicId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPublicId(List<IsarLevel> objects) {
    return putAllByIndex(r'publicId', objects);
  }

  List<Id> putAllByPublicIdSync(
    List<IsarLevel> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'publicId', objects, saveLinks: saveLinks);
  }
}

extension IsarLevelQueryWhereSort
    on QueryBuilder<IsarLevel, IsarLevel, QWhere> {
  QueryBuilder<IsarLevel, IsarLevel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IsarLevelQueryWhere
    on QueryBuilder<IsarLevel, IsarLevel, QWhereClause> {
  QueryBuilder<IsarLevel, IsarLevel, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterWhereClause> publicIdEqualTo(
    String publicId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'publicId', value: [publicId]),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterWhereClause> publicIdNotEqualTo(
    String publicId,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'publicId',
                lower: [],
                upper: [publicId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'publicId',
                lower: [publicId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'publicId',
                lower: [publicId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'publicId',
                lower: [],
                upper: [publicId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterWhereClause> ecosystemIdEqualTo(
    String ecosystemId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'ecosystemId',
          value: [ecosystemId],
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterWhereClause> ecosystemIdNotEqualTo(
    String ecosystemId,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'ecosystemId',
                lower: [],
                upper: [ecosystemId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'ecosystemId',
                lower: [ecosystemId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'ecosystemId',
                lower: [ecosystemId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'ecosystemId',
                lower: [],
                upper: [ecosystemId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension IsarLevelQueryFilter
    on QueryBuilder<IsarLevel, IsarLevel, QFilterCondition> {
  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  blockedReasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'blockedReason'),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  blockedReasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'blockedReason'),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  blockedReasonEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'blockedReason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  blockedReasonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'blockedReason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  blockedReasonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'blockedReason',
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
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'blockedReason',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  blockedReasonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'blockedReason',
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
        FilterCondition.endsWith(
          property: r'blockedReason',
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
        FilterCondition.contains(
          property: r'blockedReason',
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
        FilterCondition.matches(
          property: r'blockedReason',
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
        FilterCondition.equalTo(property: r'blockedReason', value: ''),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  blockedReasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'blockedReason', value: ''),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  contentVersionEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'contentVersion',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  contentVersionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'contentVersion',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  contentVersionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'contentVersion',
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
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'contentVersion',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  contentVersionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'contentVersion',
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
        FilterCondition.endsWith(
          property: r'contentVersion',
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
        FilterCondition.contains(
          property: r'contentVersion',
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
        FilterCondition.matches(
          property: r'contentVersion',
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
        FilterCondition.equalTo(property: r'contentVersion', value: ''),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  contentVersionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'contentVersion', value: ''),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> ecosystemIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'ecosystemId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  ecosystemIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'ecosystemId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> ecosystemIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'ecosystemId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> ecosystemIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'ecosystemId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  ecosystemIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'ecosystemId',
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
        FilterCondition.endsWith(
          property: r'ecosystemId',
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
        FilterCondition.contains(
          property: r'ecosystemId',
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
        FilterCondition.matches(
          property: r'ecosystemId',
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
        FilterCondition.equalTo(property: r'ecosystemId', value: ''),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  ecosystemIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'ecosystemId', value: ''),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  learningGoalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'learningGoal'),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  learningGoalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'learningGoal'),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> learningGoalEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'learningGoal',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  learningGoalGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'learningGoal',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  learningGoalLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'learningGoal',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> learningGoalBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'learningGoal',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  learningGoalStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'learningGoal',
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
        FilterCondition.endsWith(
          property: r'learningGoal',
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
        FilterCondition.contains(
          property: r'learningGoal',
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
        FilterCondition.matches(
          property: r'learningGoal',
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
        FilterCondition.equalTo(property: r'learningGoal', value: ''),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  learningGoalIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'learningGoal', value: ''),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> minimumScoreEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'minimumScore',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  minimumScoreGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'minimumScore',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  minimumScoreLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'minimumScore',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> minimumScoreBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'minimumScore',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  plantIdsElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'plantIds',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  plantIdsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'plantIds',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  plantIdsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'plantIds',
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
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'plantIds',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  plantIdsElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'plantIds',
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
        FilterCondition.endsWith(
          property: r'plantIds',
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
        FilterCondition.contains(
          property: r'plantIds',
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
        FilterCondition.matches(
          property: r'plantIds',
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
        FilterCondition.equalTo(property: r'plantIds', value: ''),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  plantIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'plantIds', value: ''),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  plantIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'plantIds', length, true, length, true);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> plantIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'plantIds', 0, true, 0, true);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  plantIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'plantIds', 0, false, 999999, true);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  plantIdsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'plantIds', 0, true, length, include);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  plantIdsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'plantIds', length, include, 999999, true);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  plantIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'plantIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> progressIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'progress'),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  progressIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'progress'),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> progressEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'progress',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> progressGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'progress',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> progressLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'progress',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> progressBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'progress',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> publicIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'publicId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> publicIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'publicId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> publicIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'publicId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> publicIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'publicId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
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
        FilterCondition.startsWith(
          property: r'publicId',
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
        FilterCondition.endsWith(
          property: r'publicId',
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
        FilterCondition.contains(
          property: r'publicId',
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
        FilterCondition.matches(
          property: r'publicId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> publicIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'publicId', value: ''),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  publicIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'publicId', value: ''),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredQuizIdsElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'requiredQuizIds',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredQuizIdsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'requiredQuizIds',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredQuizIdsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'requiredQuizIds',
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
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'requiredQuizIds',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredQuizIdsElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'requiredQuizIds',
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
        FilterCondition.endsWith(
          property: r'requiredQuizIds',
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
        FilterCondition.contains(
          property: r'requiredQuizIds',
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
        FilterCondition.matches(
          property: r'requiredQuizIds',
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
        FilterCondition.equalTo(property: r'requiredQuizIds', value: ''),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredQuizIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'requiredQuizIds', value: ''),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredQuizIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'requiredQuizIds', length, true, length, true);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredQuizIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'requiredQuizIds', 0, true, 0, true);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredQuizIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'requiredQuizIds', 0, false, 999999, true);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredQuizIdsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'requiredQuizIds', 0, true, length, include);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredQuizIdsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'requiredQuizIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition>
  requiredQuizIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'requiredQuizIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> sequenceEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sequence', value: value),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> sequenceGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sequence',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> sequenceLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sequence',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> sequenceBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sequence',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> statusEqualTo(
    IsarLevelStatus value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> statusGreaterThan(
    IsarLevelStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> statusLessThan(
    IsarLevelStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> statusBetween(
    IsarLevelStatus lower,
    IsarLevelStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'status',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> statusContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> statusMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'status',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'title',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
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
        FilterCondition.startsWith(
          property: r'title',
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
        FilterCondition.endsWith(
          property: r'title',
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
        FilterCondition.contains(
          property: r'title',
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
        FilterCondition.matches(
          property: r'title',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'title', value: ''),
      );
    });
  }
}

extension IsarLevelQueryObject
    on QueryBuilder<IsarLevel, IsarLevel, QFilterCondition> {}

extension IsarLevelQueryLinks
    on QueryBuilder<IsarLevel, IsarLevel, QFilterCondition> {}

extension IsarLevelQuerySortBy on QueryBuilder<IsarLevel, IsarLevel, QSortBy> {
  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> sortByBlockedReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockedReason', Sort.asc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> sortByBlockedReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockedReason', Sort.desc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> sortByContentVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentVersion', Sort.asc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> sortByContentVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentVersion', Sort.desc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> sortByEcosystemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ecosystemId', Sort.asc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> sortByEcosystemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ecosystemId', Sort.desc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> sortByLearningGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'learningGoal', Sort.asc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> sortByLearningGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'learningGoal', Sort.desc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> sortByMinimumScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minimumScore', Sort.asc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> sortByMinimumScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minimumScore', Sort.desc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> sortByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.asc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> sortByProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.desc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> sortByPublicId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publicId', Sort.asc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> sortByPublicIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publicId', Sort.desc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> sortBySequence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sequence', Sort.asc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> sortBySequenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sequence', Sort.desc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension IsarLevelQuerySortThenBy
    on QueryBuilder<IsarLevel, IsarLevel, QSortThenBy> {
  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> thenByBlockedReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockedReason', Sort.asc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> thenByBlockedReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockedReason', Sort.desc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> thenByContentVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentVersion', Sort.asc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> thenByContentVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentVersion', Sort.desc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> thenByEcosystemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ecosystemId', Sort.asc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> thenByEcosystemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ecosystemId', Sort.desc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> thenByLearningGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'learningGoal', Sort.asc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> thenByLearningGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'learningGoal', Sort.desc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> thenByMinimumScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minimumScore', Sort.asc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> thenByMinimumScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minimumScore', Sort.desc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> thenByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.asc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> thenByProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.desc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> thenByPublicId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publicId', Sort.asc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> thenByPublicIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publicId', Sort.desc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> thenBySequence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sequence', Sort.asc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> thenBySequenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sequence', Sort.desc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension IsarLevelQueryWhereDistinct
    on QueryBuilder<IsarLevel, IsarLevel, QDistinct> {
  QueryBuilder<IsarLevel, IsarLevel, QDistinct> distinctByBlockedReason({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'blockedReason',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QDistinct> distinctByContentVersion({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'contentVersion',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QDistinct> distinctByEcosystemId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ecosystemId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QDistinct> distinctByLearningGoal({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'learningGoal', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QDistinct> distinctByMinimumScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'minimumScore');
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QDistinct> distinctByPlantIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'plantIds');
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QDistinct> distinctByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'progress');
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QDistinct> distinctByPublicId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'publicId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QDistinct> distinctByRequiredQuizIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'requiredQuizIds');
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QDistinct> distinctBySequence() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sequence');
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QDistinct> distinctByStatus({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarLevel, IsarLevel, QDistinct> distinctByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }
}

extension IsarLevelQueryProperty
    on QueryBuilder<IsarLevel, IsarLevel, QQueryProperty> {
  QueryBuilder<IsarLevel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarLevel, String?, QQueryOperations> blockedReasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'blockedReason');
    });
  }

  QueryBuilder<IsarLevel, String, QQueryOperations> contentVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contentVersion');
    });
  }

  QueryBuilder<IsarLevel, String, QQueryOperations> ecosystemIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ecosystemId');
    });
  }

  QueryBuilder<IsarLevel, String?, QQueryOperations> learningGoalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'learningGoal');
    });
  }

  QueryBuilder<IsarLevel, double, QQueryOperations> minimumScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'minimumScore');
    });
  }

  QueryBuilder<IsarLevel, List<String>, QQueryOperations> plantIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'plantIds');
    });
  }

  QueryBuilder<IsarLevel, double?, QQueryOperations> progressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'progress');
    });
  }

  QueryBuilder<IsarLevel, String, QQueryOperations> publicIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'publicId');
    });
  }

  QueryBuilder<IsarLevel, List<String>, QQueryOperations>
  requiredQuizIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'requiredQuizIds');
    });
  }

  QueryBuilder<IsarLevel, int, QQueryOperations> sequenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sequence');
    });
  }

  QueryBuilder<IsarLevel, IsarLevelStatus, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<IsarLevel, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }
}
