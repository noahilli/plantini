// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_ecosystem.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarEcosystemCollection on Isar {
  IsarCollection<IsarEcosystem> get isarEcosystems => this.collection();
}

const IsarEcosystemSchema = CollectionSchema(
  name: r'IsarEcosystem',
  id: -6335849797685259107,
  properties: {
    r'description': PropertySchema(
      id: 0,
      name: r'description',
      type: IsarType.string,
    ),
    r'levelIds': PropertySchema(
      id: 1,
      name: r'levelIds',
      type: IsarType.stringList,
    ),
    r'publicId': PropertySchema(
      id: 2,
      name: r'publicId',
      type: IsarType.string,
    ),
    r'releaseVersion': PropertySchema(
      id: 3,
      name: r'releaseVersion',
      type: IsarType.string,
    ),
    r'slug': PropertySchema(
      id: 4,
      name: r'slug',
      type: IsarType.string,
    ),
    r'title': PropertySchema(
      id: 5,
      name: r'title',
      type: IsarType.string,
    )
  },
  estimateSize: _isarEcosystemEstimateSize,
  serialize: _isarEcosystemSerialize,
  deserialize: _isarEcosystemDeserialize,
  deserializeProp: _isarEcosystemDeserializeProp,
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
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _isarEcosystemGetId,
  getLinks: _isarEcosystemGetLinks,
  attach: _isarEcosystemAttach,
  version: '3.1.0+1',
);

int _isarEcosystemEstimateSize(
  IsarEcosystem object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.description;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.levelIds.length * 3;
  {
    for (var i = 0; i < object.levelIds.length; i++) {
      final value = object.levelIds[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.publicId.length * 3;
  bytesCount += 3 + object.releaseVersion.length * 3;
  bytesCount += 3 + object.slug.length * 3;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _isarEcosystemSerialize(
  IsarEcosystem object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.description);
  writer.writeStringList(offsets[1], object.levelIds);
  writer.writeString(offsets[2], object.publicId);
  writer.writeString(offsets[3], object.releaseVersion);
  writer.writeString(offsets[4], object.slug);
  writer.writeString(offsets[5], object.title);
}

IsarEcosystem _isarEcosystemDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarEcosystem();
  object.description = reader.readStringOrNull(offsets[0]);
  object.id = id;
  object.levelIds = reader.readStringList(offsets[1]) ?? [];
  object.publicId = reader.readString(offsets[2]);
  object.releaseVersion = reader.readString(offsets[3]);
  object.slug = reader.readString(offsets[4]);
  object.title = reader.readString(offsets[5]);
  return object;
}

P _isarEcosystemDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringList(offset) ?? []) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarEcosystemGetId(IsarEcosystem object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarEcosystemGetLinks(IsarEcosystem object) {
  return [];
}

void _isarEcosystemAttach(
    IsarCollection<dynamic> col, Id id, IsarEcosystem object) {
  object.id = id;
}

extension IsarEcosystemByIndex on IsarCollection<IsarEcosystem> {
  Future<IsarEcosystem?> getByPublicId(String publicId) {
    return getByIndex(r'publicId', [publicId]);
  }

  IsarEcosystem? getByPublicIdSync(String publicId) {
    return getByIndexSync(r'publicId', [publicId]);
  }

  Future<bool> deleteByPublicId(String publicId) {
    return deleteByIndex(r'publicId', [publicId]);
  }

  bool deleteByPublicIdSync(String publicId) {
    return deleteByIndexSync(r'publicId', [publicId]);
  }

  Future<List<IsarEcosystem?>> getAllByPublicId(List<String> publicIdValues) {
    final values = publicIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'publicId', values);
  }

  List<IsarEcosystem?> getAllByPublicIdSync(List<String> publicIdValues) {
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

  Future<Id> putByPublicId(IsarEcosystem object) {
    return putByIndex(r'publicId', object);
  }

  Id putByPublicIdSync(IsarEcosystem object, {bool saveLinks = true}) {
    return putByIndexSync(r'publicId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPublicId(List<IsarEcosystem> objects) {
    return putAllByIndex(r'publicId', objects);
  }

  List<Id> putAllByPublicIdSync(List<IsarEcosystem> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'publicId', objects, saveLinks: saveLinks);
  }
}

extension IsarEcosystemQueryWhereSort
    on QueryBuilder<IsarEcosystem, IsarEcosystem, QWhere> {
  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IsarEcosystemQueryWhere
    on QueryBuilder<IsarEcosystem, IsarEcosystem, QWhereClause> {
  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterWhereClause> publicIdEqualTo(
      String publicId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'publicId',
        value: [publicId],
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterWhereClause>
      publicIdNotEqualTo(String publicId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'publicId',
              lower: [],
              upper: [publicId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'publicId',
              lower: [publicId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'publicId',
              lower: [publicId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'publicId',
              lower: [],
              upper: [publicId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension IsarEcosystemQueryFilter
    on QueryBuilder<IsarEcosystem, IsarEcosystem, QFilterCondition> {
  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      descriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      descriptionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      descriptionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      descriptionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      descriptionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      levelIdsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'levelIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      levelIdsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'levelIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      levelIdsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'levelIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      levelIdsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'levelIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      levelIdsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'levelIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      levelIdsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'levelIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      levelIdsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'levelIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      levelIdsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'levelIds',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      levelIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'levelIds',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      levelIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'levelIds',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      levelIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'levelIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      levelIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'levelIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      levelIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'levelIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      levelIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'levelIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      levelIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'levelIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      levelIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'levelIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      publicIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'publicId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      publicIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'publicId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      publicIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'publicId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      publicIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'publicId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      publicIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'publicId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      publicIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'publicId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      publicIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'publicId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      publicIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'publicId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      publicIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'publicId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      publicIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'publicId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      releaseVersionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'releaseVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      releaseVersionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'releaseVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      releaseVersionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'releaseVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      releaseVersionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'releaseVersion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      releaseVersionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'releaseVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      releaseVersionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'releaseVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      releaseVersionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'releaseVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      releaseVersionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'releaseVersion',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      releaseVersionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'releaseVersion',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      releaseVersionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'releaseVersion',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition> slugEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'slug',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      slugGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'slug',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      slugLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'slug',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition> slugBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'slug',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      slugStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'slug',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      slugEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'slug',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      slugContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'slug',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition> slugMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'slug',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      slugIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'slug',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      slugIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'slug',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }
}

extension IsarEcosystemQueryObject
    on QueryBuilder<IsarEcosystem, IsarEcosystem, QFilterCondition> {}

extension IsarEcosystemQueryLinks
    on QueryBuilder<IsarEcosystem, IsarEcosystem, QFilterCondition> {}

extension IsarEcosystemQuerySortBy
    on QueryBuilder<IsarEcosystem, IsarEcosystem, QSortBy> {
  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterSortBy> sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterSortBy>
      sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterSortBy> sortByPublicId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publicId', Sort.asc);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterSortBy>
      sortByPublicIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publicId', Sort.desc);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterSortBy>
      sortByReleaseVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'releaseVersion', Sort.asc);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterSortBy>
      sortByReleaseVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'releaseVersion', Sort.desc);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterSortBy> sortBySlug() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'slug', Sort.asc);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterSortBy> sortBySlugDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'slug', Sort.desc);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension IsarEcosystemQuerySortThenBy
    on QueryBuilder<IsarEcosystem, IsarEcosystem, QSortThenBy> {
  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterSortBy> thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterSortBy>
      thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterSortBy> thenByPublicId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publicId', Sort.asc);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterSortBy>
      thenByPublicIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publicId', Sort.desc);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterSortBy>
      thenByReleaseVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'releaseVersion', Sort.asc);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterSortBy>
      thenByReleaseVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'releaseVersion', Sort.desc);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterSortBy> thenBySlug() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'slug', Sort.asc);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterSortBy> thenBySlugDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'slug', Sort.desc);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension IsarEcosystemQueryWhereDistinct
    on QueryBuilder<IsarEcosystem, IsarEcosystem, QDistinct> {
  QueryBuilder<IsarEcosystem, IsarEcosystem, QDistinct> distinctByDescription(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QDistinct> distinctByLevelIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'levelIds');
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QDistinct> distinctByPublicId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'publicId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QDistinct>
      distinctByReleaseVersion({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'releaseVersion',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QDistinct> distinctBySlug(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'slug', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }
}

extension IsarEcosystemQueryProperty
    on QueryBuilder<IsarEcosystem, IsarEcosystem, QQueryProperty> {
  QueryBuilder<IsarEcosystem, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarEcosystem, String?, QQueryOperations> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<IsarEcosystem, List<String>, QQueryOperations>
      levelIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'levelIds');
    });
  }

  QueryBuilder<IsarEcosystem, String, QQueryOperations> publicIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'publicId');
    });
  }

  QueryBuilder<IsarEcosystem, String, QQueryOperations>
      releaseVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'releaseVersion');
    });
  }

  QueryBuilder<IsarEcosystem, String, QQueryOperations> slugProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'slug');
    });
  }

  QueryBuilder<IsarEcosystem, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }
}
