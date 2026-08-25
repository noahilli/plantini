//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_import

import 'package:one_of_serializer/any_of_serializer.dart';
import 'package:one_of_serializer/one_of_serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:openapi/src/date_serializer.dart';
import 'package:openapi/src/model/date.dart';

import 'package:openapi/src/model/ecosystem.dart';
import 'package:openapi/src/model/level.dart';
import 'package:openapi/src/model/manifest.dart';
import 'package:openapi/src/model/media.dart';
import 'package:openapi/src/model/observation.dart';
import 'package:openapi/src/model/observation_location.dart';
import 'package:openapi/src/model/plant.dart';
import 'package:openapi/src/model/quiz.dart';
import 'package:openapi/src/model/user_profile.dart';

part 'serializers.g.dart';

@SerializersFor([
  Ecosystem,
  Level,
  Manifest,
  Media,
  Observation,
  ObservationLocation,
  Plant,
  Quiz,
  UserProfile,
])
Serializers serializers = (_$serializers.toBuilder()
      ..addBuilderFactory(
        const FullType(BuiltMap, [FullType(String), FullType(String)]),
        () => MapBuilder<String, String>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Plant)]),
        () => ListBuilder<Plant>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Media)]),
        () => ListBuilder<Media>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Observation)]),
        () => ListBuilder<Observation>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Level)]),
        () => ListBuilder<Level>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Ecosystem)]),
        () => ListBuilder<Ecosystem>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(String)]),
        () => ListBuilder<String>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Quiz)]),
        () => ListBuilder<Quiz>(),
      )
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer())
    ).build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
