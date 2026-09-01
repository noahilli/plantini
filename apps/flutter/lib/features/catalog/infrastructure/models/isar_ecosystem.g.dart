// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_ecosystem.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetIsarEcosystemCollection on Isar {
  IsarCollection<int, IsarEcosystem> get isarEcosystems => this.collection();
}

final IsarEcosystemSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'IsarEcosystem',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(name: 'publicId', type: IsarType.string),
      IsarPropertySchema(name: 'slug', type: IsarType.string),
      IsarPropertySchema(name: 'title', type: IsarType.string),
      IsarPropertySchema(name: 'releaseVersion', type: IsarType.string),
      IsarPropertySchema(name: 'levelIds', type: IsarType.stringList),
      IsarPropertySchema(name: 'description', type: IsarType.string),
    ],
    indexes: [
      IsarIndexSchema(
        name: 'publicId',
        properties: ["publicId"],
        unique: true,
        hash: false,
      ),
    ],
  ),
  converter: IsarObjectConverter<int, IsarEcosystem>(
    serialize: serializeIsarEcosystem,
    deserialize: deserializeIsarEcosystem,
    deserializeProperty: deserializeIsarEcosystemProp,
  ),
  getEmbeddedSchemas: () => [],
);

@isarProtected
int serializeIsarEcosystem(IsarWriter writer, IsarEcosystem object) {
  IsarCore.writeString(writer, 1, object.publicId);
  IsarCore.writeString(writer, 2, object.slug);
  IsarCore.writeString(writer, 3, object.title);
  IsarCore.writeString(writer, 4, object.releaseVersion);
  {
    final list = object.levelIds;
    final listWriter = IsarCore.beginList(writer, 5, list.length);
    for (var i = 0; i < list.length; i++) {
      IsarCore.writeString(listWriter, i, list[i]);
    }
    IsarCore.endList(writer, listWriter);
  }
  {
    final value = object.description;
    if (value == null) {
      IsarCore.writeNull(writer, 6);
    } else {
      IsarCore.writeString(writer, 6, value);
    }
  }
  return object.id;
}

@isarProtected
IsarEcosystem deserializeIsarEcosystem(IsarReader reader) {
  final object = IsarEcosystem();
  object.id = IsarCore.readId(reader);
  object.publicId = IsarCore.readString(reader, 1) ?? '';
  object.slug = IsarCore.readString(reader, 2) ?? '';
  object.title = IsarCore.readString(reader, 3) ?? '';
  object.releaseVersion = IsarCore.readString(reader, 4) ?? '';
  {
    final length = IsarCore.readList(reader, 5, IsarCore.readerPtrPtr);
    {
      final reader = IsarCore.readerPtr;
      if (reader.isNull) {
        object.levelIds = const <String>[];
      } else {
        final list = List<String>.filled(length, '', growable: true);
        for (var i = 0; i < length; i++) {
          list[i] = IsarCore.readString(reader, i) ?? '';
        }
        IsarCore.freeReader(reader);
        object.levelIds = list;
      }
    }
  }
  object.description = IsarCore.readString(reader, 6);
  return object;
}

@isarProtected
dynamic deserializeIsarEcosystemProp(IsarReader reader, int property) {
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
      return IsarCore.readString(reader, 4) ?? '';
    case 5:
      {
        final length = IsarCore.readList(reader, 5, IsarCore.readerPtrPtr);
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
    case 6:
      return IsarCore.readString(reader, 6);
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _IsarEcosystemUpdate {
  bool call({
    required int id,
    String? publicId,
    String? slug,
    String? title,
    String? releaseVersion,
    String? description,
  });
}

class _IsarEcosystemUpdateImpl implements _IsarEcosystemUpdate {
  const _IsarEcosystemUpdateImpl(this.collection);

  final IsarCollection<int, IsarEcosystem> collection;

  @override
  bool call({
    required int id,
    Object? publicId = ignore,
    Object? slug = ignore,
    Object? title = ignore,
    Object? releaseVersion = ignore,
    Object? description = ignore,
  }) {
    return collection.updateProperties(
          [id],
          {
            if (publicId != ignore) 1: publicId as String?,
            if (slug != ignore) 2: slug as String?,
            if (title != ignore) 3: title as String?,
            if (releaseVersion != ignore) 4: releaseVersion as String?,
            if (description != ignore) 6: description as String?,
          },
        ) >
        0;
  }
}

sealed class _IsarEcosystemUpdateAll {
  int call({
    required List<int> id,
    String? publicId,
    String? slug,
    String? title,
    String? releaseVersion,
    String? description,
  });
}

class _IsarEcosystemUpdateAllImpl implements _IsarEcosystemUpdateAll {
  const _IsarEcosystemUpdateAllImpl(this.collection);

  final IsarCollection<int, IsarEcosystem> collection;

  @override
  int call({
    required List<int> id,
    Object? publicId = ignore,
    Object? slug = ignore,
    Object? title = ignore,
    Object? releaseVersion = ignore,
    Object? description = ignore,
  }) {
    return collection.updateProperties(id, {
      if (publicId != ignore) 1: publicId as String?,
      if (slug != ignore) 2: slug as String?,
      if (title != ignore) 3: title as String?,
      if (releaseVersion != ignore) 4: releaseVersion as String?,
      if (description != ignore) 6: description as String?,
    });
  }
}

extension IsarEcosystemUpdate on IsarCollection<int, IsarEcosystem> {
  _IsarEcosystemUpdate get update => _IsarEcosystemUpdateImpl(this);

  _IsarEcosystemUpdateAll get updateAll => _IsarEcosystemUpdateAllImpl(this);
}

sealed class _IsarEcosystemQueryUpdate {
  int call({
    String? publicId,
    String? slug,
    String? title,
    String? releaseVersion,
    String? description,
  });
}

class _IsarEcosystemQueryUpdateImpl implements _IsarEcosystemQueryUpdate {
  const _IsarEcosystemQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<IsarEcosystem> query;
  final int? limit;

  @override
  int call({
    Object? publicId = ignore,
    Object? slug = ignore,
    Object? title = ignore,
    Object? releaseVersion = ignore,
    Object? description = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (publicId != ignore) 1: publicId as String?,
      if (slug != ignore) 2: slug as String?,
      if (title != ignore) 3: title as String?,
      if (releaseVersion != ignore) 4: releaseVersion as String?,
      if (description != ignore) 6: description as String?,
    });
  }
}

extension IsarEcosystemQueryUpdate on IsarQuery<IsarEcosystem> {
  _IsarEcosystemQueryUpdate get updateFirst =>
      _IsarEcosystemQueryUpdateImpl(this, limit: 1);

  _IsarEcosystemQueryUpdate get updateAll =>
      _IsarEcosystemQueryUpdateImpl(this);
}

class _IsarEcosystemQueryBuilderUpdateImpl
    implements _IsarEcosystemQueryUpdate {
  const _IsarEcosystemQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<IsarEcosystem, IsarEcosystem, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? publicId = ignore,
    Object? slug = ignore,
    Object? title = ignore,
    Object? releaseVersion = ignore,
    Object? description = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (publicId != ignore) 1: publicId as String?,
        if (slug != ignore) 2: slug as String?,
        if (title != ignore) 3: title as String?,
        if (releaseVersion != ignore) 4: releaseVersion as String?,
        if (description != ignore) 6: description as String?,
      });
    } finally {
      q.close();
    }
  }
}

extension IsarEcosystemQueryBuilderUpdate
    on QueryBuilder<IsarEcosystem, IsarEcosystem, QOperations> {
  _IsarEcosystemQueryUpdate get updateFirst =>
      _IsarEcosystemQueryBuilderUpdateImpl(this, limit: 1);

  _IsarEcosystemQueryUpdate get updateAll =>
      _IsarEcosystemQueryBuilderUpdateImpl(this);
}

extension IsarEcosystemQueryFilter
    on QueryBuilder<IsarEcosystem, IsarEcosystem, QFilterCondition> {
  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition> idEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  idGreaterThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  idGreaterThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition> idLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 0, value: value));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  idLessThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition> idBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 0, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  publicIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 1, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  publicIdGreaterThan(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
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

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  publicIdLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 1, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
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

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  publicIdBetween(String lower, String upper, {bool caseSensitive = true}) {
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

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  publicIdStartsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  publicIdEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  publicIdContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  publicIdMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  publicIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 1, value: ''),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  publicIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 1, value: ''),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition> slugEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 2, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  slugGreaterThan(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  slugGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  slugLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 2, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  slugLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition> slugBetween(
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

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  slugStartsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  slugEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  slugContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition> slugMatches(
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

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  slugIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 2, value: ''),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  slugIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 2, value: ''),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  titleEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 3, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  titleGreaterThan(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
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

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  titleLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 3, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
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

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  titleBetween(String lower, String upper, {bool caseSensitive = true}) {
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

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  titleStartsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  titleEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  titleContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  titleMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 3, value: ''),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 3, value: ''),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  releaseVersionEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 4, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  releaseVersionGreaterThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  releaseVersionGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  releaseVersionLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 4, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  releaseVersionLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  releaseVersionBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 4,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  releaseVersionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  releaseVersionEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  releaseVersionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  releaseVersionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 4,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  releaseVersionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 4, value: ''),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  releaseVersionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 4, value: ''),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  levelIdsElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 5, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  levelIdsElementGreaterThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  levelIdsElementGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  levelIdsElementLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 5, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  levelIdsElementLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  levelIdsElementBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 5,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  levelIdsElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  levelIdsElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  levelIdsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  levelIdsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 5,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  levelIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 5, value: ''),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  levelIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 5, value: ''),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  levelIdsIsEmpty() {
    return not().levelIdsIsNotEmpty();
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  levelIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterOrEqualCondition(property: 5, value: null),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 6));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  descriptionIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 6));
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  descriptionEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 6, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  descriptionGreaterThan(String? value, {bool caseSensitive = true}) {
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

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  descriptionGreaterThanOrEqualTo(String? value, {bool caseSensitive = true}) {
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

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  descriptionLessThan(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 6, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  descriptionLessThanOrEqualTo(String? value, {bool caseSensitive = true}) {
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

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  descriptionBetween(
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

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  descriptionStartsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  descriptionEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  descriptionContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  descriptionMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 6, value: ''),
      );
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterFilterCondition>
  descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 6, value: ''),
      );
    });
  }
}

extension IsarEcosystemQueryObject
    on QueryBuilder<IsarEcosystem, IsarEcosystem, QFilterCondition> {}

extension IsarEcosystemQuerySortBy
    on QueryBuilder<IsarEcosystem, IsarEcosystem, QSortBy> {
  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterSortBy> sortByPublicId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterSortBy> sortByPublicIdDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterSortBy> sortBySlug({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterSortBy> sortBySlugDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterSortBy> sortByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterSortBy> sortByTitleDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterSortBy>
  sortByReleaseVersion({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterSortBy>
  sortByReleaseVersionDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterSortBy> sortByDescription({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterSortBy>
  sortByDescriptionDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }
}

extension IsarEcosystemQuerySortThenBy
    on QueryBuilder<IsarEcosystem, IsarEcosystem, QSortThenBy> {
  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterSortBy> thenByPublicId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterSortBy> thenByPublicIdDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterSortBy> thenBySlug({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterSortBy> thenBySlugDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterSortBy> thenByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterSortBy> thenByTitleDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterSortBy>
  thenByReleaseVersion({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterSortBy>
  thenByReleaseVersionDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterSortBy> thenByDescription({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterSortBy>
  thenByDescriptionDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }
}

extension IsarEcosystemQueryWhereDistinct
    on QueryBuilder<IsarEcosystem, IsarEcosystem, QDistinct> {
  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterDistinct>
  distinctByPublicId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterDistinct> distinctBySlug({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterDistinct> distinctByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterDistinct>
  distinctByReleaseVersion({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterDistinct>
  distinctByLevelIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5);
    });
  }

  QueryBuilder<IsarEcosystem, IsarEcosystem, QAfterDistinct>
  distinctByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6, caseSensitive: caseSensitive);
    });
  }
}

extension IsarEcosystemQueryProperty1
    on QueryBuilder<IsarEcosystem, IsarEcosystem, QProperty> {
  QueryBuilder<IsarEcosystem, int, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<IsarEcosystem, String, QAfterProperty> publicIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<IsarEcosystem, String, QAfterProperty> slugProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<IsarEcosystem, String, QAfterProperty> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<IsarEcosystem, String, QAfterProperty> releaseVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<IsarEcosystem, List<String>, QAfterProperty> levelIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<IsarEcosystem, String?, QAfterProperty> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }
}

extension IsarEcosystemQueryProperty2<R>
    on QueryBuilder<IsarEcosystem, R, QAfterProperty> {
  QueryBuilder<IsarEcosystem, (R, int), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<IsarEcosystem, (R, String), QAfterProperty> publicIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<IsarEcosystem, (R, String), QAfterProperty> slugProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<IsarEcosystem, (R, String), QAfterProperty> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<IsarEcosystem, (R, String), QAfterProperty>
  releaseVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<IsarEcosystem, (R, List<String>), QAfterProperty>
  levelIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<IsarEcosystem, (R, String?), QAfterProperty>
  descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }
}

extension IsarEcosystemQueryProperty3<R1, R2>
    on QueryBuilder<IsarEcosystem, (R1, R2), QAfterProperty> {
  QueryBuilder<IsarEcosystem, (R1, R2, int), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<IsarEcosystem, (R1, R2, String), QOperations>
  publicIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<IsarEcosystem, (R1, R2, String), QOperations> slugProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<IsarEcosystem, (R1, R2, String), QOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<IsarEcosystem, (R1, R2, String), QOperations>
  releaseVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<IsarEcosystem, (R1, R2, List<String>), QOperations>
  levelIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<IsarEcosystem, (R1, R2, String?), QOperations>
  descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }
}
